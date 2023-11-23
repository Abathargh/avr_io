## A simple application, implementing an echo server running on an 
## ATMega328P-based Arduino Uno, showcasing the 9-bit data Usart peripheral 
## functionalities in synchronous mode. 

import avr_io

const
  builtinLed = 5'u8

proc loop = 
  # The baud rate template allows for the end user to have a compile-time 
  # evaluated baud rate, compliant with the 16-bit value expected from the 
  # MCU. Use with `const`.
  const baud = baudRate(9600'u32) 

  # As for the 8-bit example, the ucsz2 bit can be sit directly here as a flag 
  # in a bitset, enabling 9-bit mode.
  usart0.initUart(baud, {}, {txen, rxen, ucsz2}, {ucsz1, ucsz0})
  portB.asOutputPin(builtinLed)
  
  while true:
    let n = usart0.readInt()     # Read up to 9-bit of data
    usart0.sendInt(n)            # And send it back
    portB.togglePin(builtinLed)  # Toggling the LED to have some feedback

when isMainModule:
  loop()
