--Realising I was going to create a tonne of reusable code and functions, I present this:
-- Chrolo's Library --
script_name = "Chrolo's Library."
script_description = "When you need something done, check everywhere else first, then here."
script_author = "Chrolo"
script_version = "1.0.0"
script_namespace = "chrolo.lib"

local util = require 'aegisub.util'

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

["frz"]		={ ["type"] = "float",	["style"] = "angle",	["par_c"] = 1,	["desc"] = "Z-rotation"		},
["fscx"]	={ ["type"] = "float",	["style"] = "scale_x",	["par_c"] = 1,	["desc"] = "Horizontal Scaling"		},
["fscy"]	={ ["type"] = "float",	["style"] = "scale_y",	["par_c"] = 1,	["desc"] = "Vertical Scaling"		},

["b"]	={ ["type"] = "bool",	["style"] = "bold",			["par_c"] = 1,	["desc"] = "Bold"		},
["u"]	={ ["type"] = "bool",	["style"] = "underline",	["par_c"] = 1,	["desc"] = "Underlined"		},
["i"]	={ ["type"] = "bool",	["style"] = "italic",		["par_c"] = 1,	["desc"] = "Italics"		},

--Non Style tags:
--[""]	={ ["type"] = "",	["par_c"] = ,	["desc"] = ""},
["fade"]	={ ["type"] = "time",	["par_c"] = 7,	["desc"] = "Complex fade"},
["pos"]		={ ["type"] = "float",	["par_c"] = 2,	["desc"] = "Position of Line"		},
["move"]	={ ["type"] = "float",	["par_c"] = 6,	["desc"] = "Movement of line"		},

["clip"]	={ ["type"] = "text",	["par_c"] = 1,	["desc"] = "Clip"		},
["iclip"]	={ ["type"] = "text",	["par_c"] = 1,	["desc"] = "Inverse Clip"		},

["blur"]	={ ["type"] = "float",	["par_c"] = 1,	["desc"] = "Gaussian Edge Blur"},
	
