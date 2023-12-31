### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	IMU_PERFORMANCE_TESTS_2.agc
## Purpose:	A section of Sunrise 69.
##		It is part of the reconstructed source code for the final
##		release of the Block I Command Module system test software. No
##		original listings of this program are available; instead, this
##		file was created via disassembly of dumps of Sunrise core rope
##		memory modules and comparison with the later Block I program
##		Solarium 55.
## Assembler:	yaYUL --block1
## Contact:	Ron Burkey <info@sandroid.org>.
## Website:	www.ibiblio.org/apollo/index.html
## Mod history:	2023-06-19 MAS	Created from Solarium 55.
## 		2023-06-21 MAS	Updated for Sunrise 69, which involved copious
##				swapping of code with IMU PERFORMANCE TESTS 1.


		SETLOC	56000

# THIS IS A ROUGH CHECK PROGRAM FOR THE IMU GYROS AND ACCELEROMETERS

IMUCHK		CAF	QUARTER
		TS	AZIMUTH
		CAF	ZERO
		TS	AZIMUTH +1
		CAF	SIX
		TS	NBPOS
		CAF	BIT4
		TS	POSITON
		CS	A
		TS	GENPL +76D
		TC	STEVEIN
		
IMUCHKR		TC	BANKCALL	# CHECKS COARSE ALIGN AND GYRO TORQUING
		CADR	IMULOCK		# CHECKS ALL MODE SWITCHING
		TC	BANKCALL
		CADR	IMUSTALL
		TC	ENDOFJOB
		
		TC	BANKCALL
		CADR	IMUREENT
		TC	BANKCALL
		CADR	IMUSTALL
		TC	ENDOFJOB
		
		TC	BANKCALL
		CADR	IMUFINE
		CAF	ZERO
		TS	PIPAX
		TS	PIPAY
		TS	PIPAZ
		TC	BANKCALL
		CADR	IMUSTALL
		TC	ENDOFJOB
		
		CAF	ONE
		TS	RESULTCT
		TS	POSITON
		
IMUCHK1		CAF	TWO		# MEASURE TIME OF OCCURRENCE OF EACH
IMUCHK2		TS	PIPINDX2	# PIP PULSE. ALSO STORE VELOCITY
		INHINT
		TC	CHECKG
		CS	PIPAY
		CS	A
		INDEX	POSITON
		TS	DATAPL +30D
		CS	PIPAZ
		CS	A
		INDEX	POSITON
		TS	DATAPL +32D
		RELINT
		TC	DATALD1
		XCH	RESULTCT
		AD	FIVE
		TS	RESULTCT
		CCS	PIPINDX2
		TC	IMUCHK2
		CCS	POSITON
		TC	+2
		TC	COMPUT
		TS	POSITON
		CAF	BIT6
		TC	WARTMAL
		CCS	COUNTPL
		TC	WARTMAL2
		TC	IMUCHK1
		


COMPUT		CAF	ZERO		# CALC V1XV2 ANDROOT(GX)2+(GY)2+(GZ)2
		TS	DATAPL
		TS	DATAPL +5
		TS	DATAPL +10D
		XCH	DATAPL +30D
		TS	DATAPL +35D
		CAF	ZERO
		XCH	DATAPL +32D
		TS	DATAPL +37D
		CAF	TWO
		TS	DATAPL +15D
		TS	DATAPL +20D
		TS	DATAPL +25D
		TS	DATAPL +34D
		TS	DATAPL +36D
		

