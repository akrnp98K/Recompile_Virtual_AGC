### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    SERVICER.agc
## Purpose:     A section of Luminary revision 163.
##              It is part of the reconstructed source code for the first
##              (unflown) release of the flight software for the Lunar
##              Module's (LM) Apollo Guidance Computer (AGC) for Apollo 14.
##              The code has been recreated from a reconstructed copy of
##              Luminary 173, as well as Luminary memos 157 amd 158.
##              It has been adapted such that the resulting bugger words
##              exactly match those specified for Luminary 163 in NASA
##              drawing 2021152N, which gives relatively high confidence
##              that the reconstruction is correct.
## Reference:   pp. 850-889
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-08-21 MAS  Created from Luminary 173. Removed checking of
##                              R12RDFLG (and NEWJOB) from VMEASCHK.

## Page 860
                BANK    37
                SETLOC  SERV1
                BANK

                EBANK=  DVCNTR
# *************************************   PREREAD   **************************************************************


                COUNT*  $$/SERV

PREREAD         CAF     SEVEN           # 5.7 SPOT TO SKIP LASTBIAS AFTER
                TC      GNUFAZE5        # RESTART.
                CAF     PRIO21
                TC      NOVAC
                EBANK=  NBDX
                2CADR   LASTBIAS        # DO LAST GYRO COMPENSATION IN FREE FALL

BIBIBIAS        TC      PIPASR +3       # CLEAR + READ PIPS LAST TIME IN FREE FALL
                                        # DO NOT DESTROY VALUE OF PIPTIME1

                CS      FLAGWRD7
                MASK    SUPER011        # SET V37FLAG AND AVEGFLAG (BITS 5 AND 6
                ADS     FLAGWRD7        #    OF FLAGWRD7)

                CS      DRFTBIT
                MASK    FLAGWRD2        # START POWERED FLITE GYRO COMPENSATION
                TS      FLAGWRD2        # BY T3RUPT

                CAF     FOUR            # NO LONGER NEEDED
                TS      PIPAGE

                CAF     PRIO22          # INITIALIZE NAVIGATED STATE VECTOR(SM COO
                TC      FINDVAC         # RD) FROM MIDTOAVE OUTPUTS PRIOR TO FIRST
                EBANK=  DVCNTR          # AVERAGE G.
                2CADR   NORMLIZE


                CA      TWO             # 5.2SPOT FOR REREADAC AND NORMLIZE
GOREADAX        TC      GNUTFAZ5
                CA      2SECS           # WAIT TWO SECONDS FOR READACCS
                TC      VARDELAY

## Page 861
# *************************************   READACCS   *************************************************************
READACCS        CS      OCT37771        # THIS PIECE OF CODING ATTEMPTS TO
                AD      TIME5           # SYNCHRONIZE READACCS WITH THE DIGITAL
                CCS     A               # AUTOPILOT SO THAT A PAXIS RUPT WILL
                CS      ONE             # OCCUR APPROXIMATELY 70 MILLISECONDS
                TCF     +2              # FOLLOWING THE READACCS RUPT.  THE 70 MS
                CA      ONE             # OFFSET WAS CHOSEN SO THAT THE PAXIS
 +2             ADS     TIME5           # RUPT WOULD NOT OCCUR SIMULTANEOUSLY
                                        # WITH ANY OF THE 8 SUBSEQUENT R10,R11
                                        # INTERRUPTS -- THUS MINIMIZING THE POSS-
                                        # IBILITY OF LOSING DOWNRUPTS.

                TC      PIPASR          # READ THE PIPAS AND THEN ZERO THEM.

PIPSDONE        CA      FIVE
                TC      GNUFAZE5
REDO5.5         CAF     ONE             # SHOWS THAT PIPAREAD HAD NOT STARTED
                TS      PIPAGE          # SO THAT RESTART BEGINS AT READACCS.

                CA      PRIO20
                TC      FINDVAC
                EBANK=  DVCNTR
                2CADR   SERVICER        # SET UP SERVICER JOB

                CA      BIT9
                EXTEND
                WOR     DSALMOUT        # TURN ON TEST CONNECTOR OUTBIT,AVE G ON.

                CA      FLAGWRD7        # WAS AVERAGE G ASKED TO BE TERMINATED?
                MASK    AVEGFBIT
                EXTEND
                BZF     AVEGOUT         # YES: SET UP FINAL EXIT.

                CA      FLAGWRD6        # NO: IS THIS P6X OR P12?
                MASK    MUNFLBIT
                EXTEND
                BZF     MAKEACCS        # NO: BYPASS LR READ AND DISPLAYS

                CS      FLGWRD11        # YES: DOES SOMEONE WANT TO BYPASS LR UPDT
                MASK    LRBYBIT
                EXTEND
                BZF     R10CALL         # YES: BYPASS LR READINGS

                CA      1.75SEC         # CALL R12 0.25 SEC PRIOR TO NEXT READACCS
                TC      WAITLIST        # VELOCITY LANDING RADAR READINGS ARE CENT
                EBANK=  VSELECT         # ERED AROUND PIPTIME. 2 VELOCITY AND 1 AL
                2CADR   R12READ         # TITUDE READINGS BEFORE PIPTIME,3 V AFTER

## Page 862
R10CALL         CCS     PHASE2
                TCF     MAKEACCS        # PHASE 2 ACTIVATED - AVOID MULTIPLE R10.

                CAF     SEVEN           # SET PIPCTR FOR 4X/SEC RATE.
                TS      PIPCTR

                CS      TIME1           # SET TBASE2 .05 SECONDS IN THE PAST.
                AD      FIVE
                AD      NEG1/2
                AD      NEG1/2
                XCH     TBASE2

                CAF     DEC17           # 2.21SPOT FOR R10,R11
                TS      L
                COM
                DXCH    -PHASE2

                CAF     OCT24           # FIRST R10,R11 IN .200 SECONDS.
                TC      WAITLIST
                EBANK=  UNIT/R/
                2CADR   R10,R11


MAKEACCS        CA      FOUR
                TCF     GOREADAX        # DO PHASE CHANGE AND RECALL READACCS


AVEGOUT         EXTEND
                DCA     AVOUTCAD        # SET UP FINAL SERVICER EXIT
                DXCH    AVGEXIT

                CA      FOUR            # SET 5.4 SPOT FOR REREADAC AND SERVICER
                TC      GNUTFAZ5        # IF REREADAC IS CALLED, IT WILL EXIT
                TC      TASKOVER        # END TASK WITHOUT CALLING READACCS


GNUTFAZ5        TS      L               # SAVE INPUT IN L
                CS      TIME1
                TS      TBASE5          # SET TBASE5
                TCF     +2

GNUFAZE5        TS      L               # SAVE INPUT IN L
                CS      L               # -PHASE IN A, PHASE IN L
                DXCH    -PHASE5         # SET -PHASE5,PHASE5
                TC      Q


                EBANK=  DVCNTR
AVOUTCAD        2CADR   AVGEND

