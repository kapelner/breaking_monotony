class User < ActiveRecord::Base
  include EncryptionTools

  #authentication stuff:
  validates_length_of :password, :within => 3..40, :if => :password_required?
  validates_length_of :login, :within => 3..100
  validates_uniqueness_of :login, :case_sensitive => false  
  before_save :encrypt_password 
  attr_accessor :password

  ########################################################################
  #
  # Authentication and passwords.
  #
  
  def self.encrypted_authenticate(enc_login, enc_password)
    self.authenticate(decrypt(enc_login.unpack('H*')[0]), decrypt(enc_password.unpack('H*')[0]))
  end
	
  # Authenticates a user by their login and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = self.find_by_login(login)
    u && u.authenticated?(password) ? u : nil
    
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 4.weeks.from_now.utc #one month
    self.remember_token            = encrypt("#{login}--#{remember_token_expires_at}")
    self.save!
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    self.save!
  end
  
  def fullname
    "#{self.first_name} #{self.last_name}"
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end  
end
