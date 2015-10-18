require 'pwss/generators/entry'

module Pwss
  class Code < Entry
    def initialize
      super
      @fields = [
        "title",
        "code",
      ]
    end
  end
end
