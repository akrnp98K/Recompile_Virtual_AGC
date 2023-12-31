### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	P70-P71.agc
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
## Contact:	Hartmuth Gutsche <hgutsche@xplornet.com>.
## Website:	www.ibiblio.org/apollo.
## Pages:	829-837
## Mod history:	2009-05-23 HG	Transcribed from page images.
##		2009-06-05 RSB	Fixed a typo.
##		2011-01-06 JL	Fixed pseudo-labels which were incorrectly real labels.
##		2016-12-17 RSB	Proofed text comments with octopus/ProoferComments
##				and corrected the errors found.
##		2017-03-14 RSB	Comment-text fixes noted in proofing Luminary 116.
##		2017-08-01 MAS	Created from LMY99 Rev 1.
##		2017-08-16 RSB	Comment typo identified in AP11ROPE scans.

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

## Page 829
		BANK	21
		SETLOC	R11
		BANK

		EBANK=	DVCNTR
		COUNT*	$$/R11

R10,R11		CS	FLAGWRD7	# IS SERVICER STILL RUNNING?
		MASK	AVEGFBIT
		CCS	A
		TCF	TASKOVER	# LET AVGEND TAKE CARE OF GROUP 2.
		CCS	PIPCTR
		TCF	+2
		TCF	LRHTASK		# LAST PASS. CALL LRHTASK.
 +2		TS	PIPCTR1

PIPCTR1		=	LADQSAVE
PIPCTR		=	PHSPRDT2
		CAF	OCT31
		TC	TWIDDLE
		ADRES	R10,R11
R10,R11A	CS	IMODES33	# IF LAMP TEST, DO NOT CHANGE LR LITES.
		MASK	BIT1
		EXTEND
		BZF	10,11

FLASHH?		MASK	FLGWRD11	# C(A) = 1 = HFLASH BIT
		EXTEND
		BZF	FLASHV?		# H FLASH OFF, SO LEAVE ALONE

		CA	HLITE
		TS	L
		TC	FLIP		# FLIP H LITE

FLASHV?		CA	VFLSHBIT	# VFLASHBIT MUST BE BIT 2.
		MASK	FLGWRD11
		EXTEND
		BZF	10,11		# V FLASH OFF

		CA	VLITE
		TS	L
		TC	FLIP		# FLIP V LITE

10,11		CA	FLAGWRD9	# IS THE LETABORT FLAG SET ?
		MASK	LETABBIT
		EXTEND
		BZF	LANDISP		# NO. PROCEED TO R10.

P71NOW?		CS	MODREG		# YES.  ARE WE IN P71 NOW?
## Page 830
		AD	1DEC71
		EXTEND
		BZF	LANDISP		# YES.  PROCEED TO R10.
		
		EXTEND			# NO. IS AN ABORT STAGE COMMANDED?
		READ	CHAN30
		COM
		TS	L
		MASK	BIT4
		CCS	A
		TCF	P71A		# YES.

P70NOW?		CS	MODREG		# NO. ARE WE IN P70 NOW?
		AD	1DEC70
		EXTEND
		BZF	LANDISP		# YES.  PROCEED TO R10.

		CA	L		# NO.  IS AN ABORT COMMANDED?
		MASK	BIT1
		CCS	A
		TCF	P70A		# YES.
		TCF	LANDISP		# NO.  PROCEED TO R10.

		COUNT*	$$/P70

P70		TC	LEGAL?
P70A		CS	ZERO
		TCF	+3
P71		TC	LEGAL?
P71A		CAF	TWO
 +3		TS	Q
		INHINT
		EXTEND
		DCA	CNTABTAD
		DTCB

		EBANK=	DVCNTR
CNTABTAD	2CADR	CONTABRT

1DEC70		DEC	70
1DEC71		DEC	71

		BANK	05
		SETLOC	ABORTS1
		BANK
		COUNT*	$$/P70

CONTABRT	CAF	ABRTJADR
		TS	BRUPT
		RESUME
## Page 831

ABRTJADR	TCF	ABRTJASK

