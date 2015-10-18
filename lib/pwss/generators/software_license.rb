require 'pwss/generators/entry'

module Pwss
  class SoftwareLicense < Entry
    def initialize
      super
      @fields = [
        "title",
        "version",
        "licensed_to",
        "license_number",
        "email",
        "purchased_on",
        "url",
        "description"
      ]
    end
  end
end
