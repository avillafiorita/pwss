module Pwss
  #
  # Entry generates an entry for the password safe
  # It is a wrapper to a Hash
  #
  class Entry
    attr_reader :entry
    attr_reader :fields
    
    def initialize
      @entry  = Hash.new
      @fields = [
        "title",
        "url",
        "username",
        "password",
        "recovery_email",
        "description"
      ]
    end

    # interactively ask the fields specified in +@fields+
    #
    # optional hash +arguments+ allows to pass arguments to the
    # input-asking functions (including the default value for a key)
    # See the documentation of Pwss::Fields::ask for more details.
    #
    def ask arguments = {}
      @entry = Hash.new
      @fields.each do |key|
        @entry[key] = Fields.ask key, arguments
      end
    end

  end
end
