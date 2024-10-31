program BerTlvSample;

uses
  Forms,
  USampleMain in 'USampleMain.pas' {FSampleMain},
  UBER_TLV_Parser in 'UBER_TLV_Parser.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown:= True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFSampleMain, FSampleMain);
  Application.Run;
end.
