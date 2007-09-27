#
#--
# Copyright (c) 2007, John Mettraux, OpenWFE.org
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without 
# modification, are permitted provided that the following conditions are met:
# 
# . Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.  
# 
# . Redistributions in binary form must reproduce the above copyright notice, 
#   this list of conditions and the following disclaimer in the documentation 
#   and/or other materials provided with the distribution.
# 
# . Neither the name of the "OpenWFE" nor the names of its contributors may be
#   used to endorse or promote products derived from this software without
#   specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
# POSSIBILITY OF SUCH DAMAGE.
#++
#

#
# "made in Japan"
#
# John Mettraux at openwfe.org
#

require 'thread'

require 'openwfe/service'
require 'openwfe/rudefinitions'
require 'openwfe/util/kotoba'


module OpenWFE
    
    #
    # This default wfid generator outputs a long integer as a String.
    # The last given id (in order to prevent clocks being put back) is
    # stored in the work directory in the file "wfidgen.last"
    #
    class DefaultWfidGenerator < Service

        def initialize (service_name, application_context)
            super

            @last = -1
            @mutex = Mutex.new

            @last_fn = get_work_directory + '/wfidgen.last'

            load_last()

            ensure_last_f
        end

        #
        # Returns a new workflow instance id
        #
        # The launchitem parameter is not used by this generator.
        #
        def generate (launchitem=nil)
            wfid = nil
            @mutex.synchronize do
                wfid = now
                wfid = @last + 1 if wfid <= @last
                @last = wfid
                save_last
            end
            to_string(wfid)
        end

        #
        # The actual job of turning the numeric result into a String.
        # This method is overriden in extension of this class.
        #
        def to_string (numeric_id)
            numeric_id.to_s
        end

        #
        # Is a simple call to OpenWFE::split_wfid()
        #
        def split_wfid (wfid)
            OpenWFE.split_wfid(wfid)
        end

        #
        # This method is called by OpenWFE::split_wfid() when it has detected
        # a wfid following this 'defaut' scheme.
        #
        def self.split_wfid (wfid)
            r = []
            0.upto(wfid.length-1) do |i|
                r << wfid[i, 1]
            end
            r
        end

        #
        # Stops this service.
        # In this particular implementation, makes sure the "wfidgen.last"
        # file is closed.
        #
        def stop
            #linfo { "stop() stopping '#{@service_name}'" }
            @last_f.close if @last_f
        end

        protected

            def ensure_last_f
                if (not @last_f) or @last_f.closed?
                    begin
                        @last_f = File.open(@last_fn, "w+")
                    rescue Exception => e
                        lwarn do
                            "new() failed to open #{@last_fn}, "+
                            "continuing anyway...\n"+
                            OpenWFE::exception_to_s(e)
                        end
                    end
                end
            end

            def now
                wfid = Time.now.to_f * 1000 * 10
                wfid.to_i
            end

            def save_last
                return unless @last_f
                ensure_last_f()
                @last_f.pos = 0
                @last_f.puts @last
            end

            def load_last
                @mutex.synchronize do

                    if File.exist?(@last_fn)
                        begin
                            s = File.open(@last_fn, "r") do |f|
                                f.readline
                            end
                            @last = Integer(s)
                            #puts @last
                        rescue Exception => e
                            #puts
                            #puts e.to_s
                        end
                    end

                    n = now

                    @last = n if (not @last) or (@last < n)
                end
            end
    end

    #
    # This extension of DefaultWfidGenerator produces ids like
    # "20070318-jonowoguya" or "20071224-jesoshimoha" that are a bit
    # easier to grasp than full integer wfids.
    #
    class KotobaWfidGenerator < DefaultWfidGenerator

        #
        # Overrides the to_string() method of the DefaultWfidGenerator,
        #
        def to_string (numeric_id)

            self.class.to_string(numeric_id)
        end

        #
        # That's here that the numeric wfid gets turned into a 'kotoba'.
        # A static method easily accessible by any.
        #
        def self.to_string (numeric_id)

            i = numeric_id % (10 * 1000 * 60 * 60 * 24)
            t = Time.now.gmtime

            s = sprintf "%4d%02d%02d", t.year, t.month, t.day
            s << "-"
            s << Kotoba::from_integer(i)
            s
        end

        #
        # This method is called by OpenWFE::split_wfid() when it has detected
        # a wfid following the 'kotoba' scheme.
        # Returns the 'kotoba' wfid split into its syllables
        #
        def self.split_wfid (wfid)
            Kotoba::split(wfid[9..-1])
        end

        #
        # Turns a KotobaWfidGenerator produced wfid into a UTC date.
        #
        def self.to_time (wfid)

            year = wfid[0, 4]
            month = wfid[4, 2]
            day = wfid[6, 2]

            s = wfid[9..-1]

            i = Kotoba::to_integer(s)

            hour = (i / (10000 * 60 * 60)) % 24
            min = (i / (10000 * 60)) % 60
            sec = (i / 10000) % 60
            usec = (i * 100) % 1000000

            #puts "hms #{hour} #{min} #{sec} #{usec}"

            Time.utc(year, month, day, hour, min, sec, usec)
        end

        def self.from_time (t)
            to_string(t.to_f * 10 * 1000).to_i
        end
    end

    #
    # This wfid generator returns as wfid the value found in a given
    # field of the launchitem (if any).
    #
    # If there is no launchitem or no field, a Kotoba wfid is returned.
    #
    # This generator is useful for engines that have to use workflow
    # instance ids generated by other systems.
    #
    class FieldWfidGenerator < KotobaWfidGenerator

        def initialize (service_name, application_context, field_name)

            super(service_name, application_context)

            @field_name = field_name
        end

        def generate (launchitem=nil)

            return super unless launchitem

            wfid = launchitem.attributes[@field_name]

            return wfid.to_s if wfid

            super
                #
                # if the field is not present in the launchitem, will
                # return a Kotoba wfid
        end
    end

    #
    # A wfid generator that uses any underlying "uuidgen" command it might
    # find.
    # By default, it favours "uuidgen -t".
    #
    # You can specifying a command by passing a :uuid_command param in the 
    # application context, or simply by overriding the generate() method.
    #
    class UuidWfidGenerator < Service

        COMMANDS = [
            "uuidgen -t",
            "uuidgen"
        ]

        def initialize (service_name, application_context)

            super

            @command = @application_context[:uuid_command] \
                if @application_context

            unless @command
                COMMANDS.each do |c|
                    c = "#{c} 2> /dev/null"
                    s = `#{c}`
                    h = s[0, 8].hex
                    if h > 0
                        @command = c
                        break
                    end
                end
            end

            raise "no command found for generating an uuid found..." \
                unless @command

            linfo { "new() command that will be used : '#{@command}'" }
        end

        #
        # Generates a brand new UUID
        #
        # The launchitem parameter is not used by this generator.
        #
        def generate (launchitem=nil)
            return `#{@command}`.chomp
        end

        #
        # Is a simple call to OpenWFE::split_wfid()
        #
        def split_wfid (wfid)
            OpenWFE.split_wfid(wfid)
        end

        #
        # This method is called by OpenWFE::split_wfid() when it has detected
        # a wfid that is a UUID.
        #
        # Splits the first part of the uuid (will be used for the
        # expression storage directory structure).
        #
        def self.split_wfid (wfid)
            s = wfid[0, 8]
            a = []
            4.times do |i|
                a << s[i*2, 2]
            end
            a
        end
    end

    #
    # "module methods"
    #

    SPLIT_MAP = {
        "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}" => UuidWfidGenerator,
        "[0-9]{8}-[a-z]*" => KotobaWfidGenerator
    }

    #
    # This method should be able to split any wfid whose scheme is implemented
    # here.
    #
    def OpenWFE.split_wfid (wfid)
        SPLIT_MAP.each do |regex, clazz|
            return clazz.split_wfid(wfid) if wfid.match(regex) 
        end
        #
        # else
        #
        DefaultWfidGenerator.split_wfid(wfid)
    end

end

