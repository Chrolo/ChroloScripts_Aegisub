--Chrolo's Library
script_name = "Chrolo's Library."
script_description = "When you need something done, check everywhere else first, then here."
script_author = "Chrolo"
script_version = "0.1.0"
script_namespace = "chrolo.lib"
--Realising I was going to create a tonne of reusable code and functions, I present this:

--exported tables:
local lib={} --These are the general functions of the library

--internal tables:
local tag_list={ 
--a table of all standard tags with information about values, etc.
-- possible values:
--	["type"]	- Data type for parameter
--	["style"]	- Translation of tag for use in styles line.
--	["desc"]	- Description of tag (though you probably know these
--	["par_c"]	- (max) Param count : how many parameters are there? (eg, \pos has 2, \t can have up to 4)

-- [""]	={ ["type"] = "",	["style"] = "",	["par_c"] = ,	["desc"] = 		},


["fn"]	 ={ ["type"] = "text",	["style"] = "fontname",	["par_c"] = 1,	["desc"] = "Font name"		},
["fs"]	 ={ ["type"] = "int",	["style"] = "fontsize",	["par_c"] = 1,	["desc"] = "Font Size" 		},
["fsp"]	 ={ ["type"] = "float",	["style"] = "spacing",	["par_c"] = 1,	["desc"] = "Font spacing"		},
["an"]	 ={ ["type"] = "int",	["style"] = "align",	["par_c"] = 1,	["desc"] = "Text alignement"		},

["c"]	={ ["type"] = "color",	["style"] = "color1",	["par_c"] = 1,	["desc"] = "Primary text color"		},
["2c"]	={ ["type"] = "color",	["style"] = "color2",	["par_c"] = 1,	["desc"] = "Secondary text color"		},
["3c"]	={ ["type"] = "color",	["style"] = "color3",	["par_c"] = 1,	["desc"] = "Border color"		},
["4c"]	={ ["type"] = "color",	["style"] = "color4",	["par_c"] = 1,	["desc"] = "Shadow color"		},

["frz"]		={ ["type"] = "angle",	["style"] = "angle",	["par_c"] = 1,	["desc"] = "Z-rotation"		},
["fscx"]	={ ["type"] = "float",	["style"] = "scale_x",	["par_c"] = 1,	["desc"] = "Horizontal Scaling"		},
["fscy"]	={ ["type"] = "float",	["style"] = "scale_y",	["par_c"] = 1,	["desc"] = "Vertical Scaling"		},

["b"]	={ ["type"] = "bool",	["style"] = "bold",			["par_c"] = 1,	["desc"] = "Bold"		},
["u"]	={ ["type"] = "bool",	["style"] = "underline",	["par_c"] = 1,	["desc"] = "Underlined"		},
["i"]	={ ["type"] = "bool",	["style"] = "italic",		["par_c"] = 1,	["desc"] = "Italics"		},

--Non Style tags:

["fade"]	={ ["type"] = "time",	["par_c"] = 7,	["desc"] = "Complex fade"},
["pos"]		={ ["type"] = "float",	["par_c"] = 2,	["desc"] = "Position of Line"		},
["move"]	={ ["type"] = "float",	["par_c"] = 6,	["desc"] = "Movement of line"		},

--More needs to be added....
}

local style_translator={
-- [""]	={ ["param"] = ""	},
["fontname"]	={ ["param"] = "fn"	},
["align"]		={ ["param"] = "an"	},
["angle"]		={ ["param"] = "frz"	},
["bold"]		={ ["param"] = "b"	},
["scale_y"]		={ ["param"] = "fscy"	},
["scale_x"]		={ ["param"] = "fscx"	},
}

--DEBUG SETTINGS
local debug_level = 0



--ASS TS functions
function lib.getTextBound(subs, line)
--Purpose:	Get the Text boundary of a line (useful when adjusting alignements).
--Returns:	width and height of rendered text, array of lines and subcomponent widths+heights and their parameters.
	--
	local h, w = 0, 0 
	
	local sub_parts={}

	--Make a local copy of the style used for this line.
	local this_style = getStyle(subs, line.style)
	
	--Split lines at every '\N'
	local t_lines = string_split(line.text,"\\N")

	for i,i_line in ipairs(t_lines) do
		local t_h, t_w = 0, 0
		t_w = 0
		--Split lines at every tag instance.(incase there's a change there)
		local t_subText, t_subTags = split_at_override_tags(i_line)
			if debug_level > 0 then
				aegisub.debug.out(string.format("Line text is: `%s`\n",i_line))
				aegisub.debug.out(string.format("%s\n",print_r(t_subText,"t_subText")))
				aegisub.debug.out(string.format("%s\n",print_r(t_subTags,"t_subTags")))
			end
		
		--insert new array into sub_parts
		table.insert(sub_parts,i,{})
		
		for j,_ in ipairs(t_subText) do
			
			--insert new array into line array of sub_parts:
			table.insert(sub_parts[i],j,{})
			
			--customise style based on found tags
			local param_updates = getOverrideParamsFromTags(t_subTags[j])
			this_style = applyParamstoStyle(this_style, param_updates)
			if debug_level > 0 then
				aegisub.debug.out(string.format("%s\n",print_r(this_style,"modified style")))
			end
			
			--put params for this line into array
			sub_parts[i][j][3]=getParamsFromStyle(this_style)	--grab the info from the style
			for tag, data in pairs(param_updates) do			--and add the info from the overrides
				sub_parts[i][j][3][tag] = data
			end
--[[
WORK TO DO
--]]
			--findbounding box
			local width, height, descent, ext_lead = aegisub.text_extents(this_style, t_subText[j])
				if debug_level >0 then
					--aegisub.debug.out(string.format("%s\n",print_r(this_style,"this_style")))
					aegisub.debug.out(string.format("%s\n",print_r(t_subText[j],string.format("t_subText[%d]",j))))
					aegisub.debug.out(string.format("%s\n",print_r({width, height, descent, ext_lead},"returned")))
				end
			
			--adjust for unaccounted params: (\i, \fax, \frx, \fry, etc)
--[[
WORK TO DO
--]]
			--put line_component width and height into array
			sub_parts[i][j][1]= width
			sub_parts[i][j][2]= height
			
			
			--calculate outer bounds
			t_w = t_w + width 			-- increase width of line
			t_h = math.max(t_h, height)	-- figure out tallest section of line
				if debug_level >0 then
					aegisub.debug.out(string.format("Line width is %g \t line height is %g\n",t_w, t_h))

				end
			
		end	--loop though variances on each newline
		
		h = h + t_h				-- add on the height of the last line
		w = math.max(w, t_w)	-- use maximum line width found.
		
	end	--loop through vertical lines
	
	--adjust for \shad and other tags that only affect global bounds, not line bounds
--[[
WORK TO DO
--]]

	--return the width, height and sub components of bounding box
	return w, h, sub_parts

end
function lib.getTextBoundCoords(subs, line)
--Purpose:	Get the co-ordinates of a text's bounding box.
--returns:	{{x1,y1},{x2,y2},{x3,y3},{x4,y4} , where co-ordinates are numbered clockwise from top-left

	local coords = {{nil,nil},{nil,nil},{nil,nil},{nil,nil}}
	--get text bounding box
	local w, h = lib.getTextBound(subs, line)
	
	--get params from style.
	local params = getParamsFromStyle(getStyle(subs, line.style))
	--get Override params out of the line
	local params_ov = getOverrideParamsFromTags(line.text)
	
	--combine them:
	for i,_ in pairs(params_ov) do
		params[i]=params_ov[i]	--could've used the _ variable, but I think this makes it more obvious what i'm doing.
	end
	
	--if \pos not set, calc default:
	if  params['pos'] == nil then
		params['pos'] = {getDefaultPos(subs, params['an'])}
	end
	--if \frz not set, it's 0
	if params['frz'] == nil then
		params['frz'] = {0}
	end
	--create inverted angle for calcs as vertical norm is invert.
	local w_angle = params['frz'][1] + 180
	local h_angle = params['frz'][1] + 90
	
	if debug_level > 0 then
		aegisub.debug.out(string.format("\n%s\n",print_r(params,"params")))
	end

	local d_x, d_y = 0 , 0
	local alignment = tonumber(params['an'][1])
	--Calculate difference between pos and coord[1]
	if		alignment == 1 then
		d_x, d_y = euler_to_vector(h, h_angle)
	elseif	alignment == 2 then
		d_x, d_y = unpack( matrix_sum( {euler_to_vector(w/2, w_angle)}, {euler_to_vector(h, h_angle)})	)
	elseif	alignment == 3 then
		d_x, d_y = unpack( matrix_sum( {euler_to_vector(w, w_angle)}, {euler_to_vector(h, h_angle)})	)
	elseif	alignment == 4 then
		d_x, d_y = euler_to_vector(h/2, h_angle)
	elseif	alignment == 5 then
		d_x, d_y = unpack( matrix_sum( {euler_to_vector(w/2, w_angle)}, {euler_to_vector(h/2, h_angle)})	)
	elseif	alignment == 6 then
		d_x, d_y = unpack( matrix_sum( {euler_to_vector(w, w_angle)}, {euler_to_vector(h/2, h_angle)})	)
	elseif	alignment == 7 then
		d_x, d_y = 0,0
	elseif	alignment == 8 then
		d_x, d_y = euler_to_vector(w/2, w_angle)
	elseif	alignment == 9 then
		d_x, d_y = euler_to_vector(w, w_angle)
	else
		aegisub.debug.out(string.format("Error, alignment '%s' not recongised.\n",params['an'][1]))
	end
	
	if debug_level > 0 then
		aegisub.debug.out(string.format("%s\n",print_r({d_x,d_y},"dx, dy")))
	end
	
	--generate coord[1]
	coords[1][1] = params['pos'][1] + d_x
	coords[1][2] = params['pos'][2] - d_y -- minus to account for backwards y axis in subs
	
	if debug_level > 0 then
		aegisub.debug.out(string.format("%s\n",print_r(coords[1],"coords[1]")))
	end
	
	
	--calc other co-ords based on this:
	local w_vector = {euler_to_vector(w, params['frz'][1])}
	local h_vector = {euler_to_vector(h, params['frz'][1] - 90 )}
	--invert the y of each
	w_vector[2] = - w_vector[2]
	h_vector[2] = - h_vector[2]
	
	coords[2] = matrix_sum(coords[1], w_vector)
	coords[3] = matrix_sum(coords[1], w_vector, h_vector)
	coords[4] = matrix_sum(coords[1], h_vector)
	
	--Some slight adjustments may need to be made to the co-ords.
		-- \shad throws co-ordinates off...
	
	if debug_level > 0 then
		aegisub.debug.out(string.format("%s\n",print_r(coords,"All coords")))
	end
	
	return coords
end

function split_at_override_tags(str)
--Purpose:	Split line up into substrings at each override tag.
--return:	Arrays of text and tags with aligned indexes. so tags[2] are tags for text[2], even if text[1] had no tags 
	local tags, text = {},{}
	local x = 1
	
	while str:len() > 0 do 	-- while there's still text in the string.
	
		--have to add new sub arrays to text and tags for each itteration
		table.insert(text,"")
		table.insert(tags,"")
		
		local start, stop = str:find("{(.-)}")			-- 'lazy' find of tag
		if not (start == nil) then
			if not (start == 0) then
				if x == 1 then --account for lines that start with text before first override tag
					x = x + 1
					table.insert(text,"") --have to add more lines
					table.insert(tags,"")					
				end 
				text[x-1] = str:sub( 0, start-1)	--put text into text array
			end
			--put tag into tag array
			tags[x] = str:sub(start, stop)
			--get rid of processed portion
			str = str:gsub(lib.escape_lua_pattern(str:sub( 0, stop)),"")
		else --no more matches
			if x == 1 then --account for lines that start with text before first override tag
				x = x + 1
			end
			text[x-1] = str	--put remaining text into array
			--get rid of processed portion
			str = str:gsub(lib.escape_lua_pattern(str),"")
		end 
		
		x = x + 1
	end
	
	--cleanup any blank elements
	for x,y in ipairs(text) do
		if (text[x] == "" and tags[x] == "") then
			table.remove(text, x)
			table.remove(tags, x)
		end
	end
	
	return text, tags
end

function getOverrideParamsFromTags(tag_string)
--Purpose:	output array of override parameters in the given string
--output:	table of values indexed by tag id.
	local params = {}
	
	-- 1) strip out \t transforms first as these will confuse the rest of the process
		--check for occurrence of "\t("
	local bracket_count
	local t_start, t_end = string.find(tag_string,"\\t%(")
	
	local x = 0
	while (not (t_start == nil))do
		bracket_count = 0
		t_end = t_end + 1
		while not (tag_string:sub(t_end,t_end) == ")" and bracket_count == 0) do
			if tag_string:sub(t_end,t_end) == "(" then
				bracket_count = bracket_count + 1
			elseif tag_string:sub(t_end,t_end) == ")" then
				bracket_count = bracket_count - 1
			end
			t_end = t_end + 1
		end
		--store the \t string somewhere?
		
		--delete the string from tag_string
		tag_string = tag_string:gsub(lib.escape_lua_pattern(tag_string:sub(t_start,t_end)),"")
		
		--detect next tag
		t_start, t_end = string.find(tag_string,"\\t%(")
		x = x+1
	end
	
	-- 2) get any text-param tags (eg/ '\fn', 'clip'(as that can be vectors))
	local tags_with_text_params = {'fn', 'clip', 'iclip'}
	local whole_cap
	for _,text_tag in ipairs(tags_with_text_params) do
		for whole_cap, tag_param in string.gmatch(tag_string, "(\\"..text_tag.."%(-([^%)%(\\}]+)%)*)") do 

			params[text_tag] = string_split(tag_param, ",")
			--remove from string
			tag_string = tag_string:gsub(lib.escape_lua_pattern(whole_cap),"")
		end
	end
	
	
	-- 3) Get colour based tags
	for tag, tag_param in string.gmatch(tag_string, "\\(%d-[ca])&H([%d%a]-)&") do 
		params[tag]=string_split(tag_param, ",")
	end
	
	-- 4) get data from remaining tags
	for tag, tag_param in string.gmatch(tag_string, "\\(%a+)%(-([%-%d%.,]+)") do 
		params[tag]=string_split(tag_param, ",")
		
		--format the data:
		for i,data in pairs(params[tag]) do
			if not (tag_list[tag] == nil) then
				if tag_list[tag]["type"] == "float" or tag_list[tag]["type"] == "int" then
					params[tag][i] = tonumber(data)
				end
			else
				if debug_level > 0 then
					aegisub.debug.out(string.format("Parameter '%s' not specified in tag_list\n",tag))
				end
			end
		end
	end
	
	
	-- 5) Profit
	return params
