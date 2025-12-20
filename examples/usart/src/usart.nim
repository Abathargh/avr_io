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
  const baud = baud_rate(9600'u32)

  # A number of usartN objects will be exposed by the library, depending on the 
  # number of usart peripherals on the chosen MCU. To initiaize the 
  # peripheral, just pass the required flags as flagsets for the three control 
  # registers to the `initUart` procedure.
  usart0.init_uart(baud, {}, {txen, rxen}, {ucsz1, ucsz0})
  portB.as_output_pin(builtinLed)
  
  var buf: array[100, cchar]
  while true:
    discard usart0.read_line(buf) # Read the data using `buf` as a buffer
    usart0.write_string_ln(buf)   # Send the 0-terminated string back
    portB.toggle_pin(builtinLed)   # Toggling the LED to have some feedback

when isMainModule:
  loop()