## Page 863
1.75SEC         DEC     175
OCT37771        OCT     37771

                BANK    33
                SETLOC  SERVICES
                BANK

                COUNT*  $$/SERV

## Page 864
# *************************************   SERVICER   *************************************************************
#

SERVICER        TC      PHASCHNG        # RESTART REREADAC + SERVICER
                OCT     16035
                OCT     20000
                EBANK=  DVCNTR
                2CADR   GETABVAL

                CAF     PRIO31          # INITIALIZE 1/PIPADT IN CASE RESTART HAS
                TS      1/PIPADT        # CAUSED LASTBIAS TO BE SKIPPED.


                TC      BANKCALL        # PIPA COMPENSATION CALL
                CADR    1/PIPA

GETABVAL        TC      INTPRET
                VLOAD   ABVAL
                        DELV
                EXIT
                CA      MPAC
                TS      ABDELV          # ABDELV = CM/SEC*2(-14).
                EXTEND
                MP      KPIP
                DXCH    ABDVCONV        # ABDVCONV = M/CS *2(-5).
                EXTEND
                DCA     MASS
                DXCH    MASS1           # NO MASS MONITOR ON SURFACE.

MASSMON         CS      FLAGWRD8        # ARE WE ON THE SURFACE?
                MASK    SURFFBIT
                EXTEND
                BZF     MOONSPOT        # YES:  BYPASS MASS MESS

                CA      FLGWRD10        # NO:   WHICH VEX SHOULD BE USED?
                MASK    APSFLBIT
                CCS     A
                EXTEND                  # IF EXTEND IS EXECUTED, APSVEX --> A,
                DCA     APSVEX          #   OTHERWISE DPSVEX --> A
                TS      Q

                EXTEND
                DCA     ABDVCONV
                EXTEND
                DV      Q               # WHERE APPROPRIATE VEX RESIDES
                EXTEND
                MP      MASS
                DAS     MASS1

MOONSPOT        CA      KPIP1           # TP MPAC = ABDELV AT 2(14) CM/SEC
## Page 865
                TC      SHORTMP         # MULTIPLY BY KPIP1 TO GET

                DXCH    MPAC            # ABDELV AT 2(7) M/CS
                DAS     DVTOTAL         # UPDATE DVTOTAL FOR DISPLAY

                TC      TMPTOSPT        # CDUS AT PIPTIME LOADED INTO CDUSPOT CELL
                TC      BANKCALL        # SINES AND COSINES OF CDUSPOT.
                CADR    QUICTRIG

                CAF     XNBPIPAD
                TC      BANKCALL        # COMPUTE BOD-TO-SM MATRIX (XNB),AND
                CADR    FLESHPOT        # STORE INTO XNBPIPAD.

                TC      INTPRET
AVERAGEG        BON     CALL
                        MUNFLAG         # COMPUTE LM & CM STATE VECTORS IN LUNAR G
                        RVBOTH          # ,DO R12 , DO COPYCYCL1, RETURN AT COPYCL
                        CALCRVG         # UPDATE LM STATE VECTOR.
                EXIT
GOSERV          TC      QUIKFAZ5

COPYCYCL        TC      COPYCYC         # RN1,VN1,MASS1 => RN,VN,MASS.

#               CA      ZERO            A IS ZERO ON RETURN FROM COPYCYC
                TS      PIPATMPX        # STILL UNDER INHINT
                TS      PIPATMPY
                TS      PIPATMPZ

                CS      STEERBIT        # CLEAR STEERSW PRIOR TO DVMON.
                MASK    FLAGWRD2
                TS      FLAGWRD2

                CAF     IDLEFBIT        # IS DV MONITOR TO BE TURNED ON?
                MASK    FLAGWRD7
                CCS     A
                TCF     NODVMON1        # NO: SET AUXFLAG TO 0

                CS      FLAGWRD6        # ALLOW ANOTHER PASS WITHOUT DVMON?
                MASK    AUXFLBIT
                CCS     A
                TCF     NODVMON2        # YES: SET AUXFLAG TO 0

## Page 866
DVMON           CS      DVTHRUSH        # SUFFICIENT THRUST TO STEER WITH?
                AD      ABDELV
                EXTEND
                BZMF    LOTHRUST        # NO: THRUST TOO LO, DECREMENT DVCNTR

                CS      FLAGWRD2        # YES: SET STEERSW TO ALLOW GUIDANCE.
                MASK    STEERBIT
                ADS     FLAGWRD2

DVCNTSET        CAF     ONE             # ALLOW TWO PASSES MAXIMUM NOW THAT
                TS      DVCNTR          # THRUST HAS BEEN DETECTED.

                CA      FLGWRD10        # IS APSFLAG SET?
                MASK    APSFLBIT
                CCS     A
                TCF     USEJETS         # YES: USE RCS TO STEER ASCENT STAGE.

                CA      BIT9            # NO: PITCH GIMBAL FAILURE?
                EXTEND
                RAND    CHAN32
                EXTEND
                BZF     USEJETS         # YES: USE RCS TO STEER DESCENT STAGE.

USEGTS          CS      USEQRJTS        # NO: USE GTS TO STEER DESCENT STAGE.
                MASK    DAPBOOLS
                TS      DAPBOOLS
                TCF     SERVOUT

NODVMON1        CS      AUXFLBIT        # SET AUXFLAG TO 0.
                MASK    FLAGWRD6
                TS      FLAGWRD6
                TCF     USEJETS
NODVMON2        CS      FLAGWRD6        # SET AUXFLAG TO 1.
                MASK    AUXFLBIT
                ADS     FLAGWRD6
                TCF     USEJETS

LOTHRUST        TC      QUIKFAZ5
                CCS     DVCNTR          # TWO PASSES OF LO THRUST?
                TCF     DECCNTR         # NO: DECREMENT DVCNTR.

                CCS     PHASE4          # COMFAIL JOB ACTIVE?
                TCF     SERVOUT         # YES   WON'T NEED ANOTHER.

                TC      PHASCHNG        # 4.37SPOT FOR COMFAIL.
                OCT     00374

                CAF     PRIO25
                TC      NOVAC
                EBANK=  WHICH
## Page 867
                2CADR   COMFAIL         # ESTABLISH JOB COMFAIL FOR

                TCF     SERVOUT         # THRUST FAIL LOGIC.

DECCNTR         TS      DVCNTR1
                TC      QUIKFAZ5
                CA      DVCNTR1
                TS      DVCNTR
                INHINT
                TC      IBNKCALL        # IF THRUST IS LOW, NO STEERING IS DONE
                CADR    STOPRATE        # AND THE DESIRED RATES ARE SET TO ZERO.
USEJETS         CS      DAPBOOLS
                MASK    USEQRJTS
                ADS     DAPBOOLS        # TELL DAP TO USE RCS TO STEER.