end

function getParamsFromStyle(style)
--Purpose:	Gets styling from current style object and converts to parameters
	local params = {}
	
	if debug_level>0 then
		aegisub.debug.out(string.format("From style %s\n",print_r(style," ")))
	end
	
	for key,val in pairs(style) do
	
		if debug_level>0 then
			aegisub.debug.out(string.format("looking for '%s' in translation table\n",key))
			aegisub.debug.out(string.format("\t style_translator[%s] is %s \n",key, print_r(style_translator[key]," ")))
		end
		
		if not (style_translator[key] == nil) then --make sure style is specified
			
			if debug_level>0 then
				aegisub.debug.out(string.format("\t style_translator[%s]['param'] is %s \n",key, print_r(style_translator[key]["param"]," ")))
			end
			
			if not (style_translator[key]["param"] == nil) then --only process if style translation exists
				params[style_translator[key]["param"]] = style_val_to_param_val(key, val)
			end
		else
			
		end 
	end
	
	if debug_level>0 then
		aegisub.debug.out(string.format(" We got the %s\n",print_r(params,"params")))
	end
	
	return params
end

function getDefaultPos(subs, align)
--Purpose:	Calculate and return the default origin position for text
local x, y = 0, 0

--[[
WORK TO DO:
1) Get script resolution
2) determine 0 margin alignment position.
3) Account for style margins
4) Never bother accounted for word wrap, because fuck that.
--]]

	return x,y
