# AUTHORS:
# - Matt Pizzimenti (www.livelearncode.com)

# LICENSE:
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
# 
# Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
# 
# Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
# 
# Neither the name of the original author nor the names of contributors
# may be used to endorse or promote products derived from this software
# without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require File.join(File.dirname(__FILE__), "lib", "view_extensions")
require File.join(File.dirname(__FILE__), "lib", "controller_extensions")
require File.join(File.dirname(__FILE__), "lib", "model_extensions")
require File.join(File.dirname(__FILE__), "lib", "session_extensions")


# load Facebook YAML configuration file (credit: Evan Weaver)
::FACEBOOK = {}
begin
  yamlFile = YAML.load_file("#{RAILS_ROOT}/config/facebook.yml")
rescue Exception => e
  raise StandardError, "config/facebook.yml could not be loaded."
end

if yamlFile
  if yamlFile[RAILS_ENV]
    FACEBOOK.merge!(yamlFile[RAILS_ENV])
  else
    raise StandardError, "config/facebook.yml exists, but doesn't have a configuration for RAILS_ENV=#{RAILS_ENV}."
  end
else
  raise StandardError, "config/facebook.yml does not exist."
end

# inject methods to Rails MVC classes
ActionView::Base.send(:include, RFacebook::Rails::ViewExtensions)
ActionController::Base.send(:include, RFacebook::Rails::ControllerExtensions)
ActiveRecord::Base.send(:include, RFacebook::Rails::ModelExtensions)

# inject methods to Rails session management classes
CGI::Session.send(:include, RFacebook::Rails::SessionExtensions)

# TODO: document SessionStoreExtensions as API so that anyone can patch their own custom session container in addition to these
CGI::Session::PStore.send(:include, RFacebook::Rails::SessionStoreExtensions)
CGI::Session::ActiveRecordStore.send(:include, RFacebook::Rails::SessionStoreExtensions)
CGI::Session::DRbStore.send(:include, RFacebook::Rails::SessionStoreExtensions)
CGI::Session::FileStore.send(:include, RFacebook::Rails::SessionStoreExtensions)
CGI::Session::MemoryStore.send(:include, RFacebook::Rails::SessionStoreExtensions)
CGI::Session::MemCacheStore.send(:include, RFacebook::Rails::SessionStoreExtensions) if defined?(CGI::Session::MemCacheStore)

# parse for full URLs in facebook.yml (multiple people have made this mistake)
module RFacebook::Rails
  def self.fix_path(path)
    # check to ensure that the path is relative
    if matchData = /(\w+)(\:\/\/)([\w0-9\.]+)([\:0-9]*)(.*)/.match(path)
      relativePath = matchData.captures[4]
      RAILS_DEFAULT_LOGGER.info "** RFACEBOOK INFO: It looks like you used a full URL '#{path}' in facebook.yml.  RFacebook expected a relative path and has automatically converted this URL to '#{relativePath}'."
      path = relativePath
    end
  
    # check for the proper leading/trailing slashes
    if (path and path.size>0)
      # force leading slash, then trailing slash
      path = "/#{path}" unless path.starts_with?("/")
      path = "#{path}/" unless path.reverse.starts_with?("/")
    end
  
    return path
  end
end

FACEBOOK["canvas_path"] = RFacebook::Rails::fix_path(FACEBOOK["canvas_path"])
FACEBOOK["callback_path"] = RFacebook::Rails::fix_path(FACEBOOK["callback_path"])