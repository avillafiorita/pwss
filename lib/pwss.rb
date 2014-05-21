require 'yaml'

module Pwss

  WAITING_PERIOD=30 # seconds

  def self.get account, data, interactive
    found = Array.new
    passwords = Array.new

    entries = YAML::load(data)
    entries.each do |element|
      if element["title"].downcase.include?(account.downcase)
        found << element
        passwords << element["password"]

        # to stdout, removing password
        puts "\n---\nENTRY ID: #{found.size - 1}"
        element.delete("password")
        puts element.to_yaml
      end
    end

    if found.size == 0 then
      printf "No entry matches the search criteria. Exiting.\n"
      return
    end

    if found.size > 1 then
      printf "\nVarious matches. Select entry by ID (0..#{found.size - 1}): "
      id = STDIN.gets.chomp
      id = id.to_i
    else
      id = 0
    end

    system("echo #{passwords[id]} | pbcopy")

    if interactive
      puts "\nPassword available in clipboard: press any key when you are done."
      STDIN.getc
    else
      puts "\nPassword available in clipboard for #{WAITING_PERIOD} seconds."
      sleep(WAITING_PERIOD)
    end

    system("echo ahahahahaha | pbcopy")

  end

  def self.list string
    entries = YAML::load(string)
    entries.each do |element|
      # to stdout, removing password
      element.delete("password")
      puts element.to_yaml
    end
  end
end
