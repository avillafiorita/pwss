require 'encryptor'
 
#
# Cipher does encryption and decryption of data
# It reasons at the string level (both in input and in output)
#
module Cipher
  def self.encrypt string, password
    Encryptor.encrypt(:value => string, :key => password)
  end

  def self.decrypt string, password
    begin
      Encryptor.decrypt(:value => string, :key => password)
    rescue Exception => e
      puts "Unable to decrypt. Exiting"
      exit 1
    end
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
  def self.check_password prompt="master password"
    match = false
    while ! match
      password = ask_password "Enter #{prompt}: "
      repeat = ask_password "Repeat #{prompt}: "
      match = (password == repeat)

      if match == false then
        puts "Error! Password do not match.  Please enter them again."
      end
    end
    password
  end

  # Ask for a password (twice) or generate one, if length is greater than 0
  def self.check_or_generate prompt, length=0, alnum=false
    length > 0 ? generate_password(length, alnum) : check_password(prompt)
  end

  #
  # make the password available to the clipboard.
  #
  def self.password_to_clipboard password, counter = 30
    old_clipboard = `pbpaste`
    system("printf \"%s\" \"#{password}\" | pbcopy")

    begin
      if counter <= 0
        STDIN.flush
        puts "\nPassword available in clipboard: press enter when you are done."
        STDIN.getc
      else
        puts "\nPassword available in clipboard for #{counter} seconds."
        sleep(counter)
      end
      system("printf \"#{old_clipboard}\" | pbcopy")
    rescue Exception => e
      system("printf \"#{old_clipboard}\" | pbcopy")
      puts "Clipboard restored. Exiting."
    end
  end

  private

  # Generate a random password
  # (Adapted from: http://randompasswordsgenerator.net/tutorials/ruby-random-password-generator.html)
  def self.generate_password(length=8, alnum=false)  
    chars = 'abcdefghjkmnpqrstuvwxyzABCDEFGHJKLMNOPQRSTUVWXYZ1234567890'  
    chars += '!@#$%^&*()_+=[]{}<>/~,.;:|' if not alnum
    Array.new(length) { chars[rand(chars.length)].chr }.join  
  end


end
