include mapped_io
include usart
include timer


when defined(USING_ATMEGA1280) or defined(USING_ATMEGA2560):
  include atmega64_128_256_0only

const
  PINA*    = MappedIoRegister[uint8](0x20)
  DDRA*    = MappedIoRegister[uint8](0x21)
  PORTA*   = MappedIoRegister[uint8](0x22)
  PINB*    = MappedIoRegister[uint8](0x23)
  DDRB*    = MappedIoRegister[uint8](0x24)
  PORTB*   = MappedIoRegister[uint8](0x25)
  PINC*    = MappedIoRegister[uint8](0x26)
  DDRC*    = MappedIoRegister[uint8](0x27)
  PORTC*   = MappedIoRegister[uint8](0x28)
  PIND*    = MappedIoRegister[uint8](0x29)
  DDRD*    = MappedIoRegister[uint8](0x2a)
  PORTD*   = MappedIoRegister[uint8](0x2b)
  PINE*    = MappedIoRegister[uint8](0x2c)
  DDRE*    = MappedIoRegister[uint8](0x2d)
  PORTE*   = MappedIoRegister[uint8](0x2e)
  PINF*    = MappedIoRegister[uint8](0x2f)
  DDRF*    = MappedIoRegister[uint8](0x30)
  PORTF*   = MappedIoRegister[uint8](0x31)
  PING*    = MappedIoRegister[uint8](0x32)
  DDRG*    = MappedIoRegister[uint8](0x33)
  PORTG*   = MappedIoRegister[uint8](0x34)
  TIFR0*   = MappedIoRegister[uint8](0x35)
  TIFR1*   = MappedIoRegister[uint8](0x36)
  TIFR2*   = MappedIoRegister[uint8](0x37)
  TIFR3*   = MappedIoRegister[uint8](0x38)
  TIFR4*   = MappedIoRegister[uint8](0x39)
  TIFR5*   = MappedIoRegister[uint8](0x3a)
  PCIFR*   = MappedIoRegister[uint8](0x3b)
  EIFR*    = MappedIoRegister[uint8](0x3c)
  EIMSK*   = MappedIoRegister[uint8](0x3d)
  GPIOR0*  = MappedIoRegister[uint8](0x3e)
  EECR*    = MappedIoRegister[uint8](0x3f)
  EEDR*    = MappedIoRegister[uint8](0x40)
  EEAR*    = MappedIoRegister[uint16](0x41)
  EEARL*   = MappedIoRegister[uint8](0x41)
  EEARH*   = MappedIoRegister[uint8](0x42)
  GTCCR*   = MappedIoRegister[uint8](0x43)
  TCCR0A*  = MappedIoRegister[uint8](0x44)
  TCCR0B*  = MappedIoRegister[uint8](0x45)
  TCNT0*   = MappedIoRegister[uint8](0x46)
  OCR0A*   = MappedIoRegister[uint8](0x47)
  OCR0B*   = MappedIoRegister[uint8](0x48)
  GPIOR1*  = MappedIoRegister[uint8](0x4a)
  GPIOR2*  = MappedIoRegister[uint8](0x4b)
  SPCR*    = MappedIoRegister[uint8](0x4c)
  SPSR*    = MappedIoRegister[uint8](0x4d)
  SPDR*    = MappedIoRegister[uint8](0x4e)
  ACSR*    = MappedIoRegister[uint8](0x50)
  MONDR*   = MappedIoRegister[uint8](0x51)
  OCDR*    = MappedIoRegister[uint8](0x51)
  SMCR*    = MappedIoRegister[uint8](0x53)
  MCUSR*   = MappedIoRegister[uint8](0x54)
  MCUCR*   = MappedIoRegister[uint8](0x55)
  SPMCSR*  = MappedIoRegister[uint8](0x57)
  RAMPZ*   = MappedIoRegister[uint8](0x5b)
  EIND*    = MappedIoRegister[uint8](0x5c)
  WDTCSR*  = MappedIoRegister[uint8](0x60)
  CLKPR*   = MappedIoRegister[uint8](0x61)
  PRR0*    = MappedIoRegister[uint8](0x64)
  PRR1*    = MappedIoRegister[uint8](0x65)
  OSCCAL*  = MappedIoRegister[uint8](0x66)
  PCICR*   = MappedIoRegister[uint8](0x68)
  EICRA*   = MappedIoRegister[uint8](0x69)
  EICRB*   = MappedIoRegister[uint8](0x6A)
  PCMSK0*  = MappedIoRegister[uint8](0x6B)
  PCMSK1*  = MappedIoRegister[uint8](0x6C)
  TIMSK0*  = MappedIoRegister[uint8](0x6E)
  TIMSK1*  = MappedIoRegister[uint8](0x6F)
  TIMSK2*  = MappedIoRegister[uint8](0x70)
  TIMSK3*  = MappedIoRegister[uint8](0x71)
  TIMSK4*  = MappedIoRegister[uint8](0x72)
  TIMSK5*  = MappedIoRegister[uint8](0x73)
  XMCRA*   = MappedIoRegister[uint8](0x74)
  XMCRB*   = MappedIoRegister[uint8](0x75)
  ADC*     = MappedIoRegister[uint16](0x78)
  ADCW*    = MappedIoRegister[uint16](0x78)
  ADCL*    = MappedIoRegister[uint8](0x78)
  ADCH*    = MappedIoRegister[uint8](0x79)
  ADCSRA*  = MappedIoRegister[uint8](0x7A)
  ADCSRB*  = MappedIoRegister[uint8](0x7B)
  ADMUX*   = MappedIoRegister[uint8](0x7C)
  DIDR2*   = MappedIoRegister[uint8](0x7D)
  DIDR0*   = MappedIoRegister[uint8](0x7E)
  DIDR1*   = MappedIoRegister[uint8](0x7F)
  TCCR1A*  = MappedIoRegister[uint8](0x80)
  TCCR1B*  = MappedIoRegister[uint8](0x81)
  TCCR1C*  = MappedIoRegister[uint8](0x82)
  TCNT1*   = MappedIoRegister[uint16](0x84)
  TCNT1L*  = MappedIoRegister[uint8](0x84)
  TCNT1H*  = MappedIoRegister[uint8](0x85)
  ICR1*    = MappedIoRegister[uint16](0x86)
  ICR1L*   = MappedIoRegister[uint8](0x86)
  ICR1H*   = MappedIoRegister[uint8](0x87)
  OCR1A*   = MappedIoRegister[uint16](0x88)
  OCR1AL*  = MappedIoRegister[uint8](0x88)
  OCR1AH*  = MappedIoRegister[uint8](0x89)
  OCR1B*   = MappedIoRegister[uint16](0x8A)
  OCR1BL*  = MappedIoRegister[uint8](0x8A)
  OCR1BH*  = MappedIoRegister[uint8](0x8B)
  OCR1C*   = MappedIoRegister[uint16](0x8C)
  OCR1CL*  = MappedIoRegister[uint8](0x8C)
  OCR1CH*  = MappedIoRegister[uint8](0x8D)
  TCCR3A*  = MappedIoRegister[uint8](0x90)
  TCCR3B*  = MappedIoRegister[uint8](0x91)
  TCCR3C*  = MappedIoRegister[uint8](0x92)
  TCNT3*   = MappedIoRegister[uint16](0x94)
  TCNT3L*  = MappedIoRegister[uint8](0x94)
  TCNT3H*  = MappedIoRegister[uint8](0x95)
  ICR3*    = MappedIoRegister[uint16](0x96)
  ICR3L*   = MappedIoRegister[uint8](0x96)
  ICR3H*   = MappedIoRegister[uint8](0x97)
  OCR3A*   = MappedIoRegister[uint16](0x98)
  OCR3AL*  = MappedIoRegister[uint8](0x98)
  OCR3AH*  = MappedIoRegister[uint8](0x99)
  OCR3B*   = MappedIoRegister[uint16](0x9A)
  OCR3BL*  = MappedIoRegister[uint8](0x9A)
  OCR3BH*  = MappedIoRegister[uint8](0x9B)
  OCR3C*   = MappedIoRegister[uint16](0x9C)
  OCR3CL*  = MappedIoRegister[uint8](0x9C)
  OCR3CH*  = MappedIoRegister[uint8](0x9D)
  TCCR4A*  = MappedIoRegister[uint8](0xA0)
  TCCR4B*  = MappedIoRegister[uint8](0xA1)
  TCCR4C*  = MappedIoRegister[uint8](0xA2)
  TCNT4*   = MappedIoRegister[uint16](0xA4)
  TCNT4L*  = MappedIoRegister[uint8](0xA4)
  TCNT4H*  = MappedIoRegister[uint8](0xA5)
  ICR4*    = MappedIoRegister[uint16](0xA6)
  ICR4L*   = MappedIoRegister[uint8](0xA6)
  ICR4H*   = MappedIoRegister[uint8](0xA7)
  OCR4A*   = MappedIoRegister[uint16](0xA8)
  OCR4AL*  = MappedIoRegister[uint8](0xA8)
  OCR4AH*  = MappedIoRegister[uint8](0xA9)
  OCR4B*   = MappedIoRegister[uint16](0xAA)
  OCR4BL*  = MappedIoRegister[uint8](0xAA)
  OCR4BH*  = MappedIoRegister[uint8](0xAB)
  OCR4C*   = MappedIoRegister[uint16](0xAC)
  OCR4CL*  = MappedIoRegister[uint8](0xAC)
  OCR4CH*  = MappedIoRegister[uint8](0xAD)
  TCCR2A*  = MappedIoRegister[uint8](0xB0)
  TCCR2B*  = MappedIoRegister[uint8](0xB1)
  TCNT2*   = MappedIoRegister[uint8](0xB2)
  OCR2A*   = MappedIoRegister[uint8](0xB3)
  OCR2B*   = MappedIoRegister[uint8](0xB4)
  ASSR*    = MappedIoRegister[uint8](0xB6)
  TWBR*    = MappedIoRegister[uint8](0xB8)
  TWSR*    = MappedIoRegister[uint8](0xB9)
  TWAR*    = MappedIoRegister[uint8](0xBA)
  TWDR*    = MappedIoRegister[uint8](0xBB)
  TWCR*    = MappedIoRegister[uint8](0xBC)
  TWAMR*   = MappedIoRegister[uint8](0xBD)
  UCSR0A*  = MappedIoRegister[uint8](0xC0)
  UCSR0B*  = MappedIoRegister[uint8](0XC1)
  UCSR0C*  = MappedIoRegister[uint8](0xC2)
  UBRR0*   = MappedIoRegister[uint16](0xC4)
  UBRR0L*  = MappedIoRegister[uint8](0xC4)
  UBRR0H*  = MappedIoRegister[uint8](0xC5)
  UDR0*    = MappedIoRegister[uint8](0XC6)
  UCSR1A*  = MappedIoRegister[uint8](0xC8)
  UCSR1B*  = MappedIoRegister[uint8](0XC9)
  UCSR1C*  = MappedIoRegister[uint8](0xCA)
  UBRR1*   = MappedIoRegister[uint16](0xCC)
  UBRR1L*  = MappedIoRegister[uint8](0xCC)
  UBRR1H*  = MappedIoRegister[uint8](0xCD)
  UDR1*    = MappedIoRegister[uint8](0XCE)
  TCCR5A*  = MappedIoRegister[uint8](0x120)
  TCCR5B*  = MappedIoRegister[uint8](0x121)
  TCCR5C*  = MappedIoRegister[uint8](0x122)
  TCNT5*   = MappedIoRegister[uint16](0x124)
  TCNT5L*  = MappedIoRegister[uint8](0x124)
  TCNT5H*  = MappedIoRegister[uint8](0x125)
  ICR5*    = MappedIoRegister[uint16](0x126)
  ICR5L*   = MappedIoRegister[uint8](0x126)
  ICR5H*   = MappedIoRegister[uint8](0x127)
  OCR5A*   = MappedIoRegister[uint16](0x128)
  OCR5AL*  = MappedIoRegister[uint8](0x128)
  OCR5AH*  = MappedIoRegister[uint8](0x129)
  OCR5B*   = MappedIoRegister[uint16](0x12A)
  OCR5BL*  = MappedIoRegister[uint8](0x12A)
  OCR5BH*  = MappedIoRegister[uint8](0x12B)
  OCR5C*   = MappedIoRegister[uint16](0x12C)
  OCR5CL*  = MappedIoRegister[uint8](0x12C)
  OCR5CH*  = MappedIoRegister[uint8](0x12D)

