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
script_version = "v0"

--includes:
util = require 'aegisub.util'

local KFX_options=
{
	openingfx={
		"None",		"Slide Left",	"Slide Right",		"Slide Up",		"Slide Down",
		"fry in",	"frx in"
		}
	,
	constantfx={
		"None",		"Shake"
		}
	,
	exitfx={
		"None",		"Wave",			"Fly Up"
		}
	,
	sylfx={
		"None",		"Drop in",		"NewsTwirl"
		}
}

function Quick_KFX_main(subs,sel)
	--get if current selected line has style
	
	
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
		
	}
	
	btn, dialog_result = aegisub.dialog.display(init_dialog,
		{"Next", "Cancel"},
		{ok="Next", cancel="Cancel"}
	)
	
	--if user cancelled, cancel...
	if not btn then
		aegisub.cancel()
	end
	
	--process the results
	aegisub.debug.out(string.format('Entrance selected: %s\nConstant selected: %s\n', dialog_result.entrancefx, dialog_result.constantfx))
	
end

aegisub.register_macro(script_name, script_description,Quick_KFX_main)


--[[
--Notes
code for fly up exit: \move($center,$bottom,$center,!0-$bottom!,$ldur,!$ldur+lout!)


]]