SERVOUT         RELINT
                TC      BANKCALL        # COMPUTE VEHICLE MOMENTS OF INERTIA.
                CADR    1/ACCS

                CA      PRIORITY
                MASK    LOW9
                TS      PUSHLOC
                ZL
                DXCH    FIXLOC          # FIXLOC AND OVFIND

                TC      QUIKFAZ5
                CS      PIPTIME +1
                AD      TIME1
                AD      HALF
                AD      HALF
                XCH     SERVDURN        # SERVICER DURATION FOR DOWNLINK
                EXTEND                  # EXIT TO SELECTED ROUTINE WHETHER THERE
                DCA     AVGEXIT         # IS THRUST OR NOT.  THE STATE OF STEERSW
                DXCH    Z               # WILL CONVEY THIS INFORMATION.

XNBPIPAD        ECADR   XNBPIP

                BANK    32
                SETLOC  SERV2
                BANK
                COUNT*  $$/SERV

AVGEND          CA      PIPTIME +1      # FINAL AVERAGE G EXIT,AVEGFLAG SET.
                TS      1/PIPADT        # SET UP COASTING FLIGHT GYRO COMPENSATION

                TC      UPFLAG          # SET DRIFT FLAG, TERMINATE POWERED FLITE
                ADRES   DRIFTFLG        # GYRO COMPENSATION.
## The above two instructions are circled.

                TC      BANKCALL
                CADR    PIPFREE

## Page 868
                CS      BIT9
                EXTEND
                WAND    DSALMOUT        # TELL WORLD THAT AVERAGEG IS NOW OFF.

                TC      2PHSCHNG
                OCT     5               # GROUP 5 OFF
                OCT     05022           # GROUP 2 ON
                OCT     20000

                TC      INTPRET
                CLEAR
                        SWANDISP        # SHUT OFF R10 WHEN SERVICER ENDS.
                CLEAR   CALL            # RESET MUNFLAG.
                        MUNFLAG
                        AVETOMID        # BRING CM STATE VECTOR UP TO PIPTIME.
                CLEAR   EXIT
                        V37FLAG

AVERTRN         TC      POSTJUMP
                CADR    V37RET          # GO TO V37 LOGIC.

OUTGOAVE        =       AVERTRN
DVCNTR1         =       MASS1

## Page 869
# SERVIDLE IS ENTERED AFTER A POODOO SOFTWARE RESTART. SERVICER CONTINUES,BUT GUIDANCE AND R12 ( IF RUNNING) ARE
# TERMINATED. ABORTS MONITOR CONTINUES TO RUN.

                SETLOC  SERV3
                BANK
                COUNT*  $$/SERV

SERVIDLE        EXTEND                  # DISCONNECT SERVICER FROM ALL GUIDANCE
                DCA     SVEXTADR
                DXCH    AVGEXIT

                CS      FLAGWRD7        # DISCONNECT THE DELTA-V MONITOR
                MASK    IDLEFBIT
                ADS     FLAGWRD7

                CAF     LRBYBIT         # TERMINATE R12 IF RUNNING.
                TS      FLGWRD11

                EXTEND
                DCA     NEG0
                DXCH    -PHASE1

                CA      FLAGWRD6        # DO NOT TURN OFF PHASE 2 IF MUNFLAG SET.
                MASK    MUNFLBIT
                CCS     A
                TCF     +4

                EXTEND
                DCA     NEG0
                DXCH    -PHASE2

 +4             EXTEND
                DCA     NEG0
                DXCH    -PHASE3

                EXTEND
                DCA     NEG0
                DXCH    -PHASE6

                CAF     OCT33           # 4.33SPOT FOR GOPOOFIX
                TS      L
                COM
                DXCH    -PHASE4

                TCF     WHIMPER         # PERFORM A SOFTWARE RESTART AND PROCEED
                                        # TO GOTOPOOH WHILE SERVICER CONTINUES TO
                                        # RUN, ALBEIT IN A GROUND STATE WHERE
                                        # ONLY STATE-VECTOR DEPENDENT FUNCTIONS
                                        # ARE MAINTAINED.

## Page 870
                EBANK=  DVCNTR
SVEXTADR        2CADR   SERVEXIT



                BANK    32
                SETLOC  SERV
                BANK
                COUNT*  $$/SERV

SERVEXIT        TC      PHASCHNG
                OCT     00035

                TCF     ENDOFJOB

                BANK    23
                SETLOC  NORMLIZ
                BANK

                COUNT*  $$/SERV

## Page 871
# NORMLIZE AND COPYCYCL

NORMLIZE        TC      INTPRET
                VLOAD   BOFF
                        RN1
                        MUNFLAG
                        NORMLIZ1        # DO NOT USE LUNAR LANDING AVERAGE G
                VSL6    MXV
                        REFSMMAT
                STCALL  R               # LM POS VECTOR IN SM COORD AT 2(+24)M.
                        MUNGRAV         # USE LUNAR LANDING AVERAGE G ROUTINE.
                VLOAD   VSL1
                        VN1
                MXV
                        REFSMMAT
                STOVL   V
                        V(CSM)
                VXV     UNIT
                        R(CSM)
                STORE   UHYP
ASCSPOT         EXIT
                EXTEND                  # MAKE SURE GOUP 2 IS OFF.
                DCA     NEG0
                DXCH    -PHASE2

                TC      POSTJUMP
                CADR    NORMLIZ2

                BANK    33
                SETLOC  SERVICES
                BANK
                COUNT*  $$/SERV

NORMLIZ1        CALL
                        CALCGRAV
                EXIT

NORMLIZ2        CA      EIGHTEEN
                TC      COPYCYC +1      # DO NOT COPY MASS IN NORMLIZE
                TC      ENDOFJOB

# COPYCYC PLACES NEWLY NAVIGATED STATE VECTORS AND MASS INTO DOWNLIST REG

COPYCYC         CA      OCT24           # DEC 20
## Page 872
 +1             INHINT
 +2             MASK    NEG1            # REDUCE BY 1 IF ODD
                TS      ITEMP1
                EXTEND
                INDEX   ITEMP1
                DCA     RN1
                INDEX   ITEMP1
                DXCH    RN
                CCS     ITEMP1
                TCF     COPYCYC +2
                TC      Q               # RETURN UNDER INHINT


EIGHTEEN        DEC     18

## Page 873
# ******************* PIPA READER ********************

#                 MOD NO. 00  BY D. LICKLY  DEC.9 1966


# FUNCTIONAL DESCRIPTION
#    SUBROUTINE TO READ PIPA COUNTERS, TRYING TO BE VERY CAREFUL SO THAT IT WILL BE RESTARTABLE.
#    PIPA READINGS ARE STORED IN THE VECTOR DELV. THE HIGH ORDER PART OF EACH COMPONENT CONTAINS THE PIPA READING,
#    RESTARTS BEGIN AT REREADAC.


#    AT THE END OF THE PIPA READER THE CDUS ARE READ AND STORED AS A
# VECTOR IN CDUTEMP.  THE HIGH ORDER PART OF EACH COMPONENT CONTAINS
# THE CDU READING IN 2S COMP IN THE ORDER CDUX,Y,Z.  THE THRUST
# VECTOR ESTIMATOR IN FINDCDUD REQUIRES THE CDUS BE READ AT PIPTIME.

# CALLING SEQUENCE AND EXIT

#    CALL VIA TC, ISWCALL, ETC.