CHKCALC		TC	INTPRET
		RTB	1
		RTB
			ZEROVAC
			FRESHPD
		TSU	1
		TSLT	ROUND
			DATAPL +17D
			DATAPL +2
			12D
		DSU	2
		TSLT	DMP
		DDV
			DATAPL +15D
			DATAPL
			12D
			DC585		# GZ IN 0,1
		TSU	1
		TSLT	ROUND
			DATAPL +22D
			DATAPL +7
			12D
		DSU	2
		TSLT	DMP
		DDV
			DATAPL +20D
			DATAPL +5
			12D
			DC585		# GY IN 2,3
		TSU	1
		TSLT	ROUND
			DATAPL +27D
			DATAPL +12D
			12D
		STORE	TESTTIME
		DSU	2
		TSLT	DMP
		DDV	VDEF
			DATAPL +25D
			DATAPL +10D
			12D
			DC585
			TESTTIME	# G IN 0,1,2,3,4,5
		ABVAL	1
		TSLT	RTB
			0
			1
			SGNAGREE
		STORE	DSPTEM2
		EXIT	0
		TC	GRABDSP
		TC	PREGBSY
		TC	SHOW
		
		TC	INTPRET
		DMOVE	0
			DATAPL +32D
		DMOVE	0
			DATAPL +30D
		DMOVE	2
		VDEF	UNIT
		VSLT
			DATAPL +10D
			1		# V1 IN 6,7,8,9,10,11
		DMOVE	0
			DATAPL +36D
		DMOVE	0
			DATAPL +34D
		DMOVE	2
		VDEF	UNIT
		VSLT
			DATAPL +25D
			1		# V2 IN 12,13,14,15,1 ,17
		
		VXV	3
		ABVAL	TSLT
		DDV	DMP
		RTB
			6
			12D
			1
			TESTTIME
			ERUNITS1
			SGNAGREE
		STORE	DSPTEM2
		EXIT	0
		
		TC	SHOW
		TC	ENDTEST1


CHECKG		XCH	Q		# PIP PULSE CATCH ROUTINE
		XCH	QPLACE
		
CHECKG1		RELINT
		CCS	NEWJOB
		TC	CHANG1
		INHINT
		CAF	ZERO
		INDEX	PIPINDX2
		XCH	PIPAX
		TS	STOREPL
		CCS	STOREPL
		TC	CHECKP
		TC	RESTORE1
		TC	CHECKM
		TC	RESTORE1
		
CHECKP		CAF	BIT6		# LOOKS FOR ONE MORE   PULSE
CHECKP1		TS	PIPANO
		INDEX	PIPINDX2
		CCS	PIPAX
		TC	CHECKG3
		TC	+3
		TC	RESTORE1
		TC	+1
		CCS	PIPANO
		TC	CHECKP1
		TC	RESTORE1
CHECKM		CAF	BIT6		# LOOKS FOR ONE MORE  INUS
CHECKM1		TS	PIPANO
		INDEX	PIPINDX2
		CCS	PIPAX
		TC	RESTORE1
		TC	+3
		TC	CHECKG3
		TC	+1
		CCS	PIPANO
		TC	CHECKM1
		TC	RESTORE1

CHECKG3		CS	TIME2
		CS	A
		TS	MPAC
		CS	TIME1
		CS	A
		TS	MPAC +1
		CS	IN2
		CS	IN2
		CS	A
		MASK	FINEMSK1
		TS	MPAC +2
		CCS	A
		TC	+7
		CS	TIME2
		CS	A
		TS	MPAC
		CS	TIME1
		CS	A
		TS	MPAC +1
		XCH	MPAC +2
		EXTEND
		MP	BIT11
		XCH	LP
		TS	MPAC +2

		CAF	BIT4
CHECKG5		TS	PIPANO
		INDEX	PIPINDX2
		CCS	PIPAX
		TC	+4
		TC	RESTORE1
		TC	+2
		TC	RESTORE1
		CCS	PIPANO
		TC	CHECKG5
NREAD		TC	RESTORE
		TS	STOREPL
		TC	QPLACE
		
RESTORE1	TC	RESTORE
		TC	CHECKG1
		
RESTORE		XCH	STOREPL
		INDEX	PIPINDX2
		AD	PIPAX
		INDEX	PIPINDX2
		TS	PIPAX
		TC	Q



SHOW		XCH	Q
		TS	QPLACE
SHOW1		CS	POSITON
		CS	A
		TS	DSPTEM2 +2
		TC	BANKCALL
		CADR	FLASHON
		CAF	V06N66
		TC	NVSUB
		TC	PRENVBSY
		TC	ENDIDLE
		TC	ENDTEST1
		TC	QPLACE
		TC	SHOWLD
		TC	SHOW1



