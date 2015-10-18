require 'encryptor'

#
# Cipher does encryption and decryption of data
# It reasons at the string level (both in input and in output)
#
module Pwss
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
  end
end
