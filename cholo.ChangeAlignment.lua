-- Change Alignment
------------------------------


script_name = "Change Alignment"
script_description = "Changes between Alignements, mantaining current position (where possible)"
script_author = "Chrolo"
script_version = "0.1.0"
script_namespace = "cholo.ChangeAlignment"

--global variables
local chroloLibLoad = require 'chrolo.lib'
local chLib = chroloLibLoad()


function mid_point_coord( x, y )
--purpose: returns midpoint of two co-ords
return {((x[1]+y[1])/2), ((x[2]+y[2])/2)}

end

function new_pos(coords, align)
--purpose: Determine position values for a shape given shape co-ordinates and alignment tag
--inputs: width and height of shape (px), new alignment (1-9), co-ordinates of top-right corner (pos used for \an7)
--outputs: the new values for the \pos tag

	local pos = { coords[1][1], coords[1][2]} 	--default to top-left corner

	if align == 1 then
		pos=coords[4]
	elseif align == 3 then
		pos=coords[3]
	elseif align == 9 then
		pos=coords[2]
	elseif align == 7 then
		pos=coords[1]
	
	elseif align == 2 then
		pos = mid_point_coord(coords[3],coords[4])
	elseif align == 4 then
		pos = mid_point_coord(coords[1],coords[4])
	elseif align == 5 then
		pos = mid_point_coord(coords[1],coords[3])
	elseif align == 6 then
		pos = mid_point_coord(coords[2],coords[3])
	elseif align == 8 then
		pos = mid_point_coord(coords[1],coords[2])
	end
	
	return pos
end



function change_align(subs, sel, alignment)
--Purpose:	Change the \an and \pos tags of a line, without affecting line position
--Inputs:	<Subs> file, <sel>ection, <alignment> wanted.
	
	--make sure alignment has come in as a number:
	if tonumber(alignment) == nil then
		aegisub.debug.out(string.format("'%s' is not recognised as a valid alignment.\n",alignment))
	else
		alignment = tonumber(alignment)
	end
	
	--for each line:
	local sub_lines={}
	for _, i in ipairs(sel) do
		local line = subs[i]
		--calculate the co-ordinates of the line
		coords = chLib.getTextBoundCoords(subs, line)
		
		local positions = new_pos(coords, alignment)
			--aegisub.debug.out(string.format("New tag is {\\an%d\\pos(%g,%g)}\n",alignment, positions[1], positions[2]))
		
		--replace or add the \an tag
		if line.text:find("\\an%d") then
			line.text = line.text:gsub("\\an%d",string.format("\\an%d",alignment))
		else
			line.text = line.text:gsub("{",string.format("{\\an%d",alignment),1) --add alignment tag to first tag opening, might make a library function to "add tag"
		end
			
		--replace or add the \pos tag
		line.text = line.text:gsub("\\pos%([%d.]-,[%d.]-%)",string.format("\\pos(%g,%g)", positions[1], positions[2]))
		
		--write changes back to file:
		subs[i]= line
	end
	
	return sel
	
end


--------------------------
-- Macros to register:	--
--------------------------
function GUI_change_wrapper(subs, sel)
	--Choose an alignement:
		--setup initial dialog
	dialog = {
		--Line entrance choice:
		{class="label", label="Alginment		", x=0, y=0},
		{class="dropdown", name="alignment", items = {1,2,3,4,5,6,7,8,9}, x=0, y=1, value="None"}		
	}
	btn, dialog_result = aegisub.dialog.display(dialog,
		{"Switch up", "Calm Down"},
		{ok="Switch up", cancel="Calm Down"}
	)
	
	--Make sure !nil and call function
	if not (dialog_result.alignment == nil) then
		change_align(subs, sel, dialog_result.alignment)
	else
		aegisub.debug.out("You're going to have to choose your alignment.\n")
	end
	
end
aegisub.register_macro("Chrolo/Change Alignment", "Changes between Alignements, mantaining current position (where possible)", GUI_change_wrapper)

local cur_align = 0
function Cycle_Alignments(subs, sel)
	
	--get next alignment
	cur_align = cur_align+1
	if cur_align > 9 then cur_align = 1 end
	
	--call the function
	change_align(subs, sel, cur_align)
	
end
aegisub.register_macro("Chrolo/Cycle Alignment", "Cycles between Alignements, mantaining current position (where possible)", Cycle_Alignments)


