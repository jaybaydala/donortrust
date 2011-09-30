class UpoweredShare < ActiveRecord::Base
  EMAIL_FORMAT = /^[-a-z0-9_+\.]+\@([-a-z0-9]+\.)+[a-z0-9]{2,4}$/i

  def self.columns() @columns ||= []; end

  def self.column(name, sql_type = nil, default = nil, null = true)
    columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
  end

  column :from_name, :string
  column :from_email, :string
  column :to, :string
  column :message, :text

  validates_format_of :from_email, :with => EMAIL_FORMAT
  validates_length_of :message, :maximum => 500
  validates_presence_of :from_name, :from_email, :to, :message

  def self.human_name
    "U:Powered Share"
  end

  attr_accessor :upowered_url

  def initialize(attributes={})
    super
    self.message ||= %Q{Hey!\nMy friends at UEnd:Poverty asked if I would help fuel the organization that's ending extreme poverty. They said for the price of a cup of coffee per month I could actually change the world. I said I'm in! I thought you may also want to join. R You In?\n\nGo here to learn more and sign up:\n#{self.upowered_url}}
    self.to = [*self.to].select{|t| t.present? }
  end

  def new_record?
    true
  end

  def send_messages
    self.to.each do |to_email|
      UpoweredMailer.deliver_upowered_share(self.from_name, self.from_email, to_email, self.message)
    end
  end

  def to_param
    nil
  end

  private
    def validate
      errors.add(:to, "needs to contain valid email addresses") if to.any? do |value|
        !(value.to_s =~ EMAIL_FORMAT)
      end
    end
end