#    EXIT IS VIA Q.


#

# INPUT

#    INPUT IS THROUGH THE COUNTERS PIPAX, PIPAY, PIPAZ, AND TIME2.


# OUTPUT

#    HIGH ORDER COMPONENTS OF THE VECTOR DELV CONTAIN THE PIPA READINGS.
#    PIPTIME CONTAINS TIME OF PIPA READING.


# DEBRIS (ERASABLE LOCATIONS DESTROYED BY PROGRAM)

#          TEMX   TEMY   TEMZ   PIPAGE


                BANK    37
                SETLOC  SERV1
                BANK

                COUNT*  $$/SERV

PIPASR          EXTEND
## Page 874
                DCA     TIME2
                DXCH    PIPTIME1        # CURRENT TIME  POSITIVE VALUE
 +3             CS      ZERO            # INITIALIZE THESE AT NEG. ZERO.
                TS      TEMX
                TS      TEMY
                TS      TEMZ

                CA      ZERO
                TS      DELVZ
                TS      DELVZ +1
                TS      DELVY
                TS      DELVY +1
                TS      DELVX +1
                TS      PIPAGE          # SHOW PIPA READING IN PROGRESS

REPIP1          EXTEND
                DCS     PIPAX           # X AND Y PIPS READ
                DXCH    TEMX
                DXCH    PIPAX           # PIPAS SET TO NEG ZERO AS READ.
                TS      DELVX
                LXCH    DELVY

REPIP3          CS      PIPAZ           # REPEAT PROCESS FOR Z PIP
                XCH     TEMZ
                XCH     PIPAZ
DODELVZ         TS      DELVZ

REPIP4          EXTEND                  # COMPUTE GUIDANCE PERIOD
                DCA     PIPTIME1
                DXCH    PGUIDE
                EXTEND
                DCS     PIPTIME
                DAS     PGUIDE

                CA      CDUX            # READ CDUS INTO HIGH ORDER CDUTEMPS
                TS      CDUTEMPX
                CA      CDUY
                TS      CDUTEMPY
                CA      CDUZ
                TS      CDUTEMPZ
                CA      DELVX
                TS      PIPATMPX
                CA      DELVY
                TS      PIPATMPY
                CA      DELVZ
                TS      PIPATMPZ

                TC      Q
## In the margins above there are some doodles of something I can't quite make out. Possibly satellites.

## Page 875
REREADAC        CCS     PIPAGE
                TCF     READACCS        # PIP READING NOT STARTED. GO TO BEGINNING

                CAF     DONEADR         # SET UP RETURN FROM PIPASR
                TS      Q

                CCS     DELVZ
                TCF     REPIP4          # Z DONE, GO DO CDUS
                TCF     +3              # Z NOT DONE, CHECK Y.
                TCF     REPIP4
                TCF     REPIP4

                ZL
                CCS     DELVY
                TCF     +3
                TCF     CHKTEMX         # Y NOT DONE, CHECK X.
                TCF     +1
                LXCH    PIPAZ           # Y DONE, ZERO Z PIP.

                CCS     TEMZ
                CS      TEMZ            # TEMZ NOT = -0, CONTAINS -PIPAZ VALUE.
                TCF     DODELVZ
                TCF     -2
                LXCH    DELVZ           # TEMZ = -0, L HAS ZPIP VALUE.
                TCF     REPIP4

CHKTEMX         CCS     TEMX            # HAS THIS CHANGED
                CS      TEMX            # YES
                TCF     +3              # YES
                TCF     -2              # YES
                TCF     REPIP1          # NO
                TS      DELVX

                CS      TEMY
                TS      DELVY

                CS      ZERO            # ZERO X AND Y PIPS
                DXCH    PIPAX           # L STILL ZERO FROM ABOVE

                TCF     REPIP3

DONEADR         GENADR  PIPSDONE

## Page 876
                BANK    33
                SETLOC  SERVICES
                BANK

                COUNT*  $$/SERV

TMPTOSPT        CA      CDUTEMPY        # THIS SUBROUTINE, CALLED BY AN RTB FROM
                TS      CDUSPOTY        # INTERPRETIVE, LOADS THE CDUS CORRESPON-
                CA      CDUTEMPZ        # DING TO PIPTIME INTO THE CDUSPOT VECTOR.
                TS      CDUSPOTZ
                CA      CDUTEMPX
                TS      CDUSPOTX
                TC      Q

                BANK    33
                SETLOC  SERVICES
                BANK

                COUNT* $$/SERV

# HIGATASK IS ENTERED APPROXIMATELY 6 SECS PRIOR TO HIGATE DURING THE
# DESCENT PHASE.  HIGATASK SETS THE HIGATE FLAG (BIT11) AND THE LR INHIBIT
# FLAG (BIT10) IN LRSTAT.  THE HIGATJOB IS SET UP TO REPOSITION THE LR
# ANTENNA FROM POSITION 1 TO POSITION 2.  IF THE REPOSITIONING IS
# SUCCESSFUL THE ALT BEAM AND VELOCITY BEAMS ARE TRANSFORMED TO THE NEW
# ORIENTATION IN NB COORDINATES AND STORED IN ERASABLE.

HIGATASK        TC      PHASCHNG
                OCT     51

                CA      PRIO32
                TC      FINDVAC
                EBANK=  HMEAS
                2CADR   HIGATJOB

                CS      FLGWRD11
                MASK    PRIO3
                ADS     FLGWRD11
                TCF     CONTSERV +1

## Page 877
#    MUNRETRN IS THE RETURN LOC FROM SPECIAL AVE G ROUTINE (MUNRVG)

MUNRETRN        EXIT

                CS      FLGWRD11
                MASK    LRBYBIT
                EXTEND
                BZF     COPYCYC1        # BYPASS LR LOGIC IF BIT15 IS SET.

                CS      FLGWRD11        # CHECK IF AT 30000 FT
                MASK    XORFLBIT
                EXTEND
                BZF     LROFF?

30KCHK          EXTEND
                DCA     1-30KFT
                DAS     MPAC            # HCALC IS STILL IN MPAC FROM RVBOTH

                CCS     A
                TCF     R12             # ALTITUDE > 30KFT
                TC      UPFLAG          # ALTITUDE < 30KFT SET X-AXIS OVERRIDE
                ADRES   XOVINFLG
                TC      UPFLAG
                ADRES   XORFLG

LROFF?          CA      HCALC
                EXTEND                  # IF HIGH ORDER PART ZERO, H < 3000 FT,
                BZF     +2              #   SO MAKE CUTOFF TEST
                TCF     R12
                CS      HCALC +1
                AD      HLROFF
                EXTEND
                BZMF    R12             # IF H < HLROFF, RESET LR PERMIT FLAG
                TC      DOWNFLAG
                ADRES   LRINH

R12             CS      FLGWRD11
                MASK    NOLRRBIT
                EXTEND
                BZF     CONTSERV

