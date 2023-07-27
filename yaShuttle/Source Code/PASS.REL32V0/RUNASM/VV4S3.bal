*/ Access:      Public Domain, no restrictions believed to exist.
*/ Filename:    VV4S3.bal
*/ Purpose:     This is a part of the HAL/S-FC compiler run-time library.
*/ Reference:   TBD.
*/ Language:    Basic Assembly Language (BAL), IBM System/360.
*/ Contact:     The Virtual AGC Project (www.ibiblio.org/apollo).
*/ History:     2022-12-08 RSB  Suffixed filename with ".bal".
*/ Note:        Comments beginning */ in column 1 are from the Virtual AGC 
*/              Project. Comments beginning merely with * are from the original 
*/              Space Shuttle development.

          TITLE  'VV4S3--VECTOR * SCALAR,LENGTH 3,SINGLE PREC'          00000100
*
* WHEN DATA_REMOTE IS IN EFFECT, THE LDM INSTRUCTIONS ARE NEEDED
* AROUND THE CALL TO THIS RTL ROUTINE BECAUSE R1/R3 IS USED AS
* A BASE REGISTER. (CR12620)
*
VV4S3    AMAIN    INTSIC=YES                                            00000200
*                                                                       00000300
*  COMPUTES THE VECTOR SCALAR PRODUCT:                                  00000400
*                                                                       00000500
*    V(3) =V1(3) * S                                                    00000600
*                                                                       00000700
*   WHERE V,V1,S  ARE SP                                                00000800
*                                                                       00000900
         INPUT R2,            VECTOR(3)  SP                            X00001000
               F0             SCALAR   SP                               00001100
         OUTPUT R1            VECTOR(3)  SP                             00001200
         WORK  F2                                                       00001300
*                                                                       00001400
*  ALGORITHM:                                                           00001500
*   V = (V1(1)*S,V1(2)*S,V1(3)*S);                                      00001600
*                                                                       00001700
         LE    F2,2(R2)      GET V1 ELE.                                00001800
         MER   F2,F0         MUL. BY S                                  00001900
         STE   F2,2(R1)      PLACE V ELE.                               00002000
         LE    F2,4(R2)                                                 00002100
         MER   F2,F0                                                    00002200
         STE   F2,4(R1)                                                 00002300
         LE    F2,6(R2)                                                 00002400
         MER   F2,F0                                                    00002500
         STE   F2,6(R1)                                                 00002600
         AEXIT                                                          00002700
         ACLOSE                                                         00002800
