### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	R60,R62.agc
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
## Pages:	472-485
## Mod history:	2009-05-17 RSB	Adapted from the corresponding 
##				Luminary131 file, using page 
##				images from Luminary 1A.
##		2016-12-13 RSB	GOTOP00H -> GOTOPOOH
##		2016-12-14 RSB	Proofed text comments with octopus/ProoferComments
##				and corrected the errors found.
##		2017-01-27 RSB	Back-ported a comment-text fix identified in Luminary 69.
##		2017-03-09 RSB	Comment text fixes noted in proofing Luminary 116.
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

## Page 472
# MOD NO: 0				DATE: 1 MAY 1968
# MOD BY: DIGITAL DEVEL GROUP		LOG SECTION R60,R62
#
# FUNCTIONAL DESCRIPTION:
#
# CALLED AS A GENERAL SUBROUTINE TO MANEUVER THE LM TO A SPECIFIED
# ATTITUDE.
#
# 1. IF THE 3-AXIS FLAG IS NOT SET THE FINAL CDU ANGLES ARE
# CALCULATED (VECPOINT).
#
# 2. THE FDAI BALL ANGLES (NOUN 18) ARE CALCULATED (BALLANGS).
#
# 3. REQUEST FLASHING DISPLAY V50 N18 PLEASE PERFORM AUTO MANEUVER.
#
# 4. IF PRIORITY DISPLAY FLAG IS SET DO A PHASECHANGE.  THEN AWAIT
# ASTRONAUT RESPONSE.
#
# 5. DISPLAY RESPONSE RETURNS:
#
#	A. 	ENTER - RESET 3-AXIS FLAG AND RETURN TO CLIENT.
#
#	B.	TERMINATE - IF IN P00 GO TO STEP 5A.  OTHERWISE CHECK IF R61 IS
#		THE CALLING PROGRAM.  IF IN R61 AN EXIT IS MADE TO GOTOV56.  IF
#		NOT IN R61 AN EXIT IS DONE VIA GOTOP00H.
#
#	C.	PROCEED - CONTINUE WITH PROGRAM AT STEP 6.
#
# 6. IF THE 3-AXISFLAG IS NOT SET, THE FINAL CDU ANGLES ARE CALCULATED
# (VECPOINT).
#
# 7. THE FDAI BALL ANGLES (NOUN 18) ARE CALCULATED (BALLANGS).
#
# 8. IF THE G+N SWITCH IS NOT SET GO BACK TO STEP 3.
# 
# 9. IF THE AUTO SWITCH IS NOT SET GO BACK TO STEP 3.
#
# 10. NONFLASHING DISPLAY V06N18 (FDAI ANGLES).
#
# 11. DO A PHASECHANGE.
#
# 12. DO A MANEUVER CALCULATION AND ICDU DRIVE ROUTINE TO ACHIEVE FINAL
# GIMBAL ANGLES (GOMANUR).
#
# 13. AT END OF MANEUVER GO TO STEP 3.
#
#	IF SATISFACTORY MANEUVER STEP 5A EXITS R60.
#	FOR FURTHER ADJUSTMENT OF THE VEHICLE ATTITUDE ABOUT THE
#	DESIRED VECTOR, THE ROUTINE MAY BE PERFORMED AGAIN STARTING AT
## Page 473
#	STEP 5C.
#
# CALLING SEQUENCE:	TC	BANKCALL
#			CADR	R60LEM
#
# ERASABLE INITIALIZATION REQUIRED:	SCAXIS, POINTVSM (FOR VECPOINT)
#					3AXISFLG.
#
# SUBROUTINES CALLED:	VECPOINT, BALLANGS, GOPERF2R, LINUS, GODSPER,
#			GOMANUR, DOWNFLAG, PHASCHNG, UPFLAG
#
# NORMAL EXIT MODES:	CAE	TEMPR60		(CALLERS RETURN ADDRESS)
#			TC	BANKJUMP
#
# ALARMS: NONE
#
# OUTPUT: NONE
#
# DEBRIS: CPHI, CTHETA, CPSI, 3AXISFLG, TBASE2

		BANK	34
		SETLOC	MANUVER
		BANK
		
		EBANK=	TEMPR60
		
		COUNT*	$$/R06
R60LEM		TC	MAKECADR
		TS	TEMPR60
		
