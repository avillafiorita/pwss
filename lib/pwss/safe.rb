require 'yaml'

#
# A password safe is a list of entries
#

module Pwss
  class Safe
    attr_reader :filename, :entries, :password
    
    def initialize filename
      @filename = filename
      @password = nil
      @entries = Array.new
    end

    def rename new_filename
      @filename = new_filename
    end
    
    def load
      string = FileOps::load @filename
      if FileOps::symmetric? filename then
        @password = Password::ask_password
        string = Cipher::decrypt string, password
      elsif FileOps::gpg? filename then
        crypto = GPGME::Crypto.new
        cipher = crypto.decrypt string
        string = cipher.to_s
      end
      @entries = YAML::load(string) || Array.new
    end

    
    def save
      if FileOps::symmetric? filename then
        if not @password
          @password = Password::ask_password_twice
        end
        new_string = Cipher::encrypt @entries.to_yaml, @password
      elsif FileOps::gpg? filename then
        crypto = GPGME::Crypto.new
        cipher = crypto.encrypt @entries.to_yaml, :recipients => "pwss-agent@example.com"
        new_string = cipher.to_s
      else
        new_string = entries.to_yaml
      end
      FileOps::backup filename if File.exist? filename
      FileOps::save filename, new_string
    end

    
    # switch from plain to encrypted file
    # the function changes the filename and sets a password (if needed)
    # this function requires the file to be loaded since it changes the filename
    def toggle_encryption hash = Hash.new
      password = hash[:password] || nil
      schema = hash[:schema] || :gpg
      
      if FileOps::encrypted? filename then
        @password = nil
        @filename = @filename.sub(/\.(gpg|enc)$/, "")
      else
        @password = password
        @filename = schema == :gpg ? @filename + ".gpg" : @filename + ".enc"
      end
    end

    
    def add new_entry
      @entries << new_entry
    end

    
    def update id, field, new_value
      @entries[id][field] = new_value
    end

    
    def destroy id
      @entries.delete_at(id) if id != -1
    end

    
    # return the pairs [entry, id] matching a string
    def match string
      entries.each_with_index.select { |e, i| e["title"].downcase.include?(string.downcase) }
    end

    
    def get id
      entries[id]
    end

    def get_pruned id
      entry = entries[id]
      new_entry = entry.dup
      entry.keys.map { |x| new_entry[x] = "********" if Pwss::Fields::sensitive? x }
      new_entry
    end
    
    def get_field id, field
      entries[id][field]
    end

    def [](id)
      entries[id]
    end

    # return the entries after pruning some fields
    # fields is an array of strings
    def prune fields
      entries.map { |x| Safe.prune_entry x, fields }
    end

    # prune fields (array of strings) from entry, by deleting the corresponding key
    # this is used to clean databases when support for some fields is dropeed (e.g.,
    # created_at, updated_at)
    def self.prune_entry entry, fields
      @new_entry = entry.dup
      fields.map { |x| @new_entry.delete(x) }
      @new_entry
    end

    # return the entries showing only some fields
    # fields is an array of strings
    #def pick fields
    #  entries.map { |x| Safe.cherry_pick_entry x, fields }
    #end

    # return only some fields from entry
    # def self.cherry_pick_entry entry, fields
    #   @new_entry = Hash.new
    #   fields.each do |f|
    #     @new_entry[f] = entry[f]
    #   end
    #   @new_entry
    # end

    #
    # Let the user select an id from a list 
    #
    # entries_with_ids is a array of [entry, id] (e.g. the output of match)
    # even_if_one requires to select the entry even if there is one match
    #
    def self.choose_entry entries_with_ids, even_if_one = false
      if entries_with_ids == nil or entries_with_ids.size == 0
        puts "No entry matches your search criteria. Exiting."
        return -1
      end

      entries = entries_with_ids.map { |x| x[0] }
      ids = entries_with_ids.map { |x| x[1] }

      if even_if_one or entries.size > 1
        entries.size > 1 ? puts("pwss matches:") : puts("pwss match:")
        # pruned = entries.map { |x| Pwss::Safe.prune_entry x, ["password", "pin", "verification_number"] }
        entries.each_with_index do |e, i|
          puts  Pwss::Safe.entry_to_s ids[i], e
        end
        id = nil
        puts "\n"
        while (id != -1 and not ids.include?(id))
          response = Readline.readline "Select entry by ID (#{ids.join(", ")}); -1 or empty string to exit: "
          id = response == "" ? -1 : response.to_i
        end
      else
        puts "pwss has one match:"
        # pruned = Pwss::Safe.prune_entry entries[0], ["password", "pin", "verification_number"]
        puts Pwss::Safe.entry_to_s ids[0], entries[0]
        id = ids[0]
      end
      id
    end

    private

    def self.entry_to_s id, entry
      "#{"%4d" % id}. #{entry["title"]}"
    end

  end
end
