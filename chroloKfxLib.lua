--[[
Chrolo's KFX library (in no particular order)
--]]
--requires
local util = require 'aegisub.util'
--all functions will be M.<function>
local M = {}


--[[------------------------
CONVERSION FUNCTIONS
--]]------------------------
function M.bpm_to_ms(bpm)
	local ms
	
	ms=1000/(bpm/60)
	
	return ms
end

local function hCXMtoRGB(h, C, X, M)
--this handles the last steps for HSL and HSV to RGB transforms
-- outputs rgb in 0-255 range
	local r, g, b

	if h < 60 then
		r = C
		g = X
		b = 0
	elseif h < 120 then
		r = X
		g = C
		b = 0
	elseif h < 180 then
		r = 0
		g = C
		b = X
	elseif h < 240 then
		r = 0
		g = X
		b = C
	elseif h < 300 then
		r = X
		g = 0
		b = C
	elseif h < 360 then
		r = C
		g = 0
		b = X
	else
		r = 0
		g = 0
		b = 0
	end
	
	
	r = (r + M) * 255
	g = (g + M) * 255
	b = (b + M) * 255
	
	return r, g, b
end

function M.HSVtoRGB(h, s, v)
-- Based on formula from https://en.wikipedia.org/wiki/HSL_and_HSV
--h = 0-360		s, v = 0-1
	local C, X , M
	
	--Account for value overflow:
	h = h % 360
	
	C = v*s --chroma
	X = C*(1-math.abs(((h/60)%2)-1))
	M = v - C
	
	return hCXMtoRGB(h, C, X, M)
	
end

function M.HSLtoRGB(h, s, l)
-- Based on formula from https://en.wikipedia.org/wiki/HSL_and_HSV
--h = 0-360		s, l = 0-1
	local C, X, M
	--Account for value overflow:
	h = h % 360

	C =(1-math.abs((2*l)-1))* s
	X = C*(1-math.abs(((h/60)%2)-1))
	M = l - (C/2)
	
	return hCXMtoRGB(h, C, X, M)
end

--[[------------------------
TAG OUTPUTTERS
--]]------------------------
function M.repeating_mod(effect, pulse_width, repeat_length, offset)
--purpose: makes a ton of \t tags to put in a line for repeated effects
--input: 	effect = an effect structure containing the effects needed.
--			pulse_width = length of each repetition (ms)
--			repeat_length = how long to repeat the effect for
--			offset = delay before starting effect (to help match beats)
	local tags = "" 
	local flag = true
	local x = offset
		
	
	while x<repeat_length do --start at offset time, repeat for length of repeat in steps of 0 (because the loop sorts out time adjustment)
		for i, e in ipairs(effect.effects) do
			tags = tags..string.format('\\t(%d,%d,%s)', x, x+(pulse_width*e.fadin),e.tag(effect))
			x = x+(pulse_width*(e.fadin+e.hold))
		end
	end
	
 return tags
end

--[[------------
Effects Library
--]]------------

local EL = {}
--[[
General Effect format:
-----------------------
	EL.<effect_Name>={
	name="<name of effect>",
	desc="<short description>",
	usage="<where it's used: constant, entrance, exit>",
	effects={
				--Note: tag functions should be called with the main <effect_name> as arg_1 ("self").
				{tag=function (self) return <tag string for effect> end,		fadin=<% of pulse to fade in for>,	hold=<% of pulse to hold for>	},
				--eg/
				{tag=function (self) return string.format("\\frz%g\\fscy100",self.params.sway_min) end,	fadin=0.10,	hold=0		},
			},
	params=	{
				<any parameters for the effect>
			},
	<include any functions to modify the effect/ parameters>		
	--eg/	
	setSway = function (self, newVal)
		self.params.sway_max = newVal 
		self.params.sway_min = -newVal
		end,
		
	}
----------------------------------------
--]]