ABRTJASK	CAF	OCTAL27
		AD	Q
		TS	L
		COM
		DXCH	-PHASE4
		INDEX	Q
		CAF	MODE70
		TS	MODREG

		TS	DISPDEX		# INSURE DISPDEX IS POSITIVE.

		CCS	Q		# SET APSFLAG IF P71.
		CS	FLGWRD10	# SET APSFLAG PRIOR TO THE ENEMA.
		MASK	APSFLBIT
		ADS	FLGWRD10
		CS	DAPBITS		# DAPBITS = OCT 640 = BITS 6, 8, 9
		MASK	DAPBOOLS	# (TURN OFF: ULLAGE, DRIFT, AND XOVINHIB )
		TS	DAPBOOLS

		CS	FLAGWRD5	# SET ENGONFLG.
		MASK	ENGONBIT
		ADS	FLAGWRD5

		CS	PRIO30		# INSURE THAT THE ENGINE IS ON, IF ARMED.
		EXTEND
		RAND	DSALMOUT
		AD	BIT13
		EXTEND
		WRITE	DSALMOUT

		CAF	LRBYBIT		# TERMINATE R12.
		TS	FLGWRD11

		CS	FLAGWRD0	# SET R10FLAG TO SUPPRESS OUTPUTS TO THE
		MASK	R10FLBIT	# CROSS-POINTER DISPLAY.
		ADS	FLAGWRD0	# THE FOLLOWING ENEMA WILL REMOVE THE
					# DISPLAY INERTIAL DATA OUTBIT.
		TC	CLRADMOD	# INSURE RADMODES PROPERLY SET FOR R29.

		EXTEND			# LOAD TEVENT FOR THE DOWNLINK.
		DCA	TIME2
		DXCH	TEVENT

		EXTEND
		DCA	SVEXITAD
		DXCH	AVGEXIT

## Page 832
		EXTEND
		DCA	NEG0
		DXCH	-PHASE1
		
		EXTEND
		DCA	NEG0
		DXCH	-PHASE3
		
		EXTEND
		DCA	NEG0
		DXCH	-PHASE6
		
		CAF	THREE		# SET UP 4.3SPOT FOR GOABORT
		TS	L
		COM
		DXCH	-PHASE4

		CAF	OCT37774	# SET T5RUPT TO CALL DAPIDLER IN	
		TS	TIME5		# 40 MILLISECONDS.
		
		TC	POSTJUMP
		CADR	ENEMA

		EBANK=	DVCNTR
SVEXITAD	2CADR	SERVEXIT

MODE70		DEC	70
OCTAL27		OCT	27
MODE71		DEC	71

DAPBITS		OCT	00640

		BANK	32
		SETLOC	ABORTS
		BANK

		COUNT*	$$/P70

GOABORT		TC	INTPRET
		CALL
			INITCDUW
		EXIT
		CAF	FOUR
		TS	DVCNTR

		CAF	WHICHADR
		TS	WHICH

		TC	DOWNFLAG
		ADRES	FLRCS
## Page 833
		TC	DOWNFLAG
		ADRES	FLUNDISP
		
		TC	DOWNFLAG
		ADRES	IDLEFLAG
		
		TC	UPFLAG		# INSURE 4-JET TRANSLATION CAPABILITY.
		ADRES	ACC4-2FL
		
		TC	CHECKMM
70DEC		DEC	70
		TCF	P71RET

P70INIT		TC	INTPRET
		CALL
			TGOCOMP
		DLOAD	SL
			MDOTDPS
			4D
		BDDV
			MASS
		STODL	TBUP
			MASS
		DDV	SR1
			K(1/DV)
		STORE	1/DV1
		STORE	1/DV2
		STORE	1/DV3
		BDDV
			K(AT)
		STODL	AT
			DTDECAY
		DCOMP	SL
			11D
		STORE	TTO
		SLOAD	DCOMP
			DPSVEX
		SR2
		STORE	VE		# INITIALIZE DPS EXHAUST VELOCITY
		SET	CALL
			FLAP
			COMMINIT
		AXC,1	GOTO		# RETURN HERE IN P70, SE X1 FOR DPS COEFF.
			0D
			BOTHPOLY
INJTARG		AXC,1			# RETURN HERE IN P71, SET X1 FOR APS COEFF
			8D
BOTHPOLY	DLOAD*	DMP		# TGO D
			ABTCOF,1
			TGO
