unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Buttons, StdCtrls, ExtCtrls, ComCtrls, Tabs, ShellCtrls,
  CheckLst, ShellApi, Menus;

type
  TFormMain = class(TForm)
    OpenDialog: TOpenDialog;
    ChkLock1: TCheckBox;
    btBrowse: TBitBtn;
    ListFiles: TCheckListBox;
    StatusBar: TStatusBar;
    PopupMenu: TPopupMenu;
    Toutsupprimer: TMenuItem;
    Supprimerlescochs1: TMenuItem;
    Supprimerlesnoncochs1: TMenuItem;
    procedure btBrowseClick(Sender: TObject);
    procedure ListFilesClickCheck(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ChkLock1Click(Sender: TObject);
    procedure ListFilesKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure TraiteMessage(var Msg: TMsg; var Handled: Boolean);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ToutsupprimerClick(Sender: TObject);
  private
    { Déclarations privées }
    procedure MajStatusBar;
  public
    { Déclarations publiques }
  end;

var
  FormMain: TFormMain;
  F: array of HFILE;
  LblCoche: array[boolean] of string = ('Select all', 'Deselect all');

implementation

{$R *.dfm}

procedure TFormMain.btBrowseClick(Sender: TObject);
begin
  if OpenDialog.Execute then
  if ListFiles.Items.IndexOf(OpenDialog.FileName)=-1 then
    ListFiles.Items.Add(OpenDialog.FileName);
  MajStatusBar;
end;

procedure TFormMain.ListFilesClickCheck(Sender: TObject);
var X: Integer;
    Tmp: OFSTRUCT;
begin
  SetLength(F, 0);
  for X:=0 to ListFiles.Count-1 do
  if ListFiles.Checked[X] then
  begin
    SetLength(F, Length(F)+1);
    try
      F[X]:= OpenFile(PChar(ListFiles.Items.Strings[X]), Tmp, OF_READWRITE);
    except
      on E:Exception do
      begin
        MessageDlg('Impossible d''ouvrir le fichier '+ListFiles.Items.Strings[X], mtError, [mbOK], 0);
        ListFiles.Checked[X]:= False;
      end;
    end;
  end
  else
  begin
    try
      if F[X] <> 0 then
        CloseHandle(F[X]);
    except
    //
    end;
  end;
  MajStatusBar;
end;

procedure TFormMain.TraiteMessage(var Msg: TMsg; var Handled: Boolean);
var
  NombreDeFichiers, Size, i:integer;
  NomDuFichierStr:string;
  NomDuFichier:array[0..255] of char;
begin
  if Msg.message=WM_DROPFILES then
  begin
    NombreDeFichiers:= DragQueryFile(Msg.wParam, $FFFFFFFF, NomDuFichier, SizeOf(NomDuFichier));
    for i:=0 to NombreDeFichiers-1 do
    begin
      Size:= DragQueryFile(Msg.wParam, i, NomDuFichier, SizeOf(NomDuFichier));
      NomDuFichierStr:=NomDuFichier;
      if ListFiles.Items.IndexOf(NomDuFichierStr)=-1 then
        ListFiles.Items.Add(NomDuFichierstr);
    end;
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  FillChar(F, SizeOf(F), 0);
  DragAcceptFiles(ListFiles.handle, True);
  Application.OnMessage := TraiteMessage;
  if FileExists(ChangeFileExt(Application.ExeName, '.lst')) then
    ListFiles.Items.LoadFromFile(ChangeFileExt(Application.ExeName, '.lst'));
end;

procedure TFormMain.ChkLock1Click(Sender: TObject);
var X: Integer;
begin
  ChkLock1.Caption:= LblCoche[ChkLock1.Checked];
  for X:=0 to ListFiles.Count-1 do
    ListFiles.Checked[X]:= ChkLock1.Checked;
  ListFilesClickCheck(nil);
end;

procedure TFormMain.ListFilesKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (Key=46) and (ListFiles.ItemIndex>-1) then
  begin
    try
      if ListFiles.Checked[ListFiles.ItemIndex] then
        CloseHandle(F[ListFiles.ItemIndex]);
      ListFiles.Items.Delete(ListFiles.ItemIndex);
      MajStatusBar;
    except
      on E:Exception do MessageDlg('Impossible de libérer le fichier '+ListFiles.Items[ListFiles.ItemIndex], mtError, [mbOK], 0);
    end;
  end;
end;

procedure TFormMain.MajStatusBar;
var X, Nb: Integer;
begin
  Nb:= 0;
  for X:=0 to ListFiles.Count-1 do
  if ListFiles.Checked[X] then
    Inc(Nb);
  if ListFiles.Count>0 then
       StatusBar.SimpleText:= ' '+IntToStr(Nb)+' fichier(s) locké(s) sur '+IntToStr(ListFiles.Count)+' fichier(s)'
  else StatusBar.SimpleText:= StatusBar.Hint;
end;

procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SetLength(F, 0);
  ListFiles.Items.SaveToFile(ChangeFileExt(Application.ExeName, '.lst'));
end;

procedure TFormMain.ToutsupprimerClick(Sender: TObject);
var X: Integer;
begin
  ListFiles.Items.BeginUpdate;
  for X:= ListFiles.Count-1 downto 0 do
  begin
    try
      case TMenuItem(Sender).Tag of
      1: begin // tout
        if ListFiles.Checked[X] then
          CloseHandle(F[X]);
        ListFiles.Items.Delete(X);
      end;
      2: begin // coche
        if ListFiles.Checked[X] then
        begin
          CloseHandle(F[X]);
          ListFiles.Items.Delete(X);
        end;
      end;
      3: begin // non coche
        if not ListFiles.Checked[X] then
          ListFiles.Items.Delete(X);
      end;
      end;
    except
      on E:Exception do MessageDlg('Impossible de libérer le fichier '+ListFiles.Items[X], mtError, [mbOK], 0);
    end;
  end;
  ListFiles.Items.EndUpdate;
  MajStatusBar;
end;

end.