REDOMANN	CAF	3AXISBIT
		MASK	FLAGWRD5	# IS 3-AXIS FLAG SET
		CCS	A
		TCF	TOBALL		# YES
		TC	INTPRET
		CALL
			VECPOINT	# TO COMPUTE FINAL ANGLES
		STORE	CPHI		# STORE FINAL ANGLES - CPHI, CTHETA, CPSI
		EXIT
		
TOBALL		TC	BANKCALL
		CADR	BALLANGS	# TO CONVERT ANGLES TO FDAI
TOBALLA		CAF	V06N18
		TC	BANKCALL
		CADR	GOPERF2R	# DISPLAY PLEASE PERFORM AUTO MANEUVER
		TC	R61TEST
		TC	REDOMANC	# PROCEED
		TC	ENDMANU1	# ENTER I.E. FINISHED WITH R60
## Page 474
		TC	CHKLINUS	# TO CHECK FOR PRIORITY DISPLAYS
		TC	ENDOFJOB
		
REDOMANC	CAF	3AXISBIT
		MASK	FLAGWRD5	# IS 3-AXIS FLAG SET
		CCS	A
		TCF	TOBALLC		# YES
		TC	INTPRET
		CALL
			VECPOINT	# TO COMPUTE FINAL ANGLES
		STORE	CPHI		# STORE ANGLES
		EXIT
		
TOBALLC		TC	BANKCALL
		CADR	BALLANGS	# TO CONVERT ANGLES TO FDAI
		TC	G+N,AUTO	# CHECK AUTO MODE
		CCS	A
		TCF	TOBALLA		# NOT AUTO, GO REREQUEST AUTO MANEUVER.
		
AUTOMANV	CAF	V06N18		# STATIC DISPLAY DURING AUTO MANEUVER
		TC	BANKCALL	#					-
		CADR	GODSPR		#					-
		TC	CHKLINUS	# TO CHECK FOR PRIORITY DISPLAYS
		
STARTMNV	TC	BANKCALL	# PERFORM MANEUVER VIA KALCMANU
		CADR	GOMANUR
		
ENDMANUV	TCF	TOBALLA		# FINISHED MANEUVER.
ENDMANU1	TC	DOWNFLAG	# RESET 3-AXIS FLAG
		ADRES	3AXISFLG
		CAE	TEMPR60		#					-
		TC	BANKJUMP	#					-
		
CHKLINUS	CS	FLAGWRD4
		MASK	PDSPFBIT	# IS PRIORITY DISPLAY FLAG SET?
		CCS	A		#					-
		TC	Q		# NO - EXIT
		CA	Q
		TS	MPAC +2		# SAVE RETURN
		CS	THREE		# OBTAIN LOCATION FOR RESTART
		AD	BUF2		# HOLDS Q OF LAST DISPLAY
		TS	TBASE2
		
		TC	PHASCHNG
		OCT	00132
		
		CAF	BIT7
		TC	LINUS		# GO SET BITS FOR PRIORITY DISPLAY	-
		TC	MPAC +2
		
## Page 475		
RELINUS		CAF	PRIO26		# RESTORE ORIGINAL PRIORITY
		TC	PRIOCHNG
		
		CAF	TRACKBIT	# DON'T CONTINUE R60 UNLESS TRACKFLAG ON.
		MASK	FLAGWRD1
		CCS	A
		TCF	RER60
		
		CAF	RNDVZBIT	# IS IT P20?
		MASK	FLAGWRD0
		CCS	A
		TC	+4		# YES
		TC	PHASCHNG	# NO, MUST BE P25, SET 2.11 SPOT
		OCT	40112
		
		TC	ENDOFJOB
		
		TC	PHASCHNG	# SET 2.7 SPOT FOR P20
		OCT	40072
		
		TC 	ENDOFJOB
		
RER60		TC	UPFLAG		# SET PRIO DISPLAY FLAG AFTER RESTART
		ADRES	PDSPFLAG
		
		TC	TBASE2
		
R61TEST		CA	MODREG		# IF WE ARE IN P00 IT MUST BE V49 OR V89
		EXTEND
		BZF	ENDMANU1	# THUS WE GO TO ENDEXT VIA USER
		
		CA	FLAGWRD4	# ARE WE IN R61 (P20 OR P25)
		MASK	PDSPFBIT
		EXTEND
		BZF	GOTOPOOH	# NO
		TC	GOTOV56		# YES
		
BIT14+7		OCT	20100		#					-
OCT203		OCT	203
V06N18		VN	0618

