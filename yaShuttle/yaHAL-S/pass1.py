#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Copyright:      None - the author (Ron Burkey) declares this software to
                be in the Public Domain, with no rights reserved.
Filename:       pass1.py
Purpose:        This is for yaHAL-S-FC.py.  It tries to parse the abstract
                syntax tree output by the HAL/S compiler front-end into a 
                usable form.
History:        2022-12-12 RSB  Created.

Parsing the abstract syntax tree output by the Printer.c autogenerated by
BNF Converter is actually quite hard, and may be impossible.  That's because
strings appear in the abstract syntax simply with double-quote slapped around
them, and that means that any string literals already containing double-quotes
are going to be trashed in unpredictable ways.  We get around that by altering
Printer.c before compilation (done automatically by the makefile) by inserting
a line reading 
        #include "fixPrinter.c"
at the very beginning of the bufAppendC() function.  This, obviously, relies
on a completely-unjustified assumption about the internals of BNF Converter.
At any rate, what fixPrinter.c does is to intercept this slapping on of 
double-quotes and instead to slap on carats.  Since carats aren't in the 
HAL/S character set, they won't be appearing in strings, so this should be
safe (and now trivial to parse afterward).

But the bottom line is that we expect abstract syntax trees output from the
compiler front end to have strings delimited by carats rather than quotes.
"""

import sys
import subprocess
import re
import platform
import os

tmpFile = "yaHAL-S-FC.tmp"
# Determine the path to the preprocessor script, since that's where auxiliary
# files like HAL_S.cf have been placed as well.
path = re.sub("[^/\\\\]*$", "", os.path.realpath(sys.argv[0]))

# Try to determine the operating system, and hence which compiler executable
# to run.  The test is crude, to say the least, and none of the compilers are
# really tested much except the one I run on my own computer.  The compiler 
# executables must be in the PATH.
parms = {
    "compiler": path + "modernHAL-S-FC" 
}
if platform.system() == "Windows":
    parms["compiler"] += ".exe"
elif platform.system() == "Darwin":
    parms["compiler"] += "-macosx"

"""
 Make the "abstract syntax", obtained as a big string from the compiler 
 front-end, into an actual abstract syntax tree (AST) structure.  This is 
 actually a recursive function.  It assumes that the abstract-syntax
 string passed to it always starts with "(", and it processes until the 
 matching closing parenthesis is reached, which is not necessarily the end
 of the string itself.  It returns
        success, tree, index
 where success is a boolean for success vs failure, tree is the tree structure
 created, and index is an index to the first unprocessed character in the 
 input string.
 
 The abstract syntax tree itself is in the form of a linked nodes that are 
 dictionaries generally having the form
    {
        "lbnfLabel" : string,
        "components" : [ ... strings or nodes ... ]
        "lineNumber" : integer,
        "columnNumber" : integer
    }
 The lineNumber and columnNumber fields are present if the parser provides
 them but are absent otherwise.
 Since by convention the LBNF labels in my HAL/S grammar always begin with
 two arbitrary capital letters present solely to make the labels unique, and 
 I may or may not remove those two prefixed capitals.  The number of prefixed
 characters to remove from LBNF labels is determined by removePrefixedCapitals.
 In the "components", the "strings mentioned are themselves lbnfLabels or
 else string literals, the latter of which are distinguished by the fact that
 they begin and end with carats.  For example, for the HAL/S LBNF grammar,
 the root node will always be
    {
        "lbnfLabel" : "compilaton",
        "components" : [ a single compile_list node ]
    }
 In general, the number of components is exactly the number of components
 in the LBNF rule associated with the (full LBNF label), except that string
 literals won't have been passed along.  If that sound confusing, consider
 the rule:
    AAreplace_stmt . REPLACE_STMT ::= "REPLACE" REPLACE_HEAD "BY" TEXT ;
 The string literals "REPLACE" and "BY" won't appear among the components,
 so the node associated with this rule would look like this:
    {
        "lbnfLabel" : "AAreplace_stmt",
        "components" : [ a REPLACE_HEAD node, a TEXT node ]
    }
