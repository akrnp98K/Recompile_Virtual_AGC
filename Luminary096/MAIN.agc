### FILE="Main.annotation"
# Copyright:    Public domain.
# Filename:     MAIN.agc
# Purpose:      The main source file for Luminary revision 096.
#               It is part of the reconstructed source code for the
#               original release of the flight software for the Lunar 
#               Module's (LM) Apollo Guidance Computer (AGC) for Apollo 11.
#               The code has been recreated from a copy of Luminary 99
#               revision 001, using asterisks indicating changed lines in
#               the listing and Luminary Memos #83 and #85, which list 
#               changes between Luminary 97 and 98, and 98 and 99. The
#               code has been adapted such that the resulting bugger words
#               exactly match those specified for Luminary 96 in NASA drawing
#               2021152D, which gives relatively high confidence that the
#               reconstruction is correct.
# Assembler:    yaYUL
# Contact:      Ron Burkey <info@sandroid.org>.
# Website:      www.ibiblio.org/apollo/index.html
# Warning:      THIS PROGRAM IS STILL UNDERGOING RECONSTRUCTION
#               AND DOES NOT YET REFLECT THE ORIGINAL CONTENTS OF
#               LUMINARY 97.
# Mod history:  2019-08-04 MAS  Created.

$ASSEMBLY_AND_OPERATION_INFORMATION.agc		        # pp. 1-27
$TAGS_FOR_RELATIVE_SETLOC_AND_BLANK_BANK_CARDS.agc	# pp. 28-37
$CONTROLLED_CONSTANTS.agc			        # pp. 38-53
$INPUT_OUTPUT_CHANNEL_BIT_DESCRIPTIONS.agc	        # pp. 54-60
$FLAGWORD_ASSIGNMENTS.agc			        # pp. 61-88
						        # p.  89 is a GAP-generated table.
