require 'pwss/generators/entry'

module Pwss
  class CreditCard < Entry
    def initialize
      super
      @fields = [
        "title",
        "issuer",
        "name_on_card",
        "card_number",
        "valid_from",
        "valid_till",
        "verification_number",
        "pin",
        "url",
        "username",
        "password",
        "description"
      ]
    end
  end
end