POSTST          CA      BITS6+7         # TEST LANDING RADAR POSITION DISCRETES
                EXTEND
                RAND    CHAN33
                EXTEND
                MP      BIT10           # SHIFT BITS 6+7 TO BITS 1+2

                INDEX   A
                TCF     +1
                TCF     511?            # A = 0 - BOTH DISCRETES PRESENT
## Page 878
                TCF     POSCHNG?        # A = 1 - POSITION 2
                TCF     POSCHNG?        # A = 2 - POSITION 1
511?            CCS     511CTR          # IF CONDITION PERSISTS FOR FIVE
                TCF     ST511CTR        # CONSECUTIVE PASSES,ISSUE 511 ALARM
                TC      ALARM
                OCT     511
                CS      ZERO            # SET CTR TO -0 TO BYPASS ALARM
ST511CTR        TS      511CTR
                TCF     CONTSERV
POSCHNG?        TS      L
                CA      FOUR            # SET 511CTR TO RE-ENABLE 511 ALARM
                TS      511CTR
                LXCH    LRPOS           # UPDATE LRPOS
                CS      LRPOS           # COMPARE OLD AND NEW POSITIONS
                AD      L
                EXTEND                  # IF OLDPOS = NEWPOS,
                BZF     UPDATCHK        # TRY TO UPDATE WITH LR DATA

CONTSERV        INHINT
                CS      BITS4-7
                MASK    FLGWRD11        # CLEAR LR MEASUREMENT MADE DISCRETES.
                TS      FLGWRD11

## Page 879
COPYCYC1        TC      QUIKFAZ5

                TC      INTPRET         # INTPRET DOES A RELINT.
                VLOAD   ABVAL           # MPAC = ABVAL( NEW SM. POSITION VECTOR )
                        R1S
                PUSH    DSU             #                               (2)
                        /LAND/
                STORE   HCALC           # NEW HCALC*2(24)M.
                STORE   HCALC1
                DMPR    RTB
                        ALTCONV
                        SGNAGREE
                STOVL   ALTBITS         # ALTITUDE FOR R10 IN BIT UNITS.
                        UNIT/R/
                VXV     UNIT
                        UHYP
                STOVL   UHZP            # DOWNRANGE HALF-UNIT VECTOR FOR R10.
                        R1S
                VXM     VSR4
                        REFSMMAT
                STOVL   RN1             # TEMP. REF. POSITION VECTOR*2(29)M.
                        V1S
                VXM     VSL1
                        REFSMMAT
                STOVL   VN1             # TEMP. REF. VELOCITY VECTOR*2(7)M/CS.
                        UNIT/R/
                VXV     ABVAL
## Page 872
                        V1S
                SL1     DSQ
                DDV
                DMPR    RTB
                        ARCONV1
                        SGNAGREE
COPYCYC2        EXIT                    # LEAVE ALTITUDE RATE COMPENSATION IN MPAC
                INHINT
                CA      UNIT/R/         # UPDATE RUNIT FOR R10.
                TS      RUNIT
                CA      UNIT/R/ +2
                TS      RUNIT +1
                CA      UNIT/R/ +4
                TS      RUNIT +2
                CA      MPAC            # LOAD NEW DALTRATE FOR R10.
                TS      DALTRATE

                EXTEND
                DCA     R1S
                DXCH    R
                EXTEND
                DCA     R1S +2
                DXCH    R +2
                EXTEND
                DCA     R1S +4
                DXCH    R +4
                EXTEND
                DCA     V1S
                DXCH    V
                EXTEND
                DCA     V1S +2
                DXCH    V +2
                EXTEND
                DCA     V1S +4
                DXCH    V +4

                TCF     COPYCYCL        # COMPLETE THE COYPCYCL.

## Page 882
# *********************************************************************************************************

CALCGRAV        UNIT    PUSH            # SAVE UNIT/R/ IN PUSHLIST            (18)
                STORE   UNIT/R/
                LXC,1   SLOAD           # RTX2 = 0 IF EARTH ORBIT, =2 IF LUNAR.
                        RTX2
                        RTX2
                DCOMP   BMN
                        CALCGRV1
                VLOAD   DOT             #                                     (12)
                        UNITZ
                        UNIT/R/
                SL1     PUSH            #                                     (14)
                DSQ     BDSU
                        DP1/20
                PDDL    DDV
                        RESQ
                        34D             # (RN)SQ
                STORE   32D             # TEMP FOR (RE/RN)SQ
                DMP     DMP
                        20J
                VXSC    PDDL
                        UNIT/R/
                DMP     DMP
                        2J
                        32D
                VXSC    VSL1
                        UNITZ
                VAD     STADR
                STORE   UNITGOBL
                VAD     PUSH            # MPAC = UNIT GRAVITY VECTOR.         (18)
CALCGRV1        DLOAD   NORM            # PERFORM A NORMALIZATION ON RMAGSQ IN
                        34D             # ORDER TO BE ABLE TO SCALE THE MU FOR
                        X2              # MAXIMUM PRECISION.
                BDDV*   SLR*
                        -MUDT,1
                        0 -21D,2
                VXSC    STADR
                STORE   GDT1/2          # SCALED AT 2(+7) M/CS
                RVQ

CALCRVG         VLOAD   VXM
                        DELV
                        REFSMMAT
                VXSC    VSL1
                        KPIP1
                STORE   DELVREF
                VSR1    PUSH
                VAD     PUSH            # (DV-OLDGDT)/2 TO PD SCALED AT 2(+7)M/CS
## Page 883
                        GDT/2
                VAD     PDDL            #                                       (18)
                        VN
                        PGUIDE
                SL      VXSC
                        6D
                VAD     STQ
                        RN
                        31D
                STCALL  RN1             # TEMP STORAGE OF RN SCALED 2(+29)M
                        CALCGRAV

                VAD     VAD
                VAD
                        VN
                STCALL  VN1             # TEMP STORAGE OF VN SCALED 2(+7)M/CS
                        31D

DP1/20          2DEC    0.05

SHIFT11         2DEC    1 B-11

## Page 884
# ****************************************************************************************************************

# MUNRVG IS A SPECIAL AVERAGE G INTEGRATION ROUTINE USED BY THRUSTING
# PROGRAMS WHICH FUNCTION IN THE VICINITY OF AN ASSUMED SPHERICAL MOON.
# THE INPUT AND OUTPUT QUANTITIES ARE REFERENCED TO THE STABLE MEMBER
# COORDINATE SYSTEM.

RVBOTH          VLOAD   PUSH
                        G(CSM)          # CSM GDT1/2 FOR LAST PASS.
                VAD     PDDL
                        V(CSM)
                        PGUIDE
                DDV     VXSC
                        SHIFT11
                VAD
                        R(CSM)
                STCALL  R1S             # = RCSM + PGUIDE(VCSM + GCSM) AT 2(+24)M.
                        MUNGRAV         # COMPUTE LUNAR GRAVITY AT CSM ALTITUDE.
                VAD     VAD
                        V(CSM)
                STADR
                STORE   V1S             # = VCSM + GCSM + GDT1/2 AT 2(+7)M/CS.
                EXIT
                TC      QUIKFAZ5
                TC      INTPRET
                VLOAD                   # FOR RESTART PURPOSES.
                        GDT1/2
                STOVL   G(CSM)
                        R1S
                STOVL   R(CSM)
                        V1S
                STORE   V(CSM)
                EXIT
                TC      QUIKFAZ5
                TC      INTPRET
