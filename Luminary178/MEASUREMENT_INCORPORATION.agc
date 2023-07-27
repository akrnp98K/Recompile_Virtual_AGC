### FILE="Main.annotation"
## Copyright:   Public domain.
## Filename:    MEASUREMENT_INCORPORATION.agc
## Purpose:     A section of Luminary revision 178.
##              It is part of the reconstructed source code for the final
##              release of the flight software for the Lunar Module's
##              (LM) Apollo Guidance Computer (AGC) for Apollo 14. The
##              code has been recreated from copies of Zerlina 56, Luminary
##              210, and Luminary 131, as well as many Luminary memos.
##              It has been adapted such that the resulting bugger words
##              exactly match those specified for Luminary 178 in NASA
##              drawing 2021152N, which gives relatively high confidence
##              that the reconstruction is correct.
## Reference:   pp. 1140-1149
## Assembler:   yaYUL
## Contact:     Ron Burkey <info@sandroid.org>.
## Website:     www.ibiblio.org/apollo/index.html
## Mod history: 2019-08-14 MAS  Created from Zerlina 56.
##              2021-05-30 ABS  ZEROD -> ZEROO

## Page 1140
#  INCORP1--PERFORMS THE SIX DIMENSIONAL STATE VECTOR DEVIATION FOR POSITI
# ON AND VELOCITY OR THE NINE DIMENSIONAL DEVIATION OF POSITION,VELOCITY,A
# ND RADAR OR LANDMARK BIAS.THE OUTPUT OF THE BVECTOR ROUTINE ALONG WITH T
# HE ERROR TRANSITION MATRIX(W) ARE USED AS INPUT TO THE ROUTINE.THE DEVIA
# TION IS OBTAINED BY COMPUTING AN ESTIMATED TRACKING MEASUREMENT FROM THE
# CURRENT STATE VECTOR AND COMPARING IT WITH AN ACTUAL TRACKING MEASUREMEN
# T AND APPLYING A STATISTICAL WEIGHTING VECTOR.
# INPUT
#    DMENFLG = 0 6DIMENSIONAL BVECTOR  1= 9DIMENSIONAL
#           W = ERROR TRANSITION MATRIX 6X6 OR 9X9
#    VARIANCE = VARIANCE (SCALAR)
#      DELTAQ = MEASURED DEVIATION(SCALAR)
#     BVECTOR = 6 OR 9 DIMENSIONAL BVECTOR

# OUTPUT
#      DELTAX = STATE VECTOR DEVIATIONS 6 OR 9 DIMENSIONAL
#          ZI = VECTOR USED FOR THE INCORPORATION 6 OR 9 DIMENSIONAL
#     GAMMA = SCALAR
#     OMEGA = OMEGA WEIGHTING VECTOR 6 OR 9 DIMENTIONAL
# CALLING SEQUENCE
#    L  CALL INCORP1

# NORMAL EXIT

#    L+1 OF CALLING SEQUENCE

                BANK    37
                SETLOC  MEASINC
                BANK

                COUNT*  $$/INCOR

                EBANK=  W

INCORP1         STQ
                        EGRESS
                AXT,1   SSP
                        54D
                        S1
                        18D             # IX1 = 54  S1= 18
                AXT,2   SSP
                        18D
                        S2
                        6               # IX2 = 18  S2=6
Z123            VLOAD   MXV*
                        BVECTOR         # BVECTOR (0)
                        W +54D,1
                STORE   ZI +18D,2
                VLOAD
                        BVECTOR +6      # BVECTOR (1)
## Page 1141
                MXV*    VAD*
                        W +108D,1
                        ZI +18D,2
                STORE   ZI +18D,2
                VLOAD
                        BVECTOR +12D    # BVECTOR (2)
                MXV*    VAD*
                        W +162D,1
                        ZI +18D,2       # B(0)*W+B(1)*(W+54)+B(2)*(W+108)FIRST PAS
                STORE   ZI +18D,2       # ZI THEN Z2 THEN Z3
                TIX,1
                        INCOR1
