unit USampleMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFSampleMain = class(TForm)
    MemoHexStr: TMemo;
    BtBase64Decode: TButton;
    MemoBerTlv: TMemo;
    MemoQR: TMemo;
    BtSplitBerTlv: TButton;
    BtTagValue: TButton;
    EtTagStr: TEdit;
    BtBase64Encode: TButton;
    procedure BtBase64DecodeClick(Sender: TObject);
    procedure BtSplitBerTlvClick(Sender: TObject);
    procedure BtTagValueClick(Sender: TObject);
    procedure BtBase64EncodeClick(Sender: TObject);
  private
    { Private declarations }
    function SplitBerTlv(HexStr: string): string;
    function GetBerTlvTagValue(HexStr, TagStr: string): string;
  public
    { Public declarations }
  end;

var
  FSampleMain: TFSampleMain;

implementation

uses UBER_TLV_Parser;

{$R *.dfm}

procedure TFSampleMain.BtBase64DecodeClick(Sender: TObject);
var
  InStr: string;
  OutStr: string;
begin
  InStr:= Trim(MemoQR.Text);
  InStr:= StringReplace(InStr, sLineBreak, '', [rfReplaceAll]);
  OutStr:= DecodeHexString(InStr);

  MemoHexStr.Text:= OutStr;
end;

procedure TFSampleMain.BtSplitBerTlvClick(Sender: TObject);
var
  InStr: string;
  OutStr: string;
begin
  InStr:= MemoHexStr.Text;
  InStr:= StringReplace(InStr, sLineBreak, '', [rfReplaceAll]);
  OutStr:= SplitBerTlv(InStr);

  MemoBerTlv.Text:= OutStr;
end;

procedure TFSampleMain.BtTagValueClick(Sender: TObject);
var
  InStr, TagStr: string;
  OutStr: string;
begin
  InStr := MemoHexStr.Text;
  InStr := StringReplace(InStr, sLineBreak, '', [rfReplaceAll]);
  TagStr:= Trim(EtTagStr.Text);
  OutStr:= GetBerTlvTagValue(InStr, TagStr);

  MemoBerTlv.Text:= Format('%s = %s', [TagStr, OutStr]);
end;

procedure TFSampleMain.BtBase64EncodeClick(Sender: TObject);
var
  InStr: string;
  OutStr: string;
begin
  InStr:= Trim(MemoHexStr.Text);
  InStr:= StringReplace(InStr, sLineBreak, '', [rfReplaceAll]);
  OutStr:= HexStringEncode(InStr);

  MemoQR.Text:= OutStr;
end;

function TFSampleMain.GetBerTlvTagValue(HexStr, TagStr: string): string;
var
  BER_TLV_Parser: TBER_TLV_Parser;
  BER_TLV: TBER_TLV;
begin
  Result:= '';

  BER_TLV_Parser:= TBER_TLV_Parser.Create;
  try
    BER_TLV_Parser.ParseHexString(HexStr);

    BER_TLV:= BER_TLV_Parser.Item[TagStr];
    if (BER_TLV <> nil) and (BER_TLV.Tag > 0) then
      Result:= BytesToHexString(BER_TLV.Value);
  finally
    BER_TLV_Parser.Free;
  end;
end;

function TFSampleMain.SplitBerTlv(HexStr: string): string;
var
  BER_TLV_Parser: TBER_TLV_Parser;
begin
  Result:= '';

  BER_TLV_Parser:= TBER_TLV_Parser.Create;
  try
    BER_TLV_Parser.ParseHexString(HexStr);
    Result:= BER_TLV_Parser.ParsedTLVToHexString;
  finally
    BER_TLV_Parser.Free;
  end;
end;

end.