["frx"]	={ ["type"] = "float",	["par_c"] = 1,	["desc"] = "X-Rotation"},
["fry"]	={ ["type"] = "float",	["par_c"] = 1,	["desc"] = "Y-Rotation"},
["fax"]	={ ["type"] = "float",	["par_c"] = 1,	["desc"] = "X-Shear"},
["fay"]	={ ["type"] = "float",	["par_c"] = 1,	["desc"] = "Y-Shear"},

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
	local cur_overrides = {}
	--Make a local copy of the style used for this line.
	local this_style = getStyle(subs, line.style)
	
	--Split lines at every '\N'
	local t_lines = lib.string_split(line.text,"\\N")
	
	for i,i_line in ipairs(t_lines) do
		local t_w, t_a, t_d = 0, 0, 0
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
			table.insert(sub_parts[i],j,{["params"]={}})
			
			--customise style based on found tags
			local param_updates = getOverrideParamsFromTags(t_subTags[j])
			this_style = applyParamstoStyle(this_style, param_updates);
			
			--copy overrides in current overrides variable
			for tag, data in pairs(param_updates) do			--then update them for this time
				cur_overrides[tag] = data;
			end
			
			if debug_level > 0 then
				aegisub.debug.out(string.format("%s\n",print_r(cur_overrides,"Current Overrides")))
			end
			
			--put params for this line into array
			sub_parts[i][j]["params"] = util.deep_copy(cur_overrides) --copy in the params from last time

			
			
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
			
			--height is slightly more involved. Fonts may have different lengths above/below the mid-line for a given size. 
			--ie/	arial 60pt has descent: 11.375   and ascent: 48.625
			--	 arno pro 60pt has descent: 18.09375 and ascent: 41.90625
			-- if they're on the same line together, the line height is actually 48.625 + 18.09375 = 66.71875 (!= 60)
			local accent = height - descent
			t_a = math.max(t_a, accent)		-- figure out tallest accender
			t_d = math.max(t_d, descent)	-- figure out lowest descender
			
			
			if debug_level >0 then
				aegisub.debug.out(string.format("Line width is %g \t line height is %g\n",t_w, t_a + t_d))
			end
			
		end	--loop though sub components of lines 
		
		--add total line height and width to the misc data:
		sub_parts[i]['height'] = (t_a + t_d)
		sub_parts[i]['width'] = t_w
		
		
		h = h + (t_a + t_d)		-- add on the height of the last line
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
--returns:	{{x1,y1},{x2,y2},{x3,y3},{x4,y4}}, where co-ordinates are numbered clockwise from top-left

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
		params['pos'] = {getDefaultPos(subs, getStyle(subs, line.style), params['an'][1])}
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
		d_x, d_y =  lib.polar_to_cartesian(h, h_angle)
	elseif	alignment == 2 then
		d_x, d_y = unpack( lib.matrix_sum( { lib.polar_to_cartesian(w/2, w_angle)}, { lib.polar_to_cartesian(h, h_angle)})	)
	elseif	alignment == 3 then
		d_x, d_y = unpack( lib.matrix_sum( { lib.polar_to_cartesian(w, w_angle)}, { lib.polar_to_cartesian(h, h_angle)})	)
	elseif	alignment == 4 then
		d_x, d_y =  lib.polar_to_cartesian(h/2, h_angle)
	elseif	alignment == 5 then
		d_x, d_y = unpack( lib.matrix_sum( { lib.polar_to_cartesian(w/2, w_angle)}, { lib.polar_to_cartesian(h/2, h_angle)})	)
	elseif	alignment == 6 then
		d_x, d_y = unpack( lib.matrix_sum( { lib.polar_to_cartesian(w, w_angle)}, { lib.polar_to_cartesian(h/2, h_angle)})	)
	elseif	alignment == 7 then
		d_x, d_y = 0,0
	elseif	alignment == 8 then
		d_x, d_y =  lib.polar_to_cartesian(w/2, w_angle)
	elseif	alignment == 9 then
		d_x, d_y =  lib.polar_to_cartesian(w, w_angle)
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
	local w_vector = { lib.polar_to_cartesian(w, params['frz'][1])}
	local h_vector = { lib.polar_to_cartesian(h, params['frz'][1] - 90 )}
	--invert the y of each
	w_vector[2] = - w_vector[2]
	h_vector[2] = - h_vector[2]
	
	coords[2] = lib.matrix_sum(coords[1], w_vector)
	coords[3] = lib.matrix_sum(coords[1], w_vector, h_vector)
	coords[4] = lib.matrix_sum(coords[1], h_vector)
	
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
	
	-- 2) get any text-param tags (eg/ '\fn', 'clip'(as they can be vectors))
	local tags_with_text_params = {'fn', 'clip', 'iclip'}
	local whole_cap
	for _,text_tag in ipairs(tags_with_text_params) do
		for whole_cap, tag_param in string.gmatch(tag_string, "(\\"..text_tag.."%(-([^%)%(\\}]+)%)*)") do 

			params[text_tag] = lib.string_split(tag_param, ",")
			--remove from string
			tag_string = tag_string:gsub(lib.escape_lua_pattern(whole_cap),"")
		end
	end
	
	
	-- 3) Get colour based tags
	for tag, tag_param in string.gmatch(tag_string, "\\(%d-[ca])(&H[%d%a]-&)") do 
		params[tag]=lib.string_split(tag_param, ",")
	end
	
	-- 4) get data from remaining tags
	for tag, tag_param in string.gmatch(tag_string, "\\(%a+)%(-([%-%d%.,]+)%)-") do 
		params[tag]=lib.string_split(tag_param, ",")
		
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

function lib.getOverrridesWithoutStyle(params, style)
--Purpose:	Returns only the parameters that aren't already covered by the style passed.
	local new_params={}
	
	local style_params=getParamsFromStyle(style)
	
	--go through params
	for tag,data in pairs(params) do
		
		if not ( tag_list[tag] == nil) then --make sure it's in the tag list
			if not ( tag_list[tag]["style"] == nil) then	--make sure a translation exists
				if debug_level>0 then
					aegisub.debug.out(string.format("Param value is `%s` \t and style_params[%s] is `%s` \n",data, tag , style_params[tag]))
				end
				if not ( compare_tables(data,style_params[tag]) ) then --if the parameter value is not same as value in style
					new_params[tag] = data
				end
			else
				if debug_level>0 then
					aegisub.debug.out(string.format("No tag->style translation found for `%s`\n",tag))
				end
			end 
		end
	end --end of loop
	
	return new_params
end

