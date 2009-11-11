class UpoweredEmailSubscribe < ActiveRecord::Base
  validates_presence_of :email
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "isn't a valid email address"
  before_create :make_unsubscribe_code
  
  def make_unsubscribe_code
    unsubscribe_code = UpoweredEmailSubscribe.generate_unsubscribe_code
    # ensure it's not currently being used
    if !UpoweredEmailSubscribe.find_by_code(unsubscribe_code)
      self.code = unsubscribe_code and return
    end
    # if we get here, it's being used, so try again
    make_unsubscribe_code
  end
  
  def self.generate_unsubscribe_code
    hash = ""
    srand()
    (1..8).each do
      rnd = (rand(2147483648)%36) # using 2 ** 31
      rnd = rnd<26 ? rnd+97 : rnd+22
      hash = hash + rnd.chr
    end
    hash
  end
  
  
end