---------------------------------------------
EL.LRBounce={
name="LRBounce",
desc="Bounce from left to right on the beat",
usage="repeated",
effects={
			{tag=function (self) return string.format("\\frz%g\\fscy%g",self.params.sway_min,self.params.bounce) end,		fadin=0.10,	hold=0.10	},
			{tag=function (self) return string.format("\\frz%g\\fscy100",self.params.sway_min) end,							fadin=0.10,	hold=0		},
			{tag=function (self) return string.format("\\frz%g\\fscy100",self.params.sway_max) end,							fadin=0.70, hold=0		},
			{tag=function (self) return string.format("\\frz%g\\fscy%g",self.params.sway_max,self.params.bounce) end,		fadin=0.10,	hold=0.10	},
			{tag=function (self) return string.format("\\frz%g\\fscy100",self.params.sway_max) end,							fadin=0.10,	hold=0		},
			{tag=function (self) return string.format("\\frz%g\\fscy100",self.params.sway_min) end,							fadin=0.70,	hold=0		},
		},
params=	{
			sway_min = -1,
			sway_max =	1,
			bounce =	95
		},	
setSway = function (self, newVal)
	self.params.sway_max = newVal 
	self.params.sway_min = -newVal
	end,

setBounce = function (self, nVal)
	self.params.bounce = nVal
end,	
}

----------------------------------------------
EL.LLRRBounce={
name="LLRRBounce",
desc="Double bounce on each side",
usage="repeated",
effects={
			{fadin=0.10,	hold=0.10	,tag=function (self) return string.format("\\frz%g\\fscy%g",self.params.sway_min,self.params.bounce) end},
			{fadin=0.10,	hold=0.70	,tag=function (self) return string.format("\\frz%g\\fscy100",self.params.sway_min) end},
			{fadin=0.10,	hold=0.10	,tag=function (self) return string.format("\\frz%g\\fscy%g",self.params.sway_min,self.params.bounce) end},
			{fadin=0.10,	hold=0		,tag=function (self) return string.format("\\frz%g\\fscy100",self.params.sway_min) end},
			{fadin=0.70,	hold=0		,tag=function (self) return string.format("\\frz%g\\fscy100",self.params.sway_max) end}, 
			{tfadin=0.10,	hold=0.10	,tag=function (self) return string.format("\\frz%g\\fscy%g",self.params.sway_max,self.params.bounce) end},
			{fadin=0.10,	hold=0.70	,tag=function (self) return string.format("\\frz%g\\fscy100",self.params.sway_max) end}, 
			{fadin=0.10,	hold=0.10	,tag=function (self) return string.format("\\frz%g\\fscy%g",self.params.sway_max,self.params.bounce) end},
			{fadin=0.10,	hold=0		,tag=function (self) return string.format("\\frz%g\\fscy100",self.params.sway_max) end},
			{fadin=0.70,	hold=0		,tag=function (self) return string.format("\\frz%g\\fscy100",self.params.sway_min) end},
		},
params=	{
			sway_min=	-1,
			sway_max=	1,
			bounce = 95,
		},
		
setSway = function (self, nVal)
	self.params.sway_max = nVal 
	self.params.sway_min = -nVal
	end,
	
setBounce = function (self, nVal)
	self.params.bounce = nVal
	end,	

}
-----------------------------------------------------------
EL.Shuffle={
name="Shuffle",
desc="Shuffle Around text",
usage="repeated",
effects={
			{tag= function (self) 
				math.randomseed(math.random())
				return string.format("\\fscx%d\\fscy%d",math.floor((math.random()*(self.params.shuffle_x+1))),(math.floor(math.random()*(self.params.shuffle_y+1)))) 
				end,
			fadin=0,	hold=1},
		},
params=	{
			shuffle_x=	2,
			shuffle_y=	2,
		},
		
setShuffle = function (self, x, y)
	self.params.shuffle_x = x 
	self.params.shuffle_y = y
	end,	

setShuffleFade = function (self, fad)
	if fad > 1 then	aegisub.debug.out("Fade must be <=1") end
	self.effects[1].fadin = fad 
	self.effects[1].hold = (1-fad)
	end,	

}
--------------------------------------------------------------
EL.Twirl_In={
name="Newsletter Twirl",
desc="Text spins and scales into place",
usage="entrance",
effects={
			{tag = function (self) return string.format("\\fscx%g\\fscy%g\\t(0,%d,\\fscx100\\fscy100\\frz%g)",self.params.start_size, self.params.start_size, self.params.in_time, self.params.rotation) end, test="heck"},
		},
params=	{
			in_time	=	100, --in ms
			rotation	=	360,
			start_size	=	20,
		},
setIntime = function(self, nVal)
	self.params.in_time = nVal
	end,
	
setRotations = function(self, nVal)
	self.params.rotation = nVal*360 --convert rotations to degrees
	end,
setStartScale = function(self, nVal)
	self.params.start_size = nVal
	end,
}
---------------------------------------------------------------------

