import avr_io
import avr_io/progmem
import avr_io/interrupt

import volatile

var read = false

progmem(testStr):
  "ciao\n"

progmem(testInt1, 12'u8)
progmem(testInt2, 13'u16)
progmem(testInt3, 14'u32)

proc initTimer0() =
  OCR0A[]  = 250
  TCCR0A.setBit(1)
  TCCR0B.setBit(2)
  TIMSK0.setBit(1)

proc timer0_compa_isr() {.isr(Timer0CompAVect).} =
  volatileStore(addr read, true)

proc loop =
  sei()
  initTimer0()
  portB.asOutputPort()
  usart0.initUart(baudRate(9600), {}, {txen}, {ucsz1, ucsz0})
  
  while true:
    if volatileLoad(addr read):
      usart0.sendBytes(testStr[])
      volatileStore(addr read, false)
      
when isMainModule:
  loop()
