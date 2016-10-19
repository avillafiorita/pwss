require 'clipboard'

module Pwss
  # some functions to manage password generation and clipboard
  module Password
    DEFAULT_PASSWORD_LENGTH=16
    
    # generate a password
    #
    # optional hash +arguments+ allows to define a strategy for
    # generating a password and the password length of automatically
    # generated passwords)
    #
    #
    def self.password arguments = {}
      length = arguments[:length] || DEFAULT_PASSWORD_LENGTH
      strategy = arguments[:strategy] || 'random'

      case strategy
      when 'random', 'strong', 'alpha'
        return Pwss::Password.random_password(length, strategy)
      when 'ask'
        return Pwss::Password.ask_password_twice "new password for entry"
      when 'pwgen'
        begin
          password = %x(pwgen -N1 #{length}).chomp
          return password
        rescue
          raise "Error: pwgen not found.  Use one of random, strong, alpha, or ask."
        end
      else
        raise "Error: password generation strategy #{strategy} not understood."
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
    def self.ask_password_twice prompt="master password"
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

    # Generate a random password
    # (Adapted from: http://randompasswordsgenerator.net/tutorials/ruby-random-password-generator.html)
    def self.random_password length=DEFAULT_PASSWORD_LENGTH, strategy="random"
      lower = 'abcdefghijkmnpqrstuvwxyz'
      upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ'
      digits = '123456789'
      ambiguous = '0oOlI' 
      safe_symbols = '~!@#$%^-+_.,;:'
      difficult_symbols = '&*()={}[]|\\\"\'`<>?/'

      case strategy
      when 'random'
        chars = lower + upper + digits + safe_symbols + difficult_symbols + ambiguous
      when 'strong'
        chars = lower + upper + digits + safe_symbols
      when 'alpha'
        chars = lower + upper + digits
      else
        raise "Error: password generation strategy #{strategy} is not understood."
      end        

      Array.new(length) { chars[rand(chars.length)].chr }.join
    end

    #
    # make a field available to the clipboard for a given time (in seconds).
    #
    def self.to_clipboard field_name, value, counter = 30
      old_clipboard = Clipboard.paste
      Clipboard.copy value

      begin
        if counter <= 0
          STDIN.flush
          puts "\n#{field_name.capitalize} available in clipboard: press enter when you are done."
          STDIN.getc
        else
          puts "\n#{field_name.capitalize} available in clipboard for #{counter} seconds."
          sleep(counter)
        end
        Clipboard.copy old_clipboard
      rescue Exception => e
        Clipboard.copy old_clipboard
        puts "Clipboard restored"
      end
    end
  end
end
