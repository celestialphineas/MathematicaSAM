Get["../SAM/Converter.m"]
Get["../SAM/Import.m"]

Print[Import["./0.sam", {"SAM", {"Header", "Data"}}]//AbsoluteTiming]
