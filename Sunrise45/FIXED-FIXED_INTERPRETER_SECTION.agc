### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	FIXED-FIXED_INTERPRETER_SECTION.agc
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


		SETLOC	4000		# SECOND HALF OF FIXED-FIXED.

INTPRET		CCS	Q		# ENTRY TO INTERPRETER
		TS	ADRLOC

		CS	BANKREG		# GET BANKBITS
		TS	BANKSET
		TC	+3

NEWEQUN		CS	BANKSET		# HERE FOR NEW EQUATIONS
		TS	BANKREG
		CAF	ONE		# SET NEWEQIND TO CALL LOAD
		TS	NEWEQIND
		AD	ADRLOC		# C(ADRLOC) = LOCATION LAST ADDRESS USED
		TS	LOC		# FOR OPERATORS
		INDEX	A		# GET FIRST OP  AND NO. OF OPERATOR WORDS
		CS	0
		AD	MINUS1
		TS	ORDER
		MASK	LOW7		# NUMBER OF ADDITIONAL OPERATOR WORDS
		AD	LOC
		TS	ADRLOC		# AND SET ADRLOC
		CAF	ZERO		# TO SET ORDER TO ZERO
		TC	IPROC2


DANZIG		CCS	NEWJOB		# INTERPRETIVE INTERRUPT
		TC	CHANG2		# CALL IN BANK0 AND SWITCH JOBS

		CS	BANKSET		# RESET BANK BITS OF OBJECT PROGRAM
		TS 	BANKREG

		CCS	ORDER		# HAS NEXT OP CODE BEEN PROCESSED
		TC	LOWWD		# NEXT INSTRUCTION WAS RIGHT-HAND

		INDEX	LOC		# PICK UP POSSIBLE NEXT INSTRUCTION
		CS	1
		CCS	A
		TC	IPROC		# IT IS - GO PROCESS IT
		TC	+1		# IN CASE THE FIRST ADDRESS WAS INACTIVE

		INDEX	ADRLOC		# END OF EQUATION
		CS	1
		CCS	A		# IS THERE ANOTHER ADDRESS
		TC	PUSHDOWN	# NO - INSERT IN PUSH-DOWN LIST
D34		DEC	34		# USED TO DISPATCH STORE OPERATIONS

STORADR		TS	POLISH		# PROCESS STORE ADDRESSES
		TC	INCADR		# TO SHOW WE PICKED UP ANOTHER ADDRESS
		CAF	D34		# FORM CODES 32 - 34
		AD	MODE
		DOUBLE			# BECAUSE WE HAVE TO PUT IT INTO CYR
		TS	CYR
		CAF	LOW11
		MASK	POLISH		# SAVE ERASABLE PART PLUS POSSIBLE TAG
		XCH	POLISH
		AD	NEGIDEX		# DIRECT OR INDEXED
		CCS	A
		TC	INDEX		# IT IS INDEXED - PRESENT POLISH  OK
NEGIDEX		OCT	-33777		# NEGATIVE OF STORE ADDRESS PREFIX +1
		CS	BIT11
		AD	POLISH
		TS	POLISH
		TC	NONINDEX


IPROC		TS	ORDER		# OP CODE WORD WAS PICKED UP BY CCS
		XCH	LOC
		AD	ONE
		XCH	LOC
		MASK	LOW7		# SAVE LOW ORDER CODE
IPROC2		XCH	ORDER		# ENTRY FROM NEWEQUN
		INDEX	OPOVF
		MP	BIT8		# SHIFT IT RIGHT SEVEN PLACES
		TS	CYR		# GETTING RID OF THE RIGHT-HAND OP

JUMPIT		CCS	CYR		# LOOK AT LOW-ORDER PREFIX BIT
		TC	ADDRESS		# INDEXABLE - DECODE ADDRESS IMMEDIATELY
LOADOP		OCT	43		# USED BY UNARY LOAD

		CCS	CYR		# LOOK AT SECOND ONE HERE
		TC	INCADR		# PROCESS MISCELLANEOUS
		TC	MISCPROC

UNAPROC		CCS	NEWEQIND	# PROCESS UNARY REQUESTS
		TC	UNALOAD		# LOAD AN ACCUMULATOR AND RETURN

		CAF	LOW7
		TS	BANKREG		# CALL IN BANK 0 WHERE UNARIES ARE
		MASK	CYR		# WITHOUT CLOBBERING
		INDEX	A
		TC	UNAJUMP


#	PROCESS MISCELLANEOUS OP CODES.

MISCPROC	INDEX	A
		CS	0		# WE KNOW ITS AN ADDRESS
		AD	ONE		# TO FIT IN WITH THE POLISH ADDRESS SCHEME
		TS	POLISH		# SAVE ENTIRE ADDRESS

		CCS	A
		TC	ENDMISC
42K		OCT	42000
		TC	+2
		TC	MISCREL
		AD	BANKMASK
		CCS	A
		AD	ONE
		TC	+2
		TC	MISC2

		AD	42K
		COM
		TS	POLISH
		TC	ENDMISC

MISC2		AD	RELTEST
		CCS	A
		CS	POLISH
		TC	+3
		CS	POLISH
		TC	+2
MISCREL		AD	FIXLOC
		TS	ADDRWD

ENDMISC		CAF	LOW7
		TS	BANKREG		# CALL IN BANK 0
		MASK	CYR
		INDEX	A
		TC	NONJUMP


UNALOAD		CAF	LOW7		# PROCESS LOADING REQUESTS FOR UNARY
		MASK	CYR		# OPERATIONS. START BY FINDING APPROPRIATE
		CCS	A		# MODE
		TC	+3		# TMOVE HAS CODE 0
		CS	TWO
		TC	MODESET
		CS	A
		AD	OCT40003
		TS	MODE		# SKIP IF SO AND SET A TO -1
		CS	ZERO		# IF WE DIDNT SKIP
