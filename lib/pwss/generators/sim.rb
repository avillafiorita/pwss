require 'pwss/generators/entry'

module Pwss
  class Sim < Entry
    def initialize
      super
      @fields = [
        "title",
        "phone",
        "pin",
        "puk"
      ]
    end
  end
end