MUNRVG          VLOAD   VXSC
                        DELV
                        KPIP2
                PUSH    VAD             # 1ST PUSH: DELV IN UNITS OF 2(8) M/CS
                        GDT/2
                PUSH    VAD             # 2ND PUSH: (DELV + GDT)/2, UNITS OF 2(7)
                        V               #                                     (12)
                PDDL    DDV
                        PGUIDE
                        SHIFT11
                VXSC
                VAD
                        R               # LM POSITION VECTOR AT 2(24)M.
                STCALL  R1S             # = R + PGUIDE(V + DELV + GDT1/2).
                        MUNGRAV
## Page 885
                VAD     VAD
                VAD                     #                                     (0)
                        V               # LM VELOCITY VECTOR AT 2(+7)M/CS.
                STORE   V1S             # = V + GDT1/2 + DELV
                ABVAL
                STOVL   ABVEL           # STORE SPEED FOR LR AND DISPLAYS.
                        UNIT/R/
                DOT     SL1
                        V1S
                STOVL   HDOTDISP        # HDOT = V. UNIT(R)*2(7) M/CS.
                        R1S
                VXV     VSL2
                        WM
                STODL   DELVS           # LUNAR ROTATION CORRECTION TERM*2(5)M/CS.
                        36D
                DSU     RTB
                        /LAND/
                        SGNAGREE
                STCALL  HCALC           # FOR NOW, DISPLAY WHETHER POS OR NEG
                        MUNRETRN        # GO TO LR UPDATES ROUTINE, R12.

MUNGRAV         UNIT                    # AT 36D HAVE ABVAL(R), AT 34D R.R
                STODL   UNIT/R/
                        34D
                SL      BDDV
                        6D
                        -MUDTMUN
                DMP     VXSC
                        SHIFT11
                        UNIT/R/
                STORE   GDT1/2          # 1/2GDT SCALED AT 2(7)M/CS.
                RVQ

BITS6+7         EQUALS  SUPER110        # LR POSITION DISCRETES
2SEC(18)        2DEC    200 B-18

2SEC(28)        2OCT    0000000310      # 2SEC AT 2(28)

4SEC(28)        2DEC    400 B-28

BITS4-7         OCT     110
1-30KFT         2DEC    16768072 B-24   # DPPOSMAX-30KFT

66DEC           DEC     66

## Page 886
UPDATCHK        CA      RNGEDBIT        # SEE IF ALT READING MADE
## RNGEDBIT in the above line is circled
                MASK    FLGWRD11
                EXTEND
                BZF     VMEASCHK        # NO ALT MEAS THIS CYCLE-CHECK FOR VEL

POSUPDAT        TC      QUIKFAZ5
                TC      POSINDEX        # SET X1 TO PROPER POSITION AND ZERO PLIST
                TC      INTPRET
                VLOAD*  VXM
                        HBEAMNB,1
                        XNBPIP          # HBEAM SM AT 2(1)
                PDDL    SL              # STORE IN PUSHLIST AND SCALE HMEAS
                        HMEAS
                        6D
                DMP     VXSC            # SLANT RANGE AT 2(22),PUSH UP FOR HBEAM
                        HSCAL           # TO GET SLANT RANGE VECTOR AT 2(23) M
                PUSH    DOT             # PUSH NEG OF RADAR ALTITUDE BEAM VECTOR
                        UNIT/R/         # ALTITUDE AT 2(24) METERS
                DSU     PDDL            # PUSH PARTIAL DELTA H, LOAD NEG OF BEAM Z
                        HCALC

## At the end of the 2nd divider below, the suffixed ':' was an '=' in the
## original printout.  The replacement is a workaround for our proof-reading
## system.
# ========================================================================
# TERRAIN MODEL
# =======================================================================:

                SR1     DAD
                        LAND +4
                BDSU    SL              # SCALE RANGE TO UNITS OF 2(18) METERS
                        R1S +4
                        6D
                BOVB    EXIT
                        SIGNMPAC        # PICK UP NEGMAX UPON OVERFLOW

                CS      FLAGWRD1        # IS NOTERFLG SET (BY P66 OR V68)?
                MASK    NOTERBIT
                EXTEND
                BZF     TERSKIP         # Y: SKIP TERRAIN BUT TRANSFER DELTA H

                CA      EBANK5          # N: PREPARE TO ACCESS TERRAIN TABLE
                TS      EBANK
                EBANK=  END-E5

                CA      ZERO            # INITIALIZE MINUS LAST ABSCISSA FOR
                TS      TEM2            # TERLOOP WHICH ADDS THE CONTRIBUTIONS
                CA      FOUR            # OF FIVE TERRAIN SEGMENTS TO DELTA H
TERLOOP         TS      TEM5
## Page 887
                CA      MPAC            # PICK UP CURRENT RANGE (NEG BEFORE SITE)
                TS      L
                INDEX   TEM5
                CS      ABSC0           # TERRAIN ABSCISSAE UNITS: 2(18) METERS
                TC      BANKCALL        # LIMIT GIVEN LIMITSUB MUST BE POSITIVE
                FCADR   LIMITSUB        # LIMIT |RANGE| <= |CURRENT ABSCISSA|
                TS      TEM4            # SAVE TO COMPARE WITH CURRENT ABSCISSA

                AD      TEM2            # SUBTRACT LAST ABSCISSA
                EXTEND
                INDEX   TEM5
                MP      SLOPE0          # SLOPE UNITS: 2(6) RADIANS. RESOL: 3.9 MR

                INDEX   FIXLOC          # ADD CONTRIBUTION OF SEGMENT TO YIELD
                DAS     4               # CORRECTED DELTA H IN UNITS 2(24) METERS

                CA      TEM1            # RETRIEVE MINUS CURR ABSC FROM LIMITSUB*
                TS      TEM2            # STORE AS MINUS LAST ABSC FOR NEXT SEG

# * NOTE:  IF WE HAVE FLOWN BEYOND THE LANDING SITE BY MORE THAN THE
#          LENGTH OF THE SEGMENT ADJACENT TO THE LANDING SITE, CA TEM1
#          WILL RETRIEVE - INSTEAD OF MINUS THE CURRENT ABSCISSA -
#          A ZERO OR POSITIVE REMAINDER OF THE DIVISION DONE BY LIMITSUB.
#          THIS RETRIEVAL WILL CAUSE AN IMMEDIATE BRANCH TO TEREND,
#          WHICH IS THE DESIRED RESULT.  HOWEVER, FLYING PAST THE LANDING
#          SITE IS IMPOSSIBLE EXCEPT IN P66 WHEN THE TERRAIN MODEL IS OFF.

                AD      TEM4            # HAS LM FLOWN PAST CURRENT ABSCISSA?
                EXTEND
                BZF     +2
                TCF     TEREND          # Y: IGNORE FURTHER ABSCISSAE
                CCS     TEM5            # N: IS CURRENT ABSCISSA THE LAST?
                TCF     TERLOOP         # N: REPEAT TERRAIN LOOP