MODESET		TS	MODE

		CAF	NEGSIGN		# GET INDEXING BIT FROM UNARY OP CODE IN
		MASK	CYR		# CYR
		AD	LOADOP		# AD LOAD OPCODE = OCT 43
60K		DOUBLE			# DOUBLE OP CODE AND DUPLICATE SIGN IN
		XCH	CYR		# BIT 1 WHERE IT GOES INTO SIGN OF CYR
		TS	SL		# RE-EDIT, NOT BOTHERING ABOUT BITS 8-14
		TC	ADDRESS		# STANDARD ADDRESS ROUTINE

ULRET		TS	NEWEQIND	# RETURN HERE AFTER LOADING
		XCH	SL
		TS	CYR		# RESTORE ORIGINAL OP CODE
		TC	UNAPROC +2	# AND DISPATCH AS USUAL

LOWWD		CAF	ZERO		# RIGHT HAND OP CODE HAS ALREADY BEEN SET
		XCH	ORDER
		TC	JUMPIT -1


LOAD		TS	NEWEQIND	# LOADS FIRST ADDRESS OF NEW EQUATIONS
		INDEX	MODE		# TRIGGERS TYPE OF CLEAR-AND-ADD
		TC	+3
		TC	TCA1
		TC	DCA1
		TC	VCA1

LOADRET		CCS	NEWEQIND	# IF A UNARY LOAD, THIS IS STILL ONE
		TC	ULRET		# NO SECOND ADDRESS FOR UNARY LOADS

		CS	BANKSET
		TS	BANKREG

ADDRESS		INDEX	ADRLOC		# INDEXABLE ADDRESS ROUTINE
		CS	1		# PICK UP WHAT SHOULD BE THE NEXT ADDRESS
		CCS	A
		TC	PUSHUP		# NO ADDRESS MEANS TAKE OFF TOP OF STACK
		TC	PUSHUP2		# INACTIVE ADDRESS MEANS JUST PUSHUP
		XCH	ADRLOC		# SAVE ADDRESS WHILE WE INCREMENT ADRLOC
		AD	ONE
		XCH	ADRLOC		# NOW BRING IT BACK
		TS	POLISH
		CAF	NEGSIGN
		MASK	CYR
		CCS	A		# INDEXED OR NOT
BUGMPAC		XCADR	MPAC
		TC	NONINDEX


#	PROCEDURE FOR INDEXED ADDRESSES.

INDEX		XCH	POLISH
		TS	SR		# SR NOW CONTAINS SUB-ADDRESS
		XCH	CYR		# SAVE ORDER CODE
		TS	CYL		# TO PREPARE FOR RESTORING
		TC	TAG
		INDEX	TAG1
		CS	X1		# INDEX REGISTERS ARE SUBTRACTIVE, ALA 70X
		AD	SR
		XCH	POLISH		# TS WOULD SKIP ON OVERFLOW

		XCH	CYL		# RESTORE OP CODE BITS IN CYR
		TS	CYR

		CCS	POLISH		# SEE IF BIT 15 SHOULD BE ZERO.  IT SHOULD
		TC	NONINDEX	# IF THE ADDRESS IS LESS THAN ROUGHLY
		TC	RELTOVAC +1	# -1000D.
		TC	+2
		TC	RELTOVAC +1	# QUICK ACTION ON THESE ZERO CASES.

		AD	RELTEST		# (-976D).
		CCS	A
		XCH	POLISH		# LESS THAN -1000. GO DIRECTLY TO
		TC	SWADDR		# SWITCHED-BANK ADDRESS ROUTINE.


NONINDEX	CS	POLISH		# GET 14 BIT ADDRESS
		AD	ERASTEST	# SEE IF ERASABLE OR NOT
		CCS	A
		AD	RELTEST		# YES - SEE IF IN TEMPORARY BLOCK
		TC	TEST2
		AD	STORTEST	# NO - SEE IF STORE ADDRESS
		CCS	A
		TC	PUSHUP3		# YES - PUSHUP
RELTEST		DEC	-976
		CAF	BIT15
		AD	POLISH
SWADDR		TS	BANKREG
		TS	POLISH
		MASK	LOW10
		AD	6K
		TS	ADDRWD
		TC	JUMP

TEST2		CCS	A		# DOES THIS REFER TO THE TEMPORARY BLOCK
		TC	RELTOVAC	# ADDRESS IS RELATIVE TO VAC AREA.
LOW11		OCT	3777
		XCH	POLISH		# YES - FORM ADDRESS
		TS	ADDRWD

JUMP		CAF	THREE		# LOOK AT LOW-ORDER 2 BITS IN 5 BIT CODE
		MASK	CYR
		CCS	A		# IF ZERO, LOAD NOW AND CALL IN BANK 0
		TC	+3		# NON-ZERO - GO ON.
		TC	DPSET		# LOAD DP IF NECESSARY
		TS	BANKREG		# CALL IN BANK 0
		CAF	LOW7		# BITS 6-13 ARE GUARANTEED TO BE ZERO
		MASK	CYR
		INDEX	A
		TC	INDJUMP


PUSHDOWN	XCH	PUSHLOC		# NO STORE ADDRESS GIVEN - PUSH DOWN
		TS	ADDRWD		# STORED IN THE NEXT ENTRY
		INDEX	MODE
		AD	NO.WDS		# 2 FOR DP, 6 FOR VECTORS, 3 FOR TP
		TS	PUSHLOC
		INDEX	MODE
		TC	INDJUMP +34D	# DISPATCH TO CORRECT STORE INSTRUCTION