INCOR1          TIX,2   BON
                        Z123            # LOOP FOR Z1,Z2,Z3
                        DMENFLG
                        INCOR1A
                VLOAD
                        ZEROVECS
                STORE   ZI +12D
INCOR1A         SETPD   VLOAD
                        0
                        ZI
                VSQ     RTB
                        TPMODE
                PDVL    VSQ
                        ZI +6
                RTB     TAD
                        TPMODE
                PDVL    VSQ
                        ZI +12D
                RTB     TAD
                        TPMODE
                TAD     AXT,2
                        VARIANCE
                        0
                STORE   TRIPA           # ZI*2 + Z2*2 + Z3*2 + VARIANCE
                TLOAD   BOV
                        VARIANCE        # CLEAR OVFIND
                        +1
                STORE   TEMPVAR         # TEMP STORAGE FOR VARIANCE
                BZE
                        INCOR1C
INCOR1B         SL2     BOV
                        INCOR1C
                STORE   TEMPVAR
                INCR,2  GOTO
                DEC     1
                        INCOR1B
INCOR1C         TLOAD   ROUND
                        TRIPA
## Page 1142
                DMP     SQRT
                        TEMPVAR
                SL*     TAD
                        0,2
                        TRIPA
                NORM    INCR,2
                        X2
                DEC     -2
                SXA,2   AXT,2
                        NORMGAM         # NORMALIZATION COUNT -2 FOR GAMMA
                        162D
                BDDV    SETPD
                        DP1/4TH
                        0
                STORE   GAMMA
                TLOAD   NORM
                        TRIPA
                        X1
                DLOAD   PDDL            # PD 0-1 = NORM (A)
                        MPAC
                        DELTAQ
                NORM
                        S1
                XSU,1   SR1
                        S1
                DDV     PUSH            # PD 0-1 = DELTAQ/A
                GOTO
                        NEWZCOMP
 -3             SSP
                        S2
                        54D
INCOR2          VLOAD   VXM*            # COMPUTE OMEGA1,2,3
                        ZI
                        W +162D,2
                PUSH    VLOAD
                        ZI +6
                VXM*    VAD
                        W +180D,2
                PUSH    VLOAD
                        ZI +12D
                VXM*    VAD
                        W +198D,2
                PUSH    TIX,2           # PD 2-7=OMEGA1,8-13=OMEGA2,14-19=OMEGA3
                        INCOR2
                VLOAD   STADR
                STORE   OMEGA +12D
                VLOAD   STADR
                STORE   OMEGA +6
                VLOAD   STADR
                STORE   OMEGA
## Page 1143
                BON     VLOAD
                        DMENFLG
                        INCOR2AB
                        ZEROVECS
                STORE   OMEGA +12D
INCOR2AB        AXT,2   SSP
                        18D
                        S2
                        6
INCOR3          VLOAD*
                        OMEGA +18D,2
                VXSC    VSL*
                        0               # DELTAQ/A
                        0,1
                STORE   DELTAX +18D,2
                TIX,2   VLOAD
                        INCOR3
                        DELTAX +6
                VSL3
                STORE   DELTAX +6
                GOTO
                        EGRESS

## Page 1144
#  INCORP2 -INCORPORATES THE COMPUTED STATE VECTOR DEVIATIONS INTO THE
# ESTIMATED STATE VECTOR. THE STATE VECTOR UPDATED MAY BE FOR EITHER THE
# LEM OR THE CSM.DETERMINED BY FLAG VEHUPFLG.(ZERO = LEM) (1 = CSM)
# INPUT
#    PERMANENT STATE VECTOR FOR EITHER THE LEM OR CSM
#    VEHUPFLG = UPDATE VEHICLE 0=LEM  1=CSM
#    W =        ERROR TRANSITION MATRIX
#    DELTAX  =  COMPUTED STATE VECTOR DEVIATIONS
#    DMENFLG =  SIZE OF W MATRIX (ZERO =6X6) (1=9X9)
#    GAMMA   =  SCALAR FOR INCORPORATION
#    ZI      =  VECTOR USED IN INCORPORATION
#    OMEGA  =  WEIGHTING VECTOR

