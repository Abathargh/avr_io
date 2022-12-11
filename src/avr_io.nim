import macros 

when defined(USING_ATMEGA328P):
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
