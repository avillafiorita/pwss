require 'readline'
require 'pwss/cipher'
require 'date'

module Pwss
  #
  # Entry manages an entry in the password safe
  # It is a wrapper to a Hash
  #
  class Entry
    INPUT_F = 0 
    DEFAULT = 1

    attr_reader :entry, :fields

    def initialize
      @entry = Hash.new

      # the fields of an entry, together with:
      # - the function to ask the 
      # - the default value
      @fields = {
        "title"       => ["Readline.readline('title: ')", "'title'"],
        "username"    => ["Readline.readline('username: ')", "''"],
        "password"    => ["Cipher.check_or_generate('password for entry', length, alnum)", "''"],
        "created_at"  => ["", "Date.today"],
        "updated_at"  => ["", "nil"],
        "url"         => ["Readline.readline('url: ')", "''"],
        "description" => ["get_lines",   "''"]
      }
    end

    # interactively ask from command line all fields specified in FIELDS
    # arguments length and alnum are for password generation
    def ask length = 8, alnum = true
      @fields.keys.each do |key|
        @entry[key] = (eval @fields[key][INPUT_F]) || (eval @fields[key][DEFAULT])
      end
    end
    
    # initialize all fields with the default values
    # (and set title to the argument)
    # def set_fields title
    #   fields.keys.each do |k|
    #     @entry[k] = eval(fields[k][DEFAULT])
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
