## A simple application initializing three timers in differentr modes, 
## showcasing some basic capabilities of the avr_io library timers on a 
## ATMega328P-based Arduino Uno.

import avr_io


const
  tim0Out = 6
  tim1Led = 5
  tim2Out = 3
  mcuFreq = 16_000_000'u32


proc initCompareMatchTimer0  =
  # Timer can be usedd
  const
    desFreq = 2_000_000'u32
    ocrVal = ((mcuFreq div (2 * desFreq)) - 1)
  portD.asOutputPin(tim0Out)
  timer0.setTimerFlag({coma0, wgm1})
  timer0.setTimerFlag({cs0})
  timer0.ocra[] = ocrVal.uint8


proc initCtcInterruptTimer1 =
  const
    tInterrupt = 4e-3 # ms
    pre = 256
    ocrval = ((mcuFreq div pre) div (1 / tInterrupt).uint32)
  portB.asOutputPin(tim1Led)
  timer1.setTimerFlag({TimCtlB16Flag.wgm2, cs2})
  timer1.setTimerFlag({Timsk16Flag.ociea})
  timer1.ocrah[] = (ocrval shr 8).uint8
  timer1.ocral[] = ocrval.uint8


proc initPwmTimer2 =
  const
    pwmPre  = 1'u32
    pwmFreq = 1_000_000'u32
    pwmDuty = 20'u32
  portD.asOutputPin(tim2Out)
  timer2.setTimerFlag({comb1, wgm1, wgm0})
  timer2.setTimerFlag({wgm2, cs0})
  timer2.actuatePwm(mcuFreq, pwmDuty, pwmFreq, pwmPre)


proc timer1CompaIsr() {.isr(Timer1CompAVect).} =
  portB.togglePin(tim1Led)


proc loop =
  sei()
  initCompareMatchTimer0()
  initCtcInterruptTimer1()
  initPwmTimer2()
  while true:
    discard


when isMainModule:
  loop()
