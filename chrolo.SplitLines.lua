-- Split Lines
------------------------------

--global variables
local chroloLibLoad = require 'chrolo.lib'
local chLib = chroloLibLoad()
----------------
-- Macro Info --
----------------

script_name = "Line Breaker"
script_description = "Splits a line by '\\N', preserving text position"
script_author = "Chrolo"
script_version = "1.0.2"
script_namespace = "cholo.SplitLines"

menu_embedding = "Chrolo/"	--if you don't like the menu being Chrolo>Macro, just adjust this.





---------------
-- functions --
---------------
function mid_point_coord( x, y )
--purpose: returns midpoint of two co-ords
return {((x[1]+y[1])/2), ((x[2]+y[2])/2)}

end


--------------------------
-- Macros to register:	--
--------------------------
function SplitUpLines(subs, sel)
	
	local offset=0;
	for _, i in ipairs(sel) do --foreach line of selection
	
		local line = subs[i+offset];
		
		--get the line sizing information:
		local t_width, t_height, sub_parts = chLib.getTextBound(subs, line);
		--calculate the co-ordinates of the line
		local coords = chLib.getTextBoundCoords(subs, line);
		--[[ replaced by chLib.getLineInfo(subs, line)
		--grab the alignment
		local align = line.text:match("\\an(%d)");
		--get rotation --this may need improvement. work on
		local rotation = line.text:match("\\frz(%d+)");
		if (rotation == nil) then
			rotation = 0
		end
		--]]
		local info = chLib.getLineInfo(subs, line);
		local align = info["an"]
		local rotation = info["frz"]
		
		rotation = rotation + 90
		
		--Split the line by occurences of '\N'
		local t_lines = chLib.string_split(line.text,"\\N");
		
		
		local new_lines={};
		local dx,dy = 0,0	--initial pos offsets are 0
		--start position of offset based of alignment:
		local ori_pos = {0,0};
		if align%3==1 then
			ori_pos = coords[1]		--1,4,7 are calculated off top left
		elseif align%3==2 then
			ori_pos = mid_point_coord(coords[1],coords[2])		--2,5,8 are calculated off top mid
		elseif align%3==0 then
			ori_pos = coords[2]		--3,6,9 are calculated off top right
		end
		
		
		--process each t_line
		for i,i_line in ipairs(t_lines) do
		
			--add default data to line: (copy timing and such from original line)
			table.insert(new_lines,{});
			for key,data in pairs(line) do
				new_lines[i][key] = data;
			end
			
			--calculate new line position
			
			if math.floor((align-1)/3) == 1 then --line is align 4,5,6; need to add half line height before determining position
				dx, dy = unpack( chLib.matrix_sum( {dx,dy} , { chLib.polar_to_cartesian(sub_parts[i]["height"]/2, rotation)} ) )
			elseif math.floor((align-1)/3) == 0 then --line is align 1,2,3; need to add line height before determining position
				dx, dy = unpack( chLib.matrix_sum( {dx,dy} , { chLib.polar_to_cartesian(sub_parts[i]["height"], rotation)} ) )
			end
			
			--calc the position
			if info["move_xy"] ~= nil then
				sub_parts[i][1]["params"]["move"] = {ori_pos[1]-dx,ori_pos[2]+dy,ori_pos[1]-dx+info["move_xy"][1],ori_pos[2]+dy+info["move_xy"][2]}
			else
				sub_parts[i][1]["params"]["pos"] = {ori_pos[1]-dx,ori_pos[2]+dy}
			end
			
			
			--add any remaining line height
			if math.floor((align-1)/3) == 1 then --line is align 4,5,6; need to add half line height after determining position
				dx, dy = unpack( chLib.matrix_sum( {dx,dy} , { chLib.polar_to_cartesian(sub_parts[i]["height"]/2, rotation)} ) ) 
			elseif math.floor((align-1)/3) == 2 then --line is align 7,8,9; need to add line height after determining position
				dx, dy = unpack( chLib.matrix_sum( {dx,dy} , { chLib.polar_to_cartesian(sub_parts[i]["height"], rotation)} ) )
			end
			
			
			-- update tags
			new_lines[i].text = chLib.add_params_to_line(i_line, sub_parts[i][1]["params"]);
			
		end
		
		
		--write changes back to file:
		for x,y in pairs(new_lines) do
			subs.insert(i+offset, new_lines[x]);
			offset=offset+1;	--increase line offset
		end
		
		subs.delete(i+offset);		--remove the old line
		offset=offset-1;				--minus the initial line
		
	end
	
	return sel
	
end
aegisub.register_macro(menu_embedding..script_name, script_description, SplitUpLines)