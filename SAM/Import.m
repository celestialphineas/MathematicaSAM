(* ::Package:: *)

Begin["System`Convert`SAMDump`"]


ImportExport`RegisterImport[
  "SAM",
  ImportSAM,
  "FunctionChannels"  -> {"Streams"},
  "AvailableElements" -> {"Header", "Data"},
  "DefaultElement"    -> "Data"
]


End[]
