### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	AGS_INITIALIZATION.agc
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
## Pages:	206-210
## Mod history:	2009-05-19 HG	Transcribed from page images.
##		2016-12-13 RSB	Proofed text comments with octopus/ProoferComments
##				and corrected the errors found.
##		2017-03-14 RSB	Comment-text fixes identified in 5-way
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

## Page 206

# PROGRAM NAME:  AGS INITIALIZATION (R47)
#
# WRITTEN BY:  RHODE/KILROY/FOLLETT
#
# MOD NO. :	0
# DATE:		23 MARCH 1967
# MOD BY:	KILROY
#
# MOD NO.:	1
# DATE:		28 OCTOBER 1967
# MOD BY:	FOLLETT
#
# FUNCT. DESC.:	(1) TO PROVIDE THE AGS ABORT ELECTRONICS ASSEMBLY (AEA) WITH THE LEM AND CSM STATE VECTORS
#		(POSITION,VELOCITY,TIME) IN LEM IMU COORDINATES BY MEANS OF THE LGC DIGITAL DOWNLINK.
#
#		(2) TO ZERO THE ICDU, LGC AND AEA GIMBAL ANGLE COUNTERS SIMULTANEOUSLY IN ORDER TO ESTABLISH A
#		COMMON ZERO REFERENCE FOR THE MEASUREMENT OF GIMBAL (EULER) ANGLES WHICH DEFINE LEM ATTITUDE
#
#		(3) TO ESTABLISH THE GROUND ELAPSED TIME OF AEA CLOCK ZERO.  (IF AN AEA CLOCK ZERO IS
#		REQUESTED DURING THIS PROGRAM
#
# LOG SECTION:	AGS INITIALIZATION
#
# CALLING SEQ:	PROGRAM IS ENTERED WHEN ASTRONAUT KEYS V47E ON DSKY.
#		R47 MAY BE CALLED AT ANY TIME EXCEPT WHEN ANOTHER EXTENDED VERB IS IN PROGRESS
#
# SUBROUTINES
# CALLED:
#
# NORMAL EXIT:	ENDEXT
#
# ALARM/ABORT:	ALARM - BAD REFSMMAT - CODE:220
#		OPERATOR ERROR IF V47 SELECTED DURING ANOTHER EXTENDED VERB.
#
# ERASABLES
# USED:		SAMPTIME	(2)	TIME OF :ENTER: KEYSTROKE
#		AGSK		(2)	GROUND ELAPSED TIME OF THE AEA CLOCK :ZERO:
#		AGSBUFF		(140)	CONTAINS AGS INITIALIZATION DATA (SEE :OUTPUT: BELOW)
#		AGSWORD		(1)	PREVIOUS DOWNLIST SAVED HERE

		EBANK=	AGSBUFF

		BANK	40
		SETLOC	R47
		BANK

		COUNT*	$$/R47

AGSINIT		CAF	REFSMBIT
		MASK	FLAGWRD3			# CHECK REFSMFLG.
		CCS	A
## Page 207
		TC	REDSPTEM			# REFSMMAT IS OK
		TC	ALARM				# REFSMMAT IS BAD
		OCT	220
		TC	ENDEXT

NEWAGS		EXTEND
		DCA	SAMPTIME			# TIME OF THE :ENTER: KEYSTROKE
		DXCH	AGSK				# BECOMES NEW AEA CLOCK :ZERO:

REDSPTEM	EXTEND
		DCA	AGSK
		DXCH	DSPTEMX
AGSDISPK	CAF	V06N16
		TC	BANKCALL			# R1 = 00XXX. HRS., R2 = 000XX MIN.,
		CADR	GOMARKF				# R3 = 0XX.XX SEC.
		TC	ENDEXT				# TERMINATE RETURN
		TC	AGSVCALC			# PROCEED RETURN
		CS	BIT6				# IS ENTER VIA A V32
		AD	MPAC
		EXTEND
		BZF	NEWAGS				# YES, USE KEYSTROKE TIME FOR NEW AGSK

		EXTEND					# NO, NEW AGSK LOADED VIA V25
		DCA	DSPTEMX				# LOADED INTO DSPTEMX BY KEYING
		TC	REDSPTEM -1			# V25E FOLLOWED BY HRS.,MINS.,SECS.
							# DISPLAY THE NEW K

