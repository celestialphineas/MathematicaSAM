(* This file initializes the package import *)
(* It will register the SAM importer & exporter *)
Once@Module[ {packageName},
  packageName = $Input ~StringDrop~ -2;
  Quiet@Get[packageName<>"`Converter.m"];
  Quiet@Get[packageName<>"`Import.m"];
]
