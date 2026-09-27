unit utils;

{$mode objfpc}{$H+}

interface

uses
  SysUtils;

function NormalizeLikeParam(const AValue: string): string;
function TryParsePercent(const AValue: string; out APercent: Double): Boolean;
function FormatMoney(const AValue: Double): string;

implementation

function NormalizeLikeParam(const AValue: string): string;
begin
  Result := '';
  if Trim(AValue) <> '' then
    Result := '%' + Trim(AValue) + '%';
end;

function TryParsePercent(const AValue: string; out APercent: Double): Boolean;
var
  CleanValue: string;
begin
  CleanValue := StringReplace(Trim(AValue), '%', '', [rfReplaceAll]);
  CleanValue := StringReplace(CleanValue, ',', '.', [rfReplaceAll]);
  Result := TryStrToFloat(CleanValue, APercent);
  if Result then
    APercent := APercent / 100;
end;

function FormatMoney(const AValue: Double): string;
begin
  Result := FormatFloat('#,##0.00', AValue);
end;

end.