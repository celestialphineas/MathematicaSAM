Get["../SAM/Converter.m"]
Get["../SAM/Import.m"]
Get["../SAM/Export.m"]

Print[(imported = Import["./0.sam", "SAM"];)//AbsoluteTiming]

Print[(Export["./0-built.sam", imported, "SAM"])//AbsoluteTiming]