ERUNITS1	2DEC	685683 B-28
PRIO23		OCT	23000		
SXTTR		DEC	63
DEC11		DEC	11
NINTHOU		DEC	9000
V06N66		OCT	00666
FINEMSK1	OCT	17
MTRXLD1		DEC	17
DEC20		DEC	20
ROOT2/4B	DEC	.35355339
SCNBAZ		2DEC	-.27232		# AZIMUTH OF NB IS ERAD IN AS Z AXIS EAST
		2DEC	0
		2DEC	.4194335
LABNBAZ		2DEC	0
		2DEC	0
		2DEC	.5
LABNBAZ1	2DEC	0
		2DEC	0
SCNBVER		2DEC	.4194335
		2DEC	0
		2DEC	.27232
LABNBVER	2DEC	.5
		2DEC	0
		2DEC	0
LBNBVER1	2DEC	0
		2DEC	-.5
LABLAT3		2DEC	.11767824
DC585		2DEC	585 B+14
KGIMU2		DEC	.18
ERUNITS		2DEC	4319888 B-28
ERUNITS2	2DEC	102286 B-28
DEC40		DEC	40
DEC60		DEC	60
DEC80		DEC	80
DEC100		DEC	100
DEC120		DEC	120
DEC140		DEC	140
DEC160		DEC	160
DEC180		DEC	180
VB07N30E	OCT	00730



GYDRFT		TC	GRABDSP
		TC	PREGBSY
		CAF	ZERO
		TS	TESTNDX

SFTSTIN		CAF	BIT6		# PIP SCALE FACTOR TEST ENTRY
		TS	NBPOS
		CAF	ZERO
		TS	GENPL +76D
		TS	LTSTNDX
		CAF	ONE
		TS	POSITON
		CAF	LABLAT3
		TS	AZIMUTH
		CAF	LABLAT3 +1
		TS	AZIMUTH +1
		TC	LATAZCHK
		XCH	AZIMUTH
		TS	LATITUDE
		XCH	AZIMUTH +1
		TS	LATITUDE +1
		CAF	HALF
		TS	AZIMUTH
		CAF	ZERO
		TS	AZIMUTH +1
		TS	DSPTEM2 +1
		TC	LATAZCHK
		
GYRDRFT2	TC	SHOWLD		# LOAD NAVBASE TILT ANGLE IN DEGREES
		TC	SHOW
		CCS	NBPOS		# NUMBER IN POSITON.FOR VERTICAL DRIFT
		TC	LTNDX+		# TEST IN LAB LOAD + NUMBER IN TESTNDX
		TC	LTNDX0
		CAF	TEN
		TS	NBPOS
		TC	STEVEIN
LTNDX0		CAF	SIX
		TS	NBPOS
		TC	STEVEIN
LTNDX+		CAF	ZERO
		TS	NBPOS
		TS	LTSTNDX
		
STEVEIN		CS	ZERO
		TS	CDUIND
		TC	BANKCALL
		CADR	IMUZERO
		TC	BANKCALL
		CADR	IMUSTALL
		TC	ENDTEST1

		TC	NBPOSPL
		
POSGMBL1	TC	INTPRET
		ITC	0
			CALCGA
		EXIT	0
		CAF	ZERO
		TS	KH
		CAF	KGIMU2
		TS	KG
		TC	SETHETAD
		TC	BANKCALL
		CADR	IMUCOARS
		TC	BANKCALL
		CADR	IMUSTALL
		TC	ENDTEST1
		TC	BANKCALL
		CADR	POSGMBL
		
		
		
FALNED		CCS	GENPL +76D
		TC	TORK1
		TC	+2
		TC	IMUCHKR
		TC	INTPRET
		ITC	0
			ALGNINIT
		EXIT	0
		CCS	TESTNDX
		TC	LABTEST
		TC	+2
		TC	+1
FRECT		CAF	THREE
		TS	STOREPL
		CAF	ZERO		# VERTICAL ERECTION BY NULLING PIPAS
		TS	PIPAX
		TS	PIPAY
		TS	PIPAZ
		TS	OGC		## FIXME: ANYTHING IN SOLARIUM HERE?
		TS	MGC
		TS	IGC
		CAF	BIT4
		TC	WARTMAL
		TC	INTPRET
		RTB	1
		ITC
			READPIPS
			VERTRECT
		ITC	0
			EARTHR
		ITC	0
			OUTGYR
		EXIT	0
		TC	BANKCALL
		CADR	IMUSTALL
		TC	ENDTEST1
		CCS	COUNTPL
		TC	WARTMAL2
		CCS	STOREPL
		TC	FRECT +1


