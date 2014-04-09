#
# Makefile for CompOrg Project - tile_puzzle
#

#
# Location of the processing programs
#
RASM  = /home/fac/wrc/bin/rasm
RLINK = /home/fac/wrc/bin/rlink
RSIM  = /home/fac/wrc/bin/rsim

#
# Suffixes to be used or created
#
.SUFFIXES:	.asm .obj .lst .out

#
# Object files to be created
#
OBJECTS = skyscrapers.obj

#
# Transformation rule: .asm into .obj
#
.asm.obj:
	$(RASM) -l $*.asm > $*.lst

#
# Transformation rule: .obj into .out
#
.obj.out:
	$(RLINK) -o $*.out $*.obj

#
# Main target
#
skyscrapers.out:	$(OBJECTS)
	$(RLINK) -m -o skyscrapers.out $(OBJECTS) > skyscrapers.map

run:	skyscrapers.out
	$(RSIM) skyscrapers.out
