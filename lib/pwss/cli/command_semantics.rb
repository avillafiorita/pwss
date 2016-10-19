require 'pwss/version'

module Pwss
  # what we are supposed to do with each command
  module CommandSemantics
    VERSION = Pwss::VERSION
    # TODO: make the list of entries read from code 
    MAN = <<EOS
NAME
  pwss -- A command-line password manager

SYNOPSYS
  pwss command [options] [args]

DESCRIPTION
  PWSS is a password manager, in the spirit of pass and pws.

  Features:

  * PWSS manages password *files*:
    - A password file can store different entries (password and other
      sensitive information)
    - The user can manage different password files (e.g., work, personal)

  * Entries in a password file can be of different types.  Each type stores
    different information.  Use the 'describe' command for more info about 
    the available types and their fields.

  * Password files can be encrypted

  * Encrypted password files can be decrypted, for instance, to batch process
    entries, to migrate to another tool, or to manually edit entries

  * Entries are human-readable (and editable), when the password file is not
    encrypted

  * A console allows to decrypt a file once and perform multiple queries

EXAMPLES
  pwss help                             # get syntax of each command

  # scenario
  pwss init -f a.enc                    # generate an encrypted safe a.enc
  pwss add -f a.enc                     # add an entry (pwss will generate a random 16-char password)
  pwss get -f a.enc my secret account   # find an entry
  pwss console -f a.enc                 # decrypt a.enc and enter the pwss console to operate on a.enc

VERSION
  This is version #{VERSION}

LICENSE
  MIT

SEE ALSO
  pwss man
  pwss help
  https://github.com/avillafiorita/pwss
