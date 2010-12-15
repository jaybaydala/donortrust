require 'faster_csv'
require 'tmail'
class EmailParser
  attr_reader :emails, :data, :errors
  def initialize(file_or_data)
    @emails = []
    @errors = []
    
    if file_or_data.is_a? String
      @data = file_or_data
    elsif file_or_data.respond_to?("read")
      @data = file_or_data.read
    end
  end
  
  def parse_upload
    FasterCSV.parse(@data, { :headers => true, :return_headers => false }) do |row|
      begin
        email = TMail::Address.parse("#{row[0]} <#{row[1]}>")
      rescue TMail::SyntaxError
        @errors << email
      else
        @emails << email unless @emails.detect{|e| e.address == email.address }
      end
    end  
    @emails
  end
  
  def parse_list
    @data.split(',').each do |email|
      begin
        email = TMail::Address.parse(email)      
        if valid?(email.address)
          @emails << email unless @emails.detect{|e| e.address == email.address }
        else
          @errors << email.address.to_s
        end
      rescue TMail::SyntaxError
        @errors << email.strip
      end
    end  
    @emails
  end

  def self.parse_email(email)
    begin
      TMail::Address.parse(email)
    rescue TMail::SyntaxError
      false
    end
  end
  
  private
  def valid?(address)
    unless address.to_s.match(/^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i)
      false
    else
      true
    end
  end
end
