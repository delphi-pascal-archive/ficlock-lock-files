program FicLock;

uses
  Forms,
  Unit1 in 'Unit1.pas' {FormMain};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'FicLock';
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
