(* ::Package:: *)

(* ::Subtitle:: *)
(*SAM (Sequence Alignment/Map format) Mathematica Converter*)


(* ::Section:: *)
(*LICENSE - MIT*)


(*
Copyright (c) 2019 YIN Yehang
All rights reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*)


(* ::Section::Closed:: *)
(*BEGIN CONVERTER CONTEXT*)


Begin["System`Convert`SAMDump"]


(* ::Section:: *)
(*COMMON*)

(* ::Subsection::Closed:: *)
(*Dictionaries (Rules)*)


(* ::Subsubsection:: *)
(*Meta tag dictionary*)


metaTagDict = {
  "@HD" -> "HeaderLine",
  "@SQ" -> "RefSequenceDict", 
  "@RG" -> "ReadGroup",
  "@PG" -> "Program",
  "@CO" -> "Comment"
}


(* ::Subsubsection:: *)
(*@HD tag dictionary*)


headerDict = {
  "VN" -> "FormatVersion",
  "SO" -> "SortingOrder",
  "GO" -> "AlignmentGrouping",
  "SS" -> "SubSortingOrder"
}


(* ::Subsubsection:: *)
(*@SQ tag dictionary*)


sqDict = {
  "SN" -> "Name",
  "LN" -> "Length",
  "AH" -> "AlternateLocus",
  "AN" -> "AlternativeNames",
  "AS" -> "AssemblyID", 
  "DS" -> "Description",
  "M5" -> "MD5",
  "SP" -> "Species", 
  "UR" -> "URI"
}


(* ::Subsubsection:: *)
(*@RG tag dictionary*)


rgDict = {
  "ID" -> "ID",
  "BC" -> "Barcode",
  "CN" -> "CenterName", 
  "DS" -> "Description",
  "DT" -> "Date",
  "FO" -> "FlowOrder", 
  "KS" -> "KeySequence",
  "LB" -> "Library",
  "PG" -> "Programs", 
  "PI" -> "PredictedInsertSize",
  "PL" -> "Platform", 
  "PM" -> "PlatformModel",
  "PU" -> "PlatformUnit", 
  "SM" -> "Sample"
}


(* ::Subsubsection:: *)
(*@PG tag dictionary*)


pgDict = {
  "ID" -> "ID",
  "PN" -> "Name",
  "CL" -> "CommandLine", 
  "PP" -> "PreviousProgramID",
  "DS" -> "Description", 
  "VN" -> "Version"
}


(* ::Subsection:: *)
(*Messages*)


Import::badsamheader    = "Bad or unknown .SAM file header."
Import::badsamline      = "`1` found when parsing for line `2`."
Export::badsamoptional  = "Bad optional value in alignment `1`."


(* ::Section:: *)
(*Import*)