function getDefaultPos(subs, style, ...)
--Purpose:	Calculate and return the default origin position for text
--Inputs:	Subs file, style object,< align, margin changes >
	local x, y = 0, 0
	local ad_args={...}

	require "karaskel"	--note: look for a way to get styles that isn't karaskel
	local meta = karaskel.collect_head(subs)
		
	--sort through ad_args
	for i,data in ipairs(ad_args) do
		if i == 1 then
			style["align"] = data
		end
	end
	
	if debug_level>0 then
		aegisub.debug.out(string.format("%s\n",print_r(ad_args,"ad_args")))
		aegisub.debug.out(string.format("%s\n",print_r(meta,"meta data")))
		aegisub.debug.out(string.format("%s\n",print_r(style,"style data")))
		aegisub.debug.out(string.format("Align is: %d\n",style["align"]))
		
	end
	
	--resolution is 'meta.res_x' and 'meta.res_y'
	
	--determine 0 margin alignment:
	if debug_level>1 then
		aegisub.debug.out(string.format("if values are: %d %d\n",style.align%3,math.floor((style.align-1)/3)))
	end

	--x value:
	if style.align%3 == 0 then		--\an 3, 6, 9 are right aligned
		x = meta.res_x
	elseif style.align%3 == 2 then	--\an 2, 5, 8 are center aligned
		x = meta.res_x/2
	elseif style.align%3 == 1 then	--\an 1, 4, 7 are left aligned
		x = 0
	end
		--y value:
	if math.floor((style.align-1)/3) == 0 then --
		y = meta.res_y
	elseif math.floor((style.align-1)/3) == 1 then
		y = meta.res_y/2
	elseif math.floor((style.align-1)/3) == 2 then
		y = 0
	end
	
	--Adjust for margins:
	
	
	--[[
	WORK TO DO:
	--1) Get script resolution
	--2) determine 0 margin alignment position.
	3) Account for style margins
	4) Never bother accountting for word wrap, because fuck that.
	--]]

	if debug_level>0 then
		aegisub.debug.out(string.format("Default pos is: %d %d\n",x,y))
	end
	
	return x,y
end


-------------------
-- Style editors --
-------------------
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
				--check for colour tags:
				local c = tag_list[tag]["style"]:match("color(%d)")
				if c then
					--detected a colour tag, which needs to be handled differently
					
				else
					style[tag_list[tag]["style"]] = param_val_to_style_val(tag, data)
				end
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
	elseif tag_list[tag]["type"] == "color" then
		return string.sub(data[1],3,8); -- return the middle of &H------&

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
--Purpose:	Take a value from a style parameter and return a value (or values) for the asociated param
	local ret = {}
	
	if style_translator[key]["param"] == nil then
		aegisub.debug.out(string.format("Chololib: style '%s' data conversion not supported.\n",key))
		return val
	end
	
	if debug_level>1 then
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

function params_to_tags(params)
--Purpose:	Take in a set of params and output a tag string
--returns:	tag string (ie/ '\frz-5\fscx120' )
	local str=""
	
	for tag, data in pairs(params) do
		--add tag to string
		str=str.."\\"..tag;
		--check if multiple params:
		if not(tag_list[tag] == nil) then
			if(tag_list[tag]['par_c']>1) then
				--prepend brackets:
				str=str.."(";
				for i,x in ipairs(data) do
					--prepend comma apart from first data set
					if not (i==1) then str=str..","; end
					--add data
					str=str..x;
				end
				--close brackets
				str=str..")";
			else
				--only one parameter:
				str=str..data[1];
			end
		else --tag not known
			if debug_level>0 then
				aegisub.debug.out(string.format("tag_list['%s'] not found\n",tag));
			end	
			--default to '\<tag><data[1]>'
			str=str..data[1];
		end		
		
	end
	
	return str
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

function lib.getLineInfo(subs, line)
--Purpose:	Return some standard information about a line.
--Inputs:	Subtitle file, line object
--Returns: array of {["an"],["pos"],["style"],["frz"]}
	local ret={}
	
	--Get style object
	ret["style"] = getStyle(subs, line.style)
	
	--get the params from the style:
	local params = getParamsFromStyle(ret["style"])
	
	--get alignment:
		--get style default:
	ret["an"] = unpack(params["an"])
		--check for override in line:
	if line.text:find("\\an%d") then
		ret["an"] = tonumber(line.text:match("\\an(%d)"))
	end
	
	--get line position
		--get style default:
	ret["pos"] = {getDefaultPos(subs, ret["style"] ,ret["an"])}
		--check for override in line:
	if line.text:find("\\pos%([^%)]+%)") then
		ret["pos"] = {line.text:match("\\pos%(([%d.-]+),([%d.-]+)%)")}
	end
	
	--get rotation
		--get style default:
	ret["frz"] = unpack(params["frz"])	
		--check for override
	if line.text:find("\\frz([%d-.]+)") then
		ret["frz"] = tonumber(line.text:match("\\frz([%d-.]+)"));
	end
		
	
	if debug_level>1 then
		aegisub.debug.out(string.format("%s\n",print_r(ret,"LineInfo:")));
	end
	
	return ret
end
--------------------
-- Line modifiers --
--------------------
function lib.add_tags_to_line(line_text, tags)
--Purpose:	Wrapper for "add_params_to_line" that accepts tag list instead.
local params = getOverrideParamsFromTags(tags);
return lib.add_params_to_line(line_text,params)

end 

