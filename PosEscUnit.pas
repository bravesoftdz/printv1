unit PosEscUnit;

interface
uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
    Dialogs, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
    cxContainer, cxEdit,  cxTextEdit, cxMemo, cxRichEdit, ExtCtrls, Menus,
    cxMaskEdit, cxDropDownEdit, StdCtrls, cxButtons, RxRichEd, Buttons, SPComm, MSCommLib_TLB, shellapi,
    CPort;
type

    TPrintType = (Star = 0, Epson = 1);
    TPortType = (LPT = 0, COM = 1,DEBUG=2);
    TPOSEsc = class(Tobject)
    private
        _printtype: TPrintType;
        _port: string; _porttype: TPortType;
        _ComPort: TComPort;
        _lptfile: TextFile;
        procedure _PrintStr(str: string);
    public
        constructor Create;
        procedure ChangeLine;
        procedure FontSizeDefault;
        procedure FontSizeWidth;
        procedure FontSizeHeigh;
        procedure FontSizeBig;
        procedure ChineseMode;
        procedure PrintInit;
        procedure writeStr(str: string);
        procedure Open;
        procedure Close;
        property PrintType: TPrintType read _printtype write _printtype;
        property Port: string read _port write _port;
        property PortType: TPortType read _PortType write _PortType;
    end;
 function lasts(pd:string):string;
implementation

uses fm_debug_Unit;
function kinds(const pa:string):string;
//���ش�д����
var
  pb:string;
  pi:integer;
begin
 if pa='.' then
  pb:=''
  else
  begin
   pi:=strtoint(pa);
   case pi of
    0: pb:='��';
    1: pb:='Ҽ';
    2: pb:='��';
    3: pb:='��';
    4: pb:='��';
    5: pb:='��';
    6: pb:='½';
    7: pb:='��';
    8: pb:='��';
    9: pb:='��';
   end;
  end;
   kinds:=pb;
end;

function alters(pc:integer):string;
//���ص�λ
begin
  case pc of
  1:alters:='��';
  2:alters:='��';
  3:alters:='';
  4:alters:='ʰ';
  5:alters:='��';
  6:alters:='Ǫ';
  7:alters:='��';
  8:alters:='ʰ';
  9:alters:='��';
  10:alters:='Ǫ';
  11:alters:='��';
  12:alters:='ʰ';
  13:alters:='��';
  14:alters:='Ǫ';
  15:alters:='����';
  16:alters:='ʰ';
  17:alters:='��';
  18:alters:='Ǫ';
  19:alters:='����';
  20:alters:='ʰ';
  21:alters:='��';
  22:alters:='Ǫ';
  23:alters:='������';
  24:alters:='ʰ';
  25:alters:='��';
  26:alters:='Ǫ';
  27:alters:='������';
  28:alters:='ʰ';
  29:alters:='��';
  30:alters:='Ǫ';
  end;
end;

function lasts(pd:string):string;
//����ת���õĴ�д�ַ���
var
 pt,strchuli:string;
 m,i:integer;
 had0:boolean;     //�Ƿ��С��㡱
 isfirst:boolean;  //�ǵ�һ�������λ
