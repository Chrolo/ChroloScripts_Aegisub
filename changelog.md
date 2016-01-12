##Changelog

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
 
 
##To do
- [ ] Get fancy and put dep control into my stuff

###Alignment Macro
- [ ] have macro change \move tags appropriately aswell.
- [ ] Figure out why line shifts slightly down when different fonts are present, but when cycled all the way through  still returns to start position (possibly indicating it's not a bounding box issue?)

###Lib stuff
- [ ] Improve chrolo.lib's TextBound function to handle: \shad, \fax, \fry, \frx... etc
- [ ] Add ability to determine default line position when \pos not specified.
- [ ] Turns out some tags, like \fad, will apply to the whole line no matter where they're placed. My current setup can't handle this...

###KFX lib stuff
- [ ] Change how shuffle text's extra data is prepended

- [ ] actually do kfx for a show to test my stuff

- [ ] add millions more effects to the effect library

- [ ] get "QuickKFX" up to a working standard (soon™)

###Misc
- [ ] get used to github markdown language