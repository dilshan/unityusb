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

#define USB_BUFFER_SIZE 64
#define USB_LINK_SIGNATURE 0x3E
#define ADC_NOISE_OFFSET 5

unsigned char usb_readbuff[USB_BUFFER_SIZE] absolute 0x500;
unsigned char usb_writebuff[USB_BUFFER_SIZE] absolute 0x540;
unsigned char button_buffer = 0x0;
unsigned int speed_val, speed_buffer = 0x0;

void interrupt()
{
  USB_Interrupt_Proc();
}

void clear_write_buffer()
{
  unsigned char wpos;
  for(wpos = 0; wpos < USB_BUFFER_SIZE; wpos++)
    usb_writebuff[wpos] = 0x0;
  usb_writebuff[0] = USB_LINK_SIGNATURE;
}

void init_system()
{
  clear_write_buffer();
  HID_Enable(&usb_readbuff, &usb_writebuff);
  ADC_Init();
  INTCON2 = 0x0;
  ADCON1 = 0xE;
  PORTB = 0;
  TRISB = 0x0F;
  PORTA = 0;
  TRISA = 0x1;
  Delay_ms(10);
}

void tx_usr_inputs()
{
  usb_writebuff[1] = button_buffer;
  usb_writebuff[2] = (speed_val & 0xFF);
  usb_writebuff[3] = (speed_val >> 8);
  while(!HID_Write(&usb_writebuff, 64));
  asm nop;
}

void main() 
{
  init_system();
  while(1)
  {
    speed_val = ADC_Get_Sample(0);
    if((button_buffer != (PORTB & 0xF)) || (abs(speed_val - speed_buffer) > ADC_NOISE_OFFSET))
    {
      button_buffer = (PORTB & 0xF);
      speed_buffer = speed_val;
      tx_usr_inputs();
    }
  }
}