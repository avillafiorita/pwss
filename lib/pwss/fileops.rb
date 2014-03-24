require 'fileutils'

#
# From file to string and back
#
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
    File.extname(filename) == ".enc"
  end

  def self.backup filename
    FileUtils::cp filename, filename + "~"
  end
  
end