$ERASABLE_ASSIGNMENTS.agc			        # pp. 90-152
$INTERRUPT_LEAD_INS.agc				        # pp. 153-154
$T4RUPT_PROGRAM.agc				        # pp. 155-189
$RCS_FAILURE_MONITOR.agc				# pp. 190-192
$DOWNLINK_LISTS.agc				        # pp. 193-205
$AGS_INITIALIZATION.agc				        # pp. 206-210
$FRESH_START_AND_RESTART.agc			        # pp. 211-237
$RESTART_TABLES.agc				        # pp. 238-243
$AOTMARK.agc					        # pp. 244-261
$EXTENDED_VERBS.agc				        # pp. 262-300
$PINBALL_NOUN_TABLES.agc			        # pp. 301-319
$LEM_GEOMETRY.agc				        # pp. 320-325
$IMU_COMPENSATION_PACKAGE.agc			        # pp. 326-337
$R63.agc					        # pp. 338-341
$ATTITUDE_MANEUVER_ROUTINE.agc			        # pp. 342-363
$GIMBAL_LOCK_AVOIDANCE.agc			        # p.  364
$KALCMANU_STEERING.agc				        # pp. 365-369
$SYSTEM_TEST_STANDARD_LEAD_INS.agc		        # pp. 370-372
$IMU_PERFORMANCE_TESTS_2.agc			        # pp. 373-381
$IMU_PERFORMANCE_TESTS_4.agc			        # pp. 382-389
$PINBALL_GAME__BUTTONS_AND_LIGHTS.agc		        # pp. 390-471
$R60,R62.agc					        # pp. 472-485
$S-BAND_ANTENNA_FOR_LM.agc			        # pp. 486-489
$RADAR_LEADIN_ROUTINES.agc			        # pp. 490-491
$P20-P25.agc					        # pp. 492-613
$P30,P37.agc					        # pp. 614-617
$P32-P35,_P72-P75.agc				        # pp. 618-650
$LAMBERT_AIMPOINT_GUIDANCE.agc			        # pp. 651-653
$GROUND_TRACKING_DETERMINATION_PROGRAM_-_P21.agc        # pp. 654-657
$P34-P35,_P74-P75.agc				        # pp. 658-702
$R31.agc					        # pp. 703-708
$P76.agc					        # pp. 709-711
$R30.agc					        # pp. 712-722
$STABLE_ORBIT_-_P38-P39.agc			        # pp. 723-730
$BURN,_BABY,_BURN_--_MASTER_IGNITION_ROUTINE.agc	# pp. 731-751
$P40-P47.agc					        # pp. 752-784
$THE_LUNAR_LANDING.agc				        # pp. 785-792
$THROTTLE_CONTROL_ROUTINES.agc			        # pp. 793-797
$LUNAR_LANDING_GUIDANCE_EQUATIONS.agc		        # pp. 798-828
$P70-P71.agc					        # pp. 829-837
$P12.agc					        # pp. 838-842
$ASCENT_GUIDANCE.agc				        # pp. 843-856
$SERVICER.agc					        # pp. 857-897
$LANDING_ANALOG_DISPLAYS.agc			        # pp. 898-907
$FINDCDUW_-_GUIDAP_INTERFACE.agc			# pp. 908-925
$P51-P53.agc					        # pp. 926-983
$LUNAR_AND_SOLAR_EPHEMERIDES_SUBROUTINES.agc	        # pp. 984-987
$DOWN-TELEMETRY_PROGRAM.agc			        # pp. 988-997
$INTER-BANK_COMMUNICATION.agc			        # pp. 998-1001
$INTERPRETER.agc				        # pp. 1002-1094
$FIXED-FIXED_CONSTANT_POOL.agc			        # pp. 1095-1099
$INTERPRETIVE_CONSTANTS.agc			        # pp. 1100-1101
$SINGLE_PRECISION_SUBROUTINES.agc		        # p.  1102
$EXECUTIVE.agc					        # pp. 1103-1116
$WAITLIST.agc					        # pp. 1117-1132
$LATITUDE_LONGITUDE_SUBROUTINES.agc		        # pp. 1133-1139
$PLANETARY_INERTIAL_ORIENTATION.agc		        # pp. 1140-1148
$MEASUREMENT_INCORPORATION.agc			        # pp. 1149-1158
$CONIC_SUBROUTINES.agc				        # pp. 1159-1204
$INTEGRATION_INITIALIZATION.agc			        # pp. 1205-1226
$ORBITAL_INTEGRATION.agc			        # pp. 1227-1248
$INFLIGHT_ALIGNMENT_ROUTINES.agc		        # pp. 1249-1258
$POWERED_FLIGHT_SUBROUTINES.agc			        # pp. 1259-1267
$TIME_OF_FREE_FALL.agc				        # pp. 1268-1283
$AGC_BLOCK_TWO_SELF-CHECK.agc			        # pp. 1284-1293
$PHASE_TABLE_MAINTENANCE.agc			        # pp. 1294-1302
$RESTARTS_ROUTINE.agc				        # pp. 1303-1308
$IMU_MODE_SWITCHING_ROUTINES.agc		        # pp. 1309-1337
$KEYRUPT,_UPRUPT.agc				        # pp. 1338-1340
$DISPLAY_INTERFACE_ROUTINES.agc			        # pp. 1341-1373
$SERVICE_ROUTINES.agc				        # pp. 1374-1380
$ALARM_AND_ABORT.agc				        # pp. 1381-1385
$UPDATE_PROGRAM.agc				        # pp. 1386-1396
$RTB_OP_CODES.agc				        # pp. 1397-1402
$T6-RUPT_PROGRAMS.agc				        # pp. 1403-1405
$DAP_INTERFACE_SUBROUTINES.agc			        # pp. 1406-1409
$DAPIDLER_PROGRAM.agc				        # pp. 1410-1420
$P-AXIS_RCS_AUTOPILOT.agc			        # pp. 1421-1441
$Q,R-AXES_RCS_AUTOPILOT.agc			        # pp. 1442-1459
$TJET_LAW.agc					        # pp. 1460-1469
$KALMAN_FILTER.agc				        # pp. 1470-1471
$TRIM_GIMBAL_CONTROL_SYSTEM.agc			        # pp. 1472-1484
$AOSTASK_AND_AOSJOB.agc				        # pp. 1485-1506
$SPS_BACK-UP_RCS_CONTROL.agc			        # pp. 1507-1510
						        # pp. 1511-1743: GAP-generated tables.

