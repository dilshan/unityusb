Unity3D - USB Custom Hardware Interface
=======================================

This is a simple project to demonstrate the USB custom hardware interfacing with [Unity3D](http://unity3d.com) game engine on top of Microsoft Windows operating system(s).

The custom hardware unit used in this demo is build around Microchip’s PIC18F2550 MCU. This custom USB controller consists with 4 push buttons and linear potentiometer.  In supplied demo user needs to control aircraft with those buttons and potentiometer. According to the game logic 4 buttons are used to control the flying direction and flying angle of the aircraft and potentiometer is used to control the speed of the aircraft.

![unity3dusb-system](http://elect.wikispaces.com/file/view/unityhwfunction.png/440040710/unityhwfunction.png) 

As illustrated in above figure, the host environment consists with 2 main applications such as Session Controller and Unity3D game. Session Controller is responsible for USB communication and data conversions. It’s a native application written using Delphi and it gets started with Unity game project. Communication between Session controller and Unity game project is happening through OS level shared memory location. In this demo both Session Controller and Unity game project are heavily depends on Windows API functions, and also both the applications requires administrative privileges to execute. 

In this demo project MCU firmware is developed using MikroC PRO 5.0. Session controller is developed using Embarcadero Delphi XE3 and all the Unity scripts are in C# style. HID interface of this project is based around J.W. Beunder’s Delphi HID library.

![unity3dusb-schematic](http://elect.wikispaces.com/file/view/unityhw_sch.png/440040940/720x300/unityhw_sch.png)

The supplied PCB design of this project is based on commonly available SMD components. Please note that this hardware setup is quiet sensitive to external noises, so it is recommended to use some properly grounded shield with this controller. If USB connection between host and the controller is more than 1.5m, it is advisable to use USB cable with ferrite bead(s). 

Source codes of this project are released under the terms of [MIT License](http://opensource.org/licenses/MIT). Design documents of this project are released under the terms of [CC BY 3.0](http://creativecommons.org/licenses/by/3.0).