end


--------------------
--Style editors
--------------------
function applyParamstoStyle(style, params)
--Purpose:	Applied the supplied parameters to the supplied style object
	if debug_level > 0 then
		require 'print_r'
		aegisub.debug.out(string.format("%s\n",print_r(params, "Applying")))
	end
	
	
	for tag, data in pairs(params) do
		if not (tag_list[tag] == nil) then
			if not (tag_list[tag]["style"] == nil) then --only process if tag translation exists
				if debug_level > 0 then
					aegisub.debug.out(string.format("Param %s is applied to style %s\n",tag,tag_list[tag]["style"]))
				end
				style[tag_list[tag]["style"]] = param_val_to_style_val(tag, data)
			end
		else -- parameter not specified in tag_list
			if debug_level > 0 then
				aegisub.debug.out(string.format("Parameter '%s' not specified in tag_list\n",tag))
			end
		end 
	end
	
	return style

end

function param_val_to_style_val(tag, data)
--Purpose:	Converts override tag data to style value (where necessary)
	local ret = ""
	
	if tag_list[tag] == nil then
		aegisub.debug.out(string.format("Chololib: Tag '%s' data conversion not supported.\n",tag))
		return data[1]
	end
	
	if tag_list[tag]["type"] == "bool" then
		if data[1] == 1 then
			return true
		else
			return false
		end
	
	-- elseif tag_list[tag]["type"] == "<type>" then
	