# SUBROUTINE TO CHECK FOR G+N CONTROL, AUTO STABILIZATION
#
# RETURNS WITH C(A) = + 	IF NOT SET FOR G+N, AUTO
# RETURNS WITH C(A) = +0	IF SWITCHES ARE SET

G+N,AUTO	EXTEND
		READ	CHAN30
		MASK	BIT10
		CCS	A
		TC	Q		# NOT IN G+N	C(A) = +
## Page 476		
ISITAUTO	EXTEND			# CHECK FOR AUTO MODE
		READ	CHAN31
		MASK	BIT14
		TC	Q		# (+) = NOT IN AUTO, (+0) = AOK
		
## Page 477
# PROGRAM DESCRIPTION BALLANGS
# MOD NO.				LOG SECTION R60,R62
#
# WRITTEN BY RAMA M. AIYAWAR
#
# FUNCTIONAL DESCRIPTION
#
# 	COMPUTES LM FDAI BALL DISPLAY ANGLES
#
# CALLING SEQUENCE
#
#	TC	BALLANGS
#
# NORMAL EXIT MODE
#
#	TC	BALLEXIT	(SAVED Q)
#
# ALARM OR EXIT MODE	NIL
#
# SUBROUTINES CALLED
#
#	CD*TR*G
#	ARCTAN
#
# INPUT
#
#	CPHI,CTHETA,CPSI ARE THE ANGLES CORRESPONDING TO AOG, AIG, AMG.  THEY ARE
#	SP,2S COMPLIMENT SCALED TO HALF REVOLUTION.
#
# OUTPUT
#
#	FDAIX, FDAIY, FDAIZ ARE THE REQUIRED BALL ANGLES SCALED TO HALF REVOLUTION
#	SP,2S COMPLIMENT.
#
#	THESE ANGLES WILL BE DISPLAYED AS DEGREES AND HUNDREDTHS, IN THE ORDER ROLL, PITCH, YAW, USING NOUNS 18 & 19.
#
# ERASABLE INITIALIZATION REQUIRED
#
#	CPHI, CTHETA, CPSI 	EACH A SP REGISTER
#
# DEBRIS
#
#	A,L,Q,MPAC,SINCDU,COSCDU,PUSHLIST,BALLEXIT
#
# NOMENCLATURE:	CPHI, CTHETA, & CPSI REPRESENT THE OUTER, INNER, & MIDDLE GIMBAL ANGLES, RESPECTIVELY; OR
# 		EQUIVALENTLY, CDUX, CDUY, & CDUZ.
#
# NOTE:  ARCTAN CHECKS FOR OVERFLOW AND SHOULD BE ABLE TO HANDLE ANY SINGULARITIES.

		SETLOC	BAWLANGS
		BANK
		
		COUNT*	$$/BALL
BALLANGS	TC	MAKECADR
		TS	BALLEXIT
		CA	CPHI
## Page 478
		TS	CDUSPOT +4
		CA	CTHETA
		TS	CDUSPOT
		CA	CPSI
		TS	CDUSPOT +2
		
		TC	INTPRET
		SETPD	CALL
			0D
			CD*TR*G
			
		DLOAD	DMP
			SINCDUX		# SIN (OGA)
			COSCDUZ		# COS (MGA)
			
		SL1	DCOMP		# SCALE
		ARCSIN	PDDL		# YAW = ARCSIN(-SXCZ) INTO 0 PD
			SINCDUZ		
		STODL	SINTH		# (SINTH = 18D IN PD)
			COSCDUZ
		DMP	SL1		# RESCALE
			COSCDUX
		STCALL	COSTH		# (COSTH = 16D IN PD)
			ARCTAN
		PDDL	DMP		# ROLL = ARCTAN(SZ/CZCX) INTO 2 PD
			SINCDUZ
			SINCDUX
		SL2	PUSH		# SXSZ INTO 4 PD
		DMP	PDDL		# SXSZCY INTO 4 PD
			COSCDUY
		DMP	PDDL		# SXSZSY INTO 6 PD
			SINCDUY
			COSCDUX
		DMP	SL1		# CXCY
			COSCDUY
		DSU	STADR		# PULL UP FROM 6 PD
		STODL	COSTH		# COSTH = CXCY - SXSZSY
			SINCDUY
		DMP	SL1
			COSCDUX		# CXSY
		DAD	STADR		# PULL UP FROM 4 PD
		STCALL	SINTH		# SINTH = CXSY + SXSZCY
			ARCTAN		# RETURNS WITH D(MPAC) = PITCH
		PDDL	VDEF		# PITCH INTO 2 PD, ROLL INTO MPAC FROM 2 PD
		RTB			# VDEF MAKES V(MPAC) = ROLL, PITCH, YAW
			V1STO2S
		STORE	FDAIX		# MODE IS TP
		EXIT
		
