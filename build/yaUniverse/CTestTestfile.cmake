# CMake generated Testfile for 
# Source directory: D:/Document/CSLearn/Apollo/virtualagc-master/yaUniverse
# Build directory: D:/Document/CSLearn/Apollo/virtualagc-master/build/yaUniverse
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
if(CTEST_CONFIGURATION_TYPE MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
  add_test([=[yaUniverse]=] "D:/Document/CSLearn/Apollo/virtualagc-master/build/yaUniverse/Debug/yaUniverse.exe" "--ephem-read" "--mission=Test")
  set_tests_properties([=[yaUniverse]=] PROPERTIES  WORKING_DIRECTORY "D:/Document/CSLearn/Apollo/virtualagc-master/yaUniverse" _BACKTRACE_TRIPLES "D:/Document/CSLearn/Apollo/virtualagc-master/yaUniverse/CMakeLists.txt;5;add_test;D:/Document/CSLearn/Apollo/virtualagc-master/yaUniverse/CMakeLists.txt;0;")
elseif(CTEST_CONFIGURATION_TYPE MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
  add_test([=[yaUniverse]=] "D:/Document/CSLearn/Apollo/virtualagc-master/build/yaUniverse/Release/yaUniverse.exe" "--ephem-read" "--mission=Test")
  set_tests_properties([=[yaUniverse]=] PROPERTIES  WORKING_DIRECTORY "D:/Document/CSLearn/Apollo/virtualagc-master/yaUniverse" _BACKTRACE_TRIPLES "D:/Document/CSLearn/Apollo/virtualagc-master/yaUniverse/CMakeLists.txt;5;add_test;D:/Document/CSLearn/Apollo/virtualagc-master/yaUniverse/CMakeLists.txt;0;")
elseif(CTEST_CONFIGURATION_TYPE MATCHES "^([Mm][Ii][Nn][Ss][Ii][Zz][Ee][Rr][Ee][Ll])$")
  add_test([=[yaUniverse]=] "D:/Document/CSLearn/Apollo/virtualagc-master/build/yaUniverse/MinSizeRel/yaUniverse.exe" "--ephem-read" "--mission=Test")
  set_tests_properties([=[yaUniverse]=] PROPERTIES  WORKING_DIRECTORY "D:/Document/CSLearn/Apollo/virtualagc-master/yaUniverse" _BACKTRACE_TRIPLES "D:/Document/CSLearn/Apollo/virtualagc-master/yaUniverse/CMakeLists.txt;5;add_test;D:/Document/CSLearn/Apollo/virtualagc-master/yaUniverse/CMakeLists.txt;0;")
elseif(CTEST_CONFIGURATION_TYPE MATCHES "^([Rr][Ee][Ll][Ww][Ii][Tt][Hh][Dd][Ee][Bb][Ii][Nn][Ff][Oo])$")
  add_test([=[yaUniverse]=] "D:/Document/CSLearn/Apollo/virtualagc-master/build/yaUniverse/RelWithDebInfo/yaUniverse.exe" "--ephem-read" "--mission=Test")
  set_tests_properties([=[yaUniverse]=] PROPERTIES  WORKING_DIRECTORY "D:/Document/CSLearn/Apollo/virtualagc-master/yaUniverse" _BACKTRACE_TRIPLES "D:/Document/CSLearn/Apollo/virtualagc-master/yaUniverse/CMakeLists.txt;5;add_test;D:/Document/CSLearn/Apollo/virtualagc-master/yaUniverse/CMakeLists.txt;0;")
else()
  add_test([=[yaUniverse]=] NOT_AVAILABLE)
endif()
