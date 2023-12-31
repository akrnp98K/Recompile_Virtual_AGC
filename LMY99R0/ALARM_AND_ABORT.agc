### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	ALARM_AND_ABORT.agc
## Purpose:	Part of the reconstructed source code for LMY99 Rev 0,
##		otherwise known as Luminary Rev 99, the third release
##		of the Apollo Guidance Computer (AGC) software for Apollo 11.
##		It differs from LMY99 Rev 1 (the flown version) only in the
##		placement of a single label. The corrections shown here have
##		been verified to have the same bank checksums as AGC developer
##		Allan Klumpp's copy of Luminary Rev 99, and so are believed
##		to be accurate. This file is intended to be a faithful 
##		recreation, except that the code format has been changed to 
##		conform to the requirements of the yaYUL assembler rather than 
##		the original YUL assembler.
##
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo.
## Pages:	1381-1385
## Mod history: 2009-05-10 SN   (Sergio Navarro).  Started adapting
##				from the Luminary131/ file of the same
##				name, using Luminary099 page images.
##		2009-06-05 RSB	Fixed a type.
##		2011-01-06 JL	Fixed pseudo-label indentation.
##		2016-12-13 RSB	GOTOP00H -> GOTOPOOH
##		2016-12-18 RSB	Proofed text comments with octopus/ProoferComments
##				and corrected the errors found.
##		2017-08-01 MAS	Created from LMY99 Rev 1.
##		2021-05-30 ABS  OCT21103 -> OCT1103

## This source code has been transcribed or otherwise adapted from
## digitized images of a hardcopy from the MIT Museum.  The digitization
## was performed by Paul Fjeld, and arranged for by Deborah Douglas of
## the Museum.  Many thanks to both.  The images (with suitable reduction
## in storage size and consequent reduction in image quality as well) are
## available online at www.ibiblio.org/apollo.  If for some reason you
## find that the images are illegible, contact me at info@sandroid.org
## about getting access to the (much) higher-quality images which Paul
## actually created.
##
## The code has been modified to match LMY99 Revision 0, otherwise
## known as Luminary Revision 99, the Apollo 11 software release preceeding
## the listing from which it was transcribed. It has been verified to
## contain the same bank checksums as AGC developer Allan Klumpp's listing
## of Luminary Revision 99 (for which we do not have scans).
##
## Notations on Allan Klumpp's listing read, in part:
##
##	ASSEMBLE REVISION 099 OF AGC PROGRAM LUMINARY BY NASA 2021112-51

## Page 1381
# THE FOLLOWING SUBROUTINE MAY BE CALLED TO DISPLAY A NON-ABORTIVE ALARM CONDITION.  IT MAY BE CALLED
# EITHER IN INTERRUPT OR UNDER EXECUTIVE CONTROL.
#
# CALLING SEQUENCE IS AS FOLLOWS:
#		TC	ALARM
#		OCT	AAANN		ALARM NO. NN IN GENERAL AREA AAA.
#					(RETURNS HERE)

		BLOCK	02
		SETLOC	FFTAG7
		BANK

		EBANK=	FAILREG

		COUNT*	$$/ALARM

# ALARM TURNS ON THE PROGRAM ALARM LIGHT, BUT DOES NOT DISPLAY.

ALARM		INHINT

		CA	Q
ALARM2		TS	ALMCADR
		INDEX	Q
		CA	0
BORTENT		TS	L

PRIOENT		CA	BBANK
 +1		EXTEND
		ROR	SUPERBNK	# ADD SUPER BITS.
		TS	ALMCADR +1

LARMENT		CA	Q		# STORE RETURN FOR ALARM
		TS	ITEMP1

CHKFAIL1	CCS	FAILREG		# IS ANYTHING IN FAILREG
		TCF	CHKFAIL2	# YES TRY NEXT REG
		LXCH	FAILREG
		TCF	PROGLARM	# TURN ALARM LIGHT ON FOR FIRST ALARM

CHKFAIL2	CCS	FAILREG +1
		TCF	FAIL3
		LXCH	FAILREG +1
		TCF	MULTEXIT

FAIL3		CA	FAILREG +2
		MASK	POSMAX
		CCS	A
		TCF	MULTFAIL
		LXCH	FAILREG +2
		TCF	MULTEXIT

## Page 1382

PROGLARM	CS	DSPTAB +11D
		MASK	OCT40400
		ADS	DSPTAB +11D


MULTEXIT	XCH	ITEMP1		# OBTAIN RETURN ADDRESS IN A
		RELINT
		INDEX	A
		TC	1

MULTFAIL	CA	L
		AD	BIT15
		TS	FAILREG +2

		TCF	MULTEXIT

