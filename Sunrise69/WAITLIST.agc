### FILE="Main.annotation"
## Copyright:	Public domain.
## Filename:	WAITLIST.agc
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
## Mod history:	2023-06-19 MAS	Created from Sunrise 45.


# CHECK-OUT STATUS - UNIT VERIFICATION COMPLETE MAY, 1965		EXCEPT LONGCALL SECTION.
#
# DO NOT CHANGE THIS SECTION WITHOUT PRB APPROVAL.
#
# GROUNDRULE....DELTA T SHOULD NOT EXCEED 12000 (= 2 MINUTES)

		BANK	1
WAITLIST	TS	DELT		# STORE DELTA T = TD - T (TD = DESIRED
		XCH	Q		#   TIME FOR FUTURE ACTION).
		TC	EXECCOM		# PICK UP TASK ADDRESS AND SAVE BANKREG.
		TC	WTLST3

		BANK	4
WTLST3		CS	TIME3
		AD	+1		# CCS  A  = + 1/4
		CCS	A		# TEST  1/4 - C(TIME3).  IF POSITIVE,
					# IT MEANS THAT TIME3 OVERFLOW HAS OCCURRED PRIOR TO CS  TIME3 AND THAT
					# C(TIME3) = T - T1, INSTEAD OF 1.0 - (T1 - T).  THE FOLLOWING FOUR
					# ORDERS SET C(A) = TD - T1 + 1 IN EITHER CASE.  C(CSQ) = CS  Q = 40001
					# AND  C(TSQ) = TS  Q = 50001   NOTATION...   1 - 00001,  1.0 = 37777+1

		AD	CSQ		# OVERFLOW HAS OCCURRED.  SET C(A) = 
		CS	A		# T - T1 + 3/4 - 1

# NORMAL CASE (C(A) MINUS) YIELDS SAME C(A)  -(-(1.0-(T1-T))+1/4)-1

		AD	TSQ		# TS  Q  = - 3/4 + 2
		AD	DELT		# RESULT = TD - T1 + 1
					#		10W		
		CCS	A		# TEST TD - T1 + 1

		AD	LST1		# IF TD - T1 POS, GO TO WTLST5 WITH
		TC	WTLST5		# C(A) = (TD - T1) + C(LST1) = TD-T2+1

		TC	+1
		CS	DELT

# NOTE THAT THIS PROGRAM SECTION IS NEVER ENTERED WHEN T-T1 G/E -1, 
# SINCE TD-T1+1 = (TD-T) + (T-T1+1), AND DELTA T = TD-T G/E +1.  (G/E
# SYMBOL MEANS GREATER THAN OR EQUAL TO).  THUS THERE NEED BE NO CON-
# CERN OVER A PREVIOUS OR IMMINENT OVERFLOW OF TIME3 HERE.

		AD	POS1/2		# WHEN TD IS NEXT, FORM QUANTITY
		AD	POS1/2		#   1.0 - DELTA T = 1.0 - (TD - T)
		XCH	TIME3
		AD	MSIGN
		AD	DELT
		TS	DELT
		CAF	ZERO
		XCH	DELT
WTLST4		XCH	LST1
		XCH	LST1 +1
		XCH	LST1 +2
		XCH	LST1 +3
		XCH	LST1 +4
		XCH	EXECTEM2	# TASK ADDRESS.
		INDEX	NVAL
		TC	+1
		XCH	LST2
		XCH	LST2 +1
		XCH	LST2 +2
		XCH	LST2 +3
		XCH	LST2 +4
		XCH	LST2 +5		# AT END, CHECK THAT C(LST2+5) IS STD
		AD	ENDTASK		#   END ITEM, AS CHECK FOR EXCEEDING
					#   THE LENGTH OF THE LIST.
		CCS	A
		TC	ABORT		# WAITLIST OVERFLOW.
		OCT	01203
		TC	-2

		XCH	EXECTEM1	# RETURN TO CALLER.
		TC	LVWTLIST	# SAME ROUTINE AS FINDVAC, ETC., EXIT.


WTLST5		CCS	A		# TEST  TD - T2 + 1
		AD	LST1 +1
		TC	+4
		AD	ONE
		TC	WTLST2
		OCT	1

 +4		CCS	A		# TEST  TD - T3 + 1
		AD	LST1 +2
		TC	+4
		AD	ONE
		TC	WTLST2
		OCT	2

 +4		CCS	A		# TEST  TD - T4 + 1
		AD	LST1 +3
		TC	+4
		AD	ONE
		TC	WTLST2
		OCT	3

 +4		CCS	A		# TEST  TD - T5 + 1
		AD	LST1 +4
		TC	+4
		AD	ONE
		TC	WTLST2
		OCT	4

 +4		CCS	A		# TEST  TD - T6 + 1
		TC	WTALARM
		NOOP
		AD	ONE
		TC	WTLST2
		OCT	5

WTALARM		TC	ABORT
		OCT	01204

