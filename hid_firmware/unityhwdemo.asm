
_interrupt:

;unityhwdemo.c,10 :: 		void interrupt()
;unityhwdemo.c,12 :: 		USB_Interrupt_Proc();
	CALL        _USB_Interrupt_Proc+0, 0
;unityhwdemo.c,13 :: 		}
L_end_interrupt:
L__interrupt13:
	RETFIE      1
; end of _interrupt

_clear_write_buffer:

;unityhwdemo.c,15 :: 		void clear_write_buffer()
;unityhwdemo.c,18 :: 		for(wpos = 0; wpos < USB_BUFFER_SIZE; wpos++)
	CLRF        R1 
L_clear_write_buffer0:
	MOVLW       64
	SUBWF       R1, 0 
	BTFSC       STATUS+0, 0 
	GOTO        L_clear_write_buffer1
;unityhwdemo.c,19 :: 		usb_writebuff[wpos] = 0x0;
	MOVLW       _usb_writebuff+0
	MOVWF       FSR1L 
	MOVLW       hi_addr(_usb_writebuff+0)
	MOVWF       FSR1H 
	MOVF        R1, 0 
	ADDWF       FSR1L, 1 
	BTFSC       STATUS+0, 0 
	INCF        FSR1H, 1 
	CLRF        POSTINC1+0 
;unityhwdemo.c,18 :: 		for(wpos = 0; wpos < USB_BUFFER_SIZE; wpos++)
	INCF        R1, 1 
;unityhwdemo.c,19 :: 		usb_writebuff[wpos] = 0x0;
	GOTO        L_clear_write_buffer0
L_clear_write_buffer1:
;unityhwdemo.c,20 :: 		usb_writebuff[0] = USB_LINK_SIGNATURE;
	MOVLW       62
	MOVWF       1344 
;unityhwdemo.c,21 :: 		}
L_end_clear_write_buffer:
	RETURN      0
; end of _clear_write_buffer

_init_system:

;unityhwdemo.c,23 :: 		void init_system()
;unityhwdemo.c,25 :: 		clear_write_buffer();
	CALL        _clear_write_buffer+0, 0
;unityhwdemo.c,26 :: 		HID_Enable(&usb_readbuff, &usb_writebuff);
	MOVLW       _usb_readbuff+0
	MOVWF       FARG_HID_Enable_readbuff+0 
	MOVLW       hi_addr(_usb_readbuff+0)
	MOVWF       FARG_HID_Enable_readbuff+1 
	MOVLW       _usb_writebuff+0
	MOVWF       FARG_HID_Enable_writebuff+0 
	MOVLW       hi_addr(_usb_writebuff+0)
	MOVWF       FARG_HID_Enable_writebuff+1 
	CALL        _HID_Enable+0, 0
;unityhwdemo.c,27 :: 		ADC_Init();
	CALL        _ADC_Init+0, 0
;unityhwdemo.c,28 :: 		INTCON2 = 0x0;
	CLRF        INTCON2+0 
;unityhwdemo.c,29 :: 		ADCON1 = 0xE;
	MOVLW       14
	MOVWF       ADCON1+0 
;unityhwdemo.c,30 :: 		PORTB = 0;
	CLRF        PORTB+0 
;unityhwdemo.c,31 :: 		TRISB = 0x0F;
	MOVLW       15
	MOVWF       TRISB+0 
;unityhwdemo.c,32 :: 		PORTA = 0;
	CLRF        PORTA+0 
;unityhwdemo.c,33 :: 		TRISA = 0x1;
	MOVLW       1
	MOVWF       TRISA+0 
;unityhwdemo.c,34 :: 		Delay_ms(10);
	MOVLW       156
	MOVWF       R12, 0
	MOVLW       215
	MOVWF       R13, 0
L_init_system3:
	DECFSZ      R13, 1, 1
	BRA         L_init_system3
	DECFSZ      R12, 1, 1
	BRA         L_init_system3
;unityhwdemo.c,35 :: 		}
L_end_init_system:
	RETURN      0
; end of _init_system

_tx_usr_inputs:

;unityhwdemo.c,37 :: 		void tx_usr_inputs()
;unityhwdemo.c,39 :: 		usb_writebuff[1] = button_buffer;
	MOVF        _button_buffer+0, 0 
	MOVWF       1345 
;unityhwdemo.c,40 :: 		usb_writebuff[2] = (speed_val & 0xFF);
	MOVLW       255
	ANDWF       _speed_val+0, 0 
	MOVWF       1346 
;unityhwdemo.c,41 :: 		usb_writebuff[3] = (speed_val >> 8);
	MOVF        _speed_val+1, 0 
	MOVWF       R0 
	CLRF        R1 
	MOVF        R0, 0 
	MOVWF       1347 
;unityhwdemo.c,42 :: 		while(!HID_Write(&usb_writebuff, 64));
L_tx_usr_inputs4:
	MOVLW       _usb_writebuff+0
	MOVWF       FARG_HID_Write_writebuff+0 
	MOVLW       hi_addr(_usb_writebuff+0)
	MOVWF       FARG_HID_Write_writebuff+1 
	MOVLW       64
	MOVWF       FARG_HID_Write_len+0 
	CALL        _HID_Write+0, 0
	MOVF        R0, 1 
	BTFSS       STATUS+0, 2 
	GOTO        L_tx_usr_inputs5
	GOTO        L_tx_usr_inputs4
L_tx_usr_inputs5:
;unityhwdemo.c,43 :: 		asm nop;
	NOP
;unityhwdemo.c,44 :: 		}
L_end_tx_usr_inputs:
	RETURN      0
; end of _tx_usr_inputs

_main:

;unityhwdemo.c,46 :: 		void main()
;unityhwdemo.c,48 :: 		init_system();
	CALL        _init_system+0, 0
;unityhwdemo.c,49 :: 		while(1)
L_main6:
;unityhwdemo.c,51 :: 		speed_val = ADC_Get_Sample(0);
	CLRF        FARG_ADC_Get_Sample_channel+0 
	CALL        _ADC_Get_Sample+0, 0
	MOVF        R0, 0 
	MOVWF       _speed_val+0 
	MOVF        R1, 0 
	MOVWF       _speed_val+1 
;unityhwdemo.c,52 :: 		if((button_buffer != (PORTB & 0xF)) || (abs(speed_val - speed_buffer) > ADC_NOISE_OFFSET))
	MOVLW       15
	ANDWF       PORTB+0, 0 
	MOVWF       R1 
	MOVF        _button_buffer+0, 0 
	XORWF       R1, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main11
	MOVF        _speed_buffer+0, 0 
	SUBWF       _speed_val+0, 0 
	MOVWF       FARG_abs_a+0 
	MOVF        _speed_buffer+1, 0 
	SUBWFB      _speed_val+1, 0 
	MOVWF       FARG_abs_a+1 
	CALL        _abs+0, 0
	MOVLW       128
	MOVWF       R2 
	MOVLW       128
	XORWF       R1, 0 
	SUBWF       R2, 0 
	BTFSS       STATUS+0, 2 
	GOTO        L__main18
	MOVF        R0, 0 
	SUBLW       5
L__main18:
	BTFSS       STATUS+0, 0 
	GOTO        L__main11
	GOTO        L_main10
L__main11:
;unityhwdemo.c,54 :: 		button_buffer = (PORTB & 0xF);
	MOVLW       15
	ANDWF       PORTB+0, 0 
	MOVWF       _button_buffer+0 
;unityhwdemo.c,55 :: 		speed_buffer = speed_val;
	MOVF        _speed_val+0, 0 
	MOVWF       _speed_buffer+0 
	MOVF        _speed_val+1, 0 
	MOVWF       _speed_buffer+1 
;unityhwdemo.c,56 :: 		tx_usr_inputs();
	CALL        _tx_usr_inputs+0, 0
;unityhwdemo.c,57 :: 		}
L_main10:
;unityhwdemo.c,58 :: 		}
	GOTO        L_main6
;unityhwdemo.c,59 :: 		}
L_end_main:
	GOTO        $+0
; end of _main