"""
removePrefixedCapitals = 0 # Number of chars to remove from front of LBNF labels
def makeTree(abstractSyntax, index=0):
    ast = None
    if abstractSyntax[0] != "(":
        return False, None, 0
    label = ""
    startIndex = index
    index += 1
    while abstractSyntax[index] not in [" ", ")"]:
        index += 1
    label = abstractSyntax[startIndex+1+removePrefixedCapitals:index]
    ast = { "lbnfLabel" : label, "components" : [] }
    index += 1
    # Look here for the lineNumber and columnNumber fields.
    if abstractSyntax[index].isdigit():
        start = index;
        while abstractSyntax[index].isdigit():
            index += 1
        ast["lineNumber"] = int(abstractSyntax[start:index])
        index += 1
        start = index
        while abstractSyntax[index].isdigit():
            index += 1
        ast["columnNumber"] = int(abstractSyntax[start:index])
        index += 1
    if abstractSyntax[index] == ")":
        return True, ast, index
    # Loop on the components of this node.
    while True:
        # There are several possibilities.  As atomic components, we might
        # have an lbnfLabel or a string (delimited by carats) of a couple of
        # possible types.  Or else we could have a non-atomic component that
        # actually has components of its own.  In that case, we must do a 
        # recursive descent to parse it.
        if abstractSyntax[index] == "(": # non-atomic
            success, node, index = makeTree(abstractSyntax, index)
            if success:
                ast["components"].append(node)
            else:
                print("Internal error: failure to parse abstract syntax.", \
                        file=sys.stderr)
                sys.exit(1)
        elif abstractSyntax[index] == "^": # atomic string.
            start = index
            index += 1
            while abstractSyntax[index] != "^":
                index += 1
            ast["components"].append(abstractSyntax[start:index+1])
        else:
            start = index
            while abstractSyntax[index+1] not in [" ", ")"]:
                index += 1
            componentName = abstractSyntax[start:index+1]
            # Avid lineNumber and columnNumber field, if any.
            if not componentName.isdigit():
                ast["components"].append(componentName)
        # At this point, index is pointing to the last character processed,
        # and the next character should be either " " or ")".
        index += 1  
        if abstractSyntax[index] == ")":
            return True, ast, index
        if abstractSyntax[index] != " ":
            print("Internal error: failure to parse abstract syntax.", \
                    file=sys.stderr)
            sys.exit(1)
        index += 1

# Invoke compiler front end.  The source code to be compiled is a list of 
# strings that will be written to the temporary file (tmpFile), but if the list 
# is empty, it's assumed that the temporary file is already populated.  Returns
# a pair
#       boolean, list
# where the boolean if True/False on failure/success and the list is the 
# dictionary in an actionable form of the abstract syntax tree.  Yes this is
# cumbersome, but I see no way to use the BNF Converter framework otherwise, 
# at least not in C.
captured = { "stderr" : [] }
def tokenizeAndParse(sourceList=[], trace=False, wine=False):
    global captured
    tokens = {}
    if trace and tokens == {}:
        try:
            f = open(path + "HAL_S.y")
            for line in f:
                if "%token" == line[:6]:
                    fields = line.split()
                    if len(fields) >= 4 and "_SYMB_" == fields[1][:6] \
                            and "/*" == fields[2] and fields[1][6:].isdigit():
                        tokens[fields[1]] = fields[3]   
            f.close()
        except:
            print("Could not read HAL_S.y; _SYMB_n may not be translated.")
    captured["stderr"] = []
    try:
        if len(sourceList) > 0:
            f = open(tmpFile, "w")
            f.writelines(sourceList)
            f.close()
        if wine:
            compilerAndParameters = ["wine", parms["compiler"]+".exe"]
        else:
            compilerAndParameters = [parms["compiler"]]
        if trace:
            compilerAndParameters.append("--trace")
        compilerAndParameters.append(tmpFile)
        #print(compilerAndParameters)
        run =subprocess.run(compilerAndParameters, capture_output=True)
        if len(run.stderr) > 0:
            stderr = run.stderr.decode("utf-8").strip()
            while True:
                match = re.search("\\b_SYMB_[0-9]+\\b", stderr)
                if match == None:
                    break
                key = match.group()
                if key not in tokens:
                    break
                stderr = stderr[:match.span()[0]] + tokens[key] + " " + \
                            stderr[match.span()[1]+1:]
            captured["stderr"] = stderr.split("\n")
            
        if len(run.stdout) > 0:
            output = run.stdout.decode("utf-8").strip().split("\n")
            for line in output:
                if "(" != line[:1]:
                    #print(line, file=sys.stderr)
                    continue
                else:
                    return makeTree(line)[:2]
    except:
        pass
    return False, []

# A function to read the LBNF grammar.  Returns True on success, False on
# failure.
grammar = {}
def readGrammar(filename):
    global grammar
    if grammar == {}:
        try:
            lbnf2bnf = {}
            f = open(path + filename)
            inComment = False
            for line in f:
                line = line.strip()
                if line == "":
                    continue
                if inComment:
                    if line[:2] == "-}":
                        inComment = False
                    continue
                if line[:2] == "{-":
                    inComment = True
                    continue
                if line[:2] == "--":
                    continue
                fields = line.split("::=")
                if len(fields) != 2:
                    continue
                subfields = fields[0].split(".")
                if len(subfields) != 2:
                    continue
                idLbnf = subfields[0].strip()
                idBnf = "<" + subfields[1].strip().replace("_", " ") + ">"
                lbnf2bnf[idLbnf] = idBnf
            f.close()
            grammar["lbnf2bnf"] = lbnf2bnf
        except:
            # Failed!
            return False
    return True

# A function that prints an abstract syntax tree.
indenter = "░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ ░ "
def astPrint(ast, lbnf=True, bnf=False, indent=0):
    if not (lbnf or bnf):
        return
    if bnf:
        if readGrammar("HAL_S.cf"):
            lbnf2bnf = grammar["lbnf2bnf"]
        else:
            print("Cannot read grammar file HAL_S.cf.")
            print("Cannot display BNF.")
            return
    
    if "lineNumber" in ast:
        print("%5d%4d   " % (ast["lineNumber"], ast["columnNumber"]), end="")
    else:
        print("%12s" % "", end="")
    if indent <= len(indenter):
        print("%s" % (indenter[:indent]), end="")
    else:
        print("%s(%d) " % (indenter, indent), end="")
    label = ast["lbnfLabel"]
    if bnf and label in lbnf2bnf:
        label = lbnf2bnf[label]
    print(label, ":", end="")
    interrupted = False
    needNewline = True
    for component in ast["components"]:
        if isinstance(component, str):
            if bnf and component in lbnf2bnf:
                component = lbnf2bnf[component]
            spacer = " "
            if interrupted:
                if "lineNumber" in component:
                    print("%5d%4d   " % (component["lineNumber"], \
                                         component["columnNumber"]), end="")
                else:
                    print("%12s" % "", end="")
                print("%s" % (indenter[:indent]), end="")
                interrupted = False
                if indent < len(indenter):
                    spacer = indenter[indent]
                else:
                    spacer = " "
            print("%s%s" % (spacer, component), end="")
            needNewline = True
        else:
            if needNewline:
                print()
                needNewline = False
            astPrint(component, lbnf, bnf, indent + 1)
            needNewline = False
            interrupted = True
    if needNewline:        
        print()