EL.RainbowText={
name="RainbowText",
desc="Cycles through hue rainbow using HSL",
usage="repeated",
effects={
			{tag= function(self) 
				local str= string.format("\\%s%s",self.params.colour_tag, util.ass_color(M.HSLtoRGB(self.params.cur_hue,self.params.cur_sat,self.params.cur_lum)))
				self.params.cur_hue = self.params.cur_hue + self.params.hue_step
				self.params.cur_sat = self.params.cur_sat + self.params.sat_step
				self.params.cur_lum = self.params.cur_lum + self.params.lum_step
				return str
				end,
				fadin=1,	hold=0	},
		},
params=	{
			hue_step = 1,
			cur_hue=0,
			
			sat_step=0,
			cur_sat=0.5,
			
			lum_step=0,
			cur_lum=0.5,
			
			colour_tag="c",
			},
		
setHueOffset = function (self, nVal)
	self.params.cur_hue = nVal
	end,
setHueStep = function (self, nVal)
	self.params.hue_step = nVal
	end,
	
setSatOffset = function (self, nVal)
	self.params.cur_sat = nVal
	end,
setSatStep = function (self, nVal)
	self.params.sat_step = nVal
	end,

setLumOffset = function (self, nVal)
	self.params.cur_lum = nVal
	end,
setLumStep = function (self, nVal)
	self.params.lum_step = nVal
	end,
	
setColourTag = function (self, nVal)
		if nVal==1 then
			self.params.colour_tag = "c"
		else
			self.params.colour_tag = string.format("\\%dc",nVal)
		end
	end,	
setSpeedMultiplier = function(self,nVal)
		if nVal == 0 then
			self.effects[1].fadin=1
		else
			self.effects[1].fadin=(1/nVal)
		end
	end,
}


--------------------------------------------------------------------
--[[------------------------
KFX LINE OUTPUTTERS
--]]------------------------
function M.KFX_line_out(effect,...)
--Generates Line text for KFX, without preceeding or proceeding {}, so they can be concatenated
--variable arguements after effect: 
--	for repeated use {pulse_width, repeat_length, offset}
--	for entrance use {}
	local str=""
	local arg={...}
	
	--determine how to process the effect
	if(effect.usage=="repeated") then 
		str = M.repeating_mod(effect,arg[1],arg[2],arg[3])
		--str = M.repeating_mod(effect,pulse_width,repeat_length,offset)
		
	elseif (effect.usage=="entrance") then
		str = effect.effects[1].tag(effect)
		
	end 
	
	
	--RETURNS
	--shuffle requires a different return
	if effect.name=="Shuffle" then
		return"\\an5"..str.."\\p1}m 0 0 l 0 100 l 100 100 l 0 100 l 0 0{\\fscy\\fscx\\p0"
	else
		return str
	end

end

------------------------------------------------

--[[File end]]
--return my functions to the includer
--Due to limitations, return a function that then returns all the modules to load.
local function load_lib()
	return M, EL
end

return load_lib