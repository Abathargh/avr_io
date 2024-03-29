include mapped_io
include usart
include timer


const
  UEINT*   = MappedIoRegister[uint8](0xF4)
  UEBCHX*  = MappedIoRegister[uint8](0xF3)
  UEBCLX*  = MappedIoRegister[uint8](0xF2)
  UEDATX*  = MappedIoRegister[uint8](0xF1)
  UEIENX*  = MappedIoRegister[uint8](0xF0)
  UESTA1X* = MappedIoRegister[uint8](0xEF)
  UESTA0X* = MappedIoRegister[uint8](0xEE)
  UECFG1X* = MappedIoRegister[uint8](0xED)
  UECFG0X* = MappedIoRegister[uint8](0xEC)
  UECONX*  = MappedIoRegister[uint8](0xEB)
  UERST*   = MappedIoRegister[uint8](0xEA)
  UENUM*   = MappedIoRegister[uint8](0xE9)
  UEINTX*  = MappedIoRegister[uint8](0xE8)
  UDMFN*   = MappedIoRegister[uint8](0xE6)
  UDFNUMH* = MappedIoRegister[uint8](0xE5)
  UDFNUML* = MappedIoRegister[uint8](0xE4)
  UDADDR*  = MappedIoRegister[uint8](0xE3)
  UDIEN*   = MappedIoRegister[uint8](0xE2)
  UDINT*   = MappedIoRegister[uint8](0xE1)
  UDCON*   = MappedIoRegister[uint8](0xE0)
  USBINT*  = MappedIoRegister[uint8](0xDA)
  USBSTA*  = MappedIoRegister[uint8](0xD9)
  USBCON*  = MappedIoRegister[uint8](0xD8)
  UHWCON*  = MappedIoRegister[uint8](0xD7)
  DT4*     = MappedIoRegister[uint8](0xD4)
  OCR4D*   = MappedIoRegister[uint8](0xD2)
  OCR4C*   = MappedIoRegister[uint8](0xD1)
  OCR4B*   = MappedIoRegister[uint8](0xD0)
  OCR4A*   = MappedIoRegister[uint8](0xCF)
  UDR1*    = MappedIoRegister[uint8](0xCE)
  UBRR1H*  = MappedIoRegister[uint8](0xCD)
  UBRR1L*  = MappedIoRegister[uint8](0xCC)
  UCSR1D*  = MappedIoRegister[uint8](0xCB)
  UCSR1C*  = MappedIoRegister[uint8](0xCA)
  UCSR1B*  = MappedIoRegister[uint8](0xC9)
  UCSR1A*  = MappedIoRegister[uint8](0xC8)
  CLKSTA*  = MappedIoRegister[uint8](0xC7)
  CLKSEL1* = MappedIoRegister[uint8](0xC6)
  CLKSEL0* = MappedIoRegister[uint8](0xC5)
  TCCR4E*  = MappedIoRegister[uint8](0xC4)
  TCCR4D*  = MappedIoRegister[uint8](0xC3)
  TCCR4C*  = MappedIoRegister[uint8](0xC2)
  TCCR4B*  = MappedIoRegister[uint8](0xC1)
  TCCR4A*  = MappedIoRegister[uint8](0xC0)
  TC4H*    = MappedIoRegister[uint8](0xBF)
  TCNT4*   = MappedIoRegister[uint8](0xBE)
  TWAMR*   = MappedIoRegister[uint8](0xBD)
  TWCR*    = MappedIoRegister[uint8](0xBC)
  TWDR*    = MappedIoRegister[uint8](0xBB)
  TWAR*    = MappedIoRegister[uint8](0xBA)
  TWSR*    = MappedIoRegister[uint8](0xB9)
  TWBR*    = MappedIoRegister[uint8](0xB8)
  OCR3CH*  = MappedIoRegister[uint8](0x9D)
  OCR3CL*  = MappedIoRegister[uint8](0x9C)
  OCR3BH*  = MappedIoRegister[uint8](0x9B)
  OCR3BL*  = MappedIoRegister[uint8](0x9A)
  OCR3AH*  = MappedIoRegister[uint8](0x99)
  OCR3AL*  = MappedIoRegister[uint8](0x98)
  ICR3H*   = MappedIoRegister[uint8](0x97)
  ICR3L*   = MappedIoRegister[uint8](0x96)
  TCNT3H*  = MappedIoRegister[uint8](0x95)
  TCNT3L*  = MappedIoRegister[uint8](0x94)
  TCCR3C*  = MappedIoRegister[uint8](0x92)
  TCCR3B*  = MappedIoRegister[uint8](0x91)
  TCCR3A*  = MappedIoRegister[uint8](0x90)
  OCR1CH*  = MappedIoRegister[uint8](0x8D)
  OCR1CL*  = MappedIoRegister[uint8](0x8C)
  OCR1BH*  = MappedIoRegister[uint8](0x8B)
  OCR1BL*  = MappedIoRegister[uint8](0x8A)
  OCR1AH*  = MappedIoRegister[uint8](0x89)
  OCR1AL*  = MappedIoRegister[uint8](0x88)
  ICR1H*   = MappedIoRegister[uint8](0x87)
  ICR1L*   = MappedIoRegister[uint8](0x86)
  TCNT1H*  = MappedIoRegister[uint8](0x85)
  TCNT1L*  = MappedIoRegister[uint8](0x84)
  TCCR1C*  = MappedIoRegister[uint8](0x82)
  TCCR1B*  = MappedIoRegister[uint8](0x81)
  TCCR1A*  = MappedIoRegister[uint8](0x80)
  DIDR1*   = MappedIoRegister[uint8](0x7F)
  DIDR0*   = MappedIoRegister[uint8](0x7E)
  DIDR2*   = MappedIoRegister[uint8](0x7D)
  ADMUX*   = MappedIoRegister[uint8](0x7C)
  ADCSRB*  = MappedIoRegister[uint8](0x7B)
  ADCSRA*  = MappedIoRegister[uint8](0x7A)
  ADCH*    = MappedIoRegister[uint8](0x79)
  ADCL*    = MappedIoRegister[uint8](0x78)
  TIMSK4*  = MappedIoRegister[uint8](0x72)
  TIMSK3*  = MappedIoRegister[uint8](0x71)
  TIMSK1*  = MappedIoRegister[uint8](0x6F)
  TIMSK0*  = MappedIoRegister[uint8](0x6E)
  PCMSK0*  = MappedIoRegister[uint8](0x6B)
  EICRB*   = MappedIoRegister[uint8](0x6A)
  EICRA*   = MappedIoRegister[uint8](0x69)
  PCICR*   = MappedIoRegister[uint8](0x68)
  RCCTRL*  = MappedIoRegister[uint8](0x67)
  OSCCAL*  = MappedIoRegister[uint8](0x66)
  PRR1*    = MappedIoRegister[uint8](0x65)
  PRR0*    = MappedIoRegister[uint8](0x64)
  CLKPR*   = MappedIoRegister[uint8](0x61)
  WDTCSR*  = MappedIoRegister[uint8](0x60)
  SREG*    = MappedIoRegister[uint8](0x5F)
  SPH*     = MappedIoRegister[uint8](0x5E)
  SPL*     = MappedIoRegister[uint8](0x5D)
  RAMPZ*   = MappedIoRegister[uint8](0x5B)
  SPMCSR*  = MappedIoRegister[uint8](0x57)
  MCUCR*   = MappedIoRegister[uint8](0x55)
  MCUSR*   = MappedIoRegister[uint8](0x54)
  SMCR*    = MappedIoRegister[uint8](0x53)
  PLLFRQ*  = MappedIoRegister[uint8](0x52)
  OCDR*    = MappedIoRegister[uint8](0x51)
  ACSR*    = MappedIoRegister[uint8](0x50)
  SPDR*    = MappedIoRegister[uint8](0x4E)
  SPSR*    = MappedIoRegister[uint8](0x4D)
  SPCR*    = MappedIoRegister[uint8](0x4C)
  GPIOR2*  = MappedIoRegister[uint8](0x4B)
  GPIOR1*  = MappedIoRegister[uint8](0x4A)
  PLLCSR*  = MappedIoRegister[uint8](0x49)
  OCR0B*   = MappedIoRegister[uint8](0x48)
  OCR0A*   = MappedIoRegister[uint8](0x47)
  TCNT0*   = MappedIoRegister[uint8](0x46)
  TCCR0B*  = MappedIoRegister[uint8](0x45)
  TCCR0A*  = MappedIoRegister[uint8](0x44)
  GTCCR*   = MappedIoRegister[uint8](0x43)
  EEARH*   = MappedIoRegister[uint8](0x42)
  EEARL*   = MappedIoRegister[uint8](0x41)
  EEDR*    = MappedIoRegister[uint8](0x40)
  EECR*    = MappedIoRegister[uint8](0x3F)
  GPIOR0*  = MappedIoRegister[uint8](0x3E)
  EIMSK*   = MappedIoRegister[uint8](0x3D)
  EIFR*    = MappedIoRegister[uint8](0x3C)
  PCIFR*   = MappedIoRegister[uint8](0x3B)
  TIFR4*   = MappedIoRegister[uint8](0x39)
  TIFR3*   = MappedIoRegister[uint8](0x38)
  TIFR1*   = MappedIoRegister[uint8](0x36)
  TIFR0*   = MappedIoRegister[uint8](0x35)
  PORTF*   = MappedIoRegister[uint8](0x31)
  DDRF*    = MappedIoRegister[uint8](0x30)
  PINF*    = MappedIoRegister[uint8](0x2F)
  PORTE*   = MappedIoRegister[uint8](0x2E)
  DDRE*    = MappedIoRegister[uint8](0x2D)
  PINE*    = MappedIoRegister[uint8](0x2C)
  PORTD*   = MappedIoRegister[uint8](0x2B)
  DDRD*    = MappedIoRegister[uint8](0x2A)
  PIND*    = MappedIoRegister[uint8](0x29)
  PORTC*   = MappedIoRegister[uint8](0x28)
  DDRC*    = MappedIoRegister[uint8](0x27)
  PINC*    = MappedIoRegister[uint8](0x26)
  PORTB*   = MappedIoRegister[uint8](0x25)
  DDRB*    = MappedIoRegister[uint8](0x24)
  PINB*    = MappedIoRegister[uint8](0x23)

