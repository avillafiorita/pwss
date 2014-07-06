require 'yaml'

#
# This module reasons at the entries level
# (list of entry)
#

module Pwss

  def self.get search_string, entries
    id = choose_entry search_string, entries

    entries[id]["password"]
  end


  def self.update search_string, entries, length, alnum
    id = choose_entry search_string, entries

    password = Cipher.check_or_generate "new password for entry", length, alnum

    entries[id]["password"] = password
    entries[id]["updated_at"] = Date.today

    return entries, password
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
      printf "No entry matches the search criteria.\n"
      exit -1
    end

    if found.size > 1 then
      printf "\nVarious matches.\nSelect entry by ID (0..#{found.size-1}) or -1 to exit: "
      id = STDIN.gets.chomp.to_i
      while (id < -1 or id >= found.size)
        printf "Select entry by ID (0..#{found.size-1}) or -1 to exit: "
        id = STDIN.gets.chomp.to_i
      end
      if id == -1 then
        exit -1
      end
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
