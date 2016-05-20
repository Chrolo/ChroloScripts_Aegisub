##Changelog

**19/05/2016**
- Renamed the file names to match macro names
- Chrolo Lib "1.1.4"
	- "getTextBound()" now correctly handles blank lines (one or more \N in a row)
	
**02/04/2016**
- Chrolo Lib "1.1.3"
  - "add_params_to_line" and "rem_params_from_tags" don't fuck up on blank lines
  - Fixed error where multiparamter tags containing same value would only see the value once. ie/ \move(920,410,920,500) kept returning param ["move"]={920,410,500}
  - Added code extract initial positions from \move to use in getLineInfo, getTextBound and other position related functions.
- Change Alignment
  - Now handles \move tags, shifting them appropriately to match new alignment
- Line Splitter
  - Also now handles \move tags appropriately
  
  
**04/02/2016**
- Chrolo Lib
  - getDefaultPos() handles line margins
  - "add_params_to_line" and "rem_params_from_tags" now ignore tags inside '\t' tags and 
  
  
**03/02/2016**
- Misc:
  - Removed the debug print out... sorry guys
  - Relised that my library includes needed to be place __before__ the script info, else the values get overwritten (All my macros were being called "Chrolo's Library"
- Chrolo Lib
  - getParamsFromStyle() extracts a lot more params, including colour tags
  - rem_params_from_tags() allows you to remove certain parameters from a line
  - getOverridesWithoutStyle() now also returns an array of the duplicates, useful to use with the 'new rem_params_from_tags()'
- Change Alignment
  - Fixed dialog to not error if you cancel. (note to self: test fully and read documentation)
  
- Restyler
  - Allows user to change the style of a line, without affecting it's appearence.
  
  
**29/01/2016**
- Chrolo Lib
  - Added new functions to add tags to lines.
  - Added "getLineInfo" which returns some simple line information like it's alignment, position on screen and frz. Takes into account style defaults and overrides
- Line Splitter
  - new macro to split at '\N', maintaining text position on screen
  - Each new line attempts to maintain styling, including overrides present up to split point
- Cycle Alignment
  - Now detected current line alignment and cycles from there.
  - Cycles each line's alignement individually.



**13/01/2016**
- Chrolo lib
  - getTextBound now correctly account for different fonts on the same line, outputting the correct size for the bounding box (Note: this fixes an issue with the Change Alignment macro)


**12/01/2016**
- Change Alignment
  - Forgot to account for negative positions in my gsub. Now it's fine
  
- Chrolo lib
  - getTextBound now also returns the width/height/stylings of all subcomponents of a line

**11/01/2016**
- New "chrolo.lib" file
  - Has various functions to determine size / co ordinates of text
  - will be update with more....
  
- New macro: Change Alignment
  - Aims to change the alignement of text without modifying it's position
  - cannot handle lines without '\pos' set (due to limitations in my library)

**13/10/2015**  
- added blank returns to all effect_lib param functions, so they can be used in kfx codeblocks

------------------------------------
 
##To do

- [ ] Get fancy and put dep control into my stuff
- [x] Rename the files to match the actual macro names...
- [x] Make the "Chrolo>¬macro¬" menu nesting optional

###Alignment Macro
- [ ] make a better dialoug box for the "Change Alignment" macro (because it's shite)
- [x] have macro change \move tags appropriately aswell.
- [x] Figure out why line shifts slightly down when different fonts are present, but when cycled all the way through  still returns to start position (possibly indicating it's not a bounding box issue?)
- [x] Calculate for changes when 2 fonts on same line have varying descenders, causing line height to be bigger than character size.

###Restyler
- [ ] When detecting a change in "\2c, \3c etc." check whether this will actually affect the line. Example: If \bord = 0, don't bother adding \3c or \3a tags 
- [x] Make it ignore '\t' tags (this bug is more to do with underlying "add_params_to_line" and "rem_params_from_tags")

###Line Breaker
- [ ] Fix issue when multiple sequential newlines are present. (Currently creates an empty object, causing script to fail.)

###Lib stuff
- [ ] Improve chrolo.lib's TextBound function to handle: \shad, \fax, \fry, \frx, \shad... etc
- [ ] list EVERY tag and style parameter in `tag_list` and `style_translator`
- [ ] Turns out some tags, like \fad, will apply to the whole line no matter where they're placed. My current setup can't handle this...
- [x] Fix the "add_params_to_line" and "rem_params_from_tags" to ignore tags inside '\t' tags
- [x] Add ability to determine default line position when \pos not specified.
- [x] make a function to add tag values to the first tag set of a line, and to add brackets if none yet exist.
- [x] Makes sure "subparts" return of linebound includes all overrides up to that point


###KFX lib stuff
- [ ] Change how shuffle text's extra data is prepended
- [ ] actually do kfx for a show to test my stuff
- [ ] add millions more effects to the effect library
- [ ] get "QuickKFX" up to a working standard ~~(soon™)~~(never™)

###Misc
- [ ] get used to github markdown language
  - still not understanding how to force newlines...
- [x] Sort out script naming... oops.