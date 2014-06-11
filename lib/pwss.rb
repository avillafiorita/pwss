require 'yaml'

#
# This module reasons at the entries level
# (list of entry)
#

module Pwss

  WAITING_PERIOD=30 # seconds

  def self.get search_string, entries, interactive
    id = choose_entry search_string, entries

    puts "Selected entry:\n"
    print_entry id, entries[id]

    #
    # make the password available and then forget it
    #
    password = entries[id]["password"]
    system("echo #{password} | pbcopy")

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