begin
  result:='';
  strchuli:=pd;
  m:=length(strchuli);
  //���������ַ���Ϊ���ֻ�.
  for i:=1 to m do
  begin
    If not((ord(strchuli[i])=46)or(ord(strchuli[i])>47)and(ord(strchuli[i])<58)) Then
    begin
      showmessage(inttostr(ord(strchuli[i])));
      Showmessage( '��ȡ����ӦΪ����');
      Exit;
    end;
  end;
  //���������ת��Ϊһ�������ַ�������С��λΪ��
  if m<10 then
  begin
    //����ֱ��ת��Ϊ��������תΪ����*100����ת��ȥ
    strchuli:=inttostr(trunc(strtofloatdef(strchuli,0)*100));
  end
  else
  begin
    //ȥ���ַ���ǰ���0
    for i:=1 to m do
    begin
      if copy(strchuli,i,1)<>'0' then break;
    end;
    if i>1 then
      strchuli:=copy(strchuli,i,m-i+1);
    //ȥ���ַ����е�.
    for i:=1 to m do
    begin
      if copy(strchuli,i,1)='.' then break;
    end;
    if i=1 then
       strchuli:=copy(strchuli,2,2)
    else if i=m-1 then
       strchuli:=copy(strchuli,1,m-2)+copy(strchuli,m,1)+'0'
    else if i=m then
       strchuli:=copy(strchuli,1,m-1)+'00'
    else if i>m then
       strchuli:=strchuli+'00'
    else
       strchuli:=copy(strchuli,1,i-1)+copy(strchuli,i+1,2);
  end;
  m:=length(strchuli);
  pt:='';
  isfirst:=true;     //�ǵ�һ��
  had0:=false;       //����
  for i:=1 to m do
  begin
    if copy(strchuli,i,1)<>'0' then
    begin
      if had0 then
      begin
        pt:=pt+'��'+kinds(copy(strchuli,i,1))+alters(m-i+1);
      end
      else
      begin
        pt:=pt+kinds(copy(strchuli,i,1))+alters(m-i+1)
      end;
      //�����������Ҫ�ָ�Ϊ��0
      had0:=false;
      //�պ��ڴ�λ����Ͳ��ǵ�һ���ˣ�����Ҫ���ڵ�һ��
      if (m-i+1>4)and(((m-i+2) mod 4)=0) then
        isfirst:=false
      else
        isfirst:=true;
    end
    else
    begin
      had0:=true;  //��0
      if (m-i+1>4)and(((m-i+2) mod 4)=0)and(isfirst) then
      begin    //�ж��0������ֻȡ��һ����λ
        pt:=pt+alters(m-i+1);
        had0:=false;    //�ֳ�����0
        isfirst:=false;  //�Ѿ����ǵ�һ����
      end;
    end;
    //��������λ�Ӹ�Ԫ��
    if (m-i+1)=3 then
    begin
      pt:=pt+'Ԫ';
      had0:=false;
    end;
  end;
  //û��С����Ӹ�����
  if copy(strchuli,m-1,2)='00' then
     pt:=pt+'��';
  result:=pt;
end;


constructor TPOSEsc.Create;
begin

end;

procedure TPOSEsc.Open;
begin
    case _porttype of
        LPT: begin
                AssignFile(_lptfile, Port);
                rewrite(_lptfile);
            end;
        COM: begin
                _ComPort := TComPort.Create(nil);
                _ComPort.port := Port;
                _ComPort.BaudRate := br9600;
                _ComPort.open;
            end;
            DEBUG:
            begin
                 AssignFile (_lptfile, 'debug.bin');
                rewrite(_lptfile);
            end;
    end;
    PrintInit;
end;

procedure TPOSEsc.Close;
begin
    case _porttype of
        LPT: begin
                closefile(_lptfile);
            end;
        COM: begin
                _ComPort.Close;
                FreeAndNil(_ComPort);
            end;
             DEBUG: begin
                closefile(_lptfile);
                frm_debug:=Tfrm_debug.Create(nil);
                frm_debug.MPHexEditor1.LoadFromFile('debug.bin');
                frm_debug.ShowModal;
            end;
    end;
end;

procedure TPOSEsc.ChangeLine;
begin
    case _printtype of
        Star: _PrintStr(chr($0D) + chr($0A));
        Epson: _PrintStr(chr($0D));
    end;

end;

procedure TPOSEsc.PrintInit;
begin
    case _printtype of
        Star: begin
                _PrintStr(chr($18) + chr($1b) + chr($4D) + chr($14));
            end;
        Epson: begin
                _PrintStr(chr($1B) + chr($40));
                _PrintStr(chr($1B) + chr($33)+ chr($01));
               // _PrintStr(chr($1C) + chr($26));
            end;
    end;
end;

procedure TPOSEsc.FontSizeDefault;
begin
    case _printtype of
        Star: _PrintStr(chr($14));
        Epson: _PrintStr('');
    end;
end;

procedure TPOSEsc.FontSizeWidth;
begin
    case _printtype of
        Star: _PrintStr(chr($0E));
        Epson: _PrintStr('');
    end;
end;

procedure TPOSEsc.FontSizeHeigh;
begin
    case _printtype of
        Star: _PrintStr('');
        Epson: _PrintStr('');
    end;
end;

procedure TPOSEsc.FontSizeBig;
begin
    case _printtype of
        Star: _PrintStr('');
        Epson: _PrintStr('');
    end;
end;

procedure TPOSEsc.ChineseMode;
begin
    case _printtype of
        Star: _PrintStr('');
        Epson: _PrintStr('');
    end;
end;

procedure TPOSEsc.writeStr(str: string);
begin
    _PrintStr(str);
end;

procedure TPOSEsc._PrintStr(str: string);
begin
    case _porttype of
        LPT: Write(_lptfile, str);
        COM: _ComPort.WriteStr(str);
        DEBUG: Write(_lptfile, str);
    end;
end;
end.

