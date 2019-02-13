(* ::Package:: *)

Begin["System`Convert`SAMDump`"]


ImportExport`RegisterImport[
  "SAM",
  ImportSAM,
  "AvailableElements" -> {"Header", "Data"},
  "DefaultElement"    -> "Everything"
]


End[]
