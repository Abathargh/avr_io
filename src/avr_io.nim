import macros 

when defined(USING_ATMEGA328P):
  include avr_io/private/atmega328p
elif defined(USING_ATMEGA644):
  include avr_io/private/atmega644
else:
  static:
    error "undefined architecture"
