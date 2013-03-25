require 'crypt/blowfish' 

module EncryptionTools
  BlowfishEncrypter = Crypt::Blowfish.new('ADKDACSL_SGDHSDDTJSFSFREHSCWEFSHSEF') #don't touch this under any circumstances!!!
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    
    def b_encrypt(string)
      BlowfishEncrypter.encrypt_string(string.to_s).unpack('H*')[0]
    end

    def b_decrypt(string)
      BlowfishEncrypter.decrypt_string([string].pack('H*'))
    end
    
    ######
    ##
    ## For ActiveRecord models
    ##     
  
    def find_by_encrypted_id(encrypted_id, *options)
      find(b_decrypt(encrypted_id), *options)
    end
  end

  #these methods should be accessible from the class itself for convenience?
  def b_encrypt(string)
    self.class.b_encrypt(string)
  end
  
  def b_decrypt(string)
    self.class.b_decrypt(string)
  end  
  
  ######
  ##
  ## For ActiveRecord models
  ## 
  
  def encrypted_id
    b_encrypt(self.id)
  end  
  
end
