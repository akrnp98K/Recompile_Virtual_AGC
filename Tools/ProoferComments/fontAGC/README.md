This folder contains a TrueType font called fontAGC.ttf, as well as the files
I used to generate it.  It is for the purpose of allowing the characters as 
printed on AGC assembly listings to be used in applications other than 
semi-automatic AGC proofing software.  However, it is *not* used by AGC-proofing 
software itself, and needn't be installed for that purpose.

Since the font contains *only* characters from AGC listings, and in particular 
doesn't contain any lower-case letters, its uses are rather specialized.

The font itself was generated by the following multistep process:

1. Use the PNG files for individual characters (in the asciiFont/ folder) to create a single PNG (fontAGC.png) listing them all.
2. Use a program called [glyphtracer.py](https://github.com/jpakkane/glyphtracer) to create a [FontForge](https://fontforge.org/en-US/) file (fontAGC.sfd) from fontAGC.png.
3. Use FontForge to edit the glyphs and to export a TrueType font (fontAGC.ttf) from them.