PUSHUP1		XCH	Q		# THE PUSH-UP ROUTINE IS CALLED UNDER THE
		TS	COMPON		# FOLLOWING CIRCUMSTANCES:
		CAF	LOW7		#    1. NO ADDRESS WORD IS FOUND.
		MASK	CYR		#    2. A STORE ADDRESS IS FOUND.
		AD	-VXSC		# OR 3. AN INACTIVE ADDRESS IS FOUND.
		CCS	A		# IF THE REQUESTING OPERATION CODE IS VXSC
		TC	PUSHUPOK	# THE MODE MUST BE SWITCHED BEFORE PUSHING 
MINUS1		OCT	-1		# UP, SINCE VXSC DEMANDS AN ARGUMENT OF
		TC	PUSHUPOK	# THE OPPOSITE MODE (SCALAR NEEDS VECTOR, 

		CCS	MODE		# ETC.)
MINUS2		OCT	-2		# UNUSED CCS BRANCHES.
NEG3		OCT	-3
		CS	FOUR
		AD	NEG2
		TC	+3
PUSHUPOK	INDEX	MODE		# DO PUSH-UP OPERATION.
		CS	NO.WDS		# 2, 3, OR 6.
		AD	PUSHLOC
		TS	PUSHLOC
		TS	ADDRWD		# SET ADDRWD AND LEAVE ADDRESS IN A.
		TC	COMPON

-VXSC		EQUALS	MINUS2

PUSHUP2		TC	INCADR		# SENT HERE ON INACTIVE ADDRESS

PUSHUP		TC	PUSHUP1		# NO ADDRESS GIVEN SENDS US HERE
		TC	JUMP		# AND JUMP

PUSHUP3		CCS	ADRLOC		# AN UNEXPECTED STORE ADDRESS SENDS US
		TS	ADRLOC		# HERE.
		TC	PUSHUP

RELTOVAC	XCH	POLISH		# ADDRESS WAS LESS THAN 42, SO ADD
		AD	FIXLOC		# ADDRESS OF VAC AREA.
		TC	JUMP -1

INCADR		CAF	ONE
		AD	ADRLOC
		TS	ADRLOC
		TC	Q


IJUMP		TC	ITCF		# INTERPRETIVE TRANSFER CONTROL
		TC	VXSC1		# VECTOR TIMES SCALAR
		TC	VSU1		# VECTOR SUBTRACT
		TC	BMN1		# BRANCH MINUS
		TC	STZ1		# STORE ZERO
		TC	BOVF		# BRANCH ON OVERFLOW
		TC	DAD2		# DOUBLE PRECISION ADD
		TC	BHIZ1		# BRANCH IF MAJOR PART ZERO
		TC	DSU2		# DP SUBTRACT
		TC	DBSU		# DP BACKWARDS SUBTRACT
		TC	DMP2		# DP MULTIPLY
		TC	SHIFTL		# TP LEFT SHIFT
		TC	DDV		# DP DIVIDE
		TC	BDDV		# DP BACKWARDS DIVIDE
		TC	TRAD		# TRIPLE PRECISION ADD
		TC	TSLC		# TP SHIFT LEFT AND COUNT
		TC	SHIFTR1		# TP SHIFT RIGHT
		TC	DMP2		# DP MULTIPLY AND THEN ROUND
		TC	TSU1		# TP SUBTRACT
		TC	SIGN		# AFFIX SIGN OF X TO MPAC
		TC	MXV1		# MATRIX TIMES VECTOR
		TC	VXM1		# VECTOR TIMES MATRIX
		TC	VAD1		# VECTOR ADD
		TC	BZE1		# BRANCH ON ZERO
		TC	BVSU1		# BACKWARDS VECTOR SUBTRACT
		TC	VSRT1		# VECTOR SHIFT RIGHT
		TC	VSLT1		# VECTOR SHIFT LEFT
		TC	BPL1		# BRANCH POSITIVE
		TC	DOT1		# VECTOR DOT PRODUCT
		TC	CROSS1		# VECTOR CROSS PRODUCT
		TC	VPROJ1		# VECTOR PROJECTION

		TC	TTS1
		TC	DTS1		# DP TRANSFER TO STORAGE
		TC	VTS1		# VECTOR TS
		TC	LOAD +1		# LOADING

6K		EQUALS	IJUMP +3	# BMN STARTS AT LOCATION 6000

INDJUMP		EQUALS	IJUMP -1


NONJUMP		TC	EXIT
		TC	AXT		# ADDRESS TO INDEX TRUE
		TC	LXA		# LOAD INDEX FROM THE ADDRESS
		TC	LXC		# LOAD INDEX FROM ADDRESS COMPLEMENTED
		TC	SXA		# STORE INDEX IN THE ADDRESS
		TC	XCHX		# INDEX REGISTER EXCHANGE
		TC	INCR		# INDEX REGISTER INCREMENT
		TC	XAD		# INDEX REGISTER ADD FROM ERASABLE
		TC	XSU		# INDEX REGISTER SUBTRACT FROM ERASABLE
		TC	AST		# ADDRESS TO STEP TRUE
		TC	AXC		# ADDRESS TO INDEX COMPLEMENTED
		TC	TIX		# TRANSFER ON INDEX
		TC	NOLOAD		# LEAVE MPAC (OR VAC) LOADED
		TC	ITA1		# TRANSFER ADDRESS
		TC	SWITCHEM	# SWITCH AND TEST INSTRUCTIONS
		TC	NEXT		# LODON AND ITCQ

