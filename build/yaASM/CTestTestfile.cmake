# CMake generated Testfile for 
# Source directory: D:/Document/CSLearn/Apollo/virtualagc-master/yaASM
# Build directory: D:/Document/CSLearn/Apollo/virtualagc-master/build/yaASM
# 
# This file includes the relevant testing commands required for 
# testing this directory and lists subdirectories to be tested as well.
if(CTEST_CONFIGURATION_TYPE MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
  add_test([=[ASM:assemble]=] "D:/Document/CSLearn/Apollo/virtualagc-master/build/yaASM/Debug/yaASM.exe" "--input=D:/Document/CSLearn/Apollo/virtualagc-master/yaASM/Test.obc")
  set_tests_properties([=[ASM:assemble]=] PROPERTIES  _BACKTRACE_TRIPLES "D:/Document/CSLearn/Apollo/virtualagc-master/yaASM/CMakeLists.txt;4;add_test;D:/Document/CSLearn/Apollo/virtualagc-master/yaASM/CMakeLists.txt;0;")
elseif(CTEST_CONFIGURATION_TYPE MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
  add_test([=[ASM:assemble]=] "D:/Document/CSLearn/Apollo/virtualagc-master/build/yaASM/Release/yaASM.exe" "--input=D:/Document/CSLearn/Apollo/virtualagc-master/yaASM/Test.obc")
  set_tests_properties([=[ASM:assemble]=] PROPERTIES  _BACKTRACE_TRIPLES "D:/Document/CSLearn/Apollo/virtualagc-master/yaASM/CMakeLists.txt;4;add_test;D:/Document/CSLearn/Apollo/virtualagc-master/yaASM/CMakeLists.txt;0;")
elseif(CTEST_CONFIGURATION_TYPE MATCHES "^([Mm][Ii][Nn][Ss][Ii][Zz][Ee][Rr][Ee][Ll])$")
  add_test([=[ASM:assemble]=] "D:/Document/CSLearn/Apollo/virtualagc-master/build/yaASM/MinSizeRel/yaASM.exe" "--input=D:/Document/CSLearn/Apollo/virtualagc-master/yaASM/Test.obc")
  set_tests_properties([=[ASM:assemble]=] PROPERTIES  _BACKTRACE_TRIPLES "D:/Document/CSLearn/Apollo/virtualagc-master/yaASM/CMakeLists.txt;4;add_test;D:/Document/CSLearn/Apollo/virtualagc-master/yaASM/CMakeLists.txt;0;")
elseif(CTEST_CONFIGURATION_TYPE MATCHES "^([Rr][Ee][Ll][Ww][Ii][Tt][Hh][Dd][Ee][Bb][Ii][Nn][Ff][Oo])$")
  add_test([=[ASM:assemble]=] "D:/Document/CSLearn/Apollo/virtualagc-master/build/yaASM/RelWithDebInfo/yaASM.exe" "--input=D:/Document/CSLearn/Apollo/virtualagc-master/yaASM/Test.obc")
  set_tests_properties([=[ASM:assemble]=] PROPERTIES  _BACKTRACE_TRIPLES "D:/Document/CSLearn/Apollo/virtualagc-master/yaASM/CMakeLists.txt;4;add_test;D:/Document/CSLearn/Apollo/virtualagc-master/yaASM/CMakeLists.txt;0;")
else()
  add_test([=[ASM:assemble]=] NOT_AVAILABLE)
endif()
