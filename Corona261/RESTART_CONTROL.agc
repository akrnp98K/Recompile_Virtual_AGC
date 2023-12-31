### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	RESTART_CONTROL.agc
## Purpose:	A section of Corona revision 261.
##		It is part of the source code for the Apollo Guidance Computer
##		(AGC) for AS-202. No original listings of this software are
##		available; instead, this file was created via disassembly of
##		the core rope modules actually flown on the mission.
## Assembler:	yaYUL
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	2023-05-27 MAS  Created from Solarium 55.
## 		2023-06-17 MAS  Changed a comment from 501 to 202.


		BANK	1
		
# OF THE PHASE TABLE IN ALMOST CONTSTANT AGREEMENT. CALLING SEQUENCES ARE AS FOLLOWS:
#
#		TC	PHASCHNG	CHANGE GROUP G TO PHASE PPP (127 MAX).
#		OCT	PPP0G		(CALL UNDER EXECUTIVE ONLY)
#
#		CAF	--		CHANGE GROUP G TO THE PHASE ARRIVING IN
#		TC	NEWPHASE	A (MAY BE CALLED ANYTIME).
#		OCT	0000G
#
#	IN EACH CASE THE OLD PHASE IS RETURNED TO THE CALLER IN A. IF THE OLD PHASE WAS +0, CONTROL IS
# GIVEN TO A ROUTINE SPECIFIED IN A CADR TABLE. THIS ROUTINE MAY EXIT OR RETURN TO CALLER VIA SWRETURN.

PHASCHNG	XCH	Q
		INHINT
		TS	RUPTREG4
		INDEX	A
		CAF	0
		TS	PHASDATA
		MASK	LOW5		# (MAY WANT MORE GROUPS SOME DAY)
		XCH	PHASDATA
		EXTEND
		MP	-BIT9		# NOTE LP NOT SAVED.
		TC	PHASCH2

-BIT9		OCT	-400

NEWPHASE	INHINT
		XCH	Q
		TS	RUPTREG4
		INDEX	A
		CAF	0
		TS	PHASDATA

		CS	Q
PHASCH2		INDEX	PHASDATA
		TS	-PHASE1 -1	# PHASE1 IS FOR PROG NUM 1.
		COM
		INDEX	PHASDATA
		XCH	PHASE1 -1	# INTO PHASE1 FOR PROG 1.

		CCS	A
		TC	+3

		TC	UPT		# ON +0.

		CS	TWO		# -1 IS INACTIVE STATE
 +3		AD	ONE

PHASEXIT	XCH	RUPTREG4
		AD	ONE
		TS	Q		# WE MUST RELINT BEFORE RETURN.
		XCH	RUPTREG4	# OLD PHASE BITS.
		RELINT
		TC	Q

UPT		INDEX	PHASDATA
		CAF	UPTCADR -1
		TC	SWCALL

		CAF	ZERO		# IF RETURN
		TC	PHASEXIT


#	MAJOR MODE LIGHT MAINTENANCE ROUTINES.

#	ROUTINE TO CHECK EQUALITY BETWEEN THE MAJOR MODE DISPLAY AND THE ARGUMENT AT CALLER +1. RETURNS TO
# CALLER +2 IF NOT AND CALLER +3 IF SO.

CHECKMM		CAF	ONE
		AD	Q
		XCH	Q
		INDEX	A
		CS	0
		AD	MODREG
		CCS	A
		TC	Q
FINEMASK	OCT	17
		TC	Q
		INDEX	Q
		TC	Q

#	TO UPDATE THE MAJOR MODE LIGHTS:

NEWMODE		INDEX	Q
		CAF	0
		TS	MODREG
		CAF	GRABUSY +1	# CADR OF BANK CONTAINING DSPMM.
		XCH	BANKREG
		TS	MPAC +1		# MPACS NOT USED BY DSPMM.
		XCH	Q
		TS	MPAC
		TC	DSPMM

		XCH	MPAC +1
		TS	BANKREG
		INDEX	MPAC
		TC	1


# PROGRAM PRGSTALL IS AN EXECUTIVE INTERLOCK ROUTINE. REQUESTING PROGS DO
# 		TC	BANKCALL
#		CADR	PRGSTALL
# RETURN IS TO L+2 AFTER TWO PROGS HAVE CALLED.



		BANK	4
PRGSTALL	INHINT
		CS	STATE
		MASK	PRGBIT
		TS	Q
		CS	PRGBIT
		MASK	STATE
		AD	Q
		TS	STATE
		CCS	Q
		TC	PRGSLEEP
		CAF	LPRGRET
		TC	JOBWAKE
		RELINT
		TC	SWRETURN

PRGSLEEP	TC	MAKECADR
		XCH	ADDRWD
		TS	MPAC +2
		CAF	LPRGRET
		TC	JOBSLEEP

PRGRET		XCH	MPAC +2
		TC	BANKJUMP

LPRGRET		CADR	PRGRET
PRGBIT		EQUALS	BIT1

UPTCADR		CADR


#	PINBALL COMES TO MODROUT ON RECEIVING THE NEW MODE REQUESTED BY VERB 37. THE DESIRED MODE IN IS A
# ON ARRIVAL.

MODROUT		INHINT
		AD	NEG3		# FOR FLIGHT 202, ONLY MODES 01 AND 03 MAY
		CCS	A		# BE INITIATED BY VERB 37.
		TC	V37BAD
		TC	CCSHOLE
		TC	1CHECK		# SEE IF 01 CALLED FOR.

		TC	CHECKMM		# MODE 03 REQUESTED - DEMANDS MODE 02
		OCT	02		# PRESENTLY. 
		TC	V37BAD

		CAF	PRIO14		# START OPTICAL CHECK.
		TC	FINDVAC
		CADR	CHKOPT
		TC	ENDOFJOB

1CHECK		AD	MINUS1		# SEE IF 01 REQUESTED.
		CCS	A
		TC	V37BAD
		TC	CCSHOLE
		TC	V37BAD

		CCS	MODREG		# DEMAND IDLE MODE.
		TC	V37BAD

		CAF	PRIO20
		TC	FINDVAC
		CADR	TOP1
		TC	ENDOFJOB

V37BAD		TC	FALTON		# ILLEGAL REQUEST.
		TC	ENDOFJOB

