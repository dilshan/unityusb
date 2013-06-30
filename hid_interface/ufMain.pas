{
  Unity3D Custom Hardware Interface Demo.

  Copyright (c) 2013 Dilshan R Jayakody (jayakody2000lk at gmail dot com).

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to
  deal in the Software without restriction, including without limitation the
  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
  sell copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
  IN THE SOFTWARE.
}

unit ufMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uCommon, HIDctrlIntf, Vcl.ExtCtrls;

const
  USB_CNTLR_VID = $8462;
  USB_CNTLR_PID = $0004;
  USB_CNTLR_SIGNATURE_CODE = $3E;

  SPEED_ADC_MIN = $08C;
  SPEED_ADC_MAX = $384;

type
  TfrmMain = class(TForm)
    tmrUSB: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tmrUSBTimer(Sender: TObject);
  private
    IsDevInUse: Boolean;
    IPCPntr: PIPCDataset;
    MemMapHandler: THandle;
    USBDevList: THIDdeviceList;
    procedure InitIPCDataSet();
  public
    procedure InitUSBDeviceScan();
    procedure TxHIDData(BtnCode: Byte; ADCInput: Word);
  end;

var
  frmMain: TfrmMain;
  ADCSpeedPos: Word;

implementation

{$R *.dfm}

procedure OnUSBEvent; stdcall;
begin
  TfrmMain(Application.MainForm).InitUSBDeviceScan;
end;

procedure OnHIDRead(Data: THIDbuffer); stdcall;
begin
  if((SizeOf(THIDbuffer) > 3) and (Data[0] = USB_CNTLR_SIGNATURE_CODE)) then
  begin
    ADCSpeedPos := Data[2] + (Data[3] shl 8);
    if(ADCSpeedPos < SPEED_ADC_MIN) then
      ADCSpeedPos := 0
    else
      ADCSpeedPos := Round(((ADCSpeedPos - SPEED_ADC_MIN)/SPEED_ADC_MAX) * 100);
    TfrmMain(Application.MainForm).TxHIDData((not Data[1]) and $0F, ADCSpeedPos);
  end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  try
    USBsetEventHandler(@OnUSBEvent);
    HIDsetEventHandler(@OnHIDRead);
    IsDevInUse := false;
    MemMapHandler := CreateFileMapping(INVALID_HANDLE_VALUE, nil, PAGE_READWRITE, 0, $100, COMLINK_NAME);
    Win32Check(MemMapHandler > 0);
    IPCPntr := MapViewOfFile(MemMapHandler, FILE_MAP_ALL_ACCESS, 0, 0, $100);
    Win32Check(Assigned(IPCPntr));
    InitIPCDataSet();
    InitUSBDeviceScan;
  except
    MessageBox(0, 'Unable to create shared memory to initiate the communication link'#10#10'Is this application running with administrative privileges?', Pchar(Application.Title), MB_OK + MB_ICONHAND);
    if(MemMapHandler > 0) then
      CloseHandle(MemMapHandler);
    Application.Terminate;
  end;
end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  if(MemMapHandler > 0) then
    CloseHandle(MemMapHandler);
end;

procedure TfrmMain.InitIPCDataSet();
begin
  IPCPntr^.SignatureCode := COMLINK_SIGNATURE;
  TxHIDData(0, 0);
end;

procedure TfrmMain.TxHIDData(BtnCode: Byte; ADCInput: Word);
begin
  if(MemMapHandler > 0) then
  begin
    IPCPntr^.ControlInputs := BtnCode;
    IPCPntr^.SpeedInput := ADCInput;
  end;
end;

procedure TfrmMain.InitUSBDeviceScan();
var
  USBDevCount : Byte;
begin
  HIDscanForDevices(USBDevList, USBDevCount, USB_CNTLR_VID, USB_CNTLR_PID);
  if((USBDevCount > 0) and (not IsDevInUse)) then
    tmrUSB.Enabled := true
  else
  begin
    try
      HIDcloseDevice(USBDevList[0]);
    finally
      IsDevInUse := false;
    end;
  end;
end;

procedure TfrmMain.tmrUSBTimer(Sender: TObject);
begin
  tmrUSB.Enabled := false;
  IsDevInUse := HIDopenDevice(USBDevList[0]);
end;

end.