AGSVCALC	TC	INTPRET
		SET
			NODOFLAG			# DONT ALLOW V37
		SET	EXIT
			XDSPFLAG

		CAF	V06N16
		TC	BANKCALL
		CADR	EXDSPRET

		TC	INTPRET				# EXTRAPOLATE LEM AND CSM STATE VECTORS
		RTB					# TO THE PRESENT TIME
			LOADTIME			# LOAD MPAC WITH TIME2,TIME1
		STCALL	TDEC1				# CALCULATE LEM STATE VECTOR
			LEMPREC
		CALL					# CALL ROUTINE TO CONVERT TO SM COORDS AND
			SCALEVEC			# PROVIDE PROPER SCALING
		STODL	AGSBUFF				# (LEMPREC AND CSMPREC LEAVE TDEC1 IN TAT)
			TAT				# TAT = TIME TO WHICH RATT1 AND VATT1 ARE
		STCALL	TDEC1				# COMPUTED (CSEC SINCE CLOCK START B-28).
			CSMPREC				# CALCULATE CSM STATE VECTOR FOR SAME TIME
		CALL
			SCALEVEC
## Page 208
		STODL	AGSBUFF +6
			TAT
		DSU	DDV				# CALCULATE AND STORE THE TIME
			AGSK
			TSCALE
		STORE	AGSBUFF +12D
		EXIT

		CAF	LAGSLIST
		TS	DNLSTCOD

		CAF	20SEC				# DELAY FOR 20 SEC WHILE THE AGS
		TC	BANKCALL			# DOWNLIST IS TRANSMITTED
		CADR	DELAYJOB

		CA	AGSWORD
		TS	DNLSTCOD			# RETURN TO THE OLD DOWNLIST
		CAF	IMUSEBIT
		MASK	FLAGWRD0			# CHECK IMUSE FLAG.
		CCS	A
		TC	AGSEND				# IMU IS BEING USED - DO NOT ZERO
CKSTALL		CCS	IMUCADR				# CHECK FOR IMU USAGE WHICH AVOIDS THE
		TCF	+3				# IMUSE BIT:  I.E., IMU COMPENSATION.
		TCF	+6				# FREE.  GO AHEAD WITH THE IMU ZERO.
		TCF	+1
 +3		CAF	TEN				# WAIT .1 SEC AND TRY AGAIN.
		TC	BANKCALL
		CADR	DELAYJOB
		TCF	CKSTALL

 +6		TC	BANKCALL			# IMU IS NOT IN USE
		CADR	IMUZERO				# SET IMU ZERO DISCRETE FOR 320MSECS
		TC	BANKCALL			# WAIT 3 SEC FOR COUNTERS TO INCREMENT
		CADR	IMUSTALL
		TC	AGSEND
AGSEND		TC	DOWNFLAG			# ALLOW V37
		ADRES	NODOFLAG

		CAF	V50N16
		TC	BANKCALL
		CADR	GOMARK3
		TCF	ENDEXT
		TCF	ENDEXT
		TC	ENDEXT

SCALEVEC	VLOAD	MXV
			VATT1
			REFSMMAT
		VXSC	VSL2
			VSCALE
## Page 209
		VAD	VAD				# THIS SECTION ROUNDS THE VECTOR, AND
			AGSRND1				# CORRECTS FOR THE FACT THAT THE AGS
			AGSRND2				# IS A 2 S COMPLIMENT MACHINE WHILE THE
		RTB					# LGC IS A 1 S COMPLIMENT MACHINE.
			VECSGNAG
		STOVL	VATT1
			RATT1
		MXV	VXSC
			REFSMMAT
			RSCALE
		VSL8	VAD				# AGAIN THIS SECTION ROUNDS.  TWO VECTORS
			AGSRND1				# ARE ADDED TO DEFEAT ALSIGNAG IN THE
		VAD	RTB				# CASE OF A HIGH-ORDER ZERO COUPLED WITH
			AGSRND2				# A LOW ORDER NEGATIVE PART.
			VECSGNAG
		LXA,1
			VATT1
		SXA,1	LXA,1
			MPAC +1
			VATT1 +2
		SXA,1	LXA,1
			MPAC +4
			VATT1 +4
		SXA,1	RVQ
			MPAC +6

LAGSLIST	=	ONE
V01N14		VN	0114
V50N00A		VN	5000
V00N25		EQUALS	OCT31
V06N16		VN	0616
V00N34		EQUALS	34DEC
V50N16		VN	5016
TSCALE		2DEC	100 B-10			# CSEC TO SEC SCALE FACTOR
20SEC		DEC	2000
RSCALE		2DEC	3.280839 B-3			# METERS TO FEET SCALE FACTOR
VSCALE		2DEC	3.280839 E2 B-9			# METERS/CS TO FEET/SEC SCALE FACTOR
AGSRND1		2OCT	0000060000
		2OCT	0000060000
		2OCT	0000060000
AGSRND2		2OCT	0000037777
		2OCT	0000037777
## Page 210
		2OCT	0000037777

		SBANK=	LOWSUPER			# FOR SUBSEQUENT LOW 2CADRS.