TEREND          CA      EBANK7          # Y: RESTORE EBANK AND DEPART
                TS      EBANK
                EBANK=  END-E7

TERSKIP         INDEX   FIXLOC          # TRANSFER COMPLETED DELTA H HOME
                DXCH    4               # TO BE ACCESSED BY DISPLAYS, TELEMETRY,
                DXCH    DELTAH          # AND POSITION UPDATE.

                CA      FIXLOC          # RESTORE PUSHDOWN POINTER TO ZERO
                TS      PUSHLOC

## Page 888
                CA      FLGWRD11        # IS PSTHIBIT SET (BY HIGATASK)?
                MASK    PSTHIBIT
                EXTEND                  # DO NOT PERFORM DATA REASONABLENESS TEST
                BZF     NOREASON        # UNTIL AFTER HIGATE

                TC      INTPRET
                DLOAD   ABS
                        DELTAH
                DSU     SL3             # ABS(DELTAH) - DQFIX
                        DELQFIX
                DSU     EXIT            # ABS(DELTAH) - (DQFIX + HCALC/8) AT 2(21)
                        HCALC

                INCR    LRLCTR
                TC      BRANCH
                TCF     HFAIL           # DELTA H TOO LARGE
                TCF     HFAIL           # DELTA H TOO LARGE
                TC      DOWNFLAG        # RESET HFAIL FLAG
                ADRES   HFAILFLG
                TC      DOWNFLAG        # TURN OFF ALT FAIL LAMP
                ADRES   HFLSHFLG

NOREASON        CS      FLGWRD11
                MASK    LRINHBIT
                CCS     A
                TCF     VMEASCHK        # UPDATE INHIBITED - TEST VELOCITY ANYWAY

                TC      INTPRET
POSUP           DLOAD   SR4
                        HCALC           # RESCALE H TO 2(28)M
                EXIT
                EXTEND
                DCA     DELTAH          # STORE DELTAH IN MPAC AND
                DXCH    MPAC            # BRING HCALC INTO A,L
                TC      ALSIGNAG
                EXTEND                  # IF HIGH PART OF HCALC IS NON ZERO, THEN
                BZF     +2              # HCALC > HMAX,
                TCF     VMEASCHK        # SO UPDATE IS BYPASSED
                TS      MPAC +2         #   FOR LATER SHORTMP

                CS      L               # -H AT 2(14)M
                AD      LRHMAX          # HMAX - H
                EXTEND
                BZMF    VMEASCHK        # IF H >HMAX, BYPASS UPDATE
                EXTEND
                MP      LRWH            # WH(HMAX - H)
                EXTEND
                DV      LRHMAX          # WH(1 - H/HMAX)
                TS      MPTEMP
                TC      SHORTMP2        # DELTAH (WH)(1 - H/HMAX) IN MPAC
## Page 889
                TC      INTPRET         # MODE IS DP FROM ABOVE
                SL1
                VXSC    VAD
                        UNIT/R/         # DELTAR = DH(WH)(1 - H/HMAX) UNIT/R/
                        R1S
                STORE   GNUR
                EXIT

                TC      QUIKFAZ5

                CA      ZERO
RUPDATED        TC      GNURVST

VMEASCHK        TC      QUIKFAZ5        # RESTART AT NEXT LOCATION
                CS      FLGWRD11
                MASK    VELDABIT        # IS V READING AVAILABLE?
                CCS     A
                TCF     VALTCHK         # NO   SEE IF V READING TO BE TAKEN

VELUPDAT        TC      POSINDEX        # SET X1 AND X2 AND ZERO PUSHLIST
                CS      VSELECT
                TS      L
                ADS     L               # -2 VSELECT IN L
                AD      L
                AD      L               # -6 VSELECT IN A
                INDEX   FIXLOC
                DAS     X1              # X1 = -6 VSELECT(POS), X2 = -2 VSELECT

                TC      INTPRET
                VLOAD*  VXM
                        VZBEAMNB,1      # CONVERT PROPER VBEAM FROM NB TO SM
                        XNBPIP          # SCALED AT 2(1)
                PDDL    SL              # STORE IN PD 0-5
                        VMEAS           # LOAD VELOCITY MEASUREMENT
                        12D
                DMP*    PDVL            # SCALE TO M/CS AT 2(6)
                        VZSCAL,2        # AND STORE IN PD 6-7
                        V1S             # VELOCITY AT TIME OF READING
                VSL2    VAD             # SCALE TO 2(5) M/CS AND SUBTRACT
                        DELVS           #               MOON ROTATION.
                PUSH    ABVAL           # STORE IN PD
                SR4     DAD             # ABS(VM)/8 + VELBIAS AT 2(6)
                        VELBIAS
## Page 890
                STOVL   20D             # STORE IN 20D AND PICK UP VM
                DOT     BDSU
                        0               # DELTAV = VMEAS - V(EST)
                PUSH    ABS
                DSU     EXIT            # ABS(DV) - (7.5 + ABS(VM)/8))
                        20D

                INCR    LRMCTR
                TC      BRANCH
                TCF     VFAIL           # DELTA V TOO LARGE     ALARM
                TCF     VFAIL           # DELTA V TOO LARGE     ALARM

                TC      DOWNFLAG        # RESET HFAIL FLAG
                ADRES   VFAILFLG
                TC      DOWNFLAG        # TURN OFF VEL FAIL LAMP
                ADRES   VFLSHFLG
## The above line is circled.

                CA      FLGWRD11
                MASK    VXINHBIT
                EXTEND
                BZF     VUPDAT          # IF VX INHIBIT RESET, INCORPORATE DATA.

                TC      DOWNFLAG
                ADRES   VXINH           # RESET VX INHIBIT

                CA      VSELECT
                AD      NEG2            # IF VSELECT = 2 (X AXIS),
                EXTEND                  # BYPASS UPDATE
                BZF     ENDVDAT

VUPDAT          CS      FLGWRD11
                MASK    LRINHBIT
                CCS     A
                TCF     VALTCHK         # UPDATE INHIBITED

                TS      MPAC +1

                CA      ABVEL           # STORE E7 ERASABLES NEEDED IN TEMPS
                TS      ABVEL*
                CA      VSELECT
                TS      VSELECT*
                CA      EBANK5
                TS      EBANK           # CHANGE EBANKS

                EBANK=  LRVF
                CS      LRVF
                AD      ABVEL*          # IF V < VF, USE WVF
                EXTEND
                BZMF    USEVF

## Page 891
                CS      ABVEL*
                AD      LRVMAX          # VMAX - V
                EXTEND
                BZMF    WSTOR -1        # IF V > VMAX, W = 0

                EXTEND
                INDEX   VSELECT*
                MP      LRWVZ           # WV(VMAX - V)

                EXTEND
                DV      LRVMAX          # WV( 1 - V/VMAX )
                TCF     WSTOR