LVWTLIST	EQUALS	FOUNDVAC

SVCT3		TC	TASKOVER

# C(TIME3) = 1.0 - (T1 - T)
#
# C(LST1  ) = - (T2 - T1) + 1
# C(LST1+1) = - (T3 - T2) + 1
# C(LST1+2) = - (T4 - T3) + 1
# C(LST1+3) = - (T5 - T4) + 1
# C(LST1+4) = - (T6 - T5) + 1

# C(LST2  ) = TC  TASK1
# C(LST2+1) = TC  TASK2
# C(LST2+2) = TC  TASK3
# C(LST2+3) = TC  TASK4
# C(LST2+4) = TC  TASK5
# C(LST2+5) = TC  TASK6						11W


# THE ENTRY TO WTLST2 JUST PRECEDING OCT  N  IS FOR T  LE TD LE T   -1.
#                                                    N           N+1
# (LE MEANS LESS THAN OR EQUAL TO).  AT ENTRY, C(A) = -(TD - T   + 1)
#                                                             N+1
#
# THE LST1 ENTRY -(T   - T +1) IS TO BE REPLACED BY -(TD - T + 1), AND
#                   N+1   N                                 N
#
# THE ENTRY -(T   - TD + 1) IS TO BE INSERTED IMMEDIATELY FOLLOWING.
#              N+1

WTLST2		XCH	Q		# NEW C(Q) = -(TD - T   + 1)
		INDEX	A		#                    N+1
		CAF	0
		TS	NVAL		# VALUE OF N INTO NVAL

		INDEX	NVAL
		CS	LST1 -1
		COM
		AD	Q
		AD	ONE
		INDEX	NVAL		# C(A) = -(TD - T ) + 1.
		TS	LST1 -1		#                N

		CS	Q		# -C(Q) = -(T    - TD) + 1
		INDEX	NVAL		#            N+1
		TC	WTLST4


#	ENTERS HERE ON T3 RUPT TO DISPATCH WAITLISTED TASK.

		SETLOC	WAITLIST +4	# BACK TO FF.

NEG13		DEC	-13

T3RUPT		XCH	BANKREG		#  TIME 3 OVERFLOW INTERRUPT PROGRAM
		TS	BANKRUPT
		XCH	OVCTR		# 1.  PICK UP CONTENTS OF THE OVERFLOW
		TS	OVRUPT		#    AND SAVE IN OVRUPT FOR ENTIRE T3RUPT.

T3RUPT2		CS	ZERO		# 2.  SET T3 TO -0 WHILE WE MAKE UP ITS NEW
		XCH	TIME3		#    CONTENTS SO WE CAN DETECT AN INCREMENT
		AD	ONE		#    OCCURING IN THE PROCESS.
		TS	ITEMP1
		TC	+2
		TS	ITEMP1

		CAF	NEG1/2
		XCH	LST1 +4		# 3.  MOVE UP LST1 CONTENTS, ENTERING
		XCH	LST1 +3		#     A VALUE OF 1/2 +1 AT THE BOTTOM
		XCH	LST1 +2		#     FOR T6-T5, CORRESPONDING TO THE
		XCH	LST1 +1		#     INTERVAL 81.93 SEC FOR ENDTASK.
		XCH	LST1
		AD	ITEMP1		# 4. SET T3 = 1.0 - T2 -T USING LIST 1.
		AD	OCT17777
		AD	OCT17777
		AD	TIME3
		TS	TIME3
		CS	ZERO
		TS	RUPTAGN

		CS	ENDTASK
		XCH	LST2 +5		#	ENTERING THE ENDTASK AT BOTTOM.
		XCH	LST2 +4
		XCH	LST2 +3
		XCH	LST2 +2
		XCH	LST2 +1
		XCH	LST2		# 9.  PICK UP TOP TASK ON LIST

		TS	BANKREG		# SWITCH BANKS IF NECESSARY
		TS	ITEMP1
		MASK	70K
		CCS	A
		TC	+2		# IF +
		TC	ITEMP1
		XCH	ITEMP1
		MASK	LOW10
		INDEX	A
		TC	6000

70K		OCT	70000
ENDTASK        -CADR	SVCT3

# RETURN, AFTER EXECUTION OF TIME3 OVERFLOW TASK.
TASKOVER	CCS	RUPTAGN		# IF +1 RETURN TO T3RUPT, IF -0 RESUME.
		TC	T3RUPT2		# DISPATCH NEXT TASK IF IT WAS DUE.

OCT17777	OCT	17777
BANKMASK	OCT	76000

OVRESUME	XCH	OVRUPT		# OVCTR RESTORE AND BANKREG RESTORE.
		TS	OVCTR

RESUME		XCH	BANKRUPT	# STANDARD BANK-SWITCH RESUME.
		TS	BANKREG

NBRESUME	XCH	QRUPT		# NO-BANK-SWITCH RESUME.
		TS	Q
		XCH	ARUPT
		RESUME
