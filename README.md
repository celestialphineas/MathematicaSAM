# MathematicaSAM

Import/Export .SAM file in Mathematica.

## Usage

### As an external package

Copy the `SAM` directory to wherever you want.

If you already have the directory `SAM` accessible by a relative path to `Directory[]`, say, `RelativePath/SAM`, then you can simply import the package by:

```mathematica
<< RelativePath`SAM`
```

The import and export converters will be automatically registered.

If you want to import the package by an absolute path, you need to open a read stream of the package's `init.m` file explicitly.

```mathematica
Get[OpenRead["AbsolutePath/SAM/init.m"]]
```

### Add the package to user/install directory

You can follow the official tutorial `tutorial/AutomaticLoadingOfImportExportConverters` for details of how to do this.

### Using the registered import and export converters

As long as the import and export converters are registered (i.e. package executed with no problems), you can import the .SAM files to your Mathematica notebooks / Wolfram Language scripts!

To import a .SAM file:

```mathematica
Import[fileName, "SAM"]
```

Note that, Mathematica still cannot tell the document type of a custom format (I would appreciate it if someone could tell me how to make this possible), so you need to explicitly refer the file format `"SAM"` in the import option.

This expression will return all of the dumped .SAM file, with its first element to be a set of rules equivalent to the header, and the second element to be an array of sequence alignments also in the form of a set of rules.

If you want to import the header or the data only, 

```mathematica
Import[fileName, {"SAM", "Header"}]
```

or

```mathematica
Import[fileName, {"SAM", "Data"}]
```

Importing the header only can be much faster than importing the whole file, for parsing the data still causes overhead.

Exporting is similar to importing. But you need to keep in mind that only the full data with both the header and the body is exportable. The exporting data is also expected to agree with the importing format.

```mathematica
Export[fileName, data, "SAM"];
```

## Data format

The imported data follows Mathematica's naming convention, which is much different to the documented .SAM specification.

### Header

#### Meta tags

```mathematica
"@HD" -> "HeaderLine",
"@SQ" -> "ReferenceSequences", 
"@RG" -> "ReadGroup",
"@PG" -> "Program",
"@CO" -> "Comment"
```
#### `@HD` header line

```mathematica
"VN" -> "FormatVersion",
"SO" -> "SortingOrder",
"GO" -> "AlignmentGrouping",
"SS" -> "SubSortingOrder"
```

#### `@SQ` header lines

``` mathematica
"SN" -> "Name",
"LN" -> "Length",
"AH" -> "AlternateLocus",
"AN" -> "AlternativeNames",
"AS" -> "AssemblyID", 
"DS" -> "Description",
"M5" -> "MD5",
"SP" -> "Species", 
"UR" -> "URI"
```

#### `@RG` header lines

```mathematica
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
```

#### `@PG` header lines

```mathematica
"ID" -> "ID",
"PN" -> "Name",
"CL" -> "CommandLine", 
"PP" -> "PreviousProgramID",
"DS" -> "Description", 
"VN" -> "Version"
```

#### `@CO` header lines

```mathematica
"A" -> "Character",
"i" -> "Integer",
"f" -> "Float", 
"Z" -> "String",
"H" -> "Hex",
"B" -> "Array"
```

### Alignment line field definitions

```mathematica
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
```

#### Flag definition

```mathematica
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
```

## TODOs and known issues

- The array type optional fields are not yet dumped
- The dump and build functions need improving to be more efficient.

## References

- [SAM Format Specification](https://samtools.github.io/hts-specs/SAMv1.pdf)
