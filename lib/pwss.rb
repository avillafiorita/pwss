require 'yaml'

#
# This module reasons at the entries level
# (list of entry)
#

module Pwss

  # entry_no is the relative id of an entry, specified by the user from the command line
  # (useful when the search criteria returns more than one match, in an order which is known
  # to the user)
  def self.get search_string, entries, entry_no = nil
    id = choose_entry search_string, entries, false, entry_no

    entries[id]["password"]
  end


  def self.update search_string, entries, length, alnum
    id = choose_entry search_string, entries, true

    password = Cipher.check_or_generate "new password for entry", length, alnum

    entries[id]["password"] = password
    entries[id]["updated_at"] = Date.today

    return entries, password
  end
    
  def self.update_field search_string, entries, field
    id = choose_entry search_string, entries, true

    field_value = Readline.readline("\nEnter new value for #{field}: ")
    
    entries[id][field] = field_value
    entries[id]["updated_at"] = Date.today
    password = entries[id]["password"]
    
    return entries, password
  end


  def self.destroy search_string, entries
    id = choose_entry search_string, entries, true

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
  def self.choose_entry search_string, entries, confirm_even_if_one = false, entry_no = nil
    # here we have a nuisance: we want the user to choose one entry
    # by relative id (e.g. the third found), but we need to return
    # the absolute id (to update the right entry in the safe)
    #
    # ... so we just keep track of the real ids with an array
    #     the relative id is the index in the array

    found = Array.new
    entries.each_with_index do |entry, index|
      if entry["title"].downcase.include?(search_string.downcase)
        found << index
      end
    end

    if found.size == 0 then
      printf "No entry matches the search criteria.\n"
      exit -1
    end

    if entry_no then
      # accept entry_no even if there is one entry
      id = entry_no
    elsif found.size > 1 or confirm_even_if_one then
      # print the entry or the entries found together with their relative ids
      found.each_with_index do |absolute_index, relative_index|
        print_entry relative_index, entries[absolute_index]
      end

      printf "\nVarious matches." if found.size > 1
      
      printf "\nSelect entry by ID (0..#{found.size-1}); -1 or empty string to exit: "
      response = Readline.readline
      id = response == "" ? -1 : response.to_i
      while (id < -1 or id >= found.size)
        printf "Select entry by ID (0..#{found.size-1}); -1 or empty string to exit: "
        response = Readline.readline
        id = response == "" ? -1 : response.to_i
      end
      if id == -1 then
        exit -1
      end
    else
      id = 0
      print_entry 0, entries[found[id]]
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
