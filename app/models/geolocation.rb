class Geolocation < ActiveRecord::Base

	validates_presence_of :ip_address, :country_code

	before_validation_on_create :lookup_country_code_by_ip_address, :if => Proc.new { |g| g.ip_address? }, :unless => Proc.new { |g| g.country_code? }

	def self.lookup(ip)
		geo = find_or_create_by_ip_address(ip)
		geo.try(:country_code)
	end

private

	def lookup_country_code_by_ip_address
		Rails.logger.info "Looking up location for ip: #{ip_address}"
		location = Geokit::Geocoders::MultiGeocoder.geocode(ip_address)
		self.country_code = location.try(:country_code) || 'CA' # Defaults to Canada
	end

end
