require 'pwss/generators/entry'

module Pwss
  class BankAccount < Entry
    def initialize
      super
      @fields = [
        "title",
        "name",
        "iban",
        "url",
        "username",
        "password",
        "description"
      ]
    end
  end
end