--[[
WORK TO DO
	- add section to handle colour changes.
--]]
			
	else
		--generate var list:
		for i = 1, tag_list[tag]["par_c"] do
			if not ( data[i] == nil ) then
				if i > 1 then
				 ret = ret..","
				end
				ret = ret..data[i]
			end
		end
		return ret
	end
end

function style_val_to_param_val(key,val)
--Purpose:	
	local ret = {}
	
	if style_translator[key]["param"] == nil then
		aegisub.debug.out(string.format("Chololib: style '%s' data conversion not supported.\n",key))
		return val
	end
	
	if debug_level>0 then
		aegisub.debug.out(string.format("\n%s\n%s\n",print_r(key,"key"),print_r(val,"val")))
		aegisub.debug.out(string.format("\n%s\n",print_r(tag_list[style_translator[key]["param"]],tag_list[style_translator[key]])))
	end
	
	if tag_list[style_translator[key]["param"]]["type"] == "bool" then
		if val == true then
			table.insert(ret, 1)
		else
			table.insert(ret, 0)
		end
	else 
		table.insert(ret, val) 
	end
	
	return ret
end

---------------------
-- Data collectors
---------------------
function getStyles(subs)
--Purpose:	get the styles present in the subtitle file:

	--Acquire styles:
	require "karaskel"	--note: look for a way to get styles that isn't karaskel
	local meta, styles = karaskel.collect_head(subs)
	
	return styles
