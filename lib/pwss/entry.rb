module Pwss
  class Entry
    INPUT_F=0
    DEFAULT=1
    PROMPT=2

    FIELDS = {
      "title"       => ["gets.chomp", "'title'", "title: "], 
      "username"    => ["gets.chomp", "''", "username: "],
      "password"    => ["Cipher.check_password('password for entry: ')", "''", ""],
      "added"       => ["", "Date.today.to_s", ""],
      "url"         => ["gets.chomp", "''", "url: "],
      "description" => ["get_lines",   "''", "description (terminate with '.'):\n"]
    }

    # the values (a Hash) of this issue
    attr_reader :entry

    def initialize
      @entry = Hash.new
    end

    # interactively ask from command line all fields specified in FIELDS
    def ask
      FIELDS.keys.each do |key|
        printf "#{FIELDS[key][PROMPT]}" if FIELDS[key][PROMPT] != ""
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
      $/ = "\n.\n"  
      STDIN.gets.chomp("\n.\n")
    end

  end
end
