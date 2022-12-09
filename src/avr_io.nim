import macros 

when defined(USING_ATMEGA644):
  include avr_io/private/atmega644
else:
  static:
    error "undefined architecture"