# OUTPUT
#    UPDATED PERMANENT STATE VECTOR

# CALLING SEQUENCE
#    L  CALL INCORP2

# NORMAL EXIT
#    L+1 OF CALLING SEQUENCE

                SETLOC  MEASINC1
                BANK

                COUNT*  $$/INCOR

INCORP2         STQ     CALL
                        EGRESS
                        INTSTALL
                VLOAD   VXSC            # CALC. GAMMA * OMEGA1,2,3
                        OMEGA
                        GAMMA
                STOVL   OMEGAM1
                        OMEGA +6
                VXSC
                        GAMMA
                STOVL   OMEGAM2
                        OMEGA +12D
                VXSC
                        GAMMA
                STORE   OMEGAM3
                EXIT
                CAF     54DD            # INITIAL IX 1 SETTING FOR W MATRIX
                TS      WIXA
                TS      WIXB
                CAF     ZERO
                TS      ZIXA            # INITIAL IX 2 SETTING FOR Z COMPONENT
                TS      ZIXB
FAZA            TC      PHASCHNG
## Page 1145
                OCT     04022
                TC      UPFLAG
                ADRES   REINTFLG
FAZA1           CA      WIXB            # START FIRST PHASE OF INCORP2
                TS      WIXA            #  TO UPDATE 6 OR 9 DIM. W MATRIX IN TEMP
                CA      ZIXB
                TS      ZIXA
                TC      INTPRET
                LXA,1   LXA,2
                        WIXA
                        ZIXA
                SSP     DLOAD*
                        S1
                        6
                        ZI,2
                DCOMP   NORM            # CALC UPPER 3X9 PARTITION OF W MATRIX
                        S2
                VXSC    XCHX,2
                        OMEGAM1
                        S2
                LXC,2   XAD,2
                        X2
                        NORMGAM
                VSL*    XCHX,2
                        0,2
                        S2
                VAD*
                        W +54D,1
                STORE   HOLDW
                DLOAD*  DCOMP           # CALC MIDDLE 3X9 PARTITION OF W MATRIX
                        ZI,2
                NORM    VXSC
                        S2
                        OMEGAM2
                XCHX,2  LXC,2
                        S2
                        X2
                XAD,2   VSL*
                        NORMGAM
                        0,2
                XCHX,2  VAD*
                        S2
                        W +108D,1
                STORE   HOLDW +6
                BOFF
                        DMENFLG         # BRANCH IF 6 DIMENSIONAL
                        FAZB
                DLOAD*  DCOMP           # CALC LOWER 3X9 PARTITION OF W MATRIX
                        ZI,2
                NORM    VXSC
## Page 1146
                        S2
                        OMEGAM3
                XCHX,2  LXC,2
                        S2
                        X2
                XAD,2   VSL*
                        NORMGAM
                        0,2
                XCHX,2  VAD*
                        S2
                        W +162D,1
                STORE   HOLDW +12D
FAZB            CALL
                        GRP2PC
                EXIT
FAZB1           CA      WIXA            # START 2ND PHASE OF INCORP2 TO TRANSFER
                AD      6DD             #     TEMP REG TO PERM W MATRIX
                TS      WIXB
                CA      ZIXA
                AD      MINUS2
                TS      ZIXB
                TC      INTPRET
                LXA,1   SSP
                        WIXA
                        S1
                        6
                VLOAD
                        HOLDW
                STORE   W +54D,1
                VLOAD
                        HOLDW +6
                STORE   W +108D,1
                BOFF    VLOAD
                        DMENFLG
                        FAZB5
                        HOLDW +12D
                STORE   W +162D,1
FAZB2           TIX,1   GOTO
                        +2
                        FAZC            # DONE WITH W MATRIX. UPDATE STATE VECTOR
                RTB
                        FAZA
