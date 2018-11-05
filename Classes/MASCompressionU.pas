//
// Unit: MasCompressionU
// Author: M.A.Sargent  Date: 27/09/12  Version: V1.0
//         M.A.Sargent        28/12/13           V2.0
//
// Notes:
//  V2.0: Updated to Raise exceptions and not use Assert
//
unit MASCompressionU;

interface

uses
  Classes, ZLib, DB, SysUtils, IdCoderMIME;

  //
  Procedure CompressStream (Const aList: tStrings; aCompressedStream: tStream);
  Procedure DeCompressStream (Const aField: tBlobField; aUnCompressedStream: tStream); overload;
  Procedure DeCompressStream (Const aCompressedStream, aUnCompressedStream: tStream); overload;
  //
  Procedure Compress (Const AUncompressed, ACompressed: TStream; Const ACompressionLevel: TCompressionLevel = clDefault);
  Procedure DeCompress (Const ACompressed, AUncompressed: TStream );
  Procedure CompressionSafeCopy (Const ASource, ADestination: TStream );


  // Helpers Classes
  Procedure DeCompressFieldValue (Const aStr: String; Const aList: tStrings);


  //
Type
  tDecodeBase64 = Class (tIdDecoderMIME)
  Public
    Function IntDecodeToString (const AIn: string): string;
  end;


implementation

//FCompressionLevel := clMax;

Procedure DeCompressFieldValue (Const aStr: String; Const aList: tStrings);
var
  lvCompressed: tStringStream;
  lvUnCompressed: tMemoryStream;
begin
  if not Assigned (aList) then Raise Exception.Create ('Error: DeCompressFieldValue. aList Must be Assigned');
  lvCompressed := tStringStream.Create (aStr);
  Try
    lvUnCompressed := tMemoryStream.Create;
    Try
      DeCompressStream (lvCompressed, lvUnCompressed);
      aList.LoadFromStream (lvUnCompressed);
    Finally
      lvUnCompressed.Free;
    end;
  Finally
    lvCompressed.Free;
  end;
end;


procedure Compress (Const aUncompressed, aCompressed: TStream; Const aCompressionLevel: TCompressionLevel);
var
  lvStream: tCompressionStream;
begin
  if not Assigned (aUncompressed) then Raise Exception.Create ('Compress - AUncompressed not assigned');
  if not Assigned (aCompressed) then Raise Exception.Create ('Compress - ACompressed not assigned' );
  aUncompressed.Position := 0;
  lvStream := tCompressionStream.Create (aCompressionLevel, aCompressed);
  try
    CompressionSafeCopy (aUncompressed, lvStream);
  finally
    lvStream.Free;
  end;
end;

procedure DeCompress (Const aCompressed, aUncompressed: TStream );
var
  lvStream: tDecompressionStream;
begin
  if not Assigned (aUncompressed) then Raise Exception.Create ('Decompress - AUncompressed not assigned');
  if not Assigned (aCompressed) then Raise Exception.Create ('Decompress - ACompressed not assigned' );
  aCompressed.Position := 0;
  lvStream := tDecompressionStream.Create (aCompressed);
  try
    CompressionSafeCopy (lvStream, aUncompressed);
  finally
    lvStream.Free;
  end;
end;

procedure CompressionSafeCopy (Const aSource, aDestination: TStream);
const
  MaxBufSize = 4096;
var
  BufSize: Integer;
  Buffer: PChar;
begin
  GetMem( Buffer, MaxBufSize );
  try
    repeat
      BufSize := aSource.Read( Buffer^, MaxBufSize );
      aDestination.WriteBuffer( Buffer^, BufSize );
    until ( BufSize < MaxBufsize );
  finally
    FreeMem( Buffer, MaxBufSize );
  end;
end;

// Routine: DeCompressStream
// Author: M.A.Sargent  Date: 04/10/12  Version: V1.0
//
// Notes:
//
procedure DeCompressStream (Const aField: tBlobField; aUnCompressedStream: tStream);
var
  lvCompressedStream: TMemoryStream;
begin
  lvCompressedStream := TMemoryStream.Create;
  try
    aField.SaveToStream (lvCompressedStream);
    lvCompressedStream.Position := 0;

    DeCompress (lvCompressedStream, aUnCompressedStream);
  finally
    lvCompressedStream.Free;
  end;
  aUnCompressedStream.Position := 0;
end;

// Routine: DeCompressStream
// Author: M.A.Sargent  Date: 30/12/13  Version: V1.0
//
// Notes:
//
Procedure DeCompressStream (Const aCompressedStream, aUnCompressedStream: tStream);
begin
  if not Assigned (aCompressedStream) then Raise Exception.Create ('DeCompress - aCompressedStream not assigned');
  aCompressedStream.Position := 0;
  DeCompress (aCompressedStream, aUnCompressedStream);
  aUnCompressedStream.Position := 0;
end;

// Routine: CompressStream
// Author: M.A.Sargent  Date: 04/09/12  Version: V1.0
//
// Notes:
//
Procedure CompressStream (Const aList: tStrings; aCompressedStream: tStream);
var
  lvAsStream: tMemoryStream;
begin
  lvAsStream := tMemoryStream.Create;
  Try
    aList.SaveToStream (lvAsStream);
    lvAsStream.Position := 0;
    //DEBUG lvAsStream.SaveToFile (fnGenFileName ('c:\junk\new\mick_BEFORE.zip', fntIncremental));
    //
    Compress (lvAsStream, aCompressedStream, clDefault);
    //DEBUG SetIncrementLimit (1000);
    //DEBUG lvCompressedStream.SaveToFile (fnGenFileName ('c:\junk\new\mick.zip', fntIncremental));
  finally
    lvAsStream.Free;
  end;
end;

{procedure TOrderDocFiler.ReadFromFile (Const ADocument: TParam; Const AFilename: string);
var
  UncompressedStream: TFileStream;
  CompressedStream: TMemoryStream;
begin
  Inherited;
  UncompressedStream := TFileStream.Create( AFilename, fmOpenRead );
  try
    CompressedStream := TMemoryStream.Create;
    try
      Compress( UncompressedStream, CompressedStream, FCompressionLevel );
      ADocument.LoadFromStream( CompressedStream, ftBlob );
    finally
      CompressedStream.Free;
    end;
  finally
    UncompressedStream.Free;
  end;
end;}

{procedure TOrderDocFiler.WriteToFile(const ADocument: tBlobField; const AFilename: string);
var
  CompressedStream: TMemoryStream;
  UncompressedStream: TFileStream;
begin
  Inherited;
  CompressedStream := TMemoryStream.Create;
  try
    ADocument.SaveToStream( CompressedStream );
    CompressedStream.Position := 0;
    UncompressedStream := TFileStream.Create (AFilename, fmCreate );
    try
      Decompress( CompressedStream, UncompressedStream);
    finally
      UncompressedStream.Free;
    end;
  finally
    CompressedStream.Free;
  end;
end;}

{ tDecodeBase64 }

Function tDecodeBase64.IntDecodeToString (Const AIn: string): string;
var
  LDestStream: TStringStream;
begin
  LDestStream := TStringStream.Create ('');
  try  {Do not Localize}
    Self.DecodeStream (AIn, LDestStream);
    Result := LDestStream.DataString;
  finally
    FreeAndNil(LDestStream);
  end;
end;

end.
