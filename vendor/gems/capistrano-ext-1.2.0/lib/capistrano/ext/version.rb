module Capistrano
  module Ext
    module Version #:nodoc:
      MAJOR = 1
      MINOR = 2
      TINY  = 0

      STRING = [MAJOR, MINOR, TINY].join(".")
    end
  end
end
