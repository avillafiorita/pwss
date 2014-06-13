require 'yaml'

#
# This module reasons at the entries level
# (list of entry)
#

module Pwss

  WAITING_PERIOD=30 # seconds

  def self.get search_string, entries, interactive
    id = choose_entry search_string, entries

    # it causes confusion ... here id is the absolute id
    # (the one printed by choose_entry is the relative match)
    # puts "Selected entry:\n"
    # print_entry id, entries[id]

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


  def self.update search_string, entries
    id = choose_entry search_string, entries
    password = Cipher::check_password
    entries[id]["password"] = password
    entries
  end
    

  def self.destroy search_string, entries
    id = choose_entry search_string, entries
    entries.delete_at(id) if id != -1
    entries
  end
  

  def self.list entries
    index = 0
    entries.each do |element|
      print_entry index, element
      index += 1
    end
  end

  private

  #
  # Let the user select an entry from data
  # (data is a YAML string with an array of entries)
  #
  def self.choose_entry search_string, entries
    # here we have a nuisance: we want the user to choose one entry
    # by relative id (e.g. the third found), but we need to return
    # the absolute id... so we just keep track of the real ids with an array
    # we ask the user the index of the array

    index = 0
    found = Array.new
    entries.each do |entry|
      if entry["title"].downcase.include?(search_string.downcase)
        print_entry found.size, entry
        found << index
      end
      index += 1
    end

    if found.size == 0 then
      printf "\nNo entry matches the search criteria."
      return -1
    end

    if found.size > 1 then
      printf "\nVarious matches. Select entry by ID (0..#{found.size-1}): "
      id = STDIN.gets.chomp.to_i
    else
      id = 0
    end

    found[id]
  end

  #
  # Print entry
  #
  def self.print_entry id, element
    puts "\n---\nENTRY ID: #{id}"
    # we need to duplicate, because deletion in place will remove
    # passwords from entries (and, frankly, we need them)
    new_el = element.dup
    new_el.delete("password")
    puts new_el.to_yaml
  end
  
end