function lib.add_params_to_line(line_text,params)
--Purpose:	Add the given parameters to the beginning of the given line_text. Process is addative: no tags are removed, existing tags are updated and new tags are added.
--input:	Line text, Parameters (as array of with named indeces)

	local texts, tags = split_at_override_tags(line_text)
		
	
	if(debug_level >0) then
		aegisub.debug.out(string.format("Splits: %s\n",print_r({["texts"]=texts, ["tags"]=tags},"")))
	end
	
	--we only add params to first tag
	tags[1]="{"..add_replace_tags(tags[1]:sub(2,-2),params).."}"; --strip curly brackets for funciton, but replace afterward
	
	--rejoin up the line.
	local new_line_text="";
	for i,x in ipairs(texts) do
		new_line_text = new_line_text..tags[i]..texts[i];
	end
--[[
WORK TO DO
--]]

	return new_line_text;
end

function add_replace_tags(tag_string,params)
--Purpose:	Scan through given tags text, updating/adding values present in the 'params' array
--return:	updated string
	
	--foreach parameter in array:
	for tag, data in pairs(params) do
		--look for a match in the text:
		if string.find(tag_string,"\\"..tag.."[^%\\}]+") then
			
			--replace the occurence with new values:
			local x,y = string.find(tag_string, "\\"..tag.."[^%\\}]+");
				--debug output:
				if(debug_level >0) then
					aegisub.debug.out(string.format("Tag '%s' found at position %d,%d\n",tag,x,y));
					aegisub.debug.out(string.format("Replacing `%s` with `%s`\n",tag_string:sub(x,y),params_to_tags({[tag]=data})));
				end
			tag_string = tag_string:gsub(lib.escape_lua_pattern(tag_string:sub(x,y)),params_to_tags({[tag]=data}));

		--[[
		WORK TO DO
		--]]
		else
			--tag not found: append to tag string
			tag_string = tag_string..params_to_tags({[tag]=data});
		end
	
	end
--[[
WORK TO DO
--]]
	return tag_string;
end


--------------------
-- Misc Functions --
--------------------
function lib.string_split(str, delim)
--Purpose: Split string by delimiter. Delimiter can be multi-character (such as "\\N") and can also be a pattern if you want.
	
	local ret={}
	
	while str:len() > 0 do 	-- while there's still text in the string.
		local start, stop = str:find(delim)			-- look for delimi
			
			if(debug_level >2) then
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

function compare_tables(table_1, table_2)
--Purpose:	Look through 2 tables and return true if they're the same
	for i, data in pairs(table_1) do
		if not(table_1[i]==table_2[i]) then --should probably check for table references and add some recursion
			return false
		end
	end
	return true
end

--------------
--Misc Math --
--------------
function  lib.polar_to_cartesian(r, angle)
--purpose:	convert vector in form <distance><angle(degrees)> to form <dx><dy>
	local x,y
	
	if(debug_level >2) then
		aegisub.debug.out(string.format("Length %g at angle %d produces vector:",r, angle))
	end
	--convert the angle from degrees to radians:
	angle = math.rad(angle)
	
	x = r*math.cos(angle)
	y = r*math.sin(angle)
	
	--because of the degree -> radian transformation, these calcs have floating point inaccuaracies
	-- ie/ at 90 degrees we still get some x > 0 (around 1e-15)
	-- still, it fucks around with some calcs, so let get rid of it:
	local precision = 6 --6 places is double the precision used in standard pos tags, should be alright
	x = roundDecimal(x,precision) 
	y = roundDecimal(y,precision)
	
	if(debug_level >0) then
		aegisub.debug.out(string.format("(%g, %g)\n",x,y))
	end
	
	return x, y 
end

function lib.matrix_sum(...)
--Purpose:	Sums entries from two (or more) tables and outputs result
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

function roundDecimal(num,places)
--Purpose: Round a number to a given amount of decimal places:
	local mult = 10^places
	return math.floor(num * mult + 0.5) / mult
end
----------------------
--QuickTestFunciton---
----------------------

--So I can test local functions without making them global:
function lib.test()
require 'print_r'

--test data:
local str="\\fnParisish\\blur0.6\\c&H141410&\\b1\\fscx27.594\\fscy27.594\\fax0.05\\frx6\\fry354\\frz7.436\\pos(527,338)";

--test function:
local params = getOverrideParamsFromTags(str);

local new_str =  lib.add_params_to_line("{\\frx20\\fsp6\\c&HFFFFFF&}Test{\\fax3}Line",params);

--output some debug text:
aegisub.debug.out(string.format("original:\n%s\n",str));
aegisub.debug.out(string.format("%s\n",print_r(params,"Params")));
aegisub.debug.out(string.format("new line:\n%s\n",new_str));

end
--------------


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