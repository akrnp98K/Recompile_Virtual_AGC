### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	GROUND_TRACKING_DETERMINATION_PROGRAM_-_P21.agc
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
## Pages:	654-657
## Mod history:	2009-05-18 RSB	Adapted from the corresponding 
##				Luminary131 file, using page 
##				images from Luminary 1A.
##		2016-12-13 RSB	GOTOP00H -> GOTOPOOH
##		2016-12-14 RSB	Proofed text comments with octopus/ProoferComments
##				but no errors found.
##		2017-03-15 RSB	Comment-text fixes identified in 5-way
##				side-by-side diff of Luminary 69/99/116/131/210.
##		2017-08-01 MAS	Created from LMY99 Rev 1.

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

## Page 654
# GROUND TRACKING DETERMINATION PROGRAM P21
# PROGRAM DESCRIPTION
#	MOD NO - 1
#	MOD BY - N. M. NEVILLE
#
# FUNCTIONAL DECRIPTION -
#	TO PROVIDE THE ASTRONAUT DETAILS OF THE LM OR CSM GROUND TRACK WITHOUT
#	THE NEED FOR GROUND COMMUNICATION (REQUESTED BY DSKY).
#
# CALLING SEQUENCE -
#	ASTRONAUT REQUEST THROUGH DSKY V37E21E
#
# SUBROUTINES CALLED -
#	GOPERF4
#	GOFLASH
#	THISPREC
#	OTHPREC
#	LAT-LONG
#
# NORMAL EXIT MODES -
#	ASTRONAUT REQUEST TROUGH DSKY TO TERMINATE PROGRAM V34E
#
# ALARM OR ABORT EXIT MODES -
#	NONE
#
# OUTPUT -
#	OCTAL DISPLAY OF OPTION CODE AND VEHICLE WHOSE GROUND TRACK IS TO BE
#	COMPUTED
#		OPTION CODE	00002
#		THIS		00001
#		OTHER		00002
#	DECIMAL DISPLAY OF TIME TO BE INTEGRATED TO HOURS, MINUTES, SECONDS
#	DECIMAL DISPLAY OF LAT,LONG,ALT
#
# ERASABLE INITIALIZATION REQUIRED
#	AX0		2DEC	4.652459653 E-5 RADIANS		%68-69 CONSTANTS"
#	-AY0		2DEC	2.147535898 E-5 RADIANS
#	AZ0		2DEC	.7753206164	REVOLUTIONS
# 	FOR LUNAR ORBITS 504LM VECTOR IS NEEDED
#	504LM		2DEC	-2.700340600 E-5 RADIANS
#	504LM _2	2DEC	-7.514128400 E-4 RADIANS
#	504LM _4	2DEC	_2.553198641 E-4 RADIANS
#
# 	NONE
#
# DEBRIS
## Page 655
#	CENTRALS - A,Q,L
#	OTHER - THOSE USED BY THE ABOVE LISTED SUBROUTINES
#	SEE LEMPREC, LAT-LONG

		SBANK=	LOWSUPER	# FOR LOW 2CADR'S.

		BANK	33
		SETLOC	P20S
		BANK

		EBANK=	P21TIME
		COUNT*	$$/P21
PROG21		CAF	ONE
		TS	OPTION2		# ASSUMED VEHICLE IS LM, R2 = 00001
		CAF	BIT2		# OPTION 2
		TC	BANKCALL
		CADR	GOPERF4
		TC	GOTOPOOH	# TERMINATE
		TC	+2		# PROCEED VALUE OF ASSUMED VEHICLE OK
		TC	-5		# R2 LOADED THROUGH DSKY
P21PROG1	CAF	V6N34		# LOAD DESIRED TIME OF LAT-LONG.
		TC	BANKCALL
		CADR	GOFLASH
		TC	GOTOPOOH	# TERM
		TC	+2		# PROCEED VALUES OK
		TC	-5		# TIME LOADED THROUGH DSKY
		TC	INTPRET
		DLOAD
			DSPTEM1
		STCALL	TDEC1		# INTEGRATE TO TIME SPECIFIED IN TDEC
			INTSTALL
		BON	CLEAR
			P21FLAG
			P21CONT		# ON --- RECYCLE USING BASE VECTOR
			VINTFLAG	# OFF -- 1ST PASS CALL BASE VECTOR
		SLOAD	SR1
			OPTION2
		BHIZ	SET
			+2		# ZERO -- THIS VEHICLE (LM)
			VINTFLAG	# ONE -- OTHER VEHICLE (CM)
		CLEAR	CLEAR
			DIM0FLAG
			INTYPFLG	# PRECISION
		CALL
			INTEGRV		# CALCULATE
		GOTO			# -AND
			P21VSAVE	# -SAVE BASE VECTOR
P21CONT		VLOAD
			P21BASER	# RECYCLE -- INTEG FROM BASE VECTOR
		STOVL	RCV		# --POS
## Page 656		
			P21BASEV
		STODL	VCV		# --VEL
			P21TIME
		STORE	TET		# --TIME
		CLEAR	CLEAR
			DIM0FLAG
			MOONFLAG
		SLOAD	BZE
			P21ORIG
			+3		# ZERO = EARTH
		SET			# ---2 = MOON
			MOONFLAG
 +3		CALL
			INTEGRVS
P21VSAVE	DLOAD			# SAVE CURRENT BASE VECTOR
			TAT
		STOVL	P21TIME		# --TIME
			RATT1
		STOVL	P21BASER	# --POS B-29 OR B-27
			VATT1
		STORE	P21BASEV	# --VEL B-07 OR B-05
		ABVAL	SL*
			0,2
		STOVL	P21VEL		# VEL/ FOR N91 DISP
			RATT
		UNIT	DOT
			VATT		# U(R).V
		DDV	ASIN		# U(R).U(V)
			P21VEL
		STORE	P21GAM		# SIN-1 U(R).U(V) , -90 TO &90
		SXA,2	SLOAD
			P21ORIG		# 0 = EARTH
			OPTION2
		SR1	BHIZ
			+3
		GOTO
			+4
 +3		BON
			SURFFLAG
			P21DSP
 +4		SET
			P21FLAG
P21DSP		CLEAR	SLOAD		# GENERATE DISPLAY DATA
			LUNAFLAG
			X2
		BZE	SET
			+2		# 0 = EARTH
			LUNAFLAG
		VLOAD
			RATT
## Page 657			
		STODL	ALPHAV
			TAT
		CLEAR	CALL
			ERADFLAG
			LAT-LONG
		DMP			# MPAC = ALT, METERS B-29
			K.01
		STORE	P21ALT		# ALT/100 FOR N91 DISP
		EXIT
		CAF	V06N43		# DISPLAY LAT, LONG, ALT
		TC	BANKCALL	# LAT, LONG = 1/2 REVS B0
		CADR	GOFLASH		# ALT = KM B14
		TC	GOTOPOOH	# TERM
		TC	GOTOPOOH
		TC	INTPRET		# V32E RECYCLE
		DLOAD	DAD
			P21TIME
			600SEC		# 600 SECONDS OR 10 MIN
		STORE	DSPTEM1
		RTB
			P21PROG1
600SEC		2DEC	60000		# 10 MIN

V06N43		VN	00643
V6N34		VN	00634
K.01		2DEC	.01

