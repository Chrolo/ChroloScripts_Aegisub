--[[ 
Chrolo's Quick KFXer
------------------------------
So this was an idea I had whilst learning to KFX. It's a simple tool to spit out some useful karaoke templates for your k-timed lines.
This will never replace having an actually KFXer, but should allow people/groups to easily add simple KFX to their scripts.

Project goals:
-bank of atleast 3 basic effects for each of entrance/constant/exit/sylable
-detect style from selected line for template style

--long term goals
---Easy interface
---implement hue rainbow
]]
script_name = "Quick KFX"
script_description = "Add instant KFX to your script!"
script_author = "Chrolo"
script_version = "0.0.0"

--includes:
util = require 'aegisub.util'
local libLoad = require'chroloKfxLib'
local libChroloKfx , eff_lib = libLoad()

require 'print_r' --useful for debug: http://www.hpelbers.org/lua/print_r

local KFX_options=
{
	openingfx={
		"None",		"Slide Left",	"Slide Right",		"Slide Up",		"Slide Down",
		"fry in",	"frx in",		"Newsletter Twirl",
		}
	,
	constantfx={
		"None",		"Shuffle",		"LRBounce",			"Rainbow",
		}
	,
	exitfx={
		"None",		"Wave",			"Fly Up",
		}
	,
	sylfx={
		"None",		"Drop in",		"NewsTwirl",
		}
}

function Quick_KFX_main(subs,sel)

	--check for styles in selection:
	local selection_styles = {}
	local loop = 1
	local bool_flag = true
	for _,i in ipairs(sel) do
	
		--check style not already found
		bool_flag = true
		for index, style in ipairs(selection_styles) do
			if style==subs[i].style then
				bool_flag = false
			end
		end
		
		if bool_flag then
			selection_styles[loop]=subs[i].style
			loop = loop + 1
		end
		
		
	end
	---[[
	--debug
	aegisub.debug.out(string.format('%s\n', print_r(selection_styles,"selection_styles")))
	--]]
	
	
	
	--present options
	
	--setup initial dialog
	init_dialog = {
		--Line entrance choice:
		{class="label", label="Entrance		", x=0, y=0},
		{class="dropdown", name="entrancefx", items = KFX_options.openingfx, x=0, y=1, value="None"},
		--Line constant choice:
		{class="label", label="Constant		", x=1, y=0},
		{class="dropdown", name="constantfx", items = KFX_options.constantfx, x=1, y=1, value="None"},
		--Line exit choice:
		{class="label", label="Exit			", x=2, y=0},
		{class="dropdown", name="exitfx", items = KFX_options.exitfx, x=2, y=1, value="None"},
		--global options:
		{class="checkbox", label="Process KFX", name="opt_process_kfx", x=0, y=2, value="None"},
		
	}
	--display the init dialog
	btn, dialog_result = aegisub.dialog.display(init_dialog,
		{"Next", "Cancel"},
		{ok="Next", cancel="Cancel"}
	)
	
	--if user cancelled, cancel...
	if not btn then
		aegisub.cancel()
	end
	
	--process the results
		--debug out:
		---[[
		local temp_str
		if dialog_result.opt_process_kfx then
			temp_str="yes"
		else
			temp_str="no"
		end
		aegisub.debug.out(string.format('Entrance selected: %s\nConstant selected: %s\nPre-process?  %s\n', dialog_result.entrancefx, dialog_result.constantfx,temp_str))
		--]]
		
	--process entrance choice:
	if not dialog_result.entrancefx=="None" then
		--determine and load the entrance KFX
		if dialog_result.entrancefx=="Newsletter Twirl" then
			local ent_fx=eff_lib.Twirl_In
		end
		
		--process the KFX
		
	end --end of "If entrance KFX not blank"
	
	
end

aegisub.register_macro(script_name, script_description,Quick_KFX_main)