FAZB5           SLOAD   DAD
                        ZIXB
                        12DD
                BHIZ    GOTO
                        FAZC
                        FAZB2
FAZC            CALL
                        GRP2PC
## Page 1147
                VLOAD   VAD             # START 3RD PHASE OF INCORP2
                        X789            # 7TH,8TH,9TH,COMPONENT OF STATE VECTOR
                        DELTAX +12D     # INCORPORATION FOR X789
                STORE   TX789
                BON     RTB
                        VEHUPFLG
                        DOCSM
                        MOVEPLEM
FAZAB           BOVB    AXT,2
                        TCDANZIG
                        0
                BOFF    AXT,2
                        MOONTHIS
                        +2
                        2
                VLOAD   VSR*
                        DELTAX          # B27 IF MOON ORBIT, B29 IF EARTH
                        0 -7,2
                VAD     BOV
                        TDELTAV
                        FAZAB1
                STOVL   TDELTAV
                        DELTAX +6       # B5 IF MOON ORBIT, B7 IF EARTH
                VSR*    VAD
                        0 -4,2
                        TNUV
                BOV
                        FAZAB2
                STCALL  TNUV
                        FAZAB3
FAZAB1          VLOAD   VAD
                        RCV
                        DELTAX
                STORE   RCV
FAZAB2          VLOAD   VAD
                        VCV
                        DELTAX +6
                STORE   VCV
                SXA,2   CALL
                        PBODY
                        RECTIFY
FAZAB3          CALL
                        GRP2PC
                BON     RTB
                        VEHUPFLG
                        DOCSM1
                        MOVEALEM
                CALL
                        SVDWN2          # STORE DOWNLINK STATE VECTOR
FAZAB4          CALL
## Page 1148
                        GRP2PC          # PHASE CHANGE
                BOFF    VLOAD
                        DMENFLG
                        FAZAB5          # 6 DIMENSIONAL
                        TX789           # 9 DIMENSIONAL
                STORE   X789
FAZAB5          LXA,1   SXA,1
                        EGRESS
                        QPRET
                EXIT
                TC      POSTJUMP        # EXIT
                CADR    INTWAKE
DOCSM           RTB     GOTO
                        MOVEPCSM
                        FAZAB
DOCSM1          RTB     CALL
                        MOVEACSM
                        SVDWN1          # STORE DOWNLINK STATE VECTOR
                GOTO
                        FAZAB4
ZEROO           =       ZEROVECS
54DD            DEC     54
6DD             DEC     -6
12DD            DEC     12
                SETLOC  RENDEZ
                BANK
                COUNT*  $$/INCOR

NEWZCOMP        VLOAD   ABVAL
                        ZI
                STOVL   NORMZI
                        ZI +6
                ABVAL   PUSH
                DSU     BMN
                        NORMZI
                        +3
                DLOAD   STADR
                STORE   NORMZI
                VLOAD   ABVAL
                        ZI +12D
                PUSH    DSU
                        NORMZI
                BMN     DLOAD
                        +3
                STADR
                STORE   NORMZI          # LARGEST ABVAL
                DLOAD   SXA,1
                        NORMZI
                        NORMZI          # SAVE X1
                NORM    INCR,1
## Page 1149
                        X1
                DEC     2
                VLOAD   VSL*
                        ZI
                        0,1
                STOVL   ZI
                        ZI +6
                VSL*
                        0,1
                STOVL   ZI +6
                        ZI +12D
                VSL*    SXA,1
                        0,1
                        NORMZI +1       # SAVE SHIFT
                STORE   ZI +12D
                LXA,1   XSU,1
                        NORMGAM
                        NORMZI +1
                XSU,1
                        NORMZI +1
                SXA,1   LXC,1
                        NORMGAM
                        NORMZI +1
                XAD,1   SETPD
                        NORMZI
                        2D
                GOTO
                        INCOR2 -3
NORMZI          =       36D
