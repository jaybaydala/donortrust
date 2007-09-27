#
#--
# Copyright (c) 2007, John Mettraux OpenWFE.org
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
# $Id: definitions.rb 2725 2006-06-02 13:26:32Z jmettraux $
#

#
# "made in Japan"
#
# John Mettraux at openwfe.org
#

#
# = Kotoba
# 
# This module contains methods for converting plain integers (base 10)
# into words that are easier to read and remember.
#
# For example, the equivalent of the (base 10) integer 1329724967 is
# "takeshimaya".
#
# Kotoba uses 70 of the syllables of the Japanese language, it is thus
# a base 10 to base 70 converter.
#
# Kotoba is meant to be used for generating human readable (or more
# easily rememberable) identifiers. Its first usage is within the 
# OpenWFEru Ruby workflow and bpm engine for generating 'kawaii' 
# business process intance ids.
#
# == Kotoba from the command line
#
# You can use Kotoba directly from the command line :
#
#     $ ruby kotoba.rb kotoba
#     141260
#     $ ruby kotoba.rb rubi
#     3432
#     $ ruby kotoba.rb 2455
#     nada
#
# might be useful when used from some scripts.
#
module Kotoba

    V = %w{ a e i o u }
    C = %w{ b d g h j k m n p r s t z }

    SYL = []

    C.each do |s|
        V.each do |v|
            SYL << s + v
        end
    end

    SYL << "wa"
    SYL << "wo"

    SYL << "ya"
    SYL << "yo"
    SYL << "yu"

    SPECIAL = [ 
        [ "hu", "fu" ],
        [ "si", "shi" ],
        [ "ti", "chi" ],
        [ "tu", "tsu" ],
        [ "zi", "tzu" ]
    ]

    #SYL2 = SYL.collect do |syl|
    #    s = syl
    #    SPECIAL.each do |a, b|
    #        if s == a
    #            s = b
    #            break
    #        end
    #    end
    #    s
    #end

    #
    # Turns the given integer into a Kotoba word.
    #
    def Kotoba.from_integer (integer)
        s = from_i(integer)
        to_special(s)
    end

    #
    # Turns the given Kotoba word to its equivalent integer.
    # 
    def Kotoba.to_integer (string)
        s = from_special(string)
        to_i(s)
    end

    #
    # Turns a simple syllable into the equivalent number.
    # For example Kotoba::to_number("fu") will yield 19.
    #
    def Kotoba.to_number (syllable)
        SYL.each_with_index do |s, index|
            return index if syllable == s
        end
        raise "did not find syllable '#{syllable}'"
    end

    #
    # Given a Kotoba 'word', will split into its list of syllables.
    # For example, "tsunashima" will be split into 
    # [ "tsu", "na", "shi", "ma" ]
    #
    def Kotoba.split (word)
        word = from_special(word)
        a = string_split(word)
        a_to_special(a)
    end

    #
    # Returns if the string is a Kotoba word, like "fugu" or 
    # "toriyamanobashi".
    #
    def Kotoba.is_kotoba_word (string)
        begin
            to_integer(string)
            true
        rescue #Exception => e
            false
        end
    end

    protected

        def Kotoba.string_split (s, result=[])
            return result if s.length < 1
            result << s[0, 2]
            string_split(s[2..-1], result)
        end

        def Kotoba.a_to_special (a)
            a.collect do |syl|
                SPECIAL.each do |a, b|
                    if syl == a
                        syl = b
                        break
                    end
                end
                syl
            end
        end

        def Kotoba.to_special (s)
            SPECIAL.each do |a, b|
                s = s.gsub(a, b)
            end
            s
        end

        def Kotoba.from_special (s)
            SPECIAL.each do |a, b|
                s = s.gsub(b, a)
            end
            s
        end

        def Kotoba.from_i (integer)

            return '' if integer == 0

            mod = integer % SYL.length
            rest = integer / SYL.length

            return from_i(rest) + SYL[mod]
        end

        def Kotoba.to_i (s)
            return 0 if s.length == 0
            return SYL.length * to_i(s[0..-3]) + to_number(s[-2, 2])
        end
end

#
# command line interface for Kotoba

if __FILE__ == $0
    arg = ARGV[0]
    if arg and arg != "-h" and arg != "--help"
        begin
            puts Kotoba::from_integer(Integer(arg))
        rescue
            puts Kotoba::to_integer(arg)
        end
    else
        puts
        puts "ruby #{$0} {arg}"
        puts
        puts "  If the arg is a 'Kotoba' word, will turn it into the equivalent"
        puts "  integer."
        puts "  Else, it will consider the arg as an integer and attempt at"
        puts "  turning it into a Kotoba [word]."
        puts
        puts "  Kotoba uses #{Kotoba::SYL.length} syllables."
        puts
    end
end

