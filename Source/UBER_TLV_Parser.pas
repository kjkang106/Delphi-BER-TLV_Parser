unit UBER_TLV_Parser;

interface

uses
  SysUtils, Classes, Generics.Collections, EncdDecd;

type
  TBER_TLV = class
  private
    FTag: Integer;
    FLength: Integer;
    FValue: TBytes;
    FIsConstructed: Boolean;
    FSubItems: TList<TBER_TLV>;
  public
    property Tag: Integer                     read FTag;
    property Length: Integer                  read FLength;
    property Value: TBytes                    read FValue;
    property IsConstructed: Boolean           read FIsConstructed;
    property SubItems: TList<TBER_TLV>        read FSubItems;

    constructor Create(ATag, ALength: Integer; AValue: TBytes; AIsConstructed: Boolean);
    destructor Destroy; override;
    function ToHexString(Level: Integer = 0): string;
  end;
  TzBER_TLV = TList<TBER_TLV>;

  TBER_TLV_Parser = class
  private
    FzBER_TLV: TzBER_TLV;

    function ReadTag(Stream: TStream): Integer;
    function ReadLength(Stream: TStream): Integer;
    function IsConstructedTag(Tag: Integer): Boolean;
    procedure ParseStream(Stream: TStream; ParentList: TList<TBER_TLV>);

    function HexStringToInt(const HexStr: string): Integer;
    function GetBER_TLV(HexStr: string): TBER_TLV;

    procedure DisposeBER_TLVList(var zBER_TLV: TzBER_TLV);
    procedure DisposeBER_TLV(var BER_TLV: TBER_TLV);
  public
    constructor Create;
    destructor Destroy; override;

    procedure ParseHexString(const HexStr: string);
    function ParsedTLVToHexString: string;

    property zBER_TLV: TzBER_TLV              read FzBER_TLV;
    property Item[HexStr: string]: TBER_TLV   read GetBER_TLV;
  end;

function BytesToHexString(const Bytes: TBytes): string;
function HexToStream(const HexStr: string): TMemoryStream;

function DecodeHexString(const EncStr: AnsiString): string;
function HexStringEncode(const DecStr: String): AnsiString;

implementation

function BytesToHexString(const Bytes: TBytes): string;
var
  I: Integer;
begin
  Result := '';
  for I := Low(Bytes) to High(Bytes) do
    Result := Result + IntToHex(Bytes[I], 2);
end;

function HexToStream(const HexStr: string): TMemoryStream;
var
  I: Integer;
  ByteValue: Byte;
begin
  Result := TMemoryStream.Create;
  I := 1;
  while I < Length(HexStr) do
  begin
    ByteValue := StrToInt('$' + Copy(HexStr, I, 2));
    Result.WriteBuffer(ByteValue, 1);
    Inc(I, 2);
  end;
  Result.Position := 0;
end;

function DecodeHexString(const EncStr: AnsiString): string;
var
  Bytes: TBytes;
begin
  Bytes := DecodeBase64(EncStr);
  Result:= BytesToHexString(Bytes);
end;

function HexStringEncode(const DecStr: String): AnsiString;
var
  Stream : TMemoryStream;
begin
  Stream := HexToStream(DecStr);
  try
    Result:= EncodeBase64(Stream.Memory, Stream.Size);
    Result:= StringReplace(Result, sLineBreak, '', [rfReplaceAll]);
  finally
    Stream.Free;
  end;
end;

{ TBER_TLV }

constructor TBER_TLV.Create(ATag, ALength: Integer; AValue: TBytes; AIsConstructed: Boolean);
begin
  FTag := ATag;
  FLength := ALength;
  FValue := AValue;
  FIsConstructed := AIsConstructed;
  if AIsConstructed then
    FSubItems := TzBER_TLV.Create;
end;

destructor TBER_TLV.Destroy;
begin
  FSubItems.Free;
  inherited;
end;

function TBER_TLV.ToHexString(Level: Integer): string;
var
  TLV: TBER_TLV;
  Indent: string;
begin
  Indent := StringOfChar(' ', Level * 2);

  if FIsConstructed then
  begin
    Result := Format('%s%.2X %.2X', [Indent, FTag, FLength]);
    if (FSubItems <> nil) then
    begin
      Result := Result + sLineBreak;
      for TLV in FSubItems do
        Result := Result + TLV.ToHexString(Level + 1) + sLineBreak;
  end;
  end
  else
    Result := Format('%s%.2X %.2X %s', [Indent, FTag, FLength, BytesToHexString(FValue)]);
end;

{ TBER_TLV_Parser }

function TBER_TLV_Parser.ReadTag(Stream: TStream): Integer;
var
  ByteRead: Byte;
  TagValue: Integer;
begin
  try
    Stream.ReadBuffer(ByteRead, 1);
    TagValue := ByteRead;

    if (ByteRead and $1F) = $1F then
    begin
      repeat
        Stream.ReadBuffer(ByteRead, 1);
        TagValue := (TagValue shl 8) or (ByteRead);
      until (ByteRead and $80) = 0;
    end;
    if TagValue < 0 then
      TagValue:= 0;
  except
    TagValue:= 0;
  end;

  Result := TagValue;
end;

function TBER_TLV_Parser.ReadLength(Stream: TStream): Integer;
var
  ByteRead: Byte;
  LengthValue: Integer;
  I: Integer;
begin
  try
    Stream.ReadBuffer(ByteRead, 1);

    if ByteRead < $80 then
      LengthValue := ByteRead
    else
    begin
      LengthValue := 0;
      for I := 1 to ByteRead and $7F do
      begin
        Stream.ReadBuffer(ByteRead, 1);
        LengthValue := (LengthValue shl 8) or ByteRead;
      end;
    end;
    if LengthValue < 0 then
      LengthValue := 0;
  except
    LengthValue:= 0;
  end;

  Result := LengthValue;