const 
  portB* = Port(direction: DDRB, output: PORTB, input: PINB)
  portC* = Port(direction: DDRC, output: PORTC, input: PINC)
  portD* = Port(direction: DDRD, output: PORTD, input: PIND)
  portE* = Port(direction: DDRE, output: PORTE, input: PINE)
  portF* = Port(direction: DDRF, output: PORTF, input: PINF)

  usart1* = UsartFlow(baudLo: UBRR1L, baudHi: UBRR1H, ctlA: UCSR1A, 
    ctlB: UCSR1B, ctlC: UCSR1C, udr: UDR1, ctlD: UCSR1D)

  timer0* = Timer8BitPwm(
    tccra: TCCR0A, tccrb: TCCR0B, tcnt: TCNT0, ocra: OCR0A, ocrb: OCR0B, 
    timsk: TIMSK0, tifr: TIFR0)
  timer1* = Timer16Bit3ComparePwm(tccra: TCCR1A, tccrb: TCCR1B, tccrc: TCCR1C,
    tcnth: TCNT1H, tcntl: TCNT1L, ocrah: OCR1AH, ocral: OCR1AL, ocrbh: OCR1BH,
    ocrbl: OCR1BL, icrh: ICR1H, icrl: ICR1L, timsk: TIMSK1, tifr: TIFR1, 
    gtccr: GTCCR)
  timer3* = Timer16Bit3ComparePwm(tccra: TCCR3A, tccrb: TCCR3B, tccrc: TCCR3C,
    tcnth: TCNT3H, tcntl: TCNT3L, ocrah: OCR3AH, ocral: OCR3AL, ocrbh: OCR3BH,
    ocrbl: OCR3BL, icrh: ICR3H, icrl: ICR3L, timsk: TIMSK3, tifr: TIFR3,
    gtccr: GTCCR)
  timer4* = Timer10bitHiSpeed(tccra:TCCR4A, tccrb:TCCR4B, tccrc:TCCR4C, 
    tccrd:TCCR4D, tccre:TCCR4E, tcnt:TCNT4, tch:TC4H, ocra:OCR4A, ocrb:OCR4B,
    ocrc:OCR4C, ocrd:OCR4D, timsk:TIMSK4, tifr:TIFR4, dt:DT4)