UNAJUMP		TC	TMOVE		# FOR TP AS WELL
		TC	VMOVE
		TC	UNIT
		TC	ABVAL1		# ABVAL
		TC	VSQ		# SQUARE OF VECTOR LENGTH
		TC	SSP		# ABSOLUTE VALUE OF SCALAR
		TC	ARCSIN1
		TC	ARCCOS1
		TC	SIN1
		TC	COS1
		TC	SQRTS
		TC	SQUARE
		TC	COMP		# COMPLEMENT
		TC	DMOVE
		TC	SMOVE
		TC	VDEF		# VECTOR DEFINE


THREE		OCT	3
		OCT	2
NO.WDS		OCT	6		# 3, 2, 6 ORDER IMPORTANT FOR PUSH-DOWN.

POSMAX		OCT	37777		# MUST BE 2 LOCATIONS BEFORE NEGMAX
FIVE		OCT	5
LIMITS		EQUALS	POSMAX +1	# USED BY CDU COUNTER ARITHMETIC PROGRAMS.

BIT15		OCT	40000
BIT14		OCT	20000
BIT13		OCT	10000
BIT12		OCT	04000
BIT11		OCT	02000
BIT10		OCT	01000
BIT9		OCT	00400
BIT8		OCT	00200
BIT7		OCT	00100
BIT6		OCT	00040
BIT5		OCT	00020
BIT4		OCT	00010
BIT3		OCT	00004
BIT2		OCT	00002
BIT1		OCT	00001

QUARTER		EQUALS	BIT13
EIGHT		EQUALS	BIT4
ONE		EQUALS	BIT1
ERASTEST	EQUALS	BIT11
BUGBITS		EQUALS	5777
ATSBITS		EQUALS	5777
NEG2		EQUALS	MINUS2
SIX		EQUALS	NO.WDS
NEG1		EQUALS	MINUS1
NEGSIGN		EQUALS	BIT15

NEG1/2		2DEC	-.5
POS1/2		2DEC	.5
HALF		EQUALS	POS1/2


TCS1		CS	BUF +2		# USED BY DMP, ETC
		TS	MPAC +2
		CS	BUF +1
		TS	MPAC +1
		CS	BUF
		TS	MPAC
		TC	Q

TCA1		INDEX	ADDRWD		# TRIPLE PRECISION CLEAR AND ADD
		CS	2
		CS	A
		TC	+2

DCA1		XCH	ZERO		# DOUBLE PRECISION CLEAR AND ADD
		TS	MPAC +2		#   (CLEARS MPAC +2)
		INDEX	ADDRWD
		CS	1
		CS	A
		TS	MPAC +1
		INDEX	ADDRWD
		CS	0
		CS	A
		TS	MPAC
		TC	LOADRET		# PREPARE TO DECODE NEXT ADDRESS

STORE3		CS	MPAC +2		# TRIPLE PRECISION TRANSFER TO STORAGE
		CS	A
		INDEX	ADDRWD
		TS	2
DTS1		CS	MPAC +1		# DOUBLE PRECISION TRANSFER TO STORAGE
		CS	A
		INDEX	ADDRWD
TSQ		TS	1
		CS	MPAC
MSIGN		CS	A
		INDEX	ADDRWD
		TS	0
NEQRET		TC	NEWEQUN		# START NEW EQUATION

TTS1		EQUALS	STORE3
#							35W


DOBR		XCH	POLISH		# DOES BRANCHES
		TC	DOBR2

EXIT2		CS	BANKSET		# COMPLETE EXIT EXECUTION BY CALLING IN
		TS	BANKREG		# BANK OF OBJECT INTERPRETIVE PROGRAM.
		TC	ADRLOC

SWF/F		CS	BANKSET		# BRANCHING TEST INSTRUCTION
		TS	BANKREG		# RETURNS HERE TO PICK UP BRANCHING ADDRES
		INDEX	ADRLOC
		CAF	0		# BRANCH IS ALWAYS TO FIXED.
		AD	NEG1		# UNDO YULISH INCREMENT.
		AD	BIT15

DOBR2		TS	BANKREG
		MASK	LOW10
		AD	6K-1
		TC	INTPRET +1

LOW10		OCT	1777
LOW9		OCT	777
6K-1		OCT	5777

VCA1		XCH	Q		# VECTOR CLEAR-AND-ADD ROUTINE
		TS	TEM5
		CAF	NEGSIGN
		TC	VECMOVE
		TC	TEM5

VCS1		XCH	Q		# DP VECTOR CLEAR-AND-SUBTRACT
		TS	TEM5
		CAF	NOOP
		TC	VCA1 +3

VTS1		XCH	ADDRWD		# TRANSFER TO STORAGE
		XCH	VACLOC		# EXCHANGE VACLOC AND ADDRWD AND DO AN
		TS	ADDRWD		# EFFECTIVE *CLEAR-AND-ADD*.
		CAF	NEGSIGN
		TC	VECMOVE
		XCH	ADDRWD		# RESTORE VACLOC
		TS	VACLOC
		TC	NEWEQUN		# THIS ONLY HAPPENS AT END OF EQUATION


VECMOVE		TS	TEM2		# MOVES A DP VECTOR IN THE FASTEST WAY
		INDEX	ADDRWD		# AVAILABLE. USED BY VCA, VCS, AND VTS.
		CS	5
		INDEX	TEM2
		0	0		# COM FOR VCA, VTS. NOOP FOR VCS.
		INDEX	VACLOC
		TS	5

		INDEX	ADDRWD
		CS	4
		INDEX	TEM2
		0	0
		INDEX	VACLOC
		TS	4

		INDEX	ADDRWD
OCT40003	CS	3		# CONSTANT USED BY UNARY LOAD ROUTINE.
		INDEX	TEM2
		0	0
		INDEX	VACLOC
		TS	3

		INDEX	ADDRWD