## Page 834
		DAD*	DMP
			ABTCOF +2,1	# TGO(C+TGO D)
			TGO
		DAD*	DMP
			ABTCOF +4,1	# TGO(B+TGO(C + TGO D))
			TGO
		DAD*
			ABTCOF +6,1	# A+TGO(B+TGO(C+TGO D))	
		STORE	ZDOTD		# STORE TENTATIVELY IN ZDOTD
		DSU	BPL		# CHECK AGAINST MINIMUM
			VMIN
			UPRATE		# IF BIG ENOUGH, LEAVE ZDOTD AS IS .
		DLOAD
			VMIN
		STORE	ZDOTD		# IF TOO SMALL, REPLACE WITH MINIMUM.
UPRATE		DLOAD
			ABTRDOT
		STCALL	RDOTD		# INITIALIZE RDOTD.
			YCOMP		# COMPUTE Y
		ABS	DSU
			YLIM		# /Y/-DYMAX
		BMN	SIGN		# IF <0, XR<.5DEG, LEAVE YCO AT 0
			YOK		# IF >0, FIX SIGN OF DEFICIT, THIS IS YCO.
			Y
		STORE	YCO
YOK		DLOAD	DSU
			YCO
			Y		# COMPUTE XRANGE IN CASE ASTRONAUT WANTS
		SR
			5D
		STORE	XRANGE		# TO LOOK.
UPTHROT		SET	EXIT
			FLVR
			
		TC	UPFLAG		# SET ROTFLAG
		ADRES	ROTFLAG
		
		TC	THROTUP

		TC	PHASCHNG
		OCT	04024

 -3		TC	BANKCALL	# VERIFY THAT THE PANEL SWITCHES 
		CADR	P40AUTO		# ARE PROPERLY SET.
		
		TC	THROTUP

UPTHROT1	EXTEND			# SET SERVICER TO CALL ASCENT GUIDANCE.
		DCA	ATMAGAD
		DXCH	AVGEXIT
## Page 835
GRP4OFF		TC	PHASCHNG	# TERMINATE USE OF GROUP 4.
		OCT	00004

		TCF	ENDOFJOB

P71RET		TC	DOWNFLAG
		ADRES	LETABORT

		CAF	THRESH2		# SET DVMON THRESHOLD TO THE ASCENT VALUE.
		TS	DVTHRUSH

		TC	INTPRET
		BON	CALL
			FLAP
			OLDTIME
			TGOCOMP		# IF FLAP=0, TGO=T-TIG
		SSP	GOTO
			QPRET
		CADR	INJTARG
			P12INIT		# WILL EXIT P12INIT TO INJTARG
OLDTIME		DLOAD	SL1		# IF FLAP=1,TGO=2 TGO
			TGO
		STCALL	TGO1
			P12INIT
		EXIT
		TC	PHASCHNG
		OCT	04024

		EXTEND
		DCA	TGO1
		DXCH	TGO
		TCF	UPTHROT1 -3

TGO1		=	VGBODY
# ************************************************************************

		BANK	21
		SETLOC	R11
		BANK
		COUNT*	$$/P70

LEGAL?		CS	MMNUMBER	# IS THE DESIRED PGM ALREADY IN PROGRESS?
		AD	MODREG
		EXTEND
		BZF	ABORTALM

		CS	FLAGWRD9	# ARE THE ABORTS ENABLED?
		MASK	LETABBIT
		CCS	A
## Page 836
		TCF	ABORTALM

		CA	FLAGWRD7	# IS SERVICER ON THE AIR?
		MASK	AVEGFBIT
		CCS	A
		TC	Q		# YES. ALL IS WELL.
ABORTALM	TC	FALTON
		TC	RELDSP
		TC	POSTJUMP
		CADR	PINBRNCH

		BANK	32
		SETLOC	ABORTS
		BANK

		COUNT*	$$/P70

# ************************************************************************

TGOCOMP		RTB	DSU
			LOADTIME
			TIG
		SL
			11D
		STORE	TGO
		RVQ

# ************************************************************************

THROTUP		CAF	BIT13
		TS	THRUST
		CAF	BIT4
		EXTEND
		WOR	CHAN14
		TC	Q

# ************************************************************************

10SECS		2DEC	1000
HINJECT		2DEC	18288 B-24	# 60,000 FEET EXPRESSED IN METERS.
(TGO)A		2DEC	37000 B-17
K(AT)		2DEC	.02		# SCALING CONSTANT
WHICHADR	REMADR	ABRTABLE

# ************************************************************************
## Page 837
		EBANK=	DVCNTR
ATMAGAD		2CADR	ATMAG
ORBMANAD	ADRES	ORBMANUV

