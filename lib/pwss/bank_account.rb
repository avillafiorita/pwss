require 'pwss/entry'

module Pwss
  class BankAccount < Entry
    def initialize
      super
      @fields = {
        "title"       => ["Readline.readline('title: ')", "'title'"],
        "name"        => ["Readline.readline('name: ')", "'name'"],
        "iban"        => ["Readline.readline('iban: ')", "ITkk xaaa aabb bbbc cccc cccc ccc"],
        "created_at"  => ["", "Date.today"],
        "updated_at"  => ["", "nil"],
        "url"         => ["Readline.readline('url: ')", "''"],
        "description" => ["get_lines",   "''"]
      }
    end
  end
end
