unit Unit2;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  Twitter.Client, FMX.Memo.Types, FMX.ScrollBox, FMX.Memo,
  FMX.Controls.Presentation, FMX.StdCtrls, Ics.Fmx.OverbyteIcsWndControl,
  Ics.Fmx.OverbyteIcsSslHttpOAuth;

type
  TForm2 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    Twitter1: TTwitter;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.fmx}

procedure TForm2.Button1Click(Sender: TObject);
begin
//  var Resp := Twitter1.CreateTweet(Memo1.Lines.Text);
//  Var Stat := Twitter1.DeleteTweet(Resp.data.id);
//  ShowMessage(Stat.data.deleted.ToString());
  Twitter1.CreateTweetWithContent(Memo1.Lines.Text,
  'C:\Users\AÏKO Silas O\Pictures\_0c7838ae-724a-49cd-9308-a8c6cf038942.jpeg')
end;

end.