# PRIOLARM DISPLAYS V05N09 VIA PRIODSPR WITH 3 RETURNS TO THE USER FROM THE ASTRONAUT AT CALL LOC +1,+2,+3 AND
# AN IMMEDIATE RETURN TO THE USER AT CALL LOC +4.  EXAMPLE FOLLOWS,
#		CAF	OCTXX		ALARM CODE
#		TC	BANKCALL
#		CADR	PRIOLARM
#		...	...
#		...	...
#		...	...		ASTRONAUT RETURN
#		TC	PHASCHNG	IMMEDIATE RETURN TO USER.  RESTART
#		OCT	X.1		PHASE CHANGE FOR PRIO DISPLAY

		BANK	10
		SETLOC	DISPLAYS
		BANK

		COUNT*	$$/DSPLA
PRIOLARM	INHINT			# * * * KEEP IN DISPLAY ROUTINES BANK
		TS	L		# SAVE ALARM CODE

		CA	BUF2		# 2 CADR OF PRIOLARM USER
		TS	ALMCADR
		CA	BUF2 +1
		TC	PRIOENT +1	# * LEAVE L ALONE
-2SEC		DEC	-200		# *** DONT MOVE
		CAF	V05N09
		TCF	PRIODSPR

		BLOCK	02
		SETLOC	FFTAG7
		BANK

		COUNT*	$$/ALARM
BAILOUT		INHINT
		CA	Q
## Page 1383
		TS	ALMCADR

		INDEX	Q
		CAF	0
		TC	BORTENT
OCT40400	OCT	40400

		INHINT
WHIMPER		CA	TWO
		AD	Z
		TS	BRUPT
		RESUME
		TC	POSTJUMP	# RESUME SENDS CONTROL HERE
		CADR	ENEMA
POODOO		INHINT
		CA	Q
ABORT2		TS	ALMCADR
		INDEX	Q
		CAF	0
		TC	BORTENT
OCT77770	OCT	77770		# DON'T MOVE

		CAF	OCT35		# 4.35SPOT FOR GOPOODOO
		TS	L
		COM
		DXCH	-PHASE4
GOPOODOO	INHINT
		TC	BANKCALL	# RESET STATEFLG, REINTFLG, AND NODOFLAG.
		CADR	FLAGS
		CA	FLAGWRD7	# IS SERVICER CURRENTLY IN OPERATION?
		MASK	V37FLBIT
		CCS	A
		TCF	STRTIDLE
		TC	BANKCALL	# TERMINATE GRPS 1, 3, 5, AND 6
		CADR	V37KLEAN
		TC	BANKCALL	# TERMINATE GRPS 2, 4, 1, 3, 5, AND 6
		CADR	MR.KLEAN	#	(I.E., GRP 4 LAST)
		TCF	WHIMPER
STRTIDLE	CAF	BBSERVDL
		TC	SUPERSW
		TC	BANKCALL	# PUT SERVICER INTO ITS "GROUND" STATE
		CADR	SERVIDLE	# AND PROCEED TO GOTOPOOH.
CCSHOLE		INHINT
		CA	Q
		TC	ABORT2
OCT1103		OCT	1103
CURTAINS	INHINT
		CA	Q
		TC	ALARM2
OCT217		OCT	00217
## Page 1384
		TC	ALMCADR		# RETURN TO USER

BAILOUT1	INHINT
		DXCH	ALMCADR
		CAF	ADR40400
BOTHABRT	TS	ITEMP1
		INDEX	Q
		CAF	0
		TS	L
		TCF	CHKFAIL1
POODOO1		INHINT
		DXCH	ALMCADR
		CAF	ADR77770
		TCF	BOTHABRT

ALARM1		INHINT
		DXCH	ALMCADR
ALMNCADR	INHINT
		INDEX	Q
		CA	0
		TS	L
		TCF	LARMENT

ADR77770	TCF	OCT77770
ADR40400	TCF	OCT40400
DOALARM		EQUALS	ENDOFJOB
		EBANK=	DVCNTR
BBSERVDL	BBCON	SERVIDLE

# CALLING SEQUENCE FOR VARALARM
#		CAF	(ALARM)
#		TC	VARALARM
#
# VARALARM TURNS ON PROGRAM ALARM LIGHT BUT DOES NOT DISPLAY

VARALARM	INHINT

		TS	L		# SAVE USERS ALARM CODE

		CA	Q		# SAVE USERS Q
		TS	ALMCADR

		TC	PRIOENT
OCT14		OCT	14		# DONT MOVE

		TC	ALMCADR		# RETURN TO USER

ABORT		EQUALS	WHIMPER
		BANK	13
		SETLOC	ABTFLGS
		BANK
## Page 1385
		COUNT*	$$/ALARM

FLAGS		CS	STATEBIT
		MASK	FLAGWRD3
		TS	FLAGWRD3
		CS	REINTBIT
		MASK	FLGWRD10
		TS	FLGWRD10
		CS	NODOBIT
		MASK	FLAGWRD2
		TS	FLAGWRD2
		TC	Q
		
