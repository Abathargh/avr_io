import avr_io
import volatile


const
  # Our timer resolution
  timerRes = 8'u8 # ms

var
  # Just used for counting in our delay routines.
  elapsed = 0'u8


proc timer0Handler() {.isr(Timer0CompAVect).} =
  # This simply adds 1 to our volatile global counter.
  volatileStore(addr elapsed, volatileLoad(addr elapsed) + 1)


proc initDelayTimer*() =
  # Same as in the arduino_uno_blink example. This time the clock frequency 
  # is 8MHz, so by keeping the same configuration, we trigger an interrupt 
  # every 8ms:
  #  (T_isr = (1/(f_cpu/prescaling)) * OCR0A) = 1/(8MHz/256) * 250 = 8 ms.
  OCR0A[]  = 250
  TCCR0A.setBit(1)
  TCCR0B.setBit(2)
  TIMSK0.setBit(1)


template delayMs*(t: static[int]) =
  # This is a generic, interrupt-driven delay. We poll a global variable 
  # until its value hits a certain treshold, which is scaled by the interrupt 
  # frequency for our chosen timer.
  const thresh = t div timerRes
  sei()
  while volatileLoad(addr elapsed) < thresh: 
    discard
  cli()
  volatileStore(addr elapsed, 0)
