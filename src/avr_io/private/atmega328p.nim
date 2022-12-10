include mapped_io

const
    PINB*   = MappedIoRegister8(ioPtr8(0x23))
    DDRB*   = MappedIoRegister8(ioPtr8(0x24))
    PORTB*  = MappedIoRegister8(ioPtr8(0x25))
    PINC*   = MappedIoRegister8(ioPtr8(0x26))
    DDRC*   = MappedIoRegister8(ioPtr8(0x27))
    PORTC*  = MappedIoRegister8(ioPtr8(0x28))
    PIND*   = MappedIoRegister8(ioPtr8(0x29))
    DDRD*   = MappedIoRegister8(ioPtr8(0x2A))
    PORTD*  = MappedIoRegister8(ioPtr8(0x2B))
    TIFR0*  = MappedIoRegister8(ioPtr8(0x35))
    TIFR1*  = MappedIoRegister8(ioPtr8(0x36))
    TIFR2*  = MappedIoRegister8(ioPtr8(0x37))
    PCIFR*  = MappedIoRegister8(ioPtr8(0x3B))
    EIFR*   = MappedIoRegister8(ioPtr8(0x3C))
    EIMSK*  = MappedIoRegister8(ioPtr8(0x3D))
    GPIOR0* = MappedIoRegister8(ioPtr8(0x3E))
    EECR*   = MappedIoRegister8(ioPtr8(0x3F))
    EEDR*   = MappedIoRegister8(ioPtr8(0x40))
    EEAR*   = MappedIoRegister16(ioPtr16(0x41))
    EEARL*  = MappedIoRegister8(ioPtr8(0x41))
    EEARH*  = MappedIoRegister8(ioPtr8(0x42))
    GTCCR*  = MappedIoRegister8(ioPtr8(0x43))
    TCCR0A* = MappedIoRegister8(ioPtr8(0x44))
    TCCR0B* = MappedIoRegister8(ioPtr8(0x45))
    TCNT0*  = MappedIoRegister8(ioPtr8(0x46))
    OCR0A*  = MappedIoRegister8(ioPtr8(0x47))
    OCR0B*  = MappedIoRegister8(ioPtr8(0x48))
    GPIOR1* = MappedIoRegister8(ioPtr8(0x4A))
    GPIOR2* = MappedIoRegister8(ioPtr8(0x4B))
    SPCR*   = MappedIoRegister8(ioPtr8(0x4C))
    SPSR*   = MappedIoRegister8(ioPtr8(0x4D))
    SPDR*   = MappedIoRegister8(ioPtr8(0x4E))
    ACSR*   = MappedIoRegister8(ioPtr8(0x50))
    SMCR*   = MappedIoRegister8(ioPtr8(0x53))
    MCUSR*  = MappedIoRegister8(ioPtr8(0x54))
    MCUCR*  = MappedIoRegister8(ioPtr8(0x55))
    SPMCSR* = MappedIoRegister8(ioPtr8(0x57))
    SPL*    = MappedIoRegister8(ioPtr8(0x5D))
    SPH*    = MappedIoRegister8(ioPtr8(0x5E))
    SREG*   = MappedIoRegister8(ioPtr8(0x5F))
    WDTCSR* = MappedIoRegister8(ioPtr8(0x60))
    CLKPR*  = MappedIoRegister8(ioPtr8(0x61))
    PRR*    = MappedIoRegister8(ioPtr8(0x64))
    OSCCAL* = MappedIoRegister8(ioPtr8(0x66))
    PCICR*  = MappedIoRegister8(ioPtr8(0x68))
    EICRA*  = MappedIoRegister8(ioPtr8(0x69))
    PCMSK0* = MappedIoRegister8(ioPtr8(0x6B))
    PCMSK1* = MappedIoRegister8(ioPtr8(0x6C))
    PCMSK2* = MappedIoRegister8(ioPtr8(0x6D))
    TIMSK0* = MappedIoRegister8(ioPtr8(0x6E))
    TIMSK1* = MappedIoRegister8(ioPtr8(0x6F))
    TIMSK2* = MappedIoRegister8(ioPtr8(0x70))
    ADC*    = MappedIoRegister16(ioPtr16(0x78))
    ADCL*   = MappedIoRegister8(ioPtr8(0x78))
    ADCH*   = MappedIoRegister8(ioPtr8(0x79))
    ADCSRA* = MappedIoRegister8(ioPtr8(0x7A))
    ADCSRB* = MappedIoRegister8(ioPtr8(0x7B))
    ADMUX*  = MappedIoRegister8(ioPtr8(0x7C))
    DIDR0*  = MappedIoRegister8(ioPtr8(0x7E))
    DIDR1*  = MappedIoRegister8(ioPtr8(0x7F))
    TCCR1A* = MappedIoRegister8(ioPtr8(0x80))
    TCCR1B* = MappedIoRegister8(ioPtr8(0x81))
    TCCR1C* = MappedIoRegister8(ioPtr8(0x82))
    TCNT1*  = MappedIoRegister16(ioPtr16(0x84))
    TCNT1L* = MappedIoRegister8(ioPtr8(0x84))
    TCNT1H* = MappedIoRegister8(ioPtr8(0x85))
    ICR1*   = MappedIoRegister16(ioPtr16(0x86))
    ICR1L*  = MappedIoRegister8(ioPtr8(0x86))
    ICR1H*  = MappedIoRegister8(ioPtr8(0x87))
    OCR1A*  = MappedIoRegister16(ioPtr16(0x88))
    OCR1AL* = MappedIoRegister8(ioPtr8(0x88))
    OCR1AH* = MappedIoRegister8(ioPtr8(0x89))
    OCR1B*  = MappedIoRegister16(ioPtr16(0x8A))
    OCR1BL* = MappedIoRegister8(ioPtr8(0x8A))
    OCR1BH* = MappedIoRegister8(ioPtr8(0x8B))
    TCCR2A* = MappedIoRegister8(ioPtr8(0xB0))
    TCCR2B* = MappedIoRegister8(ioPtr8(0xB1))
    TCNT2*  = MappedIoRegister8(ioPtr8(0xB2))
    OCR2A*  = MappedIoRegister8(ioPtr8(0xB3))
    OCR2B*  = MappedIoRegister8(ioPtr8(0xB4))
    ASSR*   = MappedIoRegister8(ioPtr8(0xB6))
    TWBR*   = MappedIoRegister8(ioPtr8(0xB8))
    TWSR*   = MappedIoRegister8(ioPtr8(0xB9))
    TWAR*   = MappedIoRegister8(ioPtr8(0xBA))
    TWDR*   = MappedIoRegister8(ioPtr8(0xBB))
    TWCR*   = MappedIoRegister8(ioPtr8(0xBC))
    TWAMR*  = MappedIoRegister8(ioPtr8(0xBD))
    UCSR0A* = MappedIoRegister8(ioPtr8(0xC0))
    UCSR0B* = MappedIoRegister8(ioPtr8(0xC1))
    UCSR0C* = MappedIoRegister8(ioPtr8(0xC2))
    UBRR0*  = MappedIoRegister16(ioPtr16(0xC4))
    UBRR0L* = MappedIoRegister8(ioPtr8(0xC4))
    UBRR0H* = MappedIoRegister8(ioPtr8(0xC5))
    UDR0*   = MappedIoRegister8(ioPtr8(0xC6))
