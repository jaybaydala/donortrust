module Packet
  class Guid
    def self.hexdigest
      values = [
                rand(0x0010000),
                rand(0x0010000),
                rand(0x0010000),
                rand(0x0010000),
                rand(0x0010000),
                rand(0x1000000),
                rand(0x1000000),
               ]
      "%04x%04x%04x%04x%04x%06x%06x" % values
    end
  end
end

