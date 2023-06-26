import avr_io
import avr_io/interrupt

import counter

var 
  ctr = newCounter(250)

const 
  builtinLed = 5'u8

proc initTimer0() =
  # Timer0 in CTC mode, interrupt on compare match with OCR0A
  # Prescaling the clock of a factor of 256.
  # Considering:
  # f = 16 MHz; f_tim0 = f/256 = 16 MHz / 256 = 62,5 KHz
  # t_tim0 = 1/t_tim0 = 16 us;
  # t_int = t_tim0 * OCR0A = 16 us * 250 = 4 ms
  # This configuration raises an interrupt every 4 ms
  OCR0A[]  = 250
  TCCR0A.setBit(1)
  TCCR0B.setBit(2)
  TIMSK0.setBit(1)


proc timer0_compa_isr() {.isr(Timer0CompAVect).} =
  inc ctr

proc loop = 
  sei()
  initTimer0()
  portB.asOutputPin(builtinLed)
  
  while true:
    if ctr.checkThreshold():
      portB.togglePin(builtinLed)
      ctr.reset()

      
when isMainModule:
  loop()
