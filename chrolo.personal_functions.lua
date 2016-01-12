-- Chrolo's Personal macros
------------------------------


script_name = "Chrolo's Scripts"
script_description = "Chrolo's personal scripts and macros."
script_author = "Chrolo"
script_version = "0.1.0"
script_namespace="chrolo.personal_functions"

---------------------------------------------------------------------------------------------------------------------
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

---------------------------------------------------------------------------------------------------------------------
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

---------------------------------------------------------------------------------------------------------------------

function copy_timing_from_above(subs,selection)
	
	local prev_line= selection[1]-1

	for _, i in ipairs(selection) do
		line = subs[i]
		line.start_time = subs[prev_line].start_time
		line.end_time = subs[prev_line].end_time
		subs[i] = line
	end
	
	return selection
end
aegisub.register_macro("Chrolo/Copy Timing", "Copy the timing of the line above selection into the selection",copy_timing_from_above)













------------------------------------------------------------
--	Test Area											  --
------------------------------------------------------------

-------------
function test(subs, sel)
	
	--util = require 'aegisub.util'
	require 'print_r'
	require 'karaskel'
	

	
---------------------------------------------------------------------

	---[[
	chroloLibLoad = require 'chrolo.lib'
	chLib = chroloLibLoad("debug_level",1)
	if chLib == nil then
		aegisub.debug.out("Chrolo lib not found\n")
		return sel
	end
	--]]
	
	--[[
	for i = 1, #subs do
		aegisub.debug.out(string.format("%s\n",print_r(subs[i],"Line")))
	end
	--]]
	---[[
	for _,i in ipairs(sel) do
		bounds = chLib.getTextBoundCoords(subs, subs[i])
		--bounds = {chLib.getTextBound(subs, subs[i])}
		
		aegisub.debug.out(string.format("%s\n",print_r(bounds,"Coords")))
		--aegisub.debug.out(string.format("\n{\\p1}m 0 0 l %g 0 %g %g 0 %g\n",bounds[1],bounds[1],bounds[2], bounds[2]))
		aegisub.debug.out(string.format("\n{\\p1\\an7\\pos(0,0)}m %g %g  l %g %g %g %g %g %g\n",bounds[1][1],bounds[1][2],bounds[2][1],bounds[2][2],bounds[3][1],bounds[3][2],bounds[4][1],bounds[4][2]))
	end
	--]]

-----------------------------------------------------------------------
	return sel
end

aegisub.register_macro("Chrolo/test new", "I need to test stuff, this helps run it.",test)