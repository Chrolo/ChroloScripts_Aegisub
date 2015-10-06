-- Chrolo's Personal macros
------------------------------


script_name = "Chrolo's Scripts"
script_description = "Chrolo's personal scripts and macros."
script_author = "Chrolo"
script_version = "v0.1"

function backup_lines(subs, selection)
	local flag = true
	local j = 0
	x = 0
	for z, i in ipairs(selection) do
		--determine first line of selection
		if flag then
			ins_index = i
		end
		flag = false
		
		--grab the line, comment the line, insert the line
		x = i+j
		local line = subs[x]
		line.comment = true
		subs.insert(ins_index+j,line)
		j = j+1
	end
	
	--Change line selection:
	x = x+1 --to account for last j++
	
	--create array of lines
	new_sel = {}
    for i=1, j do
      new_sel[i] = (x-i)+1
	  --aegisub.debug.out(string.format('new_sel[%d]: "%d"\n', i, new_sel[i]))
    end
	
	selection = new_sel
	
	return selection
end

--Macro registration
aegisub.register_macro("Chrolo/Line Backup", "Duplicates and Comments the selected lines.", backup_lines)

function sel_between_comments(subs,selection)
	local last_line=0
	local last_ind=0
	
	--a lazy way to get the last line of the selection:
	for z, i in ipairs(selection) do
		last_line = i
		last_ind = z
	end
	
	--now search onward till next comment encountered:
	local new_sel = {}
	for x = last_line+1, #subs do
		if subs[x].comment then
			return selection
		else
			last_ind=last_ind+1
			selection[last_ind]=x
		end
	end
	return selection
end
aegisub.register_macro("Chrolo/Select to next comment", "Add lines to selection until it finds a comment",sel_between_comments)

function test(subs, sel)
	
	libLoad = require'chroloKfxLib'
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
	require 'print_r'
	
	local bpm=175
	---[[
	--aegisub.debug.out(str)
	local line = subs[#subs]
	line.layer=1
	line.start_time=line.end_time
	line.end_time=line.end_time+5000
	eff_lib.Shuffle:setShuffle(100,100)
	eff_lib.Shuffle:setShuffleFade(0.5)
	str = libChroloKfx.KFX_line_out(eff_lib.RainbowText,libChroloKfx.bpm_to_ms(5000),5000,(line.start_time%libChroloKfx.bpm_to_ms(bpm)))
	line.text="{"..str.."}Test Text"
	subs.append(line)
	
	
	line.start_time=line.end_time
	--entrance line
	local time_in=1000
	line.layer=0
	line.end_time=line.start_time+time_in
	eff_lib.Twirl_In:setIntime(time_in)
	str = libChroloKfx.KFX_line_out(eff_lib.Twirl_In)
	line.text="{"..str.."}Test Text2"
	subs.append(line)
	
	--next line
	line.start_time=line.end_time
	line.end_time=line.end_time+5000
	eff_lib.RainbowText:setColourTag(3)
	str = libChroloKfx.KFX_line_out(eff_lib.LRBounce,libChroloKfx.bpm_to_ms(bpm),5000,(line.start_time%libChroloKfx.bpm_to_ms(bpm))) .. libChroloKfx.KFX_line_out(eff_lib.RainbowText,libChroloKfx.bpm_to_ms(5000),5000,(line.start_time%libChroloKfx.bpm_to_ms(bpm)))
	line.text="{\\pos()"..str.."}Test Text2"
	subs.append(line)
	--]]
	
	
	return sel
end

aegisub.register_macro("Chrolo/test new", "I need to test stuff, this helps run it.",test)