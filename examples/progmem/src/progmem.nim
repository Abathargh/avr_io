import avr_io
import avr_io/progmem
import avr_io/interrupt

import volatile

var read = false

progmem(testFloat, 11.23'f32)
progmem(testInt1,  12'u8)
progmem(testInt2,  13'u16)
progmem(testInt3,  14'u32)


type 
  foo = object
    f1: int
    f2: float32

  bar = object
    b1: bool 
    b2: string

progmem(testObj):
  bar(b1: true, b2: "test")

progmem(testStr):
  "ciao\n"

progmemArray(testArr):
  [99'u8, 105, 97, 111, 33, 10]


proc initTimer0() =
  OCR0A[]  = 250
  TCCR0A.setBit(1)
  TCCR0B.setBit(2)
  TIMSK0.setBit(1)

proc timer0_compa_isr() {.isr(Timer0CompAVect).} =
  volatileStore(addr read, true)

proc sendProgmemVar(usart: Usart) =
    for num in progmemIter(testArr):
      usart.sendByte(num)
    
    var dest: array[testStr.len, cchar]
    dest = testStr[]
    usart.sendBytes(dest)


proc loop =  
  sei()
  initTimer0()
  portB.asOutputPort()
  const baud = baudRate(9600'u32)
  usart0.initUart(baud, {}, {txen}, {ucsz1, ucsz0})
  
  while true:
    if volatileLoad(addr read):
      sendProgmemVar(usart0)
      volatileStore(addr read, false)
      
when isMainModule:
  loop()