TSTJUMP		CCS	TESTNDX
		TC	LABTEST
		TC	SCRTEST
		TC	LABTEST
PIPTST		CAF	ONE		# MEASURE PIP PULSE RATE FOR 90 SEC.
		TS	COUNTPL
		CAF	ZERO
		INDEX	PIPINDX2
		TS	PIPAX
		TS	RESULTCT
		TC	WEIKPL



SCRTEST		CAF	NINTHOU
		AD	GENPL +76D
		TS	TESTTIME
		CS	RESULTCT
		CS	A
		TS	GENPL
		CAF	THREE

DOSCTEST	TS	COUNTPL		# HORIZ DRIFT TEST SET UP TO
		INHINT			# READ EAST PIP FOUR TIMES
		CS	TESTTIME
		CS	A
		TC	WAITLIST
		CADR	CARRYON
		RELINT
		CAF	CONCADR
		TC	JOBSLEEP
		
CARRYON		CAF	CONCADR
		TC	JOBWAKE
		TC	TASKOVER
		
CONCADR		CADR	WEIKPL

WEIKPL		INHINT
		TC	CHECKG
		RELINT
		CAF	FOUR
		AD	RESULTCT
		TS	RESULTCT
		TC	DATALD1
		CCS	COUNTPL
		TC	DOSCTEST
		TC	RESULTS



LABTEST		CCS	LTSTNDX		# SET UP TO MEASURE VERTICAL DRIFT
		TC	CDUD
		CAF	ZERO
		TS	XSM
		TS	XSM +6
		TS	XSM +12D
CDUCK		CAF	BIT6
CDUCK1		TS	STOREPL
		TC	STOPHOR
		
		CCS	STOREPL
		TC	CDUCK1
		CAF	ZERO
		INDEX	CDUNDX
		TS	CDUX
CDUCK2		CAF	BIT6
CDUCK3		TS	STOREPL
		INDEX	CDUNDX
		CCS	CDUX
		TC	CDUCK4
		TC	+3
		TC	CDUCK1
		TC	CDUCK4
		CCS	STOREPL
		TC	CDUCK3
		TC	STOPHOR
		TC	CDUCK2
CDUCK4		TC	READTIME
		RELINT
		CS	RUPTSTOR
		INDEX	RESULTCT
		TS	DATAPL
		CS	RUPTSTOR +1
		INDEX	RESULTCT
		TS	DATAPL +1
		CAF	THREE
CDUCK5		TS	STOREPL
		TC	STOPHOR
		
		CCS	STOREPL
		TC	CDUCK5
		INDEX	CDUNDX
		CCS	CDUX
		TC	POSPLS
		TC	CDUCK1
		TC	CDUCK1
		TC	NEGPLS
		
POSPLS		CS	TESTNDX		# INITIALIZES VERTICAL DRIFT TEST
		CCS	A
		TC	LONGTST
		NOOP
		CS	SXTTR
		NDX	CDUNDX
		TS	CDUX
		TC	CDUCK6
NEGPLS		CS	TESTNDX
		CCS	A
		TC	LONGTST
		NOOP
		CAF	SXTTR
		NDX	CDUNDX
		TS	CDUX
		
CDUCK6		TC	STOPHOR
		CAF	BIT6
CDUCK7		TS	STOREPL
		INDEX	CDUNDX
		CCS	CDUX
		TC	+4
		TC	CDUD1
		TC	+2
		TC	CDUD1
		CCS	STOREPL
		TC	CDUCK7
		TC	CDUCK6
		
CDUD1		CAF	BIT7
		INDEX	CDUNDX
		TS	CDUX
		TC	CDUD



LATAZCHK	XCH	Q
		TS	QPLACE
		CS	AZIMUTH		# CHECK LATITUDE AND NAVBASE AZIMUTH
		CS	A
		TS	DSPTEM1
		CS	AZIMUTH +1
		CS	A
		TS	DSPTEM1 +1
		TC	BANKCALL
		CADR	FLASHON
		CAF	VB07N30E
		TC	NVSUB
		TC	PRENVBSY
		TC	ENDIDLE
		TC	ENDTEST1
		TC	QPLACE
		TC	LATAZCHK +2



