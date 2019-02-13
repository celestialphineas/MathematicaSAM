(* ::Package:: *)


(* ::Title:: *)
(*SAM Converter*)


(* ::Subtitle:: *)
(*Sequence Alignment/Map format converter for Mathematica *)


(* :Context: System`Convert`SAMDump` *)
(* :Author: YIN Yehang @ Zhejiang University *)
(* :Summary: SAM (Sequence Alignment/Map format) Mathematica Converter *)
(* :Package Version: 0.1 *)
(* :Mathematica Version: 11.1 *)
(* :Copyright: Copyright (c) 2019 YIN Yehang. All rights reserved. *)
(* :History:
	Version 0.1 Feb 13, 2019, YIN Yehang
*)
(* :Keywords:
  SAM, sequencing, bio-informatics
*)


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


Begin["System`Convert`SAMDump`"];


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


(* ::Subsubsection:: *)
(*Type dictionary*)


typeDict = {
  "A" -> "Character",
  "i" -> "Integer",
  "f" -> "Float", 
  "Z" -> "String",
  "H" -> "Hex",
  "B" -> "Array"
}


(* ::Subsection::Closed:: *)
(*Definitions*)

(* ::Subsubsection:: *)
(*Alignment line definition*)


lineDefinitions = {
  "QueryName",              (* 1    QNAME   *)
  "Flags",                  (* 2    FLAG    *)
  "Reference",              (* 3    RNAME   *)
  "Position",               (* 4    POS     *)
  "MappingQuality",         (* 5    MAPQ    *)
  "CIGAR",                  (* 6    CIGAR   *)
  "MateReference",          (* 7    MRNM    *)
  "MatePosition",           (* 8    MPOS    *)
  "InferredTemplateLength", (* 9    TLEN    *)
  "Sequence",               (* 10   SEQ     *)
  "ReadQuality",            (* 11   QUAL    *)
  "Optionals"               (* 12+  OPT     *)
}


(* ::Subsubsection:: *)
(*Flag definition*)


flagDefinitions = {
  "Paired",                 (* 0x0001 p *)
  "MappedInProperPair",     (* 0x0002 P *)
  "Unmapped",               (* 0x0004 u *)
  "MateUnmapped",           (* 0x0008 U *)
  "ReverseStrand",          (* 0x0010 r *)
  "MateStrand",             (* 0x0020 R *)
  "FirstRead",              (* 0x0040 1 *)
  "SecondRead",             (* 0x0080 2 *)
  "NonPrimaryAlign",        (* 0x0100 s *)
  "FailedRead",             (* 0x0200 f *)
  "OpticalDuplicate",       (* 0x0400 d *)
  "SupplementaryAlign"      (* 0x0800 S *)
}


(* ::Subsection:: *)
(*Messages*)


Import::badsamheader    = "Bad or unknown .SAM file header."
Import::badsamline      = "`1` found when parsing for line `2`."
Export::badsamoptional  = "Bad optional value in alignment `1`."


(* ::Section::Closed:: *)
(*Import*)


(* Dump the header *)
DumpSAMHeader[rawHeaderLines_List] :=
Module[ {cond, lines},
  (* Testing the format of header lines *)
  cond = And[
    MatchQ[rawHeaderLines, {__String}],
    And @@ StringMatchQ[
      rawHeaderLines, 
      RegularExpression["(^@(..)(\\t[A-Za-z][A-Za-z0-9]:[ -~]+)+$)|(^@CO\\t.*)"]
    ]
  ];
  If[ Not[cond],
    Message[Import::badsamheader]; Return[$Failed]
  ];
  lines = StringSplit[#, "\t"] & /@ rawHeaderLines;

  (* Transform the lines to format: {{@TAG, {{TAG, val}, {TAG, val}}}} *)
  lines = Transpose[
    {
      (* @TAGs *)
      lines[[All, 1]],
      (* key:value pairs splitted *)
      Map[
        (* Pure function *)
        If[ StringMatchQ[#, _~~_~~":"~~___], StringSplit[#, ":", 2], # ] &,
        (* The key:value pairs of each line *)
        lines[[All, 2;;]],
        (* Map level spec *)
        {2}
      ]
    }
  ];

  (* Name replacing, ignoring the unknown tags *) 
  lines = Map[
    (* Pure function to replace names according to the @TAG *)
    (* The unknown @TAGs are ignored *)
    Switch[ #[[1]],
      metaTagDict[[1, 1]],  # /. Union[metaTagDict, headerDict],
      metaTagDict[[2, 1]],  # /. Union[metaTagDict, sqDict],
      metaTagDict[[3, 1]],  # /. Union[metaTagDict, rgDict],
      metaTagDict[[4, 1]],  # /. Union[metaTagDict, pgDict],
      metaTagDict[[-1, 1]], # /. metaTagDict
    ] &,
    (* Map the function to each line *)
    lines
  ];

  (* Merging and formatting *)
  (* Merging the lines with the same @TAG *)
  lines = {#[[1, 1]], #[[All, 2]]} & /@ Split[lines, #1[[1]] == #2[[1]] &];
  (* Formatting, based on a series of rules and replacements *)
  lines /. {
    (* @HD *)
    {metaTagDict[[1, 2]], x__} :>
      (metaTagDict[[1, 2]] -> Apply[Rule, Flatten[x, 1], {1}]),
    (* @SQ *)
    {metaTagDict[[2, 2]], x__} :>
      (metaTagDict[[2, 2]] ->
        Apply[Rule, x, {2}] /. {("Length" -> n_String) :> ("Length" -> ToExpression[n])}
      ),
    (* @RG *)
    {metaTagDict[[3, 2]], x__} :>
      (metaTagDict[[3, 2]] -> Apply[Rule, x, {2}]),
    (* @PG *)
    {metaTagDict[[4, 2]], x__} :>
      (metaTagDict[[4, 2]] -> Apply[Rule, x, {2}]),
    (* CO *)
    {metaTagDict[[-1, 2]], x__} :>
      (metaTagDict[[-1, 2]] ->
        Fold[#1 <> "\n" <> #2 &, Map[Fold[#1 <> "\t" <> #2 &, #] &, x, {1}]]
      )
  }
]


(* Dump the flag, the unknown higher digits will be ignored *)
DumpFlag[flag_Integer] :=
flagDefinitions[[Flatten[Position[Reverse@IntegerDigits[BitAnd[flag, 4095], 2], 1]]]]


(* TODO: This part needs to be finished *)
(* Compile the optional arrays to human/machine readable format *)
DumpArray[array_List] := array


(* Dump each optional field *)
DumpOptional[optional_List] := 
If[ Not@MatchQ[optional, {_String, _String, _String}],
  $Failed,
  optional /. {
    {tag_String, type_String, val_String} :> (
      tag -> {
        "Type" -> type /. typeDict,
        "Value" -> Switch[ type,
          "A", val,
          "i", If[ Not@StringMatchQ[val, RegularExpression@"[-+]?[0-9]+"], 
                Return[$Failed],
                ToExpression[val]
              ],
          "f", If[ Not@StringMatchQ[val, RegularExpression@"[-+]?[0-9]*\\.?[0-9]+([eE][-+]?[0-9]+)?"],
                Return[$Failed],
                ToExpression[val]
              ],
          "Z", val,
          "H", If[ Not@StringMatchQ[val, RegularExpression@"([0-9A-F][0-9A-F])*"], 
                Return[$Failed],
                FromDigits[val, 16]
              ],
          "B", If[ Not@StringMatchQ[val, RegularExpression@"[cCsSiIf](,[-+]?[0-9]*\\.?[0-9]+([eE][-+]?[0-9]+)?)* "],
                Return[$Failed],
                DumpArray[val]
              ],
          (* Default *)
          _,   Return[$Failed]
        ]
      }
    )
  }
]


(* Dump each alignment line *)
DumpAlignment[line_String] :=
Module[ {temp, list, result = {}},
  list = StringSplit[line, "\t"];
  StringSplit[line, "\t"];
  (* QNAME *)
  AppendTo[result, lineDefinitions[[1]] -> list[[1]]];
  (* FLAG *)
  AppendTo[result, lineDefinitions[[2]] ->
    If[ Not@StringMatchQ[list[[2]], NumberString], 
      Message[Import::badsamline, "Bad witwise flag", line]; Return[$Failed], 
      DumpFlag[ToExpression[list[[2]]]]
    ]
  ];
  (* RNAME *)
  AppendTo[result, lineDefinitions[[3]] ->
    If[ list[[3]] === "*",
      Missing["NotAvailable"],
      list[[3]]
    ]
  ];
  (* POS *)
  AppendTo[result, lineDefinitions[[4]] ->
    If[ Not@StringMatchQ[list[[4]], NumberString], 
      Message[Import::badsamline, "Bad mapping position", line]; Return[$Failed],
      ToExpression@list[[4]]
    ]
  ];
  (* MAPQ *)
  AppendTo[result, lineDefinitions[[5]] ->
    If[ Not@StringMatchQ[list[[5]], NumberString], 
      Message[Import::badsamline, "Bad mapping position", line]; Return[$Failed],
      ToExpression@list[[5]]
    ]
  ];
  (* CIGAR *)
  AppendTo[result, lineDefinitions[[6]] ->
    If[ Not@StringMatchQ[list[[6]], RegularExpression@"\\*|([0-9]+[MIDNSHPX=])+"], 
      Message[Import::badsamline, "Bad CIGAR", line]; Return[$Failed],
      If[ list[[6]] === "*",
        Missing["NotAvailable"],
        list[[6]]
      ]
    ]
  ];
  (* MRNM *)
  AppendTo[result, lineDefinitions[[7]] ->
    Switch[ list[[7]],
      "*", Missing["NotAvailable"],
      "=", list[[3]],
      _,   list[[7]]
    ]
  ];
  (* MPOS *)
  AppendTo[result, lineDefinitions[[8]] ->
    If[ Not@StringMatchQ[list[[8]], NumberString], 
      Message[Import::badsamline, "Bad mapping position", line]; Return[$Failed],
      ToExpression@list[[8]]
    ]
  ];
  (* TLEN *)
  AppendTo[result, lineDefinitions[[9]] ->
    If[ Not@StringMatchQ[list[[9]], NumberString], 
      Message[Import::badsamline, "Bad mapping position", line]; Return[$Failed],
      ToExpression@list[[9]]
    ]
  ];
  (* SEQ *)
  AppendTo[result, lineDefinitions[[10]] -> list[[10]]];
  (* QUAL *)
  AppendTo[result, lineDefinitions[[11]] -> list[[11]]];
  (* OPT *)
  AppendTo[result, lineDefinitions[[-1]] -> (
    temp = DumpOptional /@ (StringSplit[#, ":", 3] & /@ list[[12 ;;]]);
    If[ temp~MemberQ~$Failed, 
      Message[Import::badsamline, "Bad optional(s)", line]; Return[$Failed],
      temp
    ]
  )];
  (* Return *)
  result
]


(* Import function *)
ImportSAM[filename_InputStream, options___?OptionQ] :=
Module[ {strm, lines, rawHead, rawData, head, data},
  strm = OpenRead[filename, Method -> {"File", CharacterEncoding -> "UTF8"}];
  lines = ReadList[file, String];
  Closed[strm];
  rawHead = Select[lines, StringMatchQ[Verbatim["@"]~~___]];
  rawData = lines[[Length[rawHead] + 1 ;;]];
  head = DumpSAMHeader[rawHead];
  data = DumpAlignment /@ rawData;
  {"Header" -> head, "Data" -> data}
]


(* ::Section::Closed:: *)
(*END CONVERTER CONTEXT*)


End[];
