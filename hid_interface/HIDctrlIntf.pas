UNIT HIDctrlIntf;
{
  USB: Human Interface Device class interface file:
  Basic calls to communicate with an HID device

  When using this unit/library make sure the next "standard"
  Windows DLL's are installed on the target system:
     - HID.DLL
     - SetupAPI.DLL

  Created:     16-04-2012 by J.W. Beunders
  Last update: 17-08-2012 by J.W. Beunders (joop@beunders.be)

  This code may be used freely. The author would appreciate it
  when he is mentioned as original creator of the interface.
  Also he would be very grateful if he is notified when changes
  and / or improvements are made,
}

INTERFACE

CONST
{
  he numberf below indicates the maximum number of HID devices the scan
  function can return.
}
  HIDmaxDevices = 31;

TYPE
{
  Basic HID data buffer. This the maximum size of an HID buffer.
  The actual size for a specific device should be cheched
  before any communication is started
}
  THIDbuffer        = Array[0..63] of Byte;

{
  The interface includes a thread which tries to read data from
  the active HID device. When a callback procdure is assigned in
  the main program, all available data is automatically returned
  to the application in this procedure
}
  THIDcallBack      = Procedure( Data : THIDbuffer); stdcall;

{
  When a USB device is attached or removed from the system, the
  system will generate a message. By specifying a callback procedure
  in the main program, the event can be used to take some action,
  for instance to check if the active device is still present.
}
  TUSBcallBack      = Procedure; stdcall;

{
  An HID device is specified by the structure shown below. Apart from
  the VID/PID combination, the beuffersize is of greate importance
  as that specifies how much data can be transferred in a single vcall.
}
  THIDdeviceInfo = Record
    SymLink            : ShortString;  // symbolic link from registry
    BufferSize         : Word;  // size of the data buffer for sending/receiving data
    Handle             : THandle;  // handle which is returned when device is opened
    VID                : Word;  // Vendor ID code
    PID                : Word;  // Product ID code
    VersionNumber      : Word;  // Vrsion information
    ManufacturerString : ShortString;  // Textual manufacurer information
    ProductString      : ShortString;  // Textual product information
    SerialNumberString : ShortString;  // Textual serial number information
  end;
              
{
  The structure below contains information of all HID devices after a call
  to ScanForHIDdevices.
}
  THIDDeviceList = Array[0..HIDmaxDevices] of THIDdeviceInfo;

{
    assign procedure to call when a usb device is inserted or removed
}
Procedure USBsetEventHandler( Callback : TUSBcallBack);  stdcall;  External 'HIDcontrol.dll';

{
  assign a user procedure which will receive data when HID device has send it
}
Procedure HIDsetEventHandler( CallBack : THIDcallback);  stdcall;  External 'HIDcontrol.dll';

{
  Scan all available HID Devices.
  When Target VID/PID equal 0 all HID entries from device manager are
  returned. To check the presence of a particular device, enter the
  required VID/PID information
}
Procedure HIDscanForDevices( Var DeviceList : THIDDeviceList;
                             Var NumDevices : Byte;
                                 TargetVID,
                                 TargetPID  : Word);  stdcall;  External 'HIDcontrol.dll';

{
  Get a Handle to the device (open it)
}
Function HIDopenDevice( Var DeviceInfo : THIDdeviceInfo) : Boolean;  stdcall;  External 'HIDcontrol.dll';

{
  Close Device
}
Function HIDcloseDevice( Var DeviceInfo : THIDdeviceInfo) : Boolean;  stdcall;  External 'HIDcontrol.dll';

{
  Write NrOfBytes to HID device
}
Function HIDwriteDevice( Var DeviceInfo   : THIDdeviceInfo;
                             Data         : THIDbuffer): Boolean;  stdcall;  External 'HIDcontrol.dll';

{
  Read data from device with a time-out.
  When succesfull NrOfBytes holds the actual number of bytes
}
Function HIDreadDevice( Var DeviceInfo : THIDdeviceInfo;
                        Var Data       : THIDbuffer ) : Boolean;  stdcall;  External 'HIDcontrol.dll';

IMPLEMENTATION
END.

