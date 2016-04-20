program WemoInsightEmoncms;

{$APPTYPE CONSOLE}

uses
  Windows,
  Classes,
  SysUtils,
  inifiles,
  StrUtils,
  IdHTTP;

var
  EmonUrl, EMonApiKey, emonNode, WemoIp, WemoPort, sConfFilename: String;
  iSleep, Delay, iTicks, iTicks2 : Integer;
  Debug: Boolean;

function HttpGetUrl(const Url:String): String;
var
  aIdHTTP: TIdHTTP;
begin
  Result := '';
  aIdHTTP := TIdHTTP.Create(nil);
  try
    aIdHTTP.ReadTimeout := 5000;
    aIdHTTP.ConnectTimeout := 5000;
    Result := aIdHTTP.Get(Url);
  finally
    aIdHTTP.Free;
  end;
end;


procedure Split(Delimiter: Char; Str: string; ListOfStrings: TStrings) ;
begin
   ListOfStrings.Clear;
   ListOfStrings.Delimiter       := Delimiter;
   ListOfStrings.StrictDelimiter := True; // Requires D2006 or newer.
   ListOfStrings.DelimitedText   := Str;
end;

function GetWemoWattUsuage(var Watt: double): boolean;
var
  aIdHTTP: TIdHTTP;
  aStream: TStringStream;
  sResult: string;
  iIndex1, iIndex2: Integer;
  InsightParams: TStringList;
begin
  Result := false;
  Watt := 0;
  aIdHTTP := TIDHttp.Create(nil);
  try
    aIdHTTP.HandleRedirects := true;
    aIdHTTP.Request.ContentType := 'text/xml; charset="utf-8"';
    aIdHTTP.Request.Accept := ' ';
    aIdHTTP.Request.CustomHeaders.AddValue('SOAPACTION', '"urn:Belkin:service:insight:1#GetInsightParams"');
    aIdHTTP.ReadTimeout := 5000;
    aIdHTTP.ConnectTimeout := 5000;
    aStream := TStringStream.Create;
    try
      aStream.WriteString('<?xml version="1.0" encoding="utf-8"?>'#13#10);
      aStream.WriteString('<s:Envelope xmlns:s="http://schemas.xmlsoap.org/soap/envelope/" s:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">'#13#10);
      aStream.WriteString('<s:Body>'#13#10);
      aStream.WriteString('<u:GetInsightParams xmlns:u="urn:Belkin:service:insight:1"></u:GetInsightParams>'#13#10);
      aStream.WriteString('</s:Body>'#10#10);
      aStream.WriteString('</s:Envelope>');
      sResult := aIdHTTP.Post('http://' + wemoIp + ':' + WemoPort + '/upnp/control/insight1', aStream);
      iIndex1 := pos('<INSIGHTPARAMS>', uppercase(sResult));
      iIndex2 := pos('</INSIGHTPARAMS>', uppercase(sResult));
      if (iIndex1 > 0) and (iIndex2 > iIndex1)  then
      begin
        sResult := Copy(sResult, iIndex1 + Length('<INSIGHTPARAMS>'), iIndex2 - (iIndex1 + Length('<INSIGHTPARAMS>')));
        InsightParams := TStringList.Create;
        try
          split('|', sResult, InsightParams);
          if InsightParams.Count = 11 then
          begin
            Result := true;
            Watt := StrToInt(InsightParams[7]) / 1000;
          end;
        finally
          FreeAndNil(InsightParams);
        end;
      end;
    finally
      FreeandNil(aStream);
    end
  finally
    FreeAndNil(aIdHTTP);
  end;
end;

procedure LoadConfig(aFilename: String = '');
var
  IniFile: TiniFile;
  sFilename : string;
begin
  sFilename := aFilename;
  if sFilename = '' then
    sFilename := ChangeFileExt(Paramstr(0), '.conf');
  if Pos(':', sFilename) = 0 then
    sFilename := '.\' + sFilename;
  if not FileExists(sFilename) then
    raise Exception.Create(sFilename + ' not found!');
  IniFile := TInifile.Create(sFilename);
  try
    if not IniFile.ValueExists('MAIN', 'EmonApiKey') then
      raise Exception.Create('Config Error in Section Main, value EmonApiKey does not exist');
    if not IniFile.ValueExists('MAIN', 'WemoIp') then
      raise Exception.Create('Config Error in Section Main, value WemoIp does not exist');
    if not IniFile.ValueExists('MAIN', 'WemoPort') then
      raise Exception.Create('Config Error in Section Main, value WemoPort does not exist');
    Debug := IniFile.ReadBool('MAIN', 'Debug', false);
    Delay := IniFile.ReadInteger('MAIN', 'Delay', 5);
    EmonNode := IniFile.ReadString('MAIN', 'EmonNode', '5');
    EmonUrl := IniFile.ReadString('MAIN', 'EmonUrl', 'Http://emoncms.org');
    EMonApiKey := IniFile.ReadString('MAIN', 'EmonApiKey', '');
    WemoIp := IniFile.ReadString('MAIN', 'WemoIp', '127.0.0.1');
    WemoPort := IniFile.ReadString('MAIN', 'WemoPort', '49153');
    Delay := Delay * 1000;
  finally
    FreeAndNil(IniFile);
  end;
end;

procedure Update;
var
  sUrl: String;
  Watt: double;
begin
  if GetWemoWattUsuage(Watt) then
  begin
    sUrl := Format('%s/input/post.json?node=%s&apikey=%s&csv=%4.3f',[EmonUrl, EmonNode, EmonApiKey, Watt]);
    if Debug then
       Writeln(sUrl);
    writeln(FormatDateTime('DD/MM/YYYY HH:NN:SS ', now) + 'Result emoncms: '  + httpGetUrl(sUrl));
  end
  else
    Writeln(FormatDateTime('DD/MM/YYYY HH:NN:SS ', now) +  'Failed Getting Watt usuage from wemo insight');
end;

begin
  try
    FormatSettings.DecimalSeparator := '.';
    sConfFilename := '';
    if ParamCount = 2 then
      if CompareText(ParamStr(1), '-CONF') = 0 then
        sConfFileName := Paramstr(2);

    LoadConfig(sConfFilename);
    while true do
    begin
      iTicks := GetTickCount;
      Update;
      iTicks2 := GetTickCount;
      if iTicks2 > iTicks then
      begin
        iSleep := Delay - (iTicks2-iTicks);
        if iSleep < 0 then
          iSleep := 0;
        writeln('Delay: ' + InttoStr(iSleep));
        Sleep(iSleep)
      end
      else
      begin
        writeln('Delay: ' + Inttostr(Delay));
        sleep(delay);
      end;
    end;
  except
    on E: Exception do
    begin
      ExitCode := 1;
      Writeln(Format('[%s] %s', [E.ClassName, E.Message]));
    end;
  end;
end.
