require 'encryptor'
 
#
# Cipher does encryption and decryption of data
# 
module Cipher
  def self.encrypt string, password
    Encryptor.encrypt(:value => string, :key => password)
  end

  def self.decrypt string, password
    Encryptor.decrypt(:value => string, :key => password)
  end

  # Ask for a password fom the command line
  def self.ask_password prompt="Enter master password: "
    printf prompt
    system "stty -echo"
    password = $stdin.gets.chomp
    system "stty echo"
    puts ""
    password
  end

  # Ask for a password twice and make sure it is entered the same
  def self.check_password prompt="master password: "
    match = false
    while ! match
      password = ask_password "Enter #{prompt}"
      repeat = ask_password "Repeat #{prompt}"
      match = (password == repeat)

      if match == false then
        puts "Error! Password do not match.  Please enter them again."
      end
    end
    password
  end
end
