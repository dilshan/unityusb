/*
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
*/ 

using System;
using System.Runtime.InteropServices;

public class UHWComLink
{
	private const byte COMLINK_SIGNATURE = 0x3C;
	private const string COMLINK_NAME = "Global\\unityhwlink";

	private enum FileProtection : uint
	{
		ReadOnly = 0x0002,
		ReadWrite = 0x0004
	}

	private enum FileRights : uint
	{
		Read = 0x0004,
		Write = 0x0002,
		AllAccess = 0x001f,
		ReadWrite = Read + Write
	}
	
	private IntPtr ShMemFileHandler, IPCMapPntr;

	[DllImport ("kernel32.dll", SetLastError = true)]
	private static extern IntPtr CreateFileMapping(IntPtr hFile, int lpAttributes, FileProtection flProtect, uint dwMaximumSizeHigh, uint dwMaximumSizeLow, string lpName);

	[DllImport ("kernel32.dll", SetLastError=true)]
	private static extern IntPtr OpenFileMapping(FileRights dwDesiredAccess, bool bInheritHandle, string lpName);

	[DllImport ("kernel32.dll", SetLastError = true)]
	private static extern IntPtr MapViewOfFile(IntPtr hFileMappingObject, FileRights dwDesiredAccess, uint dwFileOffsetHigh, uint dwFileOffsetLow, uint dwNumberOfBytesToMap);
		
	[DllImport ("Kernel32.dll")]
	private static extern bool UnmapViewOfFile(IntPtr map);

	[DllImport ("kernel32.dll")]
	private static extern int CloseHandle(IntPtr hObject);

	public bool GetHIDControlData(out UHWComData ComDataSet)
	{
		ComDataSet.SignatureCode = 0;
		ComDataSet.ControlInputs = 0;
		ComDataSet.SpeedControl = 0;	
		ShMemFileHandler = OpenFileMapping(FileRights.AllAccess, false, COMLINK_NAME);
		if (ShMemFileHandler == IntPtr.Zero)
			return false;
		IPCMapPntr = MapViewOfFile(ShMemFileHandler, FileRights.AllAccess, 0, 0, 0x100);
		if (IPCMapPntr == IntPtr.Zero)
			return false;
		ComDataSet.SignatureCode = Marshal.ReadByte(IPCMapPntr);
		ComDataSet.ControlInputs = Marshal.ReadByte(IPCMapPntr, 1);
		ComDataSet.SpeedControl = Marshal.ReadInt16(IPCMapPntr, 2);		
		CloseHandle(ShMemFileHandler);
		return true;
	}
	
	public bool IsValidSignature(byte SigData)
	{
		return (SigData == COMLINK_SIGNATURE); 	
	}
}