OCT40002	CS	2
		INDEX	TEM2
		0	0
		INDEX	VACLOC
		TS	2

		INDEX	ADDRWD
CSQ		CS	1		# CONSTANT USED BY WAITLIST.
		INDEX	TEM2
		0	0
		INDEX	VACLOC
		TS	1

		INDEX	ADDRWD
		CS	0
		INDEX	TEM2
		0	0
		INDEX	VACLOC
		TS	0

		TC	Q		# DONE


STZ1		CAF	ZERO
		INDEX	ADDRWD
		TS	0

RE-ENTER	CS	BANKSET		# ROUTINE  SIMILAR TO 'DANZIG' EXCEPT THAT
		TS	BANKREG		# NO PUSHING DOWN IS DONE AT END OF EQUN.

		CCS	ORDER		# IT IS USED BY MISCELLANEOUS INSTRUCTIONS
		TC	LOWWD		# AND BRANCHES WHICH FAILED

		INDEX	LOC		# IF WE HAD RETURNED DIRECTLY TO THE MAIN
		CS	1
		CCS	A
		TC	IPROC		# IT IS USED BY BRANCH INSTRUCTIONS WHICH
NOOP		NOOP			# IN CASE THE FIRST ADDRESS WAS INACTIVE

		INDEX	ADRLOC		# SEE IF A LEFT-OVER ADDRESS
		CS	1
		CCS	A
		TC	NEWEQUN		# NO - START NEW EQUATION
LOW7		OCT	177
		TC	STORADR		# YES - MUST BE STORE ADDRESS

STOR1		EQUALS	STZ1 +1


TAG		CCS	CYR		# SETS TAG1 ACCORDING TO SIGN BIT IN CYR
		CAF	ZERO
		CCS	A		# SKIP NEXT INS WITHOUT CHANGING Q
		CAF	ONE
		AD	FIXLOC		# INDEXES AND STEPS IN VAC AREA
		TS	TAG1
		TC	Q

TCBUF		ADRES	BUF

DSU2		TC	DPSET		# DP SUBTRACT
		TC	ADDTOSUB
		TC	DAD2 +1

DBSU		TC	DPSET
		TC	DACCOM		# COMPLEMENT DP ACCUM
		TC	DAD2 +1		# AND ADD

MPACCOM		CS	MPAC +2		# COMPLEMENT MPAC
		TS	MPAC +2
DACCOM		CS	MPAC +1
		TS	MPAC +1
		CS	MPAC
		TS	MPAC
		TC	Q

DPSET		CS	ONE		# SET UP DP MODE AND LOAD IF NECESSARY
		TS	MODE
		CCS	NEWEQIND
		TC	LOAD
		TC	Q

VECSET		CS	ZERO		# SIMILARLY FOR VECTORS
		TS	MODE
		CCS	NEWEQIND
		TC	LOAD
		TC	Q

TPSET		CS	TWO		# AND FOR TP
		TS	MODE
		CCS	NEWEQIND
		TC	LOAD
		TC	Q


DAD2		TC	DPSET		# DOUBLE PRECISION ADD INSTRUCTION
		CAF	DAD2 +4
		TC	DAD1		# PROGRAM USES CLOSED SUBROUTINE DAD1, 
		TC	INT1		# WITH ADDRESSES SET UP IN ADDRWD, TEM2

 +4		ADRES	MPAC

TSU1		TC	TPSET		# TRIPLE PRECISION SUBTRACT INSTRUCTION
		TC	ADDTOSUB
		TC	TRAD +1

TRAD		TC	TPSET		# TRIPLE PRECISION ADD INSTRUCTION
		TC	+2
		TC	INT1

 +3		XCH	Q
		TS	TEM5
		CAF	DAD2 +4
		TS	TEM2
		INDEX	A
		XCH	2
		INDEX	ADDRWD
		AD	2
		INDEX	TEM2
		TS	2		# AGAIN SKIPPING, AS IN DAD1
		CAF	ZERO
		INDEX	TEM2
		AD	1
		TC	DAD1 +3		# FINISH IN DAD1

		TC	TEM5		# AND RETURN


DAD1		TS	TEM2		# DOUBLE PRECISION ADD ROUTINE
		INDEX	TEM2		# POLYNOMIAL EVALUATOR ENTERS HERE.
		XCH	1
 +3		INDEX	ADDRWD
		AD	1
		INDEX	TEM2
		TS	1		# SKIPS IF OVERFLOW WITH COUNT IN A
		CAF	ZERO		# NO OVERFLOW IF HERE
		INDEX	TEM2		# ARRIVE HERE WITH 1 OR -1 IN A IF OVERFLO
		AD	0
		INDEX	ADDRWD
		AD	0
		INDEX	TEM2
		TS	0		# AND AGAIN SKIP IF OVERFLOW
		TC	Q		# EXIT IF NONE
		TS	OVFIND		# SAVE ANY OVERFLOW FOR BOV TESTING
		TC	Q

8TO2		TS	TEM8		# MOVES THE DP WORD LOCATED AT THE ADDRESS
		INDEX	A		# IN A TO THE ADDRESS IN TEM2
		CS	0
		CS	A
		INDEX	TEM2
		TS	0
		INDEX	TEM8
		CS	1
		CS	A
		INDEX	TEM2
		TS	1
		TC	Q

ADDTOSUB	XCH	ADDRWD		# BY PUTTING THE APPROPRIATE BITS IN
		AD	ATSBITS		# ADDRWD, DAD1 DOES A DOUBLE SUBTRACT IN-
		TS	ADDRWD		# STEAD OF A DOUBLE ADD.
		TC	Q