ENDTEST1	TC	BANKCALL
		CADR	ENDTEST



NBPOSPL		CAF	MTRXLD1
		TS	OVCTR		# ZERO STARAD
		CAF	ZERO
		INDEX	OVCTR
		TS	STARAD
		CCS	OVCTR
		TC	NBPOSPL +1
		
		TC	INTPRET		# SETS UP AZIMUTH AND VERTICAL VECTORS
		RTB	0		# FOR AXISGEN,RESULTS TO BE USED IN CALCGA
			ZEROVAC		# TO COMPUTE COARSE ALIGN ANGLES
		AXC,1	1
		XSU,1	VMOVE*
			SCNBAZ
			NBPOS
			0,1
		STORE	STARAD		# AZIMUTH IN NB COORDS
		AXC,1	1
		XSU,1	VMOVE*
			SCNBVER
			NBPOS
			0,1
		STORE	STARAD +6	# VERTICAL IN NB COORDS
		COS	1
		COMP
			AZIMUTH
		STORE	8D
		
		SIN	0
			AZIMUTH
		STORE	10D		# AZIMUTH IN CER
		VMOVE	0
			LABNBVER
		STORE	12D		#  VERTICAL IN CER
		ITC	0
			AXISGEN
		
		VMOVE	0
			XDC
		STORE	STARAD
		
		VMOVE	0
			YDC
		STORE	STARAD +6
		
		VMOVE	0
			ZDC
		STORE	STARAD +12D
		EXIT	0

POSSET		TS	QPLACE		## FIXME
		CAF	MTRXLD1
		TS	OVCTR
		CAF	ZERO
		INDEX	OVCTR
		TS	XSM
		CCS	OVCTR
		TC	-5
		INDEX	POSITON
		TC	+1
		TC	ENDTEST1
		TC	POSN1
		TC	POSN2
		TC	POSN3
		TC	POSN4
		TC	POSN5
		TC	POSN6
		TC	POSN7
		TC	POSN8
		TC	POSN9
		TC	POSN10
		TC	POSN11
POSN1		CAF	HALF		# X UP Y SOUTH Z EAST
		TS	XSM
		TS	YSM +2
		TS	ZSM +4
		CCS	TESTNDX
		TC	+2
		TC	LPNDX1
		NOOP
		CAF	ZERO
		TS	PIPINDX2
		TS	CDUNDX
		TS	RESULTCT
		TC	POSGMBL1
LPNDX1		CAF	TWO
		TS	PIPINDX2
		TC	POSGMBL1
POSN2		CAF	HALF		# X DOWN Y WEST ZNORTH
		COM
		TS	XSM
		TS	YSM +4
		TS	ZSM +2
		CAF	DEC20
		TS	RESULTCT
		CCS	TESTNDX
		TC	+2
		TC	LPNDX2
		NOOP
		CAF	ZERO
		TS	CDUNDX
		TS	PIPINDX2
		TC	POSGMBL1
LPNDX2		CAF	ONE
		TS	PIPINDX2
		TC	POSGMBL1
POSN3		CAF	HALF		# Z UP Y WEST X NORTH
		TS	ZSM
		COM
		TS	XSM +2
		TS	YSM +4
		CAF	DEC40
		TS	RESULTCT
		CCS	TESTNDX
		TC	LCNDX3
		TC	LPNDX2
		NOOP
		TC	LPNDX1

LCNDX3		CAF	ZERO
		TS	CDUNDX
		TC	POSGMBL1
POSN4		CAF	HALF		# Z DOWN Y SOUTH X EAST
		TS	XSM +4
		TS	YSM +2
		COM
		TS	ZSM
		CAF	DEC60
		TS	RESULTCT
		CCS	TESTNDX
		TC	LCNDX3
		TC	LPNDX4
		NOOP
		TC	LPNDX1

LPNDX4		TS	PIPINDX2
		TC	POSGMBL1