ENDBALL		CA	BALLEXIT

## Page 479
		TC	BANKJUMP

## Page 480
# PROGRAM DESCRIPTION - VECPOINT
#
# THIS INTERPRETIVE SUBROUTINE MAY BE USED TO POINT A SPACECRAFT AXIS IN A DESIRED DIRECTION.  THE AXIS
# TO BE POINTED MUST APPEAR AS A HALF UNIT DOUBLE PRECISION VECTOR IN SUCCESSIVE LOCATIONS OF ERASABLE MEMORY
# BEGINNING WITH THE LOCATION CALLED SCAXIS.  THE COMPONENTS OF THIS VECTOR ARE GIVEN IN SPACECRAFT COORDINATES.
# THE DIRECTION IN WHICH THIS AXIS IS TO BE POINTED MUST APPEAR AS A HALF UNIT DOUBLE PRECISION VECTOR IN
# SUCCESSIVE LOCATIONS OF ERASABLE MEMORY BEGINNING WITH THE ADDRESS CALLED POINTVSM.  THE COMPONENTS OF THIS
# VECTOR ARE GIVEN IN STABLE MEMBER COORDINATES.  WITH THIS INFORMATION VECPOINT COMPUTES A SET OF THREE GIMBAL
# ANGLES (2S COMPLEMENT) CORESPONDING TO THE CROSS-PRODUCT ROTATION BETWEEN SCAXIS AND POINTVSM AND STORES THEM
# IN T(MPAC) BEFORE RETURNING TO THE CALLER.
#
# THIS ROTATION, HOWEVER, MAY BRING THE S/C INTO GIMBAL LOCK.  WHEN POINTING A VECTOR IN THE Y-Z PLANE,
# THE TRANSPONDER AXIS, OR THE AOT FOR THE LEM, THE PROGRAM WILL CORRECT THIS PROBLEM BY ROTATING THE CROSS-
# PRODUCT ATTITUDE ABOUT POINTVSM BY A FIXED AMOUNT SUFFICIENT TO ROTATE THE DESIRED S/C ATTITUDE OUT OF GIMBAL
# LOCK.  IF THE AXIS TO BE POINTED IS MORE THAN 40.6 DEGREES BUT LESS THAN 60.5 DEG FROM THE +X (OR -X) AXIS,
# THE ADDITIONAL ROTATION TO AVOID GIMAL LOCK IS 35 DEGREES.  IF THE AXIS IS MORE THAN 60.5 DEGEES FROM +X (OR -X)
# THE ADDITIONAL ROTATION IS 35 DEGREES.  THE GIMBAL ANGLES CORRESPONDING TO THIS ATTITUDE ARE THEN COMPUTED AND
# STORED AS 2S COMPLIMENT ANGLES IN T(MPAC) BEFORE RETURNING TO THE CALLER.
#
# WHEN POINTING THE X-AXIS, OR THE THRUST VECTOR, OR ANY VECTOR WITHIN 40.6 DEG OF THE X-AXIS, VECPOINT
# CANNOT CORRECT FOR A CROSS-PRODUCT ROTATION INTO GIMBAL LOCK.  IN THIS CASE A PLATFORM REALIGNMENT WOULD BE
# REQUIRED TO POINT THE VECTOR IN THE DESIRED DIRECTION.  AT PRESENT NO INDICATION IS GIVEN FOR THIS SITUATION
# EXCEPT THAT THE FINAL MIDDLE GIMBAL ANGLE IN MPAC +2 IS GREATER THAN 59 DEGREES.
#
# CALLING SEQUENCE -
#
#	1)	LOAD SCAXIS, POINTVSM
#	2)	CALL
#			VECPOINT
#
# RETURNS WITH
#
#	1)	DESIRED OUTER GIMBAL ANGLE IN MPAC
#	2)	DESIRED INNER GIMBAL ANGLE IN MPAC +1
#	3)	DESIRED MIDDLE GIMBAL ANGLE IN MPAC +2
#
# ERASABLES USED -
#
#	1)	SCAXIS		6
#	2)	POINTVSM	6
#	3)	MIS		18
#	4)	DEL		18
#	5)	COF		6
#	6)	VECQTEMP	1
#	7)	ALL OF VAC AREA	43
#
#			TOTAL	99

		SETLOC	VECPT
		BANK
