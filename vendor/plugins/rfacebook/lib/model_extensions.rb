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
    module ModelExtensions

      ################################################################################################
      ################################################################################################
      # :section: Core API variables
      ################################################################################################

      def facebook_api_key
        FACEBOOK["key"] || super
      end
      
      def facebook_api_secret
        FACEBOOK["secret"] || super
      end
      
      ################################################################################################
      ################################################################################################
      # :section: Method mixing
      ################################################################################################
      
      def self.included(base) # :nodoc:
        base.extend ActsAsMethods
      end

      module ActsAsMethods # :nodoc:all
        def acts_as_facebook_user
          RAILS_DEFAULT_LOGGER.info "** RFACEBOOK DEPRECATION WARNING: acts_as_facebook_user will probably be deprecated in a future version of the RFacebook plugin"
          include RFacebook::Rails::ModelExtensions::ActsAsFacebookUser::InstanceMethods
          extend RFacebook::Rails::ModelExtensions::ActsAsFacebookUser::ClassMethods
        end
      end
      
      
      ##################################################################
      ##################################################################
      # :section: Acts As Facebook User
      ##################################################################
      module ActsAsFacebookUser
        
        ACTORS = [] # holds a reference to all classes that have ActsAsFacebookUser injected
        
        FIELDS = [
          "about_me",
          "activities",
          "affiliations",
          "birthday",
          "books",
          "current_location",
          "education_history",
          "name",
          "first_name",
          "last_name",
          "hometown_location",
          "hs_info",
          "interests",
          "relationship_status",
          "meeting_for",
          "meeting_sex",
          "movies",
          "music",
          "notes_count",
          "political",
          "profile_update_time",
          "quotes",
          "religion",
          "sex",
          "significant_other_id",
          "status",
          "timezone",
          "tv",
          "wall_count",
          "work_history",
          "pic",
          "pic_big",
          "pic_small",
          "pic_square"
        ]

        
        ######################
        module ClassMethods
                    
          def find_or_create_by_facebook_session(options={})
            RAILS_DEFAULT_LOGGER.info "** RFACEBOOK DEPRECATION WARNING: acts_as_facebook_user will probably be deprecated in a future version of the RFacebook plugin"
            
            # parse the options (for backwards compatibility, options MIGHT be a FacebookWebSession)
            if options.is_a?(RFacebook::FacebookWebSession)
              fbsession = options
              options = {}
            else
              fbsession = options[:facebook_session]
            end
            
            # check that we have an fbsession
            unless fbsession.is_a?(RFacebook::FacebookWebSession)
              RAILS_DEFAULT_LOGGER.debug "** RFACEBOOK INFO: find_or_create_by_facebook_session needs a :facebook_session specified"
              return nil
            end
            
            # if the session is ready to use...
            if fbsession.ready?
              
              # find or create a user
              instance = find_by_facebook_uid(fbsession.session_user_id) || self.new(options)
              
              # update session info
              instance.facebook_session = fbsession
              
              # update (or create) the object and return it
              if !instance.save
                RAILS_DEFAULT_LOGGER.debug "** RFACEBOOK INFO: failed to update or create the Facebook user object in the database"
                return nil
              end
              return instance

            # session was not ready
            else
              RAILS_DEFAULT_LOGGER.info "** RFACEBOOK WARNING: tried to use an inactive session for acts_as_facebook_user (in find_or_create_by_facebook_session)"
              return nil
            end
              
          end
                            
        end
      
        ######################
        module InstanceMethods
          
          # TODO: to help developers stay within the TOS, we should have a method in here like "with_facebook_scope(fbsession){...}"
          
          def facebook_session
            if !@facebook_session
              @facebook_session = FacebookWebSession.new(self.facebook_api_key, self.facebook_api_secret)
              begin
                @facebook_session.activate_with_previous_session(self.facebook_session_key, self.facebook_uid)
              rescue
                # not a valid facebook session, should we nil it out?
              end
            end
            return @facebook_session
          end
          
          def facebook_session=(sess)
            @facebook_session = sess
            self.facebook_session_key = @facebook_session.session_key
            self.facebook_uid = @facebook_session.session_user_id
          end

          def has_infinite_session_key?
            # TODO: this check should really look at expires
            return self.facebook_session_key != nil
          end
          
          def self.included(base) # :nodoc:
            ActsAsFacebookUser::ACTORS << base
            ActsAsFacebookUser::FIELDS.each do |fieldname|
              # TODO: do getInfo caching
              base.class_eval <<-EOF
                
                def #{fieldname}
                  if facebook_session.ready?
                    return facebook_session.users_getInfo(
                      :uids => [facebook_uid],
                      :fields => ActsAsFacebookUser::FIELDS).user.send(:#{fieldname})
                  else
                    return nil
                  end
                end
              
              EOF
            end
          end
                
        end
        
      end
      ##################################################################
      ##################################################################

      
    end    
  end
end