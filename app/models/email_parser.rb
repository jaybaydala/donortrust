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
        @emails << email
      rescue TMail::SyntaxError
      end
    end
    @emails
  end
  
  def parse_list
    @data.split(',').each do |email|
      begin
        email = TMail::Address.parse(email)
        @emails << email unless @emails.detect{|e| e.address == email.address }
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
end