DMP2		TC	DPSET		# DP MULTIPLY (AND ROUND) ROUTINE
		XCH	ADDRWD
		AD	BUGBITS		# MAKE EXENDED CODE ADDRESS.
DSQ2		TS	TEM4		# ENTRY FROM DSQ ROUTINE.
		XCH	DAD2 +4		# C(DAD2 +4) = TC MPAC
		TC	DMP1		# EXECUTE MULTIPLY AT DMP1, THEN EXIT
		TC	TCS1		# VIA TCS1 TO MOVE (BUF TO BUF+2)
					# INTO (MPAC TO MPAC+2).

OCT40020	CS	CYR
		CCS	CYR
MPACRND		CAF	DAD2 +4		# SET UP ROUND SUBROUTINE TO ROUND MPAC.
		TC	PREROUND +1
		TC	DANZIG

SHIFTR1		TC	DPSET		# TSRT INSTRUCTION.
		TS	BANKREG		# SUBROUTINE IN BANK 0
		TC	TRUE2		# GET INTEGER ADDRESS BACK
		TC	SHIFTR -1	# WITH DECREMENTED COUNT IN A.
		TC	DANZIG


DMP1		TS	TEM2		# GENERAL PURPOSE DP MULTIPLICATION
		INDEX	TEM2		# POLYNOMIAL ENTERS HERE.
		CS	1
		TS	OVCTR		# -N1 TO OVCTR
		INDEX	TEM4
		MP	1		# -M1N1
		XCH	OVCTR		# -U(M1N1) TO OVCTR, -N1 TO A
		INDEX	TEM4
		MP	0		# -M0N1
		XCH	OVCTR		# -U(M0N1) TO OVCTR, -U(M1N1) TO A
		AD	LP		# MAYBE INCREMENT -U(M0N1) IN OVCTR
		XCH	BUF +1		# -L(M0N1)-U(M1N1) TO BUF+1
		INDEX	TEM2
		CS	0
		TS	BUF +2		# -N0 TO BUF+2
		INDEX	TEM4
		MP	1		# -M1N0
		XCH	OVCTR		# -U(M1N0) TO OVCTR, -U(M0N1) TO A
		XCH	BUF +1		# -U(M0N1) TO BUF+1, -L(M0N1)-U(M1N1) TO A
		AD	LP		# MAYBE INCREMENT -U(M1N0) IN OVCTR
		XCH	BUF +2		# -L(M1N0)-L(M0N1)-U(M1N1) TO BUF+2, -N0 T
		INDEX	TEM4		# O A
		MP	0		# -M0N0
		XCH	OVCTR		# -U(M0N0) TO OVCTR, -U(M1N0) TO A
		AD	LP
		XCH	BUF +1
		AD	BUF +1
		XCH	BUF +1
		XCH	OVCTR
		TS	BUF
		TC	Q

# 	TIMING:  86 MC +-2  OR 1.032 MS +-0.024				30 WORDS


BDDV		TC	DPSET		# BACKWARDS DP DIVIDE
		CAF	ONE		# SET SWITCH
		TC	+2		# AND GO ON AS USUAL

DDV		TC	DPSET		# REGULAR DP DIVIDE
		TS	DVSW		# DPSET RETURNS WITH 0 IN A
		CAF	LDANZIG		# RETURN TO DANZIG
		TS	TEMQ3
		CAF	TCBUF
		TS	TEM2
		XCH	ADDRWD
		TC	8TO2		# X,X+1 INTO BUF, BUF+1

		CAF	ZERO
		TS	BANKREG		# CALL IN BANK 0
		TC	DDV0		# TO BANK 0 PORTION

DMP		XCH	Q		# DP MULTIPLY ROUTINE WHICH CAN BE CALLED
		TS	TEM5		# BY TC DMP, FOLLOWED BY A WORD CONTAINING
		INDEX	A		# THE ADDRESS OF THE MULTIPLIER WITH
		CAF	0		# BITS IN THE ORDER CODE TO CALL IN MP
		TS	TEM4		# IN THE EXTENDED CODE (UNKNOWN AS YET)
		CAF	DAD2 +4
		TC	DMP1
		TC	TCS1
		INDEX	TEM5		# TIME IS 120 MC+-2, OR ABOUT 1.44 MS
		TC	1		# RETURN TO INSTRUCTION AFTER ADDRESS WORD

DAD		XCH	Q		# DP ADD ROUTINE WORKING JUST AS MP ABOVE
		TS	TEM5		# HERE, HOWEVER, ONLY *ADRES X* IS NEEDED
		INDEX	A		# SINCE AD IS PART OF THE REGULAR CODE
		CAF	0
		TS	ADDRWD
		CAF	DAD2 +4
		TC	DAD1
		INDEX	TEM5
		TC	1		# TIME IS 48+-2 MC OR 576 MICRO-SEC.


VACCOM		XCH	Q		# COMPLEMENT THE APPROPRIATE VAC
		TS	TEM5
		CS	VACLOC
		COM
		XCH	ADDRWD
		TS	TEM4
		TC	VCS1 +2

VSU1		TC	VECSET		# DP VECTOR SUBTRACT
		TC	ADDTOSUB
		TC	VAD1 +1		# USES VAD ROUTINE WITH SUBS

BVSU1		TC	VECSET		# DP VECTOR BACKWARDS SUBTRACT
		TC	VACCOM		# JUST COMPLEMENT VAC
		XCH	TEM4
		TS	ADDRWD
		TC	VAD1 +1		# AND ADD

VAD1		TC	VECSET
		XCH	VACLOC		# DP VECTOR ADD
		TS	VACLOC
		TC	DAD1
		TC	AD2
		TC	INCRT2
		TC	DAD1
		TC	AD2
		TC	INCRT2
		TC	DAD1
		TC	INT1


