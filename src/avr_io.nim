## AVR register bindings and utilities written in nim.
## 
## In order to use this library, you should define a `USING_X` symbol, where 
## X is the capitalized name of the MCU you are targetting. Register 
## definitions are conditionally included (not imported) depending on this 
## symbol.
## 
## This is also valid for constants containing port and peripheral objects, 
## which can be optionally used to have a smoother user-experience.
## 
## This module also exports the following submodules:
## - `interrupt`, containing facilities to declare ISRs and use interrupts 
##   from user code.
## - `progmem`, containing a set of functionalities to store code in program 
##   memory and interact with it.
## - `system`, containing utilities to interact the system and binaries 
##   sections.
##
## Refer to the example applications contained within the `examples` directory 
## for specific use cases.


import avr_io/[interrupt, progmem, system]
export interrupt, progmem, system

when defined(USING_ATMEGA16U4):
  include avr_io/private/atmega16u4_32u4
elif defined(USING_ATMEGA32U4):
  include avr_io/private/atmega16u4_32u4
elif  defined(USING_ATMEGA328P):
  include avr_io/private/atmega328p
elif defined(USING_ATMEGA640):
  include avr_io/private/atmega64_128_256_01
elif defined(USING_ATMEGA1280):
  include avr_io/private/atmega64_128_256_01
elif defined(USING_ATMEGA1281): 
  include avr_io/private/atmega64_128_256_01
elif defined(USING_ATMEGA2560): 
  include avr_io/private/atmega64_128_256_01
elif defined(USING_ATMEGA2561):
  include avr_io/private/atmega64_128_256_01
elif defined(USING_ATMEGA644):
  include avr_io/private/atmega644
else:
  static:
    error "undefined architecture"
