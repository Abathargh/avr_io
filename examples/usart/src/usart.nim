## A simple application, implementing an echo server running on an 
## ATMega328P-based Arduino Uno, showcasing the basic Usart peripheral 
## functionalities in synchronous mode. 

import avr_io

const
  builtinLed = 5'u8

proc loop = 
  # The baud rate template allows for the end user to have a compile-time 
  # evaluated baud rate, compliant with the 16-bit value expected from the 
  # MCU. Use with `const`.
  const baud = baudRate(9600'u32) 

  # A number of usartN objects will be exposed by the library, depending on the 
  # number of usart peripherals on the chosen MCU. To initiaize the 
  # peripheral, just pass the required flags as flagsets for the three control 
  # registers to the `initUart` procedure.
  usart0.initUart(baud, {}, {txen, rxen}, {ucsz1, ucsz0})
  portB.asOutputPin(builtinLed)
  
  var buf: array[100, cchar]
  while true:
    discard usart0.readLine(buf) # Read the data using `buf` as a buffer
    usart0.sendString(buf)       # Send the 0-terminated string back
    usart0.sendByte('\n')        # Let us use `\n` as a terminator 
    portB.togglePin(builtinLed)  # Toggling the LED to have some feedback

when isMainModule:
  loop()
