-- Chrolo's KFX Example Usage
------------------------------


script_name = "Chrolo's KFX Example Usage"
script_description = "Shows how to use the KFX library"
script_author = "Chrolo"
script_version = "v0.1"

local libLoad = require'chroloKfxLib'
local libChroloKfx , eff_lib = libLoad()

if not libChroloKfx then
	aegisub.debug.out("Lib Chrolo Failed to load")
	return false
end
if not eff_lib then
	aegisub.debug.out("Effect Library Failed to load")
	return false
end

util = require 'aegisub.util'
--require 'print_r' --useful for debug: http://www.hpelbers.org/lua/print_r


function generate_example_lines(subs, sel)
	
	--just a quick definition for easy of the examples:
	local str_pre="\\fs60\\an5"
	
	--aegisub.debug.out(str)
	local line = subs[#subs]
	--Sample #1: llrr bounce to 175 beat
	--line setup:
	line.layer=1
	line.start_time=line.end_time
	line.end_time=line.end_time+5000
	--generate string:
	str = libChroloKfx.KFX_line_out(eff_lib.LLRRBounce,libChroloKfx.bpm_to_ms(175),5000,(line.start_time%libChroloKfx.bpm_to_ms(175)))
	line.text="{"..str_pre..str.."}Sample#1"
	--add the line in:
	subs.append(line)
	line.start_time=line.end_time
	
	--Sample #2: Twirl in, followed by bounce with outline colour changing
	local bpm=150
	--entrance line
	local time_in=1000
	line.layer=0
	line.end_time=line.start_time+time_in
	eff_lib.Twirl_In:setIntime(time_in)
	str = libChroloKfx.KFX_line_out(eff_lib.Twirl_In)
	line.text="{"..str_pre..str.."}Sample#2"
	subs.append(line)
	
	--main line
	line.start_time=line.end_time
	line.end_time=line.end_time+5000
	eff_lib.RainbowText:setColourTag(3)
	str = libChroloKfx.KFX_line_out(eff_lib.LRBounce,libChroloKfx.bpm_to_ms(bpm),5000,(line.start_time%libChroloKfx.bpm_to_ms(bpm))) .. libChroloKfx.KFX_line_out(eff_lib.RainbowText,libChroloKfx.bpm_to_ms(5000),5000,0)
	line.text="{"..str_pre..str.."}Sample#2"
	subs.append(line)
	
	--sample #3: using the repeated_mod function raw dog style
	line.start_time=line.end_time
	line.end_time=line.end_time+5000
	eff_lib.RainbowText:setColourTag(1)
	eff_lib.RainbowText:setHueOffset(100)
	str = libChroloKfx.repeating_mod(eff_lib.RainbowText,libChroloKfx.bpm_to_ms(5000),5000,0) --the make line function basically just helps encapsulate this function in other uses, such as shuffle text
	line.text="{"..str_pre..str.."}Sample#3"
	subs.append(line)
	
	--sample #4: Shuffling text
	line.start_time=line.end_time
	line.end_time=line.end_time+5000
	--setup effect params
	eff_lib.Shuffle:setShuffleFade(0)
	eff_lib.Shuffle:setShuffle(8,3)
	--generate string
	str = libChroloKfx.KFX_line_out(eff_lib.Shuffle,100,5000,0)
	line.text="{"..str_pre..str.."}Sample#3"
	subs.append(line)
	
	
	return sel
end

aegisub.register_macro("Chrolo/SampleLines", "Generates some sample lines.",generate_example_lines)