end;

function TBER_TLV_Parser.IsConstructedTag(Tag: Integer): Boolean;
begin
  if Hi(Tag) = 0 then
    Result := (Tag and $20) <> 0
  else
    Result := (Hi(Tag) and $20) <> 0;
end;

constructor TBER_TLV_Parser.Create;
begin
  FzBER_TLV:= TzBER_TLV.Create;
end;

destructor TBER_TLV_Parser.Destroy;
begin
  DisposeBER_TLVList(FzBER_TLV);

  inherited;
end;

procedure TBER_TLV_Parser.DisposeBER_TLV(var BER_TLV: TBER_TLV);
var
  idx, nMax: Integer;
  TLV: TBER_TLV;
begin
  if BER_TLV.SubItems <> nil then
  begin
    nMax:= BER_TLV.SubItems.Count;
    for idx:= 0 to nMax - 1 do
    begin
      TLV:= BER_TLV.SubItems[idx];
      DisposeBER_TLV(TLV);
      BER_TLV.SubItems[idx]:= TLV;

      BER_TLV.SubItems[idx].Free;
    end;
  end;
end;

procedure TBER_TLV_Parser.DisposeBER_TLVList(var zBER_TLV: TzBER_TLV);
var
  idx, nMax: Integer;
  BER_TLV: TBER_TLV;
begin
  nMax:= zBER_TLV.Count;
  for idx:= 0 to nMax - 1 do
  begin
    BER_TLV:= zBER_TLV[idx];
    DisposeBER_TLV(BER_TLV);
    zBER_TLV[idx]:= BER_TLV;

    zBER_TLV[idx].Free;
  end;
  zBER_TLV.Free;
end;

function TBER_TLV_Parser.GetBER_TLV(HexStr: string): TBER_TLV;
var
  FindTag: Integer;
  FindTLV: TBER_TLV;
  FindRlt: Boolean;
  ti, tMax: Integer;
  TLV: TBER_TLV;
  procedure FindSubItem(ParentTLV: TBER_TLV);
  var
    si, sMax: Integer;
  begin
    if ParentTLV.SubItems = nil then
      Exit;

    sMax:= ParentTLV.SubItems.Count;
    for si:= 0 to sMax - 1 do
    begin
      FindTLV:= ParentTLV.SubItems[si];
      if FindTLV.Tag = FindTag then
      begin
        FindRlt:= True;
        Break;
      end
      else
      begin
        FindSubItem(FindTLV);
        if FindRlt then
          Break;
      end;
    end;
  end;
begin
  FindTag:= HexStringToInt(HexStr);
  FindTLV:= Default(TBER_TLV);
  FindRlt:= False;

  tMax:= FzBER_TLV.Count;
  for ti:= 0 to tMax - 1 do
  begin
    FindTLV:= FzBER_TLV[ti];
    if FindTLV.Tag = FindTag then
    begin
      FindRlt:= True;
      Break;
    end
    else
    begin
      FindSubItem(FindTLV);
      if FindRlt then
        Break;
    end;
  end;

  if FindRlt then
    Result:= FindTLV
  else
    Result:= Default(TBER_TLV);
end;

function TBER_TLV_Parser.HexStringToInt(const HexStr: string): Integer;
var
  I: Integer;
  bi, bMax: Integer;
  Bytes: TBytes;
  ByteValue: Byte;
begin
  Result:= 0;

  SetLength(Bytes, 0);
  bi:= -1;
  I := 1;
  while I < Length(HexStr) do
  begin
    Inc(bi);
    SetLength(Bytes, bi + 1);
    ByteValue := StrToInt('$' + Copy(HexStr, I, 2));
    Bytes[bi]:= ByteValue;
    Inc(I, 2);
  end;

  bMax:= Length(Bytes);
  for bi:= 0 to bMax - 1 do
    Result:= (Result shl 8) or Bytes[bi];
end;

function TBER_TLV_Parser.ParsedTLVToHexString: string;
var
  TLV: TBER_TLV;
begin
  Result := '';
  for TLV in FzBER_TLV do
    Result := Result + TLV.ToHexString + sLineBreak;
end;

procedure TBER_TLV_Parser.ParseHexString(const HexStr: string);
var
  Stream: TMemoryStream;
begin
  FzBER_TLV.Clear;
  Stream := HexToStream(HexStr);
  try
    ParseStream(Stream, FzBER_TLV);
  finally
    Stream.Free;
  end;
end;

procedure TBER_TLV_Parser.ParseStream(Stream: TStream; ParentList: TList<TBER_TLV>);
var
  Tag, Length: Integer;
  Value: TBytes;
  TLV: TBER_TLV;
  IsConstructed: Boolean;
  SubStream: TMemoryStream;
begin
  while Stream.Position < Stream.Size do
  begin
    Tag := ReadTag(Stream);
    IsConstructed := IsConstructedTag(Tag);
    Length := ReadLength(Stream);
    if Stream.Position + Length > Stream.Size then
      Length := Stream.Size - Stream.Position;

    SetLength(Value, Length);
    Stream.ReadBuffer(Value[0], Length);

    TLV := TBER_TLV.Create(Tag, Length, Value, IsConstructed);
    ParentList.Add(TLV);

    if IsConstructed then
    begin
      SubStream := TMemoryStream.Create;
      try
        SubStream.WriteBuffer(Value[0], Length);
        SubStream.Position := 0;
        ParseStream(SubStream, TLV.SubItems);
      finally
        SubStream.Free;
      end;
    end;
  end;
end;

end.

