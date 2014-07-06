require 'readline'

module Pwss
  #
  # Entry manages an entry in the password safe
  # It is a wrapper to a Hash
  #
  class Entry
    INPUT_F=0
    DEFAULT=1
    PROMPT=2

    # the fields of an entry, together with the function to ask the and default value
    FIELDS = {
      "title"       => ["Readline.readline('title: ')", "'title'"],
      "username"    => ["Readline.readline('username: ')", "''"],
      "password"    => ["Cipher.check_or_generate('password for entry', length, alnum)", "''"],
      "created_at"  => ["", "Date.today"],
      "updated_at"  => ["", "nil"],
      "url"         => ["Readline.readline('url: ')", "''"],
      "description" => ["get_lines",   "''"]
    }

    # the values (a Hash) of this issue
    attr_reader :entry

    def initialize
      @entry = Hash.new
    end

    # interactively ask from command line all fields specified in FIELDS
    # arguments length and alnum are for password generation
    def ask length, alnum
      FIELDS.keys.each do |key|
        @entry[key] = (eval FIELDS[key][INPUT_F]) || (eval FIELDS[key][DEFAULT])
      end
    end
    
    # initialize all fields with the default values
    # (and set title to the argument)
    # def set_fields title
    #   FIELDS.keys.each do |k|
    #     @entry[k] = eval(FIELDS[k][DEFAULT])
    #   end
    #   @entry['title'] = title
    # end

    # read n-lines (terminated by a ".")
    def get_lines
      puts "description (terminate with '.'):"
      lines = []
      line = ""
      until line == "."
        line = Readline.readline
        lines << line
      end
      lines.join("\n")
    end

  end
end