USEVF           INDEX   VSELECT*
                CA      LRWVFZ          # USE APPROPRIATE CONSTANT WEIGHT
                TCF     WSTOR

 -1             CA      ZERO
WSTOR           TS      MPAC
                CS      BIT7            # (=64D)
                AD      MODREG
                EXTEND
                BZMF    GETGNUV         # IF IN P66 USE ANOTHER CONSTANT
                CA      LRWVFF
                TS      MPAC

GETGNUV         CA      EBANK7
                TS      EBANK           # CHANGE EBANKS

                EBANK=  ABVEL
                TC      INTPRET
                DMP     VXSC            # W(DELTA V)(VBEAMSM)  UP 6-7, 0-5
                VAD
                        V1S             # ADD WEIGHTED DELTA V TO VELOCITY
                STORE   GNUV
                EXIT

                TC      QUIKFAZ5        # DO NOT RE-UPDATE

                CA      SIX
VUPDATED        TC      GNURVST         # STORE NEW VELOCITY VECTOR
ENDVDAT         =       VALTCHK

VALTCHK         TC      QUIKFAZ5        # DO NOT REPEAT ABOVE

HIGATCHK        CS      FLGWRD11        # IS PSTHIBIT SET (BY HIGATASK)?
                MASK    PSTHIBIT
                EXTEND
                BZF     CONTSERV        # YES:  BYPASS HIGATE CHECK

## Page 892
                CA      TTF/8
                AD      RPCRTIME
                EXTEND
                BZMF    CONTSERV

                CA      EBANK4
                XCH     EBANK
                TS      L

                EBANK=  XNBPIP
                CS      XNBPIP
                EBANK=  DVCNTR
                LXCH    EBANK
                AD      RPCRTQSW
                EXTEND
                BZMF    HIGATASK
                TCF     CONTSERV


GNURVST         TS      BUF             # STORE GNUR (=GNUV) IN R1S OR V1S
                EXTEND                  # A = 0 FOR R, A = 6 FOR V
                DCA     GNUR
                INDEX   BUF
                DXCH    R1S
                EXTEND
                DCA     GNUR +2
                INDEX   BUF
                DXCH    R1S +2
                EXTEND
                DCA     GNUR +4
                INDEX   BUF
                DXCH    R1S +4
                TC      Q


QUIKFAZ5        CA      EBANK3
                XCH     EBANK           # SET EBANK 3
                DXCH    L               # Q TO A, A TO L
                EBANK=  PHSNAME5
                TS      PHSNAME5
                LXCH    EBANK
                EBANK=  DVCNTR
                TC      A


POSINDEX        CA      FIXLOC          # SET PUSHLIST TO ZERO
                TS      PUSHLOC

                CA      BIT1
                MASK    LRPOS           # *NOTE - LRPOS = 1 FOR POS 2 & VICE VERSA
## Page 893
                CCS     A
                CS      OCT30           # POS 2 , INDEX = -24D
                ZL                      # POS 1 , INDEX = 0 , X2 = 0 FOR BOTH
                INDEX   FIXLOC
                DXCH    X1              # SET X1,X2
                TC      Q
HFAIL           TC      UPFLAG          # SET HFAIL FLAG FOR DOWNLINK
                ADRES   HFAILFLG
                CS      LRRCTR
                EXTEND
                BZF     NORLITE         # IF R = 0, DO NOT TURN ON TRK FAIL
                AD      LRLCTR
                MASK    NEG3
                EXTEND                  # IF L-R LT 4, DO NOT TURN ON TRK FAIL
                BZF     +2
                TCF     NORLITE

                TC      UPFLAG          # AND SET BIT TO TURN ON TRACKER FAIL LITE
                ADRES   HFLSHFLG

NORLITE         CA      LRLCTR
                TS      LRRCTR          # SET R = L

                TCF     VMEASCHK

VFAIL           TC      UPFLAG
                ADRES   VFAILFLG        # SET VFAIL FLAG FOR DOWNLINK
## The above instruction and address are circled in red.
                CS      LRSCTR
                EXTEND                  # IF S = 0, DO NOT TURN ON TRACKER FAIL
                BZF     NOLITE
                AD      LRMCTR          # M-S
                MASK    NEG3            # TEST FOR M-S > 3
                EXTEND                  # IF M-S > 3, THEN TWO OR MORE OF THE
## In the above comment, "THEN TWO ORE MORE OF THE" is crossed out in green.
                BZF     +2              #   LAST FOUR V READINGS WERE BAD,
## In the above comment, a 3 has been written over FOUR, and "BAD," has been crossed out
## with "GOOD," written next to it.
                TCF     NOLITE          #   SO TURN ON VELOCITY FAIL LIGHT
## "DON'T" is written under "SO TURN", indicating the line should read "SO DON'T TURN ON..."

                TC      UPFLAG          # AND SET BIT TO TURN ON TRACKER FAIL LITE
                ADRES   VFLSHFLG
## The above instruction and address are circled.

NOLITE          CA      LRMCTR          # SET S = M
                TS      LRSCTR

                CCS     VSELECT         # TEST FOR Z COMPONENT
                TCF     ENDVDAT         # NOT Z, DO NOT SET VX INHIBIT

                TC      UPFLAG          # Z COMPONENT - SET FLAG TO SKIP X
                ADRES   VXINH           # COMPONENT,AS ERROR MAY BE DUE TO CROSS
                TCF     ENDVDAT         # LOBE LOCK UP NOT DETECTED ON X AXIS.

## Page 894
# ********************************************************************************************************
                BANK    33
                SETLOC  SERVICES
                BANK

                COUNT*  $$/SERV

                EBANK=  DVCNTR


# HIGATJOB IS BEGUN WHEN BOTH THE TIME AND ANGLE CRITERIA FOR ANTENNA REPOSITIONING ARE MET. THE JOB INITIATES THE
# LANDING RADAR ANTENNA REPOSITIONING ROUTINE. DURING THE REPOSITIONING, R12 IS INHIBITTED BY THE NOLRREAD FLAG.
# UPON COMPLETION OF THE REPOSITIONING,(SUCCESSFUL OR NOT),THE NOLRREAD   FLAG IS CLEARED AND R12 CONTINUES.


REREPOS         INHINT                  # ON RESTART, SET FLAGS AGAIN
                CS      FLGWRD11
                MASK    PRIO3
                ADS     FLGWRD11

HIGATJOB        TC      BANKCALL        # INITIATE REPOSITIONING ROUTINE
                CADR    LRPOS2
                TC      BANKCALL        # DELAY UNTIL FINISHED
                CADR    RADSTALL

                TCF     +1              # IF UNSUCCESSFUL, R12 WILL HANDLE THINGS
                CA      ONE             # INDICATE POS 2 IS EXPECTED
                TS      LRPOS

                TC      DOWNFLAG        # RE-ENABLE R12.
                ADRES   NOLRREAD

                TC      PHASCHNG        # CLEAR RESTART PROTECTION
                OCT     1
                TC      ENDOFJOB
## Below, in the comment column, is written "NEG3 = 77774"