DOT1		TC	VECSET		# DP DOT PRODUCT ROUTINE
		TC	DOT2
		TC	MPACCOM
DPEXIT		CS	ONE		# CHANGE MODE TO DOUBLE-PRECISION
		TS	MODE
		TC	DANZIG

AD2		XCH	ADDRWD
		AD	TWO
		TS	ADDRWD
		TC	Q

DOT2		XCH	TWO		# SUBROUTINE DOT2 COMPUTES THE TRIPLE-
		TS	TEM11
		XCH	TCBUF		# SIGN, IN MPAC TO MPAC+2.
		XCH	ADDRWD
		AD	BUGBITS
		TS	TEM4
		XCH	Q
		TS	TEM8
		XCH	VACLOC
		TS	VACLOC
		TC	DMP1
		XCH	BUF
		TS	MPAC
		XCH	BUF +1
		TS	MPAC +1
		XCH	BUF +2
		TS	MPAC +2
		TC	INCRT4
		TC	INCRT2
		TC	DMP1
		TC	TRAD +3
		TC	INCRT4
		XCH	VACLOC
		TS	VACLOC
		AD	FOUR
		TC	DMP1
		TC	TRAD +3
		TC	TEM8


INCRT4		XCH	TEM4
		AD	TEM11
		TS	TEM4
		TC	Q

VXM1		TC	VECSET		# DP VECTOR TIMES MATRIX
		CS	ADDRWD
		TS	TEM10
		XCH	TWO
		TS	TEM9
		XCH	SIX
		TC	DOT2 +1
		TC	MXV2		# REST OF OPERATION USES MXV ROUTINE

MXV1		TC	VECSET		# MATRIX TIMES DP VECTOR
		CS	ADDRWD
		TS	TEM10
		XCH	SIX		# PROGRAM USES DOT PRODUCT ROUTINES TO
		TS	TEM9
		TC	DOT2

MXV2		CAF	K2		# USES VBUF
		TC	STORDAC
		CS	TEM10
		AD	TEM9
		TS	TEM10
		TS	ADDRWD
		TC	DOT2 +2

		CAF	K2 +1
		TC	STORDAC
		XCH	TEM10
		AD	TEM9
		TS	ADDRWD
		TC	DOT2 +2
		CAF	K2
		TS	ADDRWD
		AD	FOUR
		TC	STORDAC
		TC	VCA1
		TC	DANZIG

STORDAC		TS	TEM4		# SUBROUTINE TO STORE MPAC, MPAC+1 IN
		CS	MPAC		# ADDRESSES INDICATED BY C(A) AT ENTRY.
		INDEX	TEM4
		TS	0
		CS	MPAC +1
		INDEX	TEM4
		TS	1
		TC	Q

VXSC1		CCS	NEWEQIND	# DP VECTOR TIMES SCALAR
		TC	VECSET		# LOAD INSTRUCTION
		CCS	MODE		# IF NOT, WHICH MODE ARE WE IN
SEVEN		OCT	7
MINUS13		DEC	-13

		TC	VECCHECK

		XCH	ADDRWD
		AD	BUGBITS		# TO CALL IN MP
		TC	VXSC2

VECCHECK	TC	VCA1		# USE ADDRWD TO LOAD VECTOR
		CAF	BUGMPAC


VXSC2		TS	TEM4
		CS	VACLOC
		COM
		TC	DMP1
		TC	PREROUND
		TC	STB
		TC	INCRT2
		TC	DMP1
		TC	ROUND
		TC	STB
		TC	INCRT2
		TC	DMP1
		TC	ROUND
		TC	STB
ZEROEXIT	CS	ZERO		# CHANGE MODE TO VECTOR
		TC	DPEXIT +1

INT1		EQUALS	DANZIG

INCRT2		XCH	TEM2
		AD	TWO
		TS	TEM2
		TC	Q


SHORTMP		XCH	MPAC +2		# MULTIPLY THE CONTENTS OF MPAC,MPAC+1, 
		EXTEND			# MPAC+2 BY THE SINGLE PRECISION NUMBER
		MP	MPAC +2		# ARRIVING IN A.
		XCH	MPAC +2

SHORTMP2	XCH	MPAC +1		# FASTER BUT SLOPPIER VERSION FOR DP
		EXTEND
		MP	MPAC +1
		TS	OVCTR
		XCH	LP
		AD	MPAC +2		# THE SHORTMP2 RESULT WILL BE OFF IN THE
		XCH	MPAC +2		#   LAST BIT IF THIS AD OVERFLOWS.
		XCH	MPAC
		EXTEND
		MP	MPAC +1
		XCH	OVCTR
		AD	LP
		XCH	MPAC +1
		XCH	OVCTR		# ARGUMENT IN OVCTR UPON EXIT
		TS	MPAC
		TC	Q

PREROUND	CAF	TCBUF
		TS	TEM8

ROUND		CAF	ZERO		# ROUND THE TRIPLE-PRECISION NUMBER WHOSE
		INDEX	TEM8		# ADDRESS IS IN TEM8 TO DOUBLE-PRECISION, 
		XCH	2		# SETING THE LOWEST ORDER OF THE THREE
		DOUBLE			# WORDS TO ZERO IN THE PROCESS
		TS	OVCTR
		TC	Q		# DONE IF DOESNT SKIP

		INDEX	TEM8
		AD	1
		INDEX	TEM8
		TS	1
		TC	Q

		INDEX	TEM8
		AD	0
		INDEX	TEM8
		TS	0		# ANY CARRIES BEYOND THIS POINT ARE
		TC	Q		# OVERFLOW

		TS	OVFIND
		TC	Q


