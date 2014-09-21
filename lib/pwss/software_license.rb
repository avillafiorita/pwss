require 'pwss/entry'

module Pwss
  class SoftwareLicense < Entry
    def initialize
      super
      @fields = {
        "title"          => ["Readline.readline('title: ')", "'title'"],
        "version"        => ["Readline.readline('version: ')", "0.0.1"],
        "license_number" => ["Readline.readline('license number: ')", "000-0000-0000-0000"],
        "licensed_to"    => ["Readline.readline('licensed to: ')", "'John Doe'"],
        "email"          => ["Readline.readline('email: ')", "jdoe@example.com"],
        "purchased_on"   => ["Readline.readline('purchased on: ')", "'Date.today'"],
        "created_at"     => ["", "Date.today"],
        "updated_at"     => ["", "nil"],
        "url"            => ["Readline.readline('url: ')", "''"],
        "notes"          => ["get_lines",   "''"]
      }
    end
  end
end
