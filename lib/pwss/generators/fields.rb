require 'readline'
require 'date'

require 'pwss/password'

module Pwss
  module Fields
    INPUT_F = 0 
    DEFAULT = 1
    HIDDEN = 2

    # this is a set of fields useful for different types of entries
    # each entry will reference the symbols it needs to make sense
    FIELDS = {
      # everyone has...
      "title"       => ["Readline.readline('title: ')", "''", false],
      "url"         => ["Readline.readline('url: ')", "''", false],
      "username"    => ["Readline.readline('username: ')", "''", false],
      "recovery_email" => ["Readline.readline('email: ')", "''", false],
      "password"    => ["Pwss::Password.password(arguments)", "Pwss::Password.password", true],
      "description" => ["get_lines", "''", false],

      # banks also have ...
      "name"        => ["Readline.readline('name: ')", "''", false],
      "iban"        => ["Readline.readline('iban: ')", "ITkk xaaa aabb bbbc cccc cccc ccc", false],

      # cards also have
      "issuer"       => ["Readline.readline('issuer: ')", "''", false],
      "name_on_card" => ["Readline.readline('name on card: ')", "''", false],
      "card_number"  => ["Readline.readline('number: ')", "''", true],
      "valid_from"   => ["Readline.readline('valid from: ')", "''", false],
      "valid_till"   => ["Readline.readline('valid till: ')", "''", false],
      "verification_number" => ["Readline.readline('verification number: ')", "''", true],
      "pin"          => ["Readline.readline('pin: ')", "''", true],

      # SIMs also have
      "puk"         => ["Readline.readline('puk: ')", "XXXX", true],
      "phone"       => ["Readline.readline('phone: ')", "NNN NNN NNNN", false],

      # Code has only title and code
      "code"         => ["Readline.readline('code: ')", "XXXX", true],
      
      # useful for software licenses
      "version"        => ["Readline.readline('version: ')", "''", false],
      "licensed_to"    => ["Readline.readline('licensed to: ')", "''", false],
      "license_number" => ["Readline.readline('license number: ')", "''", true],
      "purchased_on"   => ["Readline.readline('purchased on: ')", "Date.today", false],
    }

    # ask the value for +key+
    #
    # This is performed by invoking the function defined for +key+ in the
    # +FIELDS+, which typically asks for user input.  If the user enters a
    # value this is the one the function returns, otherwise we return the
    # default value defined for +key+ in +FIELDS+.
    #
    # Optional hash +arguments+ contains a list of arguments to be passed to
    # the function in +FIELDS+.  This allows to customize the behaviour of the
    # user-input function.
    #
    # **As a special case, if +arguments+ contains +key+, this is returned as
    # the value.  This allows to set the default for a +key+ outside this
    # module.**
    #
    # Thus, for instance: ask 'username', {'username' => 'a'} will return 'a'.
    #
    def self.ask key, arguments
      # if the default is specified outside this class, return it!
      return arguments[key] if arguments[key]

      # ... otherwise, do some work and ask for the value!
      input_f = FIELDS[key] ? FIELDS[key][INPUT_F] : "Readline.readline('#{key}: ')"
      default = FIELDS[key] ? FIELDS[key][DEFAULT] : nil
      value = eval input_f
      if value != nil and value != "" then
        value
      else
        default
      end
    end

    # read n-lines (terminated by a ".")
    def self.get_lines
      puts "description (terminate with '.'):"
      lines = []
      line = ""
      until line == "."
        line = Readline.readline
        lines << line if line != "."
      end
      lines.join("\n")
    end

    # take a hash as input and reorder the fields according to the order in
    # which the fields are defined in the +FIELDS+ variable
    #
    # this function is used to present records in the YAML file always in the
    # same order.
    def self.to_clean_hash hash
      output = Hash.new
      FIELDS.keys.each do |field|
        output[field] = hash[field] if hash[field]
      end
      # all the remaining fields (i.e., user-defined fields in records)
      (hash.keys - FIELDS.keys).each do |field|
        output[field] = hash[field]
      end
      output
    end

    def self.sensitive? field
      FIELDS[field][HIDDEN]
    end

    def self.sensitive
      FIELDS.select { |x| FIELDS[x][HIDDEN] }.keys
    end
  end
end