end

function getStyle(subs, style_name)
--Purpose:	get a specific style file
	local s = getStyles(subs)
	return s[style_name]
end


--------------------
-- Misc Functions --
--------------------
function string_split(str, delim)
--Purpose: Split string by delimiter. Delimiter can be multi-character (such as "\\N") and can also be a pattern if you want.
	
	local ret={}
	
	while str:len() > 0 do 	-- while there's still text in the string.
		local start, stop = str:find(delim)			-- look for delimi
			if(debug_level >0) then
				if start == nil then
					aegisub.debug.out("No more split positions found\n")
				else
					aegisub.debug.out(string.format("Splitting at %d - %d\n",start, stop))
				end
			end
		if start == nil then -- no more delims in string.
			table.insert(ret, str)		-- add the last chunk of the string
			str = str:gsub(lib.escape_lua_pattern(str),"")		-- clear string to exit loop
		else
			table.insert(ret, str:sub( 0, start-1))		-- get the string up until deliminator
			str = str:gsub(lib.escape_lua_pattern(str:sub( 0, stop)),"")		-- delete the substring from main string.
		end 
	end
	
	
	return ret

end

function lib.escape_lua_pattern(str)
--Purpose:	escape a string so find/gsub/gmatch doesn't treat it like a pattern. (Necessary if your string contains brackets or dots or lots of things really)
--Returns:	escaped string 
  local matches =
  {	--table of characters requiring escapes and their escape patterns
    ["^"] = "%^";
    ["$"] = "%$";
    ["("] = "%(";
    [")"] = "%)";
    ["%"] = "%%";
    ["."] = "%.";
    ["["] = "%[";
    ["]"] = "%]";
    ["*"] = "%*";
    ["+"] = "%+";
    ["-"] = "%-";
    ["?"] = "%?";
    ["\0"] = "%z";
  }
    return (str:gsub(".", matches))
end

--Misc Math

function euler_to_vector(r, angle)
--purpose:	convert vector in form <distance><angle(degrees)> to form <dx><dy>
	local x,y
	
	if(debug_level >0) then
		aegisub.debug.out(string.format("Length %g at angle %d produces vector:",r, angle))
	end
	--convert the angle from degrees to radians:
	angle = angle * math.pi/180
	
	x = r*math.cos(angle)
	y = r*math.sin(angle)
	
	if(debug_level >0) then
		aegisub.debug.out(string.format("(%g, %g)\n",x,y))
	end
	
	return x, y 
end

function matrix_sum(...)
--Purpose:	Sums entries from two tables and outputs result
	local arrays={...}
	local sum={}
	
	for i, x in pairs(arrays[1]) do
		sum[i]=0
		for j= 1, table.getn(arrays) do
			sum[i] = sum[i] + arrays[j][i]
		end
	end
	
	return sum 
end


----------------------------------------------------
---------[[END OF LIBRARY]]-------------------------
----------------------------------------------------

--return my functions to the includer
--Due to limitations, return a function that then returns all the modules to load.
local function load_lib(...)

	local arg={...}
	--sort through arguments
	
	for i = 1, table.getn(arg) do
		if arg[i] == "debug_level" then
			if not (aegisub.debug == nil) then
				aegisub.debug.out(string.format("Setting Debug level to %d\n", arg[i+1]))
			end
			debug_level = arg[i+1]
			i = i + 1 
		end
	end
	--Initialise globals:
	if debug_level > 0 then
		require 'print_r'
	end
	
	--randomise the seed
	math.randomseed( os.time() )
	
	
	--return this library
	return lib
end

return load_lib