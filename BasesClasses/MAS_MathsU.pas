//
// Unit: MAS_MathsU
// Author: M.A.Sargent  Date: 09/10/14  Version: V1.0
//
// Notes:
//
unit MAS_MathsU;

interface

  //
  Function fnPercentageDifference (Const aNum1, aNum2: Double): Double;
  //
  Function fnPercent (Const aDone, aTotal: Integer): Integer; overload;
  Function fnPercentFloat (Const aDone, aTotal: Integer): Single; overload;

  Function fnPercentFloat (Const aDone, aTotal: Double): Double; overload;

  Function fnPercentageOf (Const aValue, aPercentage: Currency): Currency;

implementation

// examples found on website http://www.calculatorsoup.com/calculators/algebra/percent-difference-calculator.php
{
Calculate percentage difference
 between V1 = 100 and V2 = 110

 ( | V1 - V2 | / ((V1 + V2)/2) ) * 100
 = 9.5238% difference
}
Function fnPercentageDifference (Const aNum1, aNum2: Double): Double;
begin
  Result := (( Abs (aNum1 - aNum2) / ((aNum1 + aNum2)/2) ) * 100);
end;

Function fnPercent (Const aDone, aTotal: Integer): Integer;
begin
  Result := Trunc (fnPercentFloat (aDone, aTotal));
end;

Function fnPercentFloat (Const aDone, aTotal: Integer): Single;
begin
  Case aTotal of
    0:   Result := 0;
    else Result :=  ((aDone * 100) / aTotal);
  end;
end;

Function fnPercentFloat (Const aDone, aTotal: Double): Double;
begin
  Case (aTotal = 0) of
    True: Result := 0;
    else  Result :=  ((aDone * 100) / aTotal);
  end;
end;

// Routine: fnPercentageOf
// Author: M.A.Sargent  Date: 10/10/18  Version: V1.0
//
// Notes:
//
Function fnPercentageOf (Const aValue, aPercentage: Currency): Currency;
begin
  Result :=  ((aPercentage * aValue) / 100);
end;

end.
