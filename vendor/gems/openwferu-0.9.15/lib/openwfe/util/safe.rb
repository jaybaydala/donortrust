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
# john.mettraux@openwfe.org
#

require 'open-uri'


module OpenWFE

    #--
    # Runs some remote code (uri) at a different $SAFE level.
    #
    #def OpenWFE.load_safely (uri, safe_level)
    #    source = ""
    #    source << "#\n"
    #    source << "# loaded from #{uri}\n"
    #    source << "#\n"
    #    source << open(uri).read
    #    load_eval_safely(source, safe_level)
    #end
    #
    #
    # Makes sure that a piece of Ruby code is run at certain safe level.
    # Saves in a temp file that is reloaded in its own anonymous namespace.
    #
    # (no binding passing allowed like in the basic Kernel.eval() method).
    #
    #def OpenWFE.load_eval_safely (code, safe_level)
    #    tmpfname = 
    #        "#{Dir.tmpdir}/"+
    #        "owfe_#{code.object_id}_#{Time.new.to_f}.tmp.rb"
    #    File.open tmpfname, "w" do |file|
    #        file.print code
    #    end
    #    Thread.new do
    #        $SAFE = safe_level
    #        load(tmpfname, true)
    #    end.join
    #    begin
    #        File.delete tmpfname
    #    rescue Excpetion => e
    #        # ignore
    #    end
    #end
    #++

    #
    # Runs some code within an instance's realm at a certain safety level.
    #
    def OpenWFE.instance_eval_safely (instance, code, safe_level)

        return instance.instance_eval(code) if on_jruby?

        code.untaint

        r = nil

        Thread.new do
            $SAFE = safe_level
            r = instance.instance_eval(code)
        end.join

        raise "cannot TAMPER with JRUBY_VERSION" if on_jruby?

        r
    end

    #
    # Runs an eval() call at a certain safety level.
    #
    def OpenWFE.eval_safely (code, safe_level, binding=nil)

        return eval(code, binding) if on_jruby?

        code.untaint

        r = nil

        Thread.new do
            $SAFE = safe_level
            r = eval(code, binding)
        end.join

        raise "cannot TAMPER with JRUBY_VERSION" if on_jruby?

        r
    end

    #
    # - not used currently -
    #
    # evals "requires" at the current safe level and the rest of the code
    # at the requested safety level.
    #
    def OpenWFE.eval_r_safely (code, safe_level, binding=nil)

        code.untaint

        c = ""

        code.split("\n").each do |line|
            if line.match "^ *require " and not line.index(";")
                eval(line, binding)
            else
                c << line
                c << "\n"
            end
        end

        eval_safely(c, safe_level, binding)
    end

    protected

    #
    # Returns true if the JRUBY_VERSION is defined.
    # (beware : something else than JRuby may have defined it).
    #
    def OpenWFE.on_jruby?

        defined?(JRUBY_VERSION) != nil
    end
    
end