## Page 481
		COUNT*	$$/VECPT
		
		EBANK=	BCDU
		
VECPNT1		STQ	BOV		# THIS ENTRY USES DESIRED CDUS
			VECQTEMP	# NOT PRESENT - ENTER WITH CDUD'S IN MPAC
			VECPNT2
VECPNT2		AXC,2	GOTO
			MIS
			STORANG
VECPOINT	STQ	BOV		# SAVE RETURN ADDRESS
			VECQTEMP
			VECLEAR		# AND CLEAR OVFIND
VECLEAR		AXC,2	RTB
			MIS		# READ THE PRESENT CDU ANGLES AND
			READCDUK	# STORE THEM IN PD25, 26, 27
STORANG		STCALL	25D
			CDUTODCM	# S/C AXES TO STABLE MEMBER AXES (MIS)
		VLOAD	VXM
			POINTVSM	# RESOLVE THE POINTING DIRECTION VF INTO
			MIS		# INITIAL S/C AXES (VF = POINTVSM)
		UNIT
		STORE	28D
					# PD 28 29 30 31 32 33
		VXV	UNIT		# TAKE THE CROSS PRODUCT VF X VI
			SCAXIS		# WHERE VI = SCAXIS
		BOV	VCOMP
			PICKAXIS
		STODL	COF		# CHECK MAGNITUDE
			36D		# OF CROSS PRODUCT
		DSU	BMN		# VECTOR, IF LESS
			DPB-14		# THAN B-14 ASSUME
			PICKAXIS	# UNIT OPERATION
		VLOAD	DOT		# INVALID.
			SCAXIS
			28D
		SL1	ARCCOS
COMPMATX	CALL			# NOW COMPUTE THE TRANSFORMATION FROM
			DELCOMP		# FINAL S/C AXES TO INITIAL S/C AXES MFI
		AXC,1	AXC,2
			MIS		# COMPUTE THE TRANSFORMATION FROM FINAL
			KEL		# S/C AXES TO STABLE MEMBER AXES
		CALL			# MFS = MIS MFI
			MXM3		# (IN PD LIST)
			
		DLOAD	ABS
			6		# MFS6 = SIN(CPSI)			$2
		DSU	BMN
			SINGIMLC	# = SIN(59 DEGS)			$2
			FINDGIMB	# /CPSI/ LESS THAN 59 DEGS
## Page 482
					# I.E. DESIRED ATTITUDE NOT IN GIMBAL LOCK
					
		DLOAD	ABS		# CHECK TO SEE IF WE ARE POINTING
			SCAXIS		# THE THRUST AXIS
		DSU	BPL
			SINVEC1		# SIN 49.4 DEGS				$2
			FINDGIMB	# IF SO, WE ARE TRYING TO POINT IT INTO
		VLOAD			# GIMBAL LOCK, ABORT COULD GO HERE
		STADR
		STOVL	MIS 	+12D
		STADR			# STORE MFS (IN PD LIST) IN MIS
		STOVL	MIS 	+6
		STADR
		STOVL	MIS
			MIS 	+6	# INNER GIMBAL AXIS IN FINAL S/C AXES
		BPL	VCOMP		# LOCATE THE IG AXIS DIRECTION CLOSEST TO
			IGSAMEX		# FINAL X S/C AXIS
			
IGSAMEX		VXV	BMN		# FIND THE SHORTEST WAY OF ROTATING THE 
			SCAXIS		# S/C OUT OF GIMBAL LOCK BY A ROTATION 
			U=SCAXIS	# ABOUT +- SCAXIS, I.E. IF  (IG (SGN MFS3)
					# X SCAXIS . XF) LESS THAN 0, U = SCAXIS
					# OTHERWISE U = -SCAXIS
					
		VLOAD	VCOMP
			SCAXIS
		STCALL	COF		# ROTATE ABOUT -SCAXIS
			CHEKAXIS
U=SCAXIS	VLOAD
			SCAXIS
		STORE	COF		# ROTATE ABOUT + SCAXIS
