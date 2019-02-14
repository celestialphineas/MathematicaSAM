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

## References

- [SAM Format Specification](https://samtools.github.io/hts-specs/SAMv1.pdf)