POSN5		CAF	HALF		# Y UP Z NORTH X WEST
		TS	YSM
		COM
		TS	XSM +4
		TS	ZSM +2
		CAF	DEC80
		TS	RESULTCT
		CCS	TESTNDX
		TC	LCNDX5
		TC	LPNDX4
		TC	LCNDX5
		TC	LPNDX2

LCNDX5		CAF	ONE
		TS	CDUNDX
		TC	POSGMBL1
POSN6		CAF	HALF		# Y DOWN Z EAST X SOUTH
		TS	XSM +2
		TS	ZSM +4
		COM
		TS	YSM
		CAF	DEC100
		TS	RESULTCT
		CCS	TESTNDX
		TC	LCNDX5
		TC	LPNDX1
		TC	LCNDX5
		TC	LPNDX2

POSN10		CS	ONE		# POSITION FOR LONG TEST FOR ADIAY
		TS	TESTNDX
		TC	POSN5
POSN11		CS	ONE
		TS	TESTNDX
		TC	POSN6



LONGTST		CAF	DEC180
		TS	STOREPL		# VERTICAL ERECTION FOR 14480 SECONDS
		CAF	ONE
		TS	LTSTNDX
		TC	FRECT +2


ACCELTST	TC	GRABDSP
		TC	PREGBSY
		CAF	NINTHOU
		TS	TESTTIME	# ACCELEROMETER OUTPUT TO GRAVITY
		CS	ZERO
		TS	TESTNDX
		TC	SFTSTIN



STEVEIN1	CAF	ONE
		TS	POSITON
		TC	STEVEIN

STEVEIN3	CAF	THREE
		TS	POSITON
		TC	STEVEIN

TORK1		TC	BANKCALL
		CADR	TORK

UNUSED1		2DEC	0.161641747


POSN7		CAF	ROOT2/4B
		TS	YSM
		TS	YSM +2
		TS	ZSM +2
		COM
		TS	ZSM
		CAF	HALF
		TS	XSM +4
		CAF	ZERO
		TS	PIPINDX2
		CCS	NBPOS
		TC	GYRDRFT2
		TS	TESTNDX
		CAF	DEC120
		TS	RESULTCT
		TC	POSGMBL1
POSN9		CAF	ROOT2/4B
		TS	XSM
		TS	XSM +2
		TS	ZSM
		COM
		TS	ZSM +2
		CAF	HALF
		TS	YSM +4
		CAF	ONE
		TS	PIPINDX2
		CCS	NBPOS
		TC	GYRDRFT2
		TS	TESTNDX
		CAF	DEC160
		TS	RESULTCT
		TC	POSGMBL1
POSN8		CAF	ROOT2/4B
		TS	YSM
		TS	YSM +2
		TS	XSM
		COM
		TS	XSM +2
		CAF	HALF
		TS	ZSM +4
		CAF	TWO
		TS	PIPINDX2
		CAF	ZERO
		TS	TESTNDX
		CAF	DEC140
		TS	RESULTCT
		TC	POSGMBL1



DATALD1		XCH	STOREPL
		INDEX	RESULTCT
		TS	DATAPL
		XCH	MPAC
		INDEX	RESULTCT
		TS	DATAPL +1
		XCH	MPAC +1
		INDEX	RESULTCT
		TS	DATAPL +2
		XCH	MPAC +2
		INDEX	RESULTCT
		TS	DATAPL +3
		TC	Q



WARTMAL		XCH	Q
		TS	QPLACE
		CS	Q
		TS	COUNTPL
WARTMAL4	CCS	COUNTPL
		TC	+4
		TC	QPLACE
		TC	+2
		TC	WARTMAL4 -1
		INHINT
		CAF	BIT11
		TC	WAITLIST
		CADR	WARTMAL3
		RELINT
		CCS	COUNTPL
		TC	QPLACE
		TC	QPLACE
		NOOP
WARTMAL2	TS	COUNTPL
		CAF	WTMLCADR
		TC	JOBSLEEP
WTMLCADR	CADR	WARTMAL4
WARTMAL3	CAF	WTMLCADR
		TC	JOBWAKE
		TC	TASKOVER



CDUCALC		TC	INTPRET
		LXC,1	2
		DSU*	BDDV
		DMP	RTB
			RESULTCT
			DATAPL +2,1
			DATAPL,1
			GENPL +76D
			ERUNITS		# 2DEC.66666
			SGNAGREE
		STORE	DSPTEM2
		EXIT	0
		
		TC	FINISH
		