CHEKAXIS	DLOAD	ABS
			SCAXIS		# SEE IF WE ARE POINTING THE AOT
		DSU	BPL
			SINVEC2		# SIN 29.5 DEGS				$2
			PICKANG1	# IF SO, ROTATE 50 DEGS ABOUT +- SCAXIS
		DLOAD	GOTO		# IF NOT, MUST BE POINTING THE TRANSPONDER
			VECANG2		# OR SOME VECTOR IN THE Y, OR Z PLANE
			COMPMFSN	# IN THIS CASE ROTATE 35 DEGS TO GET OUT
					# OF GIMBAL LOCK (VECANG2  $360)
PICKANG1	DLOAD
			VECANG1		# = 50 DEGS				$360
COMPMFSN	CALL
			DELCOMP		# COMPUTE THE ROTATION ABOUT SCAXIS TO
		AXC,1	AXC,2		# BRING MFS OUT OF GIMBAL LOCK
			MIS
			KEL
		CALL			# COMPUTE THE NEW TRANSFORMATION FROM
			MXM3		# DESIRED S/C AXES TO STABLE MEMBER AXES
					# WHICH WILL ALIGN VI WITH VF AND AVOID
## Page 483
					# GIMBAL LOCK
FINDGIMB	AXC,1	CALL
			0		# EXTRACT THE COMMANDED CDU ANGLES FROM
			DCMTOCDU	# THIS MATRIX
		RTB	SETPD
			V1STO2S		# CONVERT TO 2:S COMPLEMENT
			0
		GOTO
			VECQTEMP	# RETURN TO CALLER
			
PICKAXIS	VLOAD	DOT		# IF VF X VI = 0, FIND VF . VI
			28D
			SCAXIS
		BMN	TLOAD
			ROT180
			25D
		GOTO			# IF VF = VI, CDU DESIRED = PRESENT CDU
			VECQTEMP	# PRESENT CDU ANGLES
			
		BANK	35
		SETLOC	MANUVER1
		BANK
ROT180		VLOAD	VXV		# IF VF, VI ANTIPARALLEL, 108 DEG ROTATION
			MIS 	+6	# IS REQUIRED.  Y STABLE MEMBER AXIS IN
			HIDPHALF	# INITIAL S/C AXES.
		UNIT	VXV		# FIND Y(SM) X X(I)
			SCAXIS		# FIND UNIT(VI X UNIT(Y(SM) X X(I)))
		UNIT	BOV		# I.E. PICK A VECTOR IN THE PLANE OF X(I),
			PICKX		# Y(SM) PERPENDICULAR TO VI
		STODL	COF
			36D		# CHECK MAGNITUDE
		DSU	BMN		# OF THIS VECTOR.
			DPB-14		# IF LESS THAN B-14,
			PICKX		# PICK X-AXIS.
		VLOAD
			COF
XROT		STODL	COF
			HIDPHALF
		GOTO
			COMPMATX
PICKX		VLOAD	GOTO		# PICK THE XAXIS IN THIS CASE
			HIDPHALF
			XROT
SINGIMLC	2DEC	.4285836003	# = SIN(59)				$2

SINVEC1		2DEC	.3796356537	# = SIN(49.4)				$2

SINVEC2		2DEC	.2462117800	# = SIN(29.5)				$2

VECANG1		2DEC	.1388888889	# = 50 DEGREES				$360
## Page 484
VECANG2		2DEC	.09722222222	# = 35 DEGREES				$360

1BITDP		OCT	0		# KEEP THIS BEFORE DPB(-14)	   *********
DPB-14		OCT	00001
		OCT	00000
		
## Page 485
# ROUTINE FOR INITIATING AUTOMATIC MANEUVER VIA KEYBOARD (V49)

		BANK	34
		SETLOC	R62
		BANK
		EBANK=	BCDU
		
		COUNT*	$$/R62
		
R62DISP		EQUALS	R62FLASH

R62FLASH	CAF	V06N22		# FLASH V06N22 AND
		TC	BANKCALL	# ICDU ANGLES
		CADR	GOFLASH
		TCF	ENDEXT		# TERMINATE
		TCF	GOMOVE		# PROCEED
		TCF	R62FLASH	# ENTER
		
					# ASTRONAUT MAY LOAD NEW ICDUS AT THIS
					# POINT
GOMOVE		TC	UPFLAG		# SET FOR 3-AXIS MANEUVER
		ADRES	3AXISFLG
		
		TC	BANKCALL
		CADR	R60LEM
		TCF	ENDEXT		# END R62
		