EOS

    # the default filename
    # YOU SHOULDN'T BE USING THESE CONTANSTS. USE `default_filename` INSTEAD
    DEFAULT_BASENAME = File.join(Dir.home, ".pwss.yaml")
    DEFAULT_FILENAME = DEFAULT_BASENAME + ".gpg"

    # return the default filename
    # 
    # this is obtained by looking for plain text or encryped versions
    # of the DEFAULT_BASENAME, with the following priority: .enc,
    # .gpg, plain text.
    #
    # If no file is found (like it might be the case when running the
    # init command), use GPG
    def self.default_filename
      [".enc", ".gpg", ""].each do |ext|
        filename = DEFAULT_BASENAME + ext
        return filename if File.exist?(filename)
      end
      return DEFAULT_FILENAME
    end

    # return true if the default basename appears with different
    # extensions.
    #
    # for instance: if the DEFAULT_BASENAME appears both with .gpg and .enc
    # (or plain and encrypted).
    #
    # This is potentially a problem, since all operations are
    # performed on a different file from the one the user believes it
    # is operating on.
    def self.ambiguous_default
      [".enc", ".gpg", ""].map { |ext| File.exist?(DEFAULT_BASENAME + ext) }.count(true) > 1
    end
    
    # return true if none of the default files exist
    def self.no_default
      [".enc", ".gpg", ""].map { |ext| File.exist?(DEFAULT_BASENAME + ext) }.count(true) == 0
    end

    # return all the default safes we look for
    def self.all_safes
      [".enc", ".gpg", ""].map { |ext| DEFAULT_BASENAME + ext }
    end

    # return the existing safes
    def self.existing_safes
      [".enc", ".gpg", ""].map { |ext| DEFAULT_BASENAME + ext }.select { |x| File.exist?(x) }
    end      

    # cache is the content of the file last operated on
    # is it used 
    @@cache = nil
    
    def self.version opts = nil, argv = []
      puts "pwss version #{VERSION}"
    end

    def self.man opts = nil, argv = []
      puts MAN
    end

    def self.help opts = nil, argv = []
      all_commands = Pwss::CommandSyntax.commands
      
      if argv != []
        argv.map { |x| puts all_commands[x.to_sym][0] }
      else
        puts "pwss command [options] [args]"
        puts ""
        puts "Available commands:"
        puts ""
        all_commands.keys.each do |key|
          puts "  " + all_commands[key][0].banner
        end
      end
    end

    def self.describe  opts = nil, argv = []
      if opts[:type]
        types = [("Pwss::" + opts[:type].capitalize).to_sym]
      else
        types = [Pwss::Entry] + ObjectSpace.each_object(Class).select { |klass| klass < Pwss::Entry }
      end
      types.each do |type|
        t = eval("#{type}.new")
        puts "#{type.to_s.gsub("Pwss::", "").downcase}:\n  #{t.fields.join(", ")}\n\n"
      end
    end
    
    def self.init opts, argv = []
      filename = opts[:filename] || @@cache.filename || DEFAULT_FILENAME

      if File.exist?(filename)
        raise "Error: file #{filename} already exists."
      end

      safe = Pwss::Safe.new filename
      safe.save
      
      puts "New safe created in #{filename}"
    end

    def self.list opts, argv = []
      safe = use_safe opts[:filename]
      clean = opts[:clean]

      cleaned_entries = safe.prune(["created_at", "updated_at"]).map { |x| Pwss::Fields.to_clean_hash x }
      puts cleaned_entries.to_yaml
    end
    
    def self.get opts, argv
      waiting = opts[:wait]
      stdout_opt = opts[:stdout]
      field_name = opts[:field] || "password"

      show = opts[:show]
      string = argv.join(" ")
      safe = use_safe opts[:filename]
      entries_with_idx = safe.match string
      id = Pwss::Safe.choose_entry entries_with_idx
      if id != -1 then
        puts (show ? safe.get(id).to_yaml : safe.get_pruned(id).to_yaml )
        field_value = safe.get_field id, field_name
        if field_value then
          stdout_opt ? printf("%s", field_value) : Pwss::Password.to_clipboard(field_name, field_value, waiting)
        end
      end
    end

    def self.add_entry opts, argv
      waiting  = opts[:wait]
      type     = opts[:type] || "entry"
      strategy = opts[:ask] ? "ask" : (opts[:method] || "random")
      length   = opts[:length]

      safe = use_safe opts[:filename]

      # the title can be specified in the argument
      arguments = Hash.new
      arguments["title"] = argv.join(" ") if argv != []
      arguments[:strategy] = strategy
      arguments[:length] = length

      new_entry = eval("Pwss::" + type.capitalize).new
      new_entry.ask arguments

      puts "Adding entry '#{new_entry.entry["title"]}' of type '#{type}' to #{safe.filename}"
      safe.add new_entry.entry
      safe.save
      puts "Entry added"
      
      # make password available in the clipboard, if there is a password to make available
      if new_entry.entry["password"] 
        Pwss::Password.to_clipboard "password", new_entry.entry["password"], waiting
      end
    end

    def self.update opts, argv
      field    = (opts.to_hash[:password] or opts.to_hash[:method] or opts.to_hash[:ask]) ? "password" : opts.to_hash[:field]
      strategy = opts.to_hash[:ask] ? "ask" : (opts.to_hash[:method] || "random")
      length   = opts.to_hash[:length]
      waiting  = opts.to_hash[:wait]
      string   = argv.join(" ") # the entry we are looking for

      if not field then
        raise "Error: please specify a field to update (use --field, -p, or --ask)"
      end

      safe = use_safe opts[:filename]

      entries_with_idx = safe.match string
      id = Pwss::Safe.choose_entry entries_with_idx, true
      if id != -1 then
        field_value = Pwss::Fields.ask field, { strategy: strategy, length: length }
        puts "Updating #{field} field of '#{safe.entries[id]["title"]}' in #{safe.filename}"
        puts "The old value of #{field} is: #{safe.get_field id, field}"
        safe.update id, field, field_value
        safe.save
        puts "Entry updated"
        
        # make the field available in the clipboard, just in case it is needed
        if field == "password"
          Pwss::Password.to_clipboard "password", field_value, waiting
        end
      end
    end
    
    def self.destroy opts, argv
      safe = use_safe opts[:filename]

      string = argv.join(" ")
      entries_with_idx = safe.match string
      id = Pwss::Safe.choose_entry entries_with_idx, true    
      if id != -1 then
        safe.destroy id
        safe.save
      end
    end

    def self.encrypt opts, argv = []
      # filename: use the one passed from the cli or the cached one or .pwss.yaml DEFAULT_*BASE*NAME
      filename = opts[:filename] || (@@cache ? @@cache.filename : DEFAULT_BASENAME)
      encryption = opts[:symmetric] ? :enc : :gpg

      if not File.exist?(filename)
        raise "Error: file #{filename} does not exist."
      end

      if Pwss::FileOps.encrypted? filename
        raise "Error: #{filename} ends with '.gpg' or '.enc' (and I assume these files to be encrypted)"
      end

      if encryption == :enc then
        password = Pwss::Password.ask_password_twice
        if password == "" then
          raise "Error: Please specify a non-empty password."
        end  
      else
        password = nil # it will be asked by GPG
      end
      
      safe = use_safe filename
      safe.toggle_encryption :password => password, :schema => encryption
      safe.save
      puts "An encrypted copy now lives in #{safe.filename}"
      puts "You might want to check everything is ok and delete the plain file: #{filename}"
      puts "If you do nothing, the next pwss command will run on #{default_filename}"
    end

    def self.decrypt opts, argv = []
      # filename: passed from options, cached one or, in order, .gpg, .enc, plain (but plain will fail)
      filename = opts[:filename] || (@@cache ? @@cache.filename : default_filename)

      if not File.exist?(filename)
        raise "Error: file #{filename} does not exist."
      end

      if not Pwss::FileOps.encrypted? filename
        raise "Error: #{filename} does not end with '.gpg' or '.enc' (and I assume it to be in plain text)"
      end

      safe = use_safe filename
      safe.toggle_encryption
      safe.save
      puts "A plain text copy now lives in #{safe.filename}"
      puts "You might want to check everything is ok and delete the plain file: #{filename}"
      puts "If you do nothing, the next pwss command will run on #{default_filename}"
    end

    def self.console opts, argv = []
      all_commands = Pwss::CommandSyntax.commands
      all_commands.delete(:console)
      open opts, argv # open and cache the file
      
      i = 0
      while true
        string = Readline.readline('pwss:%03d> ' % i, true)
        string.gsub!(/^pwss /, "") # as a courtesy, remove any leading pwss string
        if string == "exit" or string == "quit" or string == "." then
          exit 0
        end
        reps all_commands, string.split(' ')
        i = i + 1
      end
    end

    def self.open opts, argv = []
      filename = opts[:filename] || default_filename
      @@cache = load_safe filename
      puts "Loaded #{filename}"
    end

    def self.default opts, argv = []
      if @@cache
        @@cache.filename
      elsif self.no_default
        puts "No default password file found."
        puts "Use -f if you have a password file stored somewhere else."
        puts "pwss init will create #{default_filename}."
      elsif self.ambiguous_default
        puts "Operating on #{default_filename}."
        puts "Warning: #{existing_safes.join(", ")} exist."
      else
        puts "Operating on #{default_filename}"
      end
    end
    
    # read-eval-print step
    def self.reps all_commands, argv
      if argv == []
        Pwss::CommandSemantics.help
        exit 0
      else
        command = argv[0]
        syntax_and_semantics = all_commands[command.to_sym]

        if syntax_and_semantics
          opts = syntax_and_semantics[0]
          function = syntax_and_semantics[1]
          
          begin
            parser = Slop::Parser.new(opts)
            result = parser.parse(argv[1..-1])
            options = result.to_hash
            arguments = result.arguments

            eval "Pwss::CommandSemantics::#{function}(options, arguments)"
          rescue Slop::Error => e
            puts "pwss: #{e}"
          rescue Exception => e
            puts e
          end
        else
          puts "pwss: '#{command}' is not a pwss command. See 'pwss help'"
        end
      end
    end

    private

    # use a specific filename (if specified), try @@cache if -f is not specified, or the default filename
    def self.use_safe filename
      if filename then
        load_safe filename
      elsif @@cache then
        @@cache
      else
        load_safe default_filename
      end
    end

    # load a password safe
    def self.load_safe filename
      if File.exist?(filename)
        safe = Pwss::Safe.new filename
        safe.load
        safe
      else
        raise "Error: file #{filename} does not exist."
      end
    end

  end
end