PIPCALC		INDEX	GENPL
		CS	DATAPL +4
		INDEX	GENPL
		AD	DATAPL +8D
		TS	GENPL +1
		INDEX	GENPL
		CS	DATAPL +4
		INDEX	GENPL
		AD	DATAPL +12D
		TS	GENPL +3
		INDEX	GENPL
		CS	DATAPL +4
		INDEX	GENPL
		AD	DATAPL +16D
		TS	GENPL +5
		CAF	ZERO
		TS	GENPL +2
		TS	GENPL +4
		TS	GENPL +6
		TC	INTPRET
		LXC,1	1
		RTB
			GENPL
			FRESHPD
		TSU*	1
		TSLT	ROUND
			DATAPL +9D,1
			DATAPL +5,1
			12D
		DSQ	0
			0		# T1(2) IN 2,3
		DMP	1
		VDEF
			0
			2
		STORE	GENPL +10D
		TSU*	1
		TSLT	ROUND
			DATAPL +13D,1
			DATAPL +5,1
			12D
		DSQ	0
			0
		DMP	1		# T2(2) IN 6
		VDEF
			0
			2
		STORE	GENPL +16D
		TSU*	1
		TSLT	ROUND
			DATAPL +17D,1
			DATAPL +5D,1
			12D
		DSQ	0
			0
		DMP	1
		VDEF
			0
			2
		STORE	GENPL +24D
		VXV	1
		DOT
			GENPL +16D
			GENPL +24D
			GENPL +10D
		STORE	GENPL +32D	# D2
		DMOVE	0
			GENPL +1
		STORE	GENPL +12D
		DMOVE	0
			GENPL +3
		STORE	GENPL +18D
		DMOVE	0
			GENPL +5D
		STORE	GENPL +26D
		VXV	2
		DOT	DDV
		DMP	RTB
			GENPL +16D
			GENPL +24D
			GENPL +10D
			GENPL +32D
			ERUNITS2
			SGNAGREE
		STORE	DSPTEM2
		EXIT	0

FINISH		TC	SHOW
		CAF	BIT6
		TS	NBPOS
		CAF	ONE
		AD	POSITON
		TS	POSITON
		CS	POSITON
		AD	DEC11
		CCS	A
		TC	+3
		TC	ENDTEST1
		TC	ENDTEST1
		INHINT
		CAF	PRIO23
		TC	FINDVAC
		CADR	GYRDRFT2
		TC	ENDOFJOB



RESULTS		CCS	TESTNDX
		TC	CDUCALC
		TC	PIPCALC
		TC	CDUCALC
SFCALC		CS	DATAPL +4
		AD	DATAPL +8D
		TS	DATAPL
		
		TC	INTPRET
		TSU	1
		TSLT	ROUND
			DATAPL +9D
			DATAPL +5
			14D
		SMOVE	2
		DMP	DDV
		RTB
			DATAPL
			DC585
			0
			SGNAGREE
		STORE	DSPTEM2
		EXIT	0
		TC	FINISH


SETHETAD	CS	OGC
		COM
		TS	THETAD
		CS	MGC
		COM
		TS	THETAD +2
		CS	IGC
		COM
		TS	THETAD +1
		TC	Q



SHOWLD		CS	NBPOS
		CS	A
		TS	DSPTEM2
		CS	TESTNDX
		CS	A
		TS	DSPTEM2 +1
		TC	Q
		
		

CDUD		INDEX	CDUNDX
		XCH	CDUX
		TS	GENPL +77D
		TC	READTIME
		RELINT
		CS	RUPTSTOR
		INDEX	RESULTCT
		TS	DATAPL +2
		CS	RUPTSTOR +1
		INDEX	RESULTCT
		TS	DATAPL +3
		TC	CDUCALC



STOPHOR		XCH	Q
		TS	QPLACE
		TC	INTPRET
		ITC	0
			EARTHR
		ITC	0
			OUTGYR
		EXIT	0
		TC	BANKCALL
		CADR	IMUSTALL
		TC	ENDTEST1
		TC	QPLACE
