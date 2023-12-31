### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    T6-RUPT_PROGRAMS.agc
## Purpose:     A section of Luminary revision 97.
##              It is part of the reconstructed source code for the
##              second release of the flight software for the Lunar 
##              Module's (LM) Apollo Guidance Computer (AGC) for Apollo 11.
##              It was created to fix two incorrect ephemeris constants in
##              Luminary 96, as described by anomaly report LNY-59.
##              The code has been recreated from a copy of Luminary 99
##              revision 001, using asterisks indicating changed lines in
##              the listing and Luminary Memos #83 and #85, which list 
##              changes between Luminary 97 and 98, and 98 and 99. The
##              code has been adapted such that the resulting bugger words
##              exactly match those specified for Luminary 97 in NASA drawing
##              2021152D, which gives relatively high confidence that the
##              reconstruction is correct.
## Reference:   pp. 1403-1405
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-07-28 MAS  Created from Luminary 99.

## Page 1403
# PROGRAM NAMES:	(1) T6JOBCHK	MOD. NO. 5	OCTOBER 2, 1967
#			(2) DOT6RUPT
# MODIFICATION BY:	LOWELL G HULL (A.C.ELECTRONICS)
#
# THESE PROGRAMS ENABLE THE LM DAP TO CONTROL THE THRUST TIMES OF THE REACTION CONTROL SYSTEM JETS BY USING TIME6.
# SINCE THE LM DAP MAINTAINS EXCLUSIVE CONTROL OVER TIME6 AND ITS INTERRUPTS, THE FOLLOWING CONVENTIONS HAVE BEEN
# ESTABLISHED AND MUST NOT BE TAMPERED WITH:
#	1.	NO NUMBER IS EVER PLACED INTO TIME6 EXCEPT BY LM DAP.
#	2.	NO PROGRAM OTHER THAN LM DAP ENABLES THE TIME6 COUNTER.
#	3.	TO USE TIME6, THE FOLLOWING SEQUENCE IS ALWAYS EMPLOYED:
#		A.	A POSITIVE (NON-ZERO) NUMBER IS STORED IN TIME6.
#		B.	THE TIME6 CLOCK IS ENABLED.
#		C.	TIME6 IS INTERROGATED AND IS:
#			I.	NEVER FOUND NEGATIVE (NON-ZERO) OR +0.
#			II.	SOMETIMES FOUND POSITIVE (BETWEEN 1 AND 240D) INDICATING THAT IT IS ACTIVE.
#			III.	SOMETIMES FOUND POSMAX INDICATING THAT IT IS INACTIVE AND NOT ENABLED.
#			IV.	SOMETIMES FOUND NEGATIVE ZERO INDICATING THAT:
#				A.	A T6RUPT IS ABOUT TO OCCUR AT THE NEXT DINC, OR
#				B.	A T6RUPT IS WAITING IN THE PRIORITY CHAIN, OR
#				C.	A T6RUPT IS IN PROCESS NOW.
#	4)	ALL PROGRAMS WHICH OPERATE IN EITHER INTERRUPT MODE OR WITH INTERRUPT INHIBITED MUST CALL T6JOBCHK
#		EVERY 5 MILLISECONDS TO PROCESS A POSSIBLE WAITING T6RUPT BEFORE IT CAN BE HONORED BY THE HARDWARE.
#      (5.	PROGRAM JTLST, IN Q,R-AXES, HANDLES THE INPUT LIST.)
#
# T6JOBCHK CALLING SEQUENCE:
#		L	TC	T6JOBCHK
#		L+1	(RETURN)
#
# DOT6RUPT CALLING SEQUENCE:
#			DXCH	ARUPT		T6RUPT LEAD IN AT LOCATION 4004.
#			EXTEND
#			DCA	T6ADR
#			DTCB
#
# SUBROUTINES CALLED:	DOT6RUPT CALLS T6JOBCHK.
#
# NORMAL EXIT MODES:	T6JOBCHK RETURNS TO L +1.
#			DOT6RUPT TRANSFERS CONTROL TO RESUME.
#
# ALARM/ABORT MODES:	NONE.
#
# INPUT:	TIME6		NXT6ADR		OUTPUT:		TIME6		NXT6ADR		CHANNEL 5
#		T6NEXT		T6NEXT +1			T6NEXT		T6NEXT +1	CHANNEL 6
#		T6FURTHA	T6FURTHA +1			T6FURTHA	T6FURTHA +1	BIT15/CH13
#
# DEBRIS:	T6JOBCHK CLOBBERS A.  DOT6RUPT CLOBBERS NOTHING.

		BLOCK	02
## Page 1404
		BANK	17
		SETLOC	DAPS2
		BANK
		EBANK=	T6NEXT
		COUNT*	$$/DAPT6

T6JOBCHK	CCS	TIME6		# CHECK TIME6 FOR WAITING T6RUPT:
		TC	Q		# NONE: CLOCK COUTING DOWN.
		TC	CCSHOLE
		TC	T6JOBCHK +3

# CONTROL PASSES TO T6JOB ONLY WHEN C(TIME6) = -0 (I.E. WHEN A T6RUPT MUST BE PROCESSED).

T6JOB		CAF	POSMAX		# DISABLE CLOCK: NEEDED SINCE RUPT OCCURS
		EXTEND			# 1 DINC AFTER T6 = 77777. FOR 625 MUSECS
		WAND	CHAN13		# MUST NOT HAVE T6 = +0 WITH ENABLE SET

		CA	POSMAX
		ZL
		DXCH	T6FURTHA
		DXCH	T6NEXT
		LXCH	NXT6ADR
		TS	TIME6

		AD	PRIO37
		TS	A
		TCF	ENABLET6
		CA	POSMAX
		TS	TIME6
		TCF	GOCH56
ENABLET6	CA	BIT15
		EXTEND
		WOR	CHAN13
		CA	T6NEXT
		AD	PRIO37
		TS	A
		TCF	GOCH56
		CA	POSMAX
		TS	T6NEXT
GOCH56		INDEX	L
		TCF	WRITEP -1

		BLOCK	02
		SETLOC	FFTAG9
		BANK
		EBANK=	CDUXD
		COUNT*	$$/DAPT6

		CA	NEXTP
WRITEP		EXTEND
		WRITE	CHAN6
## Page 1405
		TC	Q

		CA	NEXTU
WRITEU		TS	L
		CS	00314OCT
		EXTEND
		RAND	CHAN5
		AD	L
		EXTEND
		WRITE	CHAN5
		TC	Q

		CA	NEXTV
WRITEV		TS	L
		CA	00314OCT
		TCF	-9D
00314OCT	OCT	00314

		BANK	17
		SETLOC	DAPS2
		BANK

		EBANK=	T6NEXT
		COUNT*	$$/DAPT6

DOT6RUPT	LXCH	BANKRUPT	# (INTERRUPT LEAD INS CONTINUED)
		EXTEND
		QXCH	QRUPT

		TC	T6JOBCHK	# CALL T6JOBCHK.

		TCF	RESUME		# END TIME6 INTERRUPT PROCESSOR.

