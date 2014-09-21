require 'pwss/entry'

module Pwss
  class CreditCard < Entry
    def initialize
      super
      @fields = {
        "title"        => ["Readline.readline('title: ')", "'title'"],
        "issuer"       => ["Readline.readline('issuer: ')", "MasterCard"],
        "name_on_card" => ["Readline.readline('name on card: ')", "'john doe'"],
        "card_number"  => ["Readline.readline('number: ')", "000-0000-0000-0000"],
        "valid_from"   => ["Readline.readline('valid from: ')", "Sep 2014"],
        "valid_till"   => ["Readline.readline('valid till: ')", "Sep 2018"],
        "verification_number" => ["Readline.readline('verification number: ')", "000"],
        "pin"          => ["Readline.readline('pin: ')", "0000"],
        "created_at"   => ["", "Date.today"],
        "updated_at"   => ["", "nil"],
        "url"          => ["Readline.readline('url: ')", "''"],
        "notes"        => ["get_lines",   "''"]
      }
    end
  end
end
