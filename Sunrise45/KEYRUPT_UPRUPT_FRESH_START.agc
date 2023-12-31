### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	KEYRUPT_UPRUPT_FRESH_START.agc
## Purpose:	A section of Sunrise 45.
##		It is part of the reconstructed source code for the penultimate
##		release of the Block I Command Module system test software. No
##		original listings of this program are available; instead, this
##		file was created via disassembly of dumps of Sunrise core rope
##		memory modules and comparison with the later Block I program
##		Solarium 55.
## Assembler:	yaYUL --block1
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	2022-12-09 MAS	Initial reconstructed source.


		BANK	4
KEYRUPT1	MASK	LOW5		# C(IN0) IN A
		AD	BIT11
		TS	TMKEYBUF
		CAF	PRIO30
		TC	NOVAC
		CADR	CHARIN
		CAF	LOW5
		MASK	TMKEYBUF
		INDEX	LOCCTR
		TS	MPAC		# LEAVE 5 BIT KEY CDE IN MPAC FOR CHARIN
		TC	RESUME


UPRUPTB		CAF	ZERO
		XCH	UPLINK		# ZERO UPLINK
		TS	KEYTEMP1
		CCS	DSPTAB +7	# TURN ON UPACT LIGHT
		TC	+2		# UPACT = BIT 11 OF DSPTAB +7
		CAF	B12-1		# SAFETY PLAY
		AD	ONE
		TS	KEYTEMP2	# MAG OF DSPTAB +7 INTO KEYTEMP2
		MASK	BIT11
		CCS	A
		TC	UPRPT1		# BIT 11 ALREADY ONE
		XCH	KEYTEMP2	# BIT 11 = 0
		AD	BIT11
		CS	A		# STORE NEGATIVELY
		XCH	DSPTAB +7
		CCS	A
		TC	INCNOUTU	# PREVIOUS CONTENTS WAS +
		NOOP			# SAFETY PLAY
UPRPT1		CAF	LOW5		# TEST FOR TRIPLE CHAR REDUNDANCY
		MASK	KEYTEMP1	# LOW5 OF WORD
		XCH	KEYTEMP1	# LOW5 INTO KEYTEMP1
		XCH	SR		# WHOLE WORD INTO SR
		TS	KEYTEMP2	# ORIGINAL SR INTO KEYTEMP2
		TC	SRGHT5
		MASK	LOW5		# MID 5
		AD	HI10
		TC	UPTEST
		TC	SRGHT5
		MASK	LOW5		# HIGH 5
		COM
		TC	UPTEST
UPOK		TC	RESTORSR	# CODE IS GOOD
		XCH	KEYTEMP1
		AD	BIT6
		TC	KEYRUPT1 +1

TMFAIL2		TC	RESTORSR	# CODE IS BAD
		TC	TMFAIL
		TC	RESUME

RESTORSR	XCH	KEYTEMP2
		DOUBLE
		TS	SR
		TC	Q

SRGHT5		CS	SR
		CS	SR
		CS	SR
		CS	SR
		CS	SR
		CS	A
		TC	Q		# DELIVERS WORD UNCOMPLEMENTED

UPTEST		AD	KEYTEMP1
		CCS	A
		TC	TMFAIL2
		LOC	+1
		TC	TMFAIL2
		TC	Q

HI10		OCT	77740
UPBANK		EQUALS	EXECBANK	# IN SAME BANK AS EXEC.

B12-1		OCT	3777

INCNOUTU	XCH	NOUT
		AD	ONE
		TS	NOUT
		INDEX	Q
UPLAST		TC	1

# UPACT IS TURNED OFF BY VBRELDSP, ALSO BY ERROR LIGHT RESET.


# THE RECEPTION OF A BAD CODE BY UPLINK LOCKS OUT FURTHER UPLINK ACTIVITY 
# BY PLACING A 1 INTO UPLOCK (BIT2 OF STATE). BIT9 (AND BIT11) OF TMKEYBUF
# IS SET TO 1 TO SEND AN INDICATION OF THIS SITUATION DOWN THE DOWNLINK.
# THE UPLINK INTERLOCK IS ALLOWED WHEN AN ERROR LIGHT RESET CODE IS SENT
# UP THE UPLINK, OR WHEN A FRESH START IS PERFORMED.


		SETLOC	3200

UPRUPT		CAF	UPBANK
		XCH	BANKREG
		TS	BANKRUPT
		TC	UPRUPTB
