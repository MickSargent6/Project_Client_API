//
// Unit: MASStringList_CustomSortRoutinesU
// Author: M.A.Sargent  Date: 09/01/14  Version: V1.0
//
// Notes:
//
unit MASStringList_CustomSortRoutinesU;

interface

Uses SysUtils, Classes, MASCommonU;

  Function CompareInt (List: TStringList; Index1, Index2: Integer): Integer;
  Function CompareIntDesc (List: TStringList; Index1, Index2: Integer): Integer;
  Function CompareFloat (List: TStringList; Index1, Index2: Integer): Integer;
  Function CompareFloatDesc (List: TStringList; Index1, Index2: Integer): Integer;

implementation

Function IfTrue (aCondition: Boolean; aTrue, aFalse: Integer): Integer;
begin
  if aCondition then
       Result := aTrue
  else Result := aFalse;
end;

Function Int_CompareInt (List: TStringList; Index1, Index2: Integer; Const aDesc: Boolean = False): Integer;
var
   d1, d2: Integer;
   r1, r2: Boolean;

   function IsInt(AString : string; var AInteger : Integer): Boolean;
   var
     Code: Integer;
   begin
     Val(AString, AInteger, Code);
     Result := (Code = 0);
   end;

begin
   r1 :=  IsInt(List[Index1], d1);
   r2 :=  IsInt(List[Index2], d2);
   Result := ord(r1 or r2);
   if Result <> 0 then begin
     if d1 < d2 then
       Result := IfTrue (aDesc, 1, -1)
     else if d1 > d2 then
       Result := IfTrue (aDesc, -1, 1)
     else
      Result := 0;
   end else
    Result := StrComp (PChar(List[Index1]), PChar(List[Index2]));
end;

Function CompareInt (List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := Int_CompareInt (List, Index1, Index2, False);
end;
Function CompareIntDesc (List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := Int_CompareInt (List, Index1, Index2, True);
end;

Function Int_CompareFloat (List: TStringList; Index1, Index2: Integer; Const aDesc: Boolean = False): Integer;
var
   d1, d2: Double;
   r1, r2: Boolean;

   function IsFloat (AString : string; var aFloat: Double): Boolean;
   var
     Code: Integer;
   begin
     Val(AString, aFloat, Code);
     Result := (Code = 0);
   end;

begin
   r1 :=  IsFloat(List[Index1], d1);
   r2 :=  IsFloat(List[Index2], d2);
   Result := ord(r1 or r2);
   if Result <> 0 then begin
     if d1 < d2 then
        Result := IfTrue (aDesc, 1, -1)
     else if d1 > d2 then
       Result := IfTrue (aDesc, -1, 1)
     else
      Result := 0;
   end else
    Result := StrComp (PChar(List[Index1]), PChar(List[Index2]));
end;

Function CompareFloat (List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := Int_CompareFloat (List, Index1, Index2, False);
end;
Function CompareFloatDesc (List: TStringList; Index1, Index2: Integer): Integer;
begin
  Result := Int_CompareFloat (List, Index1, Index2, True);
end;

{
function CompareDates(List: TStringList; Index1, Index2: Integer): Integer;
var
   d1, d2: TDateTime;
begin
   d1 := StrToDate(List[Index1]);
   d2 := StrToDate(List[Index2]);
   if d1 < d2 then
     Result := -1
   else if d1 > d2 then Result := 1
   else
     Result := 0;
end;

procedure TForm1.Button1Click(Sender: TObject);
var
   sl: TStringList;
begin
   sl := TStringList.Create;
   try
     // listbox1.Sorted := False !
     sl.Assign(listbox1.Items);
     sl.CustomSort(CompareDates);
     listbox1.Items.Assign(sl);
   finally
     sl.Free
   end;
end;

end.


//********************************************************************
// To sort Integer values:

function CompareInt(List: TStringList; Index1, Index2: Integer): Integer;
var
   d1, d2: Integer;
   r1, r2: Boolean;

   function IsInt(AString : string; var AInteger : Integer): Boolean;
   var
     Code: Integer;
   begin
     Val(AString, AInteger, Code);
     Result := (Code = 0);
   end;

begin
   r1 :=  IsInt(List[Index1], d1);
   r2 :=  IsInt(List[Index2], d2);
   Result := ord(r1 or r2);
   if Result <> 0 then
   begin
     if d1 < d2 then
       Result := -1
     else if d1 > d2 then
       Result := 1
     else
      Result := 0;
   end else
    Result := lstrcmp(PChar(List[Index1]), PChar(List[Index2]));
end;

procedure TForm1.Button1Click(Sender: TObject);
var
   sl: TStringList;
begin
   sl := TStringList.Create;
   try
     // listbox1.Sorted := False;
     sl.Assign(listbox1.Items);
     sl.CustomSort(CompareInt);
     listbox1.Items.Assign(sl);
   finally
     sl.Free;
   end;
end;

}


end.
