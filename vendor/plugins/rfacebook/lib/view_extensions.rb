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

module RFacebook
  module Rails
    module ViewExtensions
      
      # returns true if the user is viewing the canvas
      def in_facebook_canvas?
        @controller.in_facebook_canvas?
      end
      
      # returns true if the user is in an iframe
      def in_facebook_frame?
        @controller.in_facebook_frame?
      end
      
      # returns true if the render is using mock ajax
      def in_mock_ajax?
        @controller.in_mock_ajax?
      end
      
      # returns true if the render is using mock ajax
      def in_ajax?
        @controller.in_ajax?
      end
      
      # returns the current fb_sig_params (only if they validated properly)
      def fbparams
        @controller.fbparams
      end
      
      # returns the current user's Facebook session (an instance of FacebookWebSession)
      def fbsession
        @controller.fbsession
      end
      
      # overrides the path_to_image method to ensure that all images are written
      # with absolute paths
      def path_to_image(*params)
        path = super(*params)
        if ((in_facebook_canvas? or in_mock_ajax? or in_ajax?) and !(/(\w+)(\:\/\/)([\w0-9\.]+)([\:0-9]*)(.*)/.match(path)))
          path = "#{request.protocol}#{request.host_with_port}#{path}"
        end
        return path
      end
      
      # Aliases to path_to_image for Rails 1.0 backwards compatibility
      def image_path(*params)
        path_to_image(*params)
      end
      
      # renders the RFacebook debug panel
      def facebook_debug_panel(options={}) # :nodoc:
        RAILS_DEFAULT_LOGGER.info "** RFACEBOOK DEPRECATION WARNING: 'facebook_debug_panel' is deprecated in ActionViews"
        return @controller.facebook_debug_panel(options)
      end
      
    end
  end
end