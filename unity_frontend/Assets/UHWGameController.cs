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

using UnityEngine;
using System.Collections;
using System.Diagnostics;

public class UHWGameController : MonoBehaviour 
{
	private bool IsHIDDevAvailable, IsOnExec;
	private Vector3 ObjFlySpeed, ObjBankSpeed, PresetSpeed, BankSpeed;
	private Vector3 BankVelocity;
	private Process HidConProcess;
	private GUIStyle UIFontStyle;
	private UHWComData HIDDataSet, GameDataBuffer;
	private UHWComLink HIDController;
	private UHWDirection DirInput;
	private AudioSource AudioController;
	
	public string HIDControllerFile = "unityhwhid.exe";
	public float ObjectWeight = 7.0f;
	public GameObject PropObject;
	public GameObject FlyObject;
	public AudioClip FlySound;
	
	void InitSystem()
	{		
		IsHIDDevAvailable = false;
		GameDataBuffer.ControlInputs = 0;
		GameDataBuffer.SpeedControl = 0;
		DirInput.IsLeft = false;
		DirInput.IsRight = false;
		DirInput.IsAsc = false;
		DirInput.IsDes = false;		
		ObjFlySpeed = new Vector3(0, 0, 0);
		IsOnExec = true;
		
		AudioController = gameObject.AddComponent<AudioSource>();
		AudioController.clip = FlySound;
		AudioController.volume = 1.0f;
		AudioController.loop = true;
	}

	void Start() 
	{
		InitSystem();		
		try	
		{
			ProcessStartInfo HIDCon = new ProcessStartInfo();
			HIDCon.FileName = HIDControllerFile;
			HIDCon.CreateNoWindow = true;
			HidConProcess = Process.Start(HIDCon);	
			IsHIDDevAvailable = (HidConProcess != null);
			
			HIDDataSet = new UHWComData();
			HIDController = new UHWComLink();
						
			if(PropObject != null)
				PropObject.GetComponent<UHWPropControl>().IsRotateProp = true;	
		}
		catch
		{
			IsHIDDevAvailable = false;		
		}		
	}
	
	void OnApplicationQuit()
	{
		if(HidConProcess != null)
			HidConProcess.Kill();	
	}
	
	void UpdateSound()
	{
		if(GameDataBuffer.SpeedControl > 0)
		{
			if(!AudioController.isPlaying)
				AudioController.Play();	
			else
				AudioController.pitch = (ObjFlySpeed.magnitude < 0.5f) ? 0.5f : ObjFlySpeed.magnitude;
		}
		else
		{
			if(AudioController.isPlaying)
				AudioController.Stop();	
		}
	}
	
	void Update () 
	{
		if(!IsOnExec) 
		{
			if(AudioController.isPlaying)
				AudioController.Stop();
			return;
		}
		
		UpdateSound();
		
		if((IsHIDDevAvailable) && (HIDController != null))
		{
			if(HIDController.GetHIDControlData(out HIDDataSet))
			{								
				
				if(HIDDataSet.SpeedControl != GameDataBuffer.SpeedControl)
				{
					GameDataBuffer.SpeedControl = HIDDataSet.SpeedControl;
					PropObject.GetComponent<UHWPropControl>().RotationRate = GameDataBuffer.SpeedControl;					
				}
				
				if(HIDDataSet.ControlInputs != GameDataBuffer.ControlInputs)
				{
					GameDataBuffer.ControlInputs = HIDDataSet.ControlInputs;
					DirInput.IsAsc = ((GameDataBuffer.ControlInputs & 0x1) > 0);
					DirInput.IsDes = ((GameDataBuffer.ControlInputs & 0x2) > 0);
					DirInput.IsRight = ((GameDataBuffer.ControlInputs & 0x4) > 0);
					DirInput.IsLeft = ((GameDataBuffer.ControlInputs & 0x8) > 0);	
					if(DirInput.IsAsc && DirInput.IsDes)
					{
						DirInput.IsAsc = false;
						DirInput.IsDes = false;
					}
					if(DirInput.IsRight && DirInput.IsLeft)
					{
						DirInput.IsRight = false;
						DirInput.IsLeft = false;
					}
				}				
			}
						
			PresetSpeed = Vector3.zero; 
			BankSpeed = Vector3.zero;
			
			if(DirInput.IsAsc || DirInput.IsDes)
				PresetSpeed.y = (DirInput.IsDes ? -1 : 1) * (GameDataBuffer.SpeedControl / 8);
			
			PresetSpeed.z = -1 * (GameDataBuffer.SpeedControl / 10);
						
			if(DirInput.IsLeft)
			{
				BankSpeed = Vector3.up * (GameDataBuffer.SpeedControl / 10);
				PresetSpeed.x = (GameDataBuffer.SpeedControl / 10);
				BankVelocity = Vector3.forward;
			}
			else 
			{
				if(DirInput.IsRight)
				{
					BankSpeed = Vector3.down * (GameDataBuffer.SpeedControl / 10);
					PresetSpeed.x = -1 * (GameDataBuffer.SpeedControl / 10);
					BankVelocity = Vector3.back;
				}
			}
									
			ObjBankSpeed = Vector3.SmoothDamp(ObjBankSpeed, BankSpeed, ref BankVelocity, Time.fixedDeltaTime * ObjectWeight);			
			ObjFlySpeed = Vector3.Lerp(ObjFlySpeed, PresetSpeed, Time.fixedDeltaTime);
			
			ObjFlySpeed.z *= Mathf.Cos(ObjBankSpeed.y);
			ObjFlySpeed.x *= Mathf.Sin(ObjBankSpeed.y);		
			
			FlyObject.transform.Rotate(ObjBankSpeed);			
			FlyObject.transform.Translate(ObjFlySpeed);				
		}
	}
	
	void OnGUI()
	{
		if(!IsHIDDevAvailable) 
		{
			UIFontStyle = new GUIStyle(GUI.skin.label);
			UIFontStyle.fontSize = 20;
			UIFontStyle.normal.textColor = Color.blue;			
			GUI.Label(new Rect(30, 30 , Screen.width, 300), "Communication Error with the Controller", UIFontStyle);	
		}
	}
	
	public void HaltGame()
	{
		IsOnExec = false;
		ObjBankSpeed = Vector3.zero;
		ObjFlySpeed = Vector3.zero;
		if(PropObject != null)
			PropObject.GetComponent<UHWPropControl>().IsRotateProp = false;		
		
	}
		
}
