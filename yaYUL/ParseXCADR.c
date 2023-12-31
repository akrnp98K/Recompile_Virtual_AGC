/*
  Copyright 2009,2016 Ronald S. Burkey <info@sandroid.org>
  
  This file is part of yaAGC. 

  yaAGC is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  yaAGC is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with yaAGC; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

  Filename:	ParseXCADR.c
  Purpose:	Assembles the XCADR pseudo-op.  This is a pseudo-op
  		unique to Block 1.
  Mode:		2009-07-25 RSB	Copied from ParseCADR.c.
                2016-08-24 RSB  Fixed for Block 1.
                2022-11-27 MAS  Corrected operation to match the original
                                Yul (needed for Sunrise 45).
*/

#include "yaYUL.h"
#include <stdlib.h>
#include <math.h>
#include <string.h>

//-------------------------------------------------------------------------
// Returns non-zero on unrecoverable error.
int ParseXCADR(ParseInput_t *InRecord, ParseOutput_t *OutRecord)
{
  Address_t Address;
  int Value, i;

  IncPc(&InRecord->ProgramCounter, 1, &OutRecord->ProgramCounter);
  if (!OutRecord->ProgramCounter.Invalid && OutRecord->ProgramCounter.Overflow)
    {
      strcpy(OutRecord->ErrorMessage, "Next code may overflow storage.");
      OutRecord->Warning = 1;
    }

  OutRecord->EBank = InRecord->EBank;
  OutRecord->SBank = InRecord->SBank;
  OutRecord->NumWords = 1;
  OutRecord->Words[0] = 0;

  if (InRecord->Extend && !InRecord->IndexValid)
    {
      strcpy(OutRecord->ErrorMessage, "Illegally preceded by EXTEND.");
      OutRecord->Fatal = 1;
      OutRecord->Extend = 0;
    }

  if (InRecord->IndexValid)
    {
      strcpy(OutRecord->ErrorMessage, "Illegally preceded by INDEX.");
      OutRecord->Fatal = 1;
      OutRecord->IndexValid = 0;
    }

  i = GetOctOrDec(InRecord->Operand, &Value);
  if (!i && *InRecord->Mod1 == 0)
    {
      IncPc(&InRecord->ProgramCounter, Value, &Address);
    DoIt:  
      if (Address.Invalid)
        {
	  strcpy(OutRecord->ErrorMessage, "Destination address not resolved.");
	  OutRecord->Fatal = 1;
	  return (0);
	}

      if (!Address.Address)
        {
	  strcpy(OutRecord->ErrorMessage, "Destination is not a memory address.");
	  OutRecord->Fatal = 1;
	  return (0);
	}

      if (InRecord->ProgramCounter.Fixed && Address.Fixed && Address.Banked &&
          (InRecord->ProgramCounter.FB != Address.FB ))
        {
          strcpy(OutRecord->ErrorMessage, "Destination must be in current fixed bank.");
          OutRecord->Fatal = 1;
        }

      if (!Block1)
        {
	  strcpy(OutRecord->ErrorMessage, "XCADR is only supported for Block I");
	  OutRecord->Fatal = 1;
	  return (0);
        }

      int isLiteralNumber = 0;
      char *s;
      unsigned offset;
      if (1 == sscanf(InRecord->Mod1, "+%o", &offset))
        OpcodeOffset = offset;
      isLiteralNumber = 1;
      for (s = InRecord->Operand; *s; s++)
        if (*s > '9' || *s < '0')
          {
            isLiteralNumber = 0;
            break;
          }
      if (isLiteralNumber)
        OutRecord->Words[0] = 047777 + atoi(InRecord->Operand);
      else
        OutRecord->Words[0] = 047777 + Address.SReg;
    }
  else
    {
      // The operand is NOT a number.  Presumably, it's a symbol.
      i = FetchSymbolPlusOffset(&InRecord->ProgramCounter, InRecord->Operand, InRecord->Mod1, &Address);
      if (!i)
        goto DoIt;
      sprintf(OutRecord->ErrorMessage, "Symbol \"%s\" undefined or offset bad", InRecord->Operand);
      OutRecord->Fatal = 1;
    }
  return (0);  
}

