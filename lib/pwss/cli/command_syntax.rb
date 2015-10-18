require 'slop'
require 'pwss/password'

module Pwss
  module CommandSyntax
    # return a hash with all the commands and their options 
    def self.commands
      h = Hash.new
      self.methods.each do |method|
        if method.to_s.include?("_opts") then
          h = h.merge(eval(method.to_s))
        end
      end
      return h
    end

    # the default number of seconds password is available in the clipboard
    DEFAULT_WAIT = 45
    # the default password length
    DEFAULT_LENGTH = Pwss::Password::DEFAULT_PASSWORD_LENGTH

    private

    def self.version_opts
      opts = Slop::Options.new
      opts.banner = "version -- print version information"
      return { :version => [opts, :version] }
    end

    def self.init_opts
      opts = Slop::Options.new
      opts.banner = "init [options] -- init a new password file"
      opts.string "-f", "--filename", "Password file to create. Use '.enc' or '.gpg' for encryption"
      return { :init => [opts, :init] }
    end
    
    def self.list_opts
      opts = Slop::Options.new
      opts.banner = "list [options] -- list all entries in a file"
      opts.string "-f", "--filename", "Password file to use"
      opts.bool   "-c", "--clean", "Clean timestamps from entries"
      return { :list => [opts, :list] }
    end

    def self.get_opts
      opts = Slop::Options.new
      opts.banner = "get [options] -- get a stored field of a record (it defaults to password)"

      opts.string "-f", "--filename", "Password file to use"
      opts.bool "--stdout", "Output the password to standard output"
      opts.bool "-h", "--hide", "Hide sensitive fields"
      opts.integer "-w", "--wait", "Number of seconds the field is available in the clipboard (0 = wait for user input)", default: DEFAULT_WAIT
      opts.string "--field", "Field to make available on stdout or clipboard (password by default)"
      return { :get => [opts, :get] }
    end

    def self.add_and_new_opts
      opts = Slop::Options.new
      opts.banner = "add|new [options] [entry title] -- add an entry and copy its password in the clipboard"
      opts.string "-f", "--filename", "Password file to use"
      opts.integer "-w", "--wait", "Seconds password is available in the clipboard (0 = interactive)", default: DEFAULT_WAIT
      opts.string "-t", "--type", "Create an entry of type TYPE (Entry, CreditCard, BankAccount, SoftwareLicense, Sim).\n                        Default to 'Entry', which is good enough for websites credentials"
      opts.string "-m", "--method", "Method to generate the password (one of: random, alpha, ask; default to random)"
      opts.bool "--ask", "A shortcut for --method ask"
      opts.integer "-l", "--length", "Password length (when random or alpha; default #{DEFAULT_LENGTH})", default: DEFAULT_LENGTH
      return { :add => [opts, :add_entry],
               :new => [opts, :add_entry] }
    end

    def self.update_opts
      opts = Slop::Options.new
      opts.banner = "update [options] string -- Update specified field of (user selected) entry matching <string>"
      opts.string "-f", "--filename", "Password file to use"
      opts.string "--field", "Field to update"
      opts.bool "-p", "--password", "an alias for --field password"
      opts.string "-m", "--method", "Method to generate the password (one of: random, alpha, ask; default to random)"
      opts.bool "--ask", "A shortcut for [--field password] --method ask"
      opts.integer "-l", "--length", "Password length (when random or alpha; default #{DEFAULT_LENGTH})", default: DEFAULT_LENGTH
      opts.integer "-w", "--wait", "Seconds new field is available in the clipboard for (0 = interactive)", default: DEFAULT_WAIT
      return { :update => [opts, :update] }
    end

    def self.destroy_opts
      opts = Slop::Options.new
      opts.banner = "destroy|rm [options] string -- Destroy a user-selected entry matching <string>, after user confirmation"
      opts.string "-f", "--filename", "Password file to create. Use extension '.enc' to encrypt it"
      return { :destroy => [opts, :destroy],
               :rm => [opts, :destroy] }
    end

    def self.encrypt_opts
      opts = Slop::Options.new
      opts.banner = "encrypt [options] -- Encrypt a password file"
      opts.bool "--symmetric", "Use symmetric encryption"
      opts.bool "--gpg", "Use gpg (default: no need to specify it)"
      opts.string "-f", "--filename", "Password file to encrypt. Write to <file>.[enc,gpg]"
      return { :encrypt => [opts, :encrypt] }
    end

    def self.decrypt_opts
      opts = Slop::Options.new
      opts.banner = "decrypt [options] -- Decrypt a password file"
      opts.string "-f", "--filename", "Password file to encrypt. Write to <file>.enc"
      return { :decrypt => [opts, :decrypt] }
    end

    def self.console_opts
      opts = Slop::Options.new
      opts.banner = "console [options] -- Enter the console"
      opts.string "-f", "--filename", "Password file to encrypt. Write to <file>.enc"
      return { :console => [opts, :console] } 
    end

    def self.man_opts
      opts = Slop::Options.new
      opts.banner = "man -- print a manual page"
      return { :man => [opts, :man] }
    end

    def self.help_opts
      opts = Slop::Options.new
      opts.banner = "help [command] -- print usage string"
      return { :help => [opts, :help] }
    end

    def self.describe_opts
      opts = Slop::Options.new
      opts.banner = "describe [options] -- describe fields of an entry type or all types"
      opts.string "-t", "--type", "Type to describe"
      return { :describe => [opts, :describe] }
    end
    
    #
    # COMMANDS WHICH MAKE SENSE ONLY WITH THE CONSOLE
    #

    # change the default file
    def self.open_opts
      opts = Slop::Options.new
      opts.banner = "open [options] -- change the default file used in the console"
      opts.banner = "                  (makes sense only when launched from the console) "
      opts.string "-f", "--filename", "Password file to use"
      return { :open => [opts, :open] }
    end

    # which is the default file?
    def self.default_opts
      opts = Slop::Options.new
      opts.banner = "default -- which file is the console currently operating on?"
      opts.banner = "           (makes sense only when launched from the console) "
      return { :default => [opts, :default] }
    end
    
    
  end
end