STB		CS	BUF
		INDEX	TEM2
		TS	0
		CS	BUF +1
		INDEX	TEM2
		TS	1
		TC	Q

K2		0	VBUF
		0	VBUF +2
		0	VBUF +4

STORTEST	EQUALS	K2 -2

SEQ		OCT	2
ZERO		OCT	0
FOUR		OCT	4
TWO		OCT	2
NEG0		OCT	-0

VPROJ1		TC	VECSET		# VECTOR PROJECT
		TC	DOT2		# LEAVES (VAC,X)VAC IN VAC
		TC	DACCOM
		TC	VXSC2 -1	# FINISH IN VXSC (USING MPAC)

CROSS1		TC	VECSET		# DP VECTOR CROSS PRODUCT (BOTH WAYS)
		XCH	TCBUF
		XCH	ADDRWD
		AD	BUGBITS		# AGAIN FOR MP
		TS	BASE
		AD	TWO		# WHERE THE VECTOR X IS THAT ADDRESSED
		TS	TEM4		# BY THE ORDER, AND V IS C(VAC).
		XCH	TWO


LUP		TS	IND
		INDEX	IND
		XCH	SEQ
		AD	VACLOC
		TC	DMP1
		INDEX	IND
		XCH	SEQ +2
		AD	K2
		TS	TEM6
		TS	TEM2
		TC	STB
		INDEX	IND
		XCH	SEQ
		AD	BASE
		TS	TEM4
		INDEX	IND
		XCH	SEQ +1
		AD	VACLOC
		TC	DMP1
		XCH	TEM6
		TC	DAD1
		CCS	IND
		TC	LUP

CREXIT		XCH	K2
		TS	ADDRWD
		TC	VCS1		# VXV
LDANZIG		TC	DANZIG


# DOUBLE-PRECISION POLYNOMIAL EVALUATION ROUTINE.
#
# PROGRAM ENTRY
# 
# L		TC	POLY
#					                            N
# L+1		OCT	-2N		COMPUTES A  +A X + ... + A X , WHERE
#					          0   1           N
# L+2		D.P.	- A		X = C(MPAC).
#			   0
#
# -   -   -   -   -   -   -   -
#
# L+2+2N	D.P.	- A
#			   N
#
# L+4+2N	NEXT OPERATION

POLY		CAF	BUGBITS2	# CONTAINS XCADR VBUF
		TS	TEM4
		CAF	ZERO		# ZERO INTO BUF, BUF+1 TO START POLYLUP
		TS	BUF
		TS	BUF +1

		XCH	MPAC		# ARGUMENT  X  INTO 6T, 7T
		TS	VBUF		# TEMPORARY STORAGE
		XCH	MPAC +1
		TS	VBUF +1

		CAF	DAD2 +4		# ADDRESS OF MPAC
		TS	TEM2

		INDEX	Q		# 2N  INTO 10T
		CAF	0
		TS	TEM10
		AD	Q		# EXIT ADDRESS INTO 11T
		AD	THREE
		TS	TEM9
		TC	POLYLUP +3


POLYLUP		TS	TEM10
		TC	DMP1 +1

		XCH	ADDRWD
 +3		AD	NEG2		# REDUCE COEFFICIENT INDEX BY 1
		TS	ADDRWD		# COEFFICIENT LOC IN ADDRWD FOR USE BY
		TC	TCS1 +2		# -BUF,BUF+1 INTO MPAC,MPAC+1
		TC	DAD1 +1		# - COEFF + (BUF) INTO BUF

		CCS	TEM10
		AD	NEG1		# THE AD NEG1 ORDER, -0 WILL BE THE END
		TC	POLYLUP

BUGBITS2	XCADR	VBUF		# USED BY POLY

		TC	TEM9		# RETURN


ITCF		CS	BANKSET		# ITC - UNCONDITIONAL TRANSFER
		XCH	ADRLOC		# PLACE IN QPRET THE POLISH ADDRESS OF
		MASK	LOW10		# THE NEXT EQUATION. ITC MUST BE THE LAST
		AD	ADRLOC		# NON-BLANK OPERATOR IN AN EQUATION
		AD	ONE
		INDEX	FIXLOC
		TS	QPRET
		CCS	ADDRWD
		TC	INTPRET +1	# BANKREG IS ALREADY SET

BOVF		CCS	OVFIND		# BRANCH IF OVERFLOW INDICATOR IS ON
		TC	+2		# OVFIND CAN BE EITHER -1, 0, OR +1
		TC	DANZIG		# IT WAS OFF - DISPATCH NEXT OPERATOR.
		TS	OVFIND		# IT WAS ON - SET TO 0 (OFF)
		TC	DOBR		# AND DO THE BRANCH

VSLT1		TC	VECSET		# DP VECTOR SHIFT LEFT
		TS	BANKREG
		TC	VSLT2

VSRT1		TC	VECSET		# DP VECTOR SHIFT RIGHT
		TS	MPAC +1		# SET SHIFTING BIT IN MPAC,MPAC+1
		TS	BANKREG		# CALL IN BANK ZERO.
		TC	TRUE2		# GET INTEGER ADDRESS
		AD	NEG13
		CCS	A
		TC	VSRT3
NEG14		DEC	-14
		TC	+1
		INDEX	ADDRWD
		CAF	BIT15
		TS	MPAC
		TC	VECCHECK +1	# FINISH IN VXSC ROUTINE.

VSRT3		INDEX	A
		CAF	BIT14
		XCH	MPAC +1		# WHICH PREVIOUSLY CONTAINED A ZERO
		TC	VSRT3 -2

		SETLOC	5777		# STANDARD LOCATION FOR EXTENDING BITS

OPOVF		XCADR	0