const
  portA* = Port(direction: DDRA, output: PORTA, input: PINA)
  portB* = Port(direction: DDRB, output: PORTB, input: PINB)
  portC* = Port(direction: DDRC, output: PORTC, input: PINC)
  portD* = Port(direction: DDRD, output: PORTD, input: PIND)
  portE* = Port(direction: DDRE, output: PORTE, input: PINE)
  portF* = Port(direction: DDRF, output: PORTF, input: PINF)
  portG* = Port(direction: DDRG, output: PORTG, input: PING)

  usart0* = BaseUsart(baudLo: UBRR0L, baudHi: UBRR0H, ctlA: UCSR0A, 
    ctlB: UCSR0B, ctlC: UCSR0C, udr: UDR0)
  usart1* = BaseUsart(baudLo: UBRR1L, baudHi: UBRR1H, ctlA: UCSR1A, 
    ctlB: UCSR1B, ctlC: UCSR1C, udr: UDR1)
  
  timer0* = Timer8BitPwm(
    tccra: TCCR0A, tccrb: TCCR0B, tcnt: TCNT0, ocra: OCR0A, ocrb: OCR0B, 
    timsk: TIMSK0, tifr: TIFR0)
  timer1* = Timer16Bit3ComparePwm(tccra: TCCR1A, tccrb: TCCR1B, tccrc: TCCR1C,
    tcnt: TCNT1, tcnth: TCNT1H, tcntl: TCNT1L, ocra: OCR1A, ocrah: OCR1AH, 
    ocral: OCR1AL, ocrb: OCR1B, ocrbh: OCR1BH, ocrbl: OCR1BL, icr: ICR1, 
    icrh: ICR1H, icrl: ICR1L, timsk: TIMSK1, tifr: TIFR1, gtccr: GTCCR)
  timer2* = Timer8BitPwmAsync(tccra: TCCR2A, tccrb: TCCR2B, tcnt: TCNT2, 
    ocra: OCR2A, ocrb: OCR2B, assr: ASSR, timsk: TIMSK2, tifr: TIFR2, 
    gtccr: GTCCR)
  timer3* = Timer16Bit3ComparePwm(tccra: TCCR3A, tccrb: TCCR3B, tccrc: TCCR3C,
    tcnt: TCNT3, tcnth: TCNT3H, tcntl: TCNT3L, ocra: OCR3A, ocrah: OCR3AH, 
    ocral: OCR3AL, ocrb: OCR3B, ocrbh: OCR3BH, ocrbl: OCR3BL, icr: ICR3, 
    icrh: ICR3H, icrl: ICR3L, timsk: TIMSK3, tifr: TIFR3, gtccr: GTCCR)
  timer4* = Timer16Bit3ComparePwm(tccra: TCCR4A, tccrb: TCCR4B, tccrc: TCCR4C,
    tcnt: TCNT4, tcnth: TCNT4H, tcntl: TCNT4L, ocra: OCR4A, ocrah: OCR4AH, 
    ocral: OCR4AL, ocrb: OCR4B, ocrbh: OCR4BH, ocrbl: OCR4BL, icr: ICR4, 
    icrh: ICR4H, icrl: ICR4L, timsk: TIMSK4, tifr: TIFR4, gtccr: GTCCR)
  timer5* = Timer16Bit3ComparePwm(tccra: TCCR5A, tccrb: TCCR5B, tccrc: TCCR5C,
    tcnt: TCNT5, tcnth: TCNT5H, tcntl: TCNT5L, ocra: OCR5A, ocrah: OCR5AH, 
    ocral: OCR5AL, ocrb: OCR5B, ocrbh: OCR5BH, ocrbl: OCR5BL, icr: ICR5, 
    icrh: ICR5H, icrl: ICR5L, timsk: TIMSK5, tifr: TIFR5, gtccr: GTCCR)
