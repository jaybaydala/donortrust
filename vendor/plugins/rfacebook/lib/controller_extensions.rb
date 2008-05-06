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

require "facebook_web_session"
require File.join(File.dirname(__FILE__), "status_manager")

module RFacebook
  module Rails
    module ControllerExtensions

      # signatures are allowed at most a 30 minute delta in the sig_time
      FACEBOOK_SIGNATURE_TIME_SLACK = 48*3600
      
      ################################################################################################
      ################################################################################################
      # :section: Core API variables
      ################################################################################################
      
      # Facebook API key, as parsed from the YAML file
      def facebook_api_key
        FACEBOOK["key"]
      end

      # Facebook API secret, as parsed from the YAML file
      def facebook_api_secret
        FACEBOOK["secret"]
      end
      
      # Facebook canvas path, as parsed from the YAML file (may be nil if this application is an external app)
      def facebook_canvas_path
        FACEBOOK["canvas_path"]
      end

      # Facebook callback path, as parsed from the YAML file (may be nil if this application is an external app)
      def facebook_callback_path
        FACEBOOK["callback_path"]
      end
        
      ################################################################################################
      ################################################################################################
      # :section: Special Facebook variables
      ################################################################################################
      
      # Accessor for all params beginning with "fb_sig_".  The signature is verified
      # to prevent replay attacks and other calls that don't originate from Facebook.
      # (the "fb_sig_" prefix is removed from the parameter name)
      def fbparams
        # check to see if we have parsed the fb_sig_ params yet
        if @fbparams.nil?
          # first, look in the params hash
          sourceParams = (params || {}).dup
          @fbparams = parse_fb_sig_params(sourceParams)
          
          # second, look in the cookies hash
          if @fbparams.size == 0
            sourceParams = (cookies || {}).dup
            @fbparams = parse_fb_sig_params(sourceParams)
          end
          
          # ensure that these parameters aren't being replayed
          sigTime = @fbparams["time"] ? @fbparams["time"].to_i : nil
          if (sigTime.nil? or (sigTime > 0 and Time.now.to_i > (sigTime + FACEBOOK_SIGNATURE_TIME_SLACK)))
            # signature expired, fbparams are not valid
            @fbparams = {}
          end
          
          # ensure that signature validates properly from Facebook
          expectedSignature =  fbsession_holder.signature(@fbparams)
          actualSignature = sourceParams["fb_sig"]
          if (actualSignature.nil? or expectedSignature != actualSignature)
            # signatures didn't match, fbparams are not valid
            @fbparams = {}
          end
        end
        
        # as a last resort, if we are an iframe app, we might have saved the
        # fbparams to the session previously
        if @fbparams.size == 0
          @fbparams ||= session[:_rfacebook_fbparams] || {}
        end
        
        # return fbparams (may or may not be populated)
        return @fbparams
      end
      
      # Gives direct access to a Facebook session (of type RFacebook::FacebookWebSession)
      # for this user. An attempt will be made to activate this session (either using
      # canvas params or an auth_token for external apps), but if the user
      # has not been forced to log in to Facebook, the session will NOT be
      # ready for usage.  To double-check this, simply call 'ready?' to
      # see if the session is okay to use.
      def fbsession
        
        # do a check to ensure that we nil out the fbsession_holder in case there is a new user visiting
        if session[:_rfacebook_fbsession_holder] and fbparams["session_key"] and session[:_rfacebook_fbsession_holder].session_key != fbparams["session_key"]
          session[:_rfacebook_fbsession_holder] = nil
        end
        
        # if we have verified fb_sig_* params, we should be able to activate the session here
        if (!fbsession_holder.ready? and facebook_platform_signature_verified?)
          # then try to activate the session somehow (or retrieve from previous state)
          # these might be nil
          facebookUserId = fbparams["user"]
          facebookSessionKey = fbparams["session_key"]
          expirationTime = fbparams["expires"]
                
          # activate the session if we got all the pieces of information we needed
          if (facebookUserId and facebookSessionKey and expirationTime)
            fbsession_holder.activate_with_previous_session(facebookSessionKey, facebookUserId, expirationTime)
            RAILS_DEFAULT_LOGGER.debug "** RFACEBOOK INFO: Activated session from inside the canvas (user=#{facebookUserId}, session_key=#{facebookSessionKey}, expires=#{expirationTime})"
            
          # warn that we couldn't get a valid Facebook session since we were missing data
          else
            RAILS_DEFAULT_LOGGER.debug "** RFACEBOOK WARNING: Tried to get a valid Facebook session from POST params, but failed"
          end
        end
        
        # if we still don't have a session, check the Rails session
        # (used for external and iframe apps when fb_sig POST params weren't present)
        if (!fbsession_holder.ready? and session[:_rfacebook_fbsession_holder] and session[:_rfacebook_fbsession_holder].ready?)
          RAILS_DEFAULT_LOGGER.debug "** RFACEBOOK INFO: grabbing Facebook session from Rails session"
          @fbsession_holder = session[:_rfacebook_fbsession_holder]
          @fbsession_holder.logger = RAILS_DEFAULT_LOGGER
        end
        
        # if all went well, we should definitely have a valid Facebook session object
        return fbsession_holder
      end
    
      ################################################################################################
      ################################################################################################
      # :section: Facebook helper methods
      ################################################################################################
      
      # returns true if the user is viewing the page in the canvas
      def in_facebook_canvas?
        # TODO: make this check fbparams instead (signature is validated there)
        return (params and params["fb_sig_in_canvas"] == "1")
      end
        
      # returns true if the user is viewing the page in an iframe
      def in_facebook_frame?
        # TODO: make this check fbparams instead (signature is validated there)
        return (params and params["fb_sig_in_iframe"] == "1")
      end
      
      # returns true if the current request is a mock-ajax request
      def in_mock_ajax?
        # TODO: make this check fbparams instead (signature is validated there)
        return (params and params["fb_sig_is_mockajax"] == "1")
      end
      
      # returns true if the current request is an FBJS ajax request
      def in_ajax?
        # TODO: make this check fbparams instead (signature is validated there)
        return (params and params["fb_sig_is_ajax"] == "1")
      end
      
      # returns true if the user is viewing the page from an external website
      def in_external_app?
        # FIXME: once you click away in an iframe app, you are considered to be an external app
        # TODO: read up on the hacks for avoiding nested iframes
        return (params and params["fb_sig"] == nil and !in_facebook_frame?)
      end
      
      # returns true if the user has added (installed) the current application
      def added_facebook_application?
        # TODO: make this check fbparams instead (signature is validated there)
        return (params and params["fb_sig_added"] == "1")
      end
      
      # clear the current session so that a new user can log in
      def log_out_of_facebook
        session[:_rfacebook_fbsession_holder] = nil
        session[:_rfacebook_fbparams] = nil
        @fbsession_holder = nil
      end
      
      # returns true if the fb_sig_* parameters have been verified with a correct signature
      def facebook_platform_signature_verified?
        return (fbparams.size != 0)
      end

      # this is a callback method for EXTERNAL web applications, you should define this method to do something
      # (for example, redirect the user to your main page, etc.)
      def finish_facebook_login
        # do nothing by default
      end
      
      ################################################################################################
      ################################################################################################
      # :section: before_filters
      ################################################################################################    
    
      # force the user to log in to Facebook
      def require_facebook_login(urlOptions={})
        # check to be sure we haven't already performed a redirect or other action
        if !performed?
          
          # handle invalid sessions by forcing the user to log in      
          if !fbsession.ready?
          
            # external applications need to be redirected
            if in_external_app?    
              RAILS_DEFAULT_LOGGER.debug "** RFACEBOOK INFO: Redirecting to login for external app"
              redirect_to fbsession.get_login_url(urlOptions)
              return false
              
            # iframe and canvas apps need *validated* fbparams, otherwise session activation cannot happen
            elsif !facebook_platform_signature_verified?
              RAILS_DEFAULT_LOGGER.debug "** RFACEBOOK WARNING: Failed to verified canvas parameters from Facebook (probably due to a bad API key or API secret)"
              render :text => facebook_debug_panel
              return false
            
            else
              RAILS_DEFAULT_LOGGER.debug "** RFACEBOOK INFO: Redirecting to login for canvas app"
              urlOptions.merge!({:canvas=>true})
              redirect_to fbsession.get_login_url(urlOptions)
              return false
              
            end
          end
        end
        
        # by default, the filter passes
        return true
      end
      
      # force the user to install your Facebook application
      def require_facebook_install(urlOptions={})
        #   if in_facebook_frame? and not added_facebook_application?
        #     render :text => %Q(<script language="javascript">top.location.href="#{fbsession.get_install_url}&next=#{request.path.gsub(/#{facebook_callback_path}/, "")}"</script>)
        #   end
        if (in_facebook_canvas? or in_facebook_frame?)
          if (!fbsession.ready? or !added_facebook_application?)
            redirect_to fbsession.get_install_url(urlOptions)
            return false
          end
        else
          RAILS_DEFAULT_LOGGER.info "** RFACEBOOK WARNING: require_facebook_install is not intended for external applications, using require_facebook_login instead"
          return require_facebook_login(urlOptions)
        end
        return true
      end

      ################################################################################################
      ################################################################################################
      # :section: Debug panel
      ################################################################################################
      
      # special rendering method to use when debugging
      def render_with_facebook_debug_panel(options={})
        begin
          renderedOutput = render_to_string(options)
        rescue Exception => e
          renderedOutput = facebook_canvas_backtrace(e)
        end
        render :text =>  "#{facebook_debug_panel}#{renderedOutput}"
      end
            
      # returns HTML containing information about the current environment (API key, API secret, etc.)
      def facebook_debug_panel
        templatePath = File.join(File.dirname(__FILE__), "..", "templates", "debug_panel.rhtml")
        template = File.read(templatePath)
        return ERB.new(template).result(Proc.new{})
      end
      
      # used for the debug panel, runs a series of tests to determine what might be wrong
      # with your particular environment
      def facebook_status_manager
        checks = [
          SessionStatusCheck.new(self),
          (FacebookParamsStatusCheck.new(self) unless (!in_facebook_canvas? and !in_facebook_frame?)),
          InCanvasStatusCheck.new(self),
          InFrameStatusCheck.new(self),
          (CanvasPathStatusCheck.new(self) unless (!in_facebook_canvas? or !in_facebook_frame?)),
          (CallbackPathStatusCheck.new(self) unless (!in_facebook_canvas? or !in_facebook_frame?)),
          (FinishFacebookLoginStatusCheck.new(self) unless (in_facebook_canvas? or in_facebook_frame?)),
          APIKeyStatusCheck.new(self),
          APISecretStatusCheck.new(self)
          ].compact
        return StatusManager.new(checks)
      end
      
      ################################################################################################
      ################################################################################################
      # :section: Utility methods
      ################################################################################################
      private
        
      # this before_filter is used by all controllers to activate a session in the case
      # that this is an external website
      # NOTE: this will change a bit in future releases (to be optionally executed)
      def handle_facebook_login
        # FIXME: make this optionally executed
        # when we don't have a valid set of fbparams, we can try using an auth_token
        # if it exists in our current parameters
        if (in_external_app? and params["auth_token"])
          
          # attempt to activate (or re-activate) with the auth token
          begin
            RAILS_DEFAULT_LOGGER.debug "** RFACEBOOK INFO: attempting to activate a new Facebook session from auth_token"
            fbsession_holder.activate_with_token(params["auth_token"])
            finish_facebook_login if fbsession_holder.ready?       
          rescue StandardError => e
            RAILS_DEFAULT_LOGGER.debug "** RFACEBOOK INFO: Tried to use a stale auth_token (#{e.to_s})"
          end
          
          # log a warning if the session was not activated during this attempt
          unless fbsession_holder.ready?
            RAILS_DEFAULT_LOGGER.info "** RFACEBOOK WARNING: Tried to activate (or re-activate) a Facebook session with auth_token and failed"
          end
        end
        
        # this before_filter never stops page load
        return true
      end
      
      # return the current FacebookWebSession (can be un-activated)
      def fbsession_holder # :nodoc:
        if (@fbsession_holder == nil)
          @fbsession_holder = FacebookWebSession.new(facebook_api_key, facebook_api_secret)
          @fbsession_holder.logger = RAILS_DEFAULT_LOGGER
        end
        return @fbsession_holder
      end
      
      # keeps a reference to the fbsession in the current user's session
      def persist_fbsession
        if (!in_facebook_canvas? and fbsession_holder.ready?)
          RAILS_DEFAULT_LOGGER.debug "** RFACEBOOK INFO: persisting Facebook session information into Rails session"
          session[:_rfacebook_fbsession_holder] = @fbsession_holder.dup
          if in_facebook_frame?
            # we need iframe apps to remember they are iframe apps
            session[:_rfacebook_fbparams] = fbparams
          end
        end
      end
      
      # given a parameter hash, parses out only the ones prefixed with fb_sig_
      def parse_fb_sig_params(sourceParams)      
        # get the params prefixed by "fb_sig_" (and remove the prefix)
        fbSigParams = {}
        sourceParams.each do |k,v|
          if matches = k.match(/fb_sig_(.+)/)
            keyWithoutPrefix = matches[1]
            fbSigParams[keyWithoutPrefix] = v
          end
        end
        
        # return the new hash
        return fbSigParams
      end
      
      # override the reset_session so that the entire session is cleared
      # (patch from chrisff)
      def reset_session_with_rfacebook
        @fbsession_holder=nil
        @fbparams=nil
        reset_session_without_rfacebook
      end
      
      ################################################################################################
      ################################################################################################
      # :section: Backtrace handling
      ################################################################################################
      
      # overrides to allow backtraces in Facebook canvas pages
      def rescue_action_with_rfacebook(exception)
        # render a special backtrace for canvas pages
        if in_facebook_canvas?
          render(:text => "#{facebook_debug_panel}#{facebook_canvas_backtrace(exception)}")
        
        # all other pages get the default rescue behavior
        else
          rescue_action_without_rfacebook(exception)
        end
      end
      
      # returns HTML containing an exception backtrace that is viewable within a Facebook canvas page
      def facebook_canvas_backtrace(exception)
        # parse the actual exception backtrace
        rfacebookBacktraceLines = []
        exception.backtrace.each do |line|
          
          # escape HTML
          cleanLine = line.gsub(RAILS_ROOT, "").gsub("<", "&lt;").gsub(">", "&gt;")
          
          # split up these lines by carriage return
          pieces = cleanLine.split("\n")
          if (pieces and pieces.size> 0)
            pieces.each do |piece|
              if matches = /.*[\/\\]+((.*)\:([0-9]+)\:\s*in\s*\`(.*)\')/.match(piece)
                # for each parsed line, add to the array for later rendering in the template
                rfacebookBacktraceLines << {
                  :filename => matches[2],
                  :line => matches[3],
                  :method => matches[4],
                  :rawsummary => piece,
                }
              end
            end
          end
        end
        
        # render to the ERB template
        templatePath = File.join(File.dirname(__FILE__), "..", "templates", "exception_backtrace.rhtml")
        template = File.read(templatePath)
        return ERB.new(template).result(Proc.new{})
      end
      
      ################################################################################################
      ################################################################################################
      # :section: URL Management
      ################################################################################################
      
      # overrides url_for to account for canvas and iframe environments
      def url_for_with_rfacebook(options={})
        
        # fix problems that some Rails installations had with sending nil options
        options ||= {}
                
        # use special URL rewriting when inside the canvas
        # setting the full_callback option to true will override this
        # and force usage of regular Rails rewriting        
        if options.is_a? Hash
          fullCallback = (options[:full_callback] == true) ? true : false # TODO: is there already a Rails param for this?
          options.delete(:full_callback)
        end
          
        if ((in_facebook_canvas? or in_mock_ajax? or in_ajax?) and !fullCallback) #TODO: do something separate for in_facebook_frame?
          
          if options.is_a? Hash
            options[:only_path] = true if options[:only_path].nil?
          end
          
          # try to get a regular URL
          path = url_for_without_rfacebook(options)
                          
          # replace anything that references the callback with the
          # Facebook canvas equivalent (apps.facebook.com/*)
          if path.starts_with?(self.facebook_callback_path)
            path.sub!(self.facebook_callback_path, self.facebook_canvas_path)
            path = "http://apps.facebook.com#{path}"
          elsif "#{path}/".starts_with?(self.facebook_callback_path)
            path.sub!(self.facebook_callback_path.chop, self.facebook_canvas_path.chop)
            path = "http://apps.facebook.com#{path}"
          elsif (path.starts_with?("http://www.facebook.com") or path.starts_with?("https://www.facebook.com"))
            # be sure that URLs that go to some other Facebook service redirect back to the canvas
            if path.include?("?")
              path = "#{path}&canvas=true"
            else
              path = "#{path}?canvas=true"
            end
          elsif (!path.starts_with?("http://") and !path.starts_with?("https://"))
            # default to a full URL (will link externally)
            RAILS_DEFAULT_LOGGER.debug "** RFACEBOOK INFO: failed to get canvas-friendly URL ("+path+") for ["+options.inspect+"], creating an external URL instead"
            path = "#{request.protocol}#{request.host}:#{request.port}#{path}"
          end
        
        # full callback rewriting
        elsif fullCallback
          options[:only_path] = true
          path = "#{request.protocol}#{request.host}:#{request.port}#{url_for_without_rfacebook(options)}"
        
        # regular Rails rewriting
        else
          path = url_for_without_rfacebook(options)
        end

        return path
      end
      
      # overrides redirect_to to account for canvas and iframe environments
      def redirect_to_with_rfacebook(options = {}, responseStatus = {})
        # get the url
        redirectUrl = url_for(options)

        # canvas redirect
        if in_facebook_canvas?
                  
          RAILS_DEFAULT_LOGGER.debug "** RFACEBOOK INFO: Canvas redirect to #{redirectUrl}"
          render :text => "<fb:redirect url=\"#{redirectUrl}\" />"
        
        # iframe redirect
        elsif redirectUrl.match(/^https?:\/\/([^\/]*\.)?facebook\.com(:\d+)?/i)
          RAILS_DEFAULT_LOGGER.debug "** RFACEBOOK INFO: iframe redirect to #{redirectUrl}"
          render :text => %Q(<script type="text/javascript">\ntop.location.href='#{redirectUrl}';\n</script>)
          
        # otherwise, we only need to do a standard redirect
        else
          RAILS_DEFAULT_LOGGER.debug "** RFACEBOOK INFO: Regular redirect_to"
          begin
          	redirect_to_without_rfacebook(options, responseStatus)
					rescue ArgumentError
						redirect_to_without_rfacebook(options)
					end
        end
      end

      ################################################################################################
      ################################################################################################
      # :section: Extension management
      ################################################################################################

      def self.included(base) # :nodoc:
        # since we currently override ALL controllers, we have to alias
        # the old methods.  Future versions will avoid this inclusion.
        # TODO: allow controller-by-controller inclusion
        base.class_eval do
          alias_method_chain :url_for,        :rfacebook
          alias_method_chain :redirect_to,    :rfacebook
          alias_method_chain :reset_session,  :rfacebook
          alias_method_chain :rescue_action,  :rfacebook
        end
        
        # ensure that every action handles facebook login
        base.before_filter(:handle_facebook_login)
        
        # ensure that we persist the Facebook session into the Rails session (if possible)
        base.after_filter(:persist_fbsession)
        
        # fix third party cookies in IE
        base.before_filter{ |c| c.headers['P3P'] = %|CP="NOI DSP COR NID ADMa OPTa OUR NOR"| }          
      end

    end
  end
end
