# Chrolo-Scripts
This is a repo of some scripts and stuff I've been (and will be) working on.  
  
If you want to use it, go ahead. Be warned it may be buggy as shit  

##Change Alignment
########_from Chaotic to Lawful_
-------------------------
This macro allows to change alignment of text whilst (attempting) to maintain it's position on screen.
It doesn't yet account for EVERYTHING, but accounts for text spanning multiple lines with varying scales and fonts in the line.
Also, text on multiple lines will obviously align against the new alignment. Only the widest line won't move.
if you need all the text to stay the same, split the lines by '\N' first, then apply this function.

##Chrolo's Library
You'll need this for my change alignment macro.
Contains a bunch of useful functions, mainly around getting styles and parameters from lines and determine line sizes and bounding boxes co-ordinates.
The whole 'chrolo' folder should be placed in includes.
Maybe I'll get around to added depCtrl onto this all to make it easier.

##Chrolo's KFX Library
This library contains functions and effects to create simple KFX.  
Current Effects:  
- Shuffling Text  
- Rainbow Text  
- Bouncing Text to beat  

##KFXExampleCode
This has some macros you can run to see what the library can do, whilst looking at the code to see how it did it.  
More will be added.


##Chrolo's Quick KFX
This project aims to make KFX available to everyone.  
This is non functional at the moment


