## A simple application running on an ATMega328P-based Arduino Uno using data 
## the baisc Usart peripheral functionalities in synchronous mode. 

import avr_io

const
  builtinLed = 5'u8

proc loop = 
  const baud = baudRate(9600'u32) 
  usart0.initUart(baud, {}, {txen, rxen}, {ucsz1, ucsz0})
  portB.asOutputPin(builtinLed)
  
  var buf: array[100, cchar]
  while true:
    discard usart0.readLine(buf)
    usart0.sendString(buf)
    usart0.sendByte('\n')
    portB.togglePin(builtinLed)

when isMainModule:
  loop()