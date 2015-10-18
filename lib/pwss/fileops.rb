require 'fileutils'
require 'gpgme'

#
# From file to string and back
# There is no lower level than this
#
module Pwss
  module FileOps
    # load a file into a string
    def self.load filename
      file = File.open(filename, "rb")
      file.read
    end

    # save a string to a file
    def self.save filename, data
      file = File.open(filename, "wb")
      file.write data
      file.close
    end

    # check if the extension is ".enc"
    def self.encrypted? filename
      gpg? filename or symmetric? filename
    end

    def self.symmetric? filename
      File.extname(filename) == ".enc"
    end

    def self.gpg? filename
     File.extname(filename) == ".gpg"
    end    

    def self.backup filename
      FileUtils::cp filename, filename + "~"
      puts "Backup copy of password safe created in #{filename}~."
    end
    
  end
end
