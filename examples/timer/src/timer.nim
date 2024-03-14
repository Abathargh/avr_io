## A simple application initializing three timers in differentr modes, 
## showcasing some basic capabilities of the avr_io library timers on a 
## ATMega328P-based Arduino Uno.

import avr_io


const
  tim0Out = 6           # POTD[6]  - Pin 6
  tim1Led = 5           # PORTB[5] - Pin 13 (Builtin LED)
  tim2Out = 3           # PORTD[3] - Pin 3
  mcuFreq = 16e6.uint32 # The arduino clock frequency, 16MHz


proc initCompareMatchTimer0  =
  ## This uses timer0 in Clear Time on Compare mode (CTC), toggling OC0A on 
  ## compare match with no prescaling. Note that we can compute the waveform 
  ## to have a desired frequency with the following formula:
  ## 
  ##    f_desired = 2MHz
  ##    T_desired = 0.5us
  ##    T_half    = T_desired/2 = 0.25 us
  ##    OCRA = T_half/T_clk - 1 = (0.25 us / 0.0625 us) - 1 = 3
  const
    desFreq = 2e6.uint32 # The generated wave will have a frequency of 2MHz
    ocrVal = ((mcuFreq div (2 * desFreq)) - 1) # As per the description above
  portD.asOutputPin(tim0Out)
  timer0.setTimerFlag({coma0, wgm1})
  timer0.setTimerFlag({TimCtlBFlag.cs0})
  timer0.ocra[] = ocrVal.uint8


proc initCtcInterruptTimer1 =
  ## This configuration generates an interrupt every 4ms, using a prescaler 
  ## value of 256, using a timer in CTC mode.
  const
    tInterrupt = 4e-3 # T = 4ms => f = 2MHz
    pre = 256
    ocrval = ((mcuFreq div pre) div (1 / tInterrupt).uint32).uint16
  portB.asOutputPin(tim1Led)
  timer1.setTimerFlag({TimCtlB16Flag.wgm2, cs2})
  timer1.setTimerFlag({Timsk16Flag.ociea})
  timer1.ocra[] = ocrval


proc initPwmTimer2 =
  ## This uses timer2 in Fast PWM mode with output on OC0B in non-inverting 
  ## mode. The specific configuration used here allows for a PWM frequency to 
  ## be controlled through OCRA, while its duty cycle is controller through 
  ## OCRB.
  const
    pwmPre  = 1'u32      # No prescaler in use
    pwmFreq = 1e6.uint32 # PWM frequency is 1MHz
    pwmDuty = 20'u32     # PWM duty cycle is 20%
  portD.asOutputPin(tim2Out)
  timer2.setTimerFlag({TimCtlAFlag.comb1, wgm1, wgm0})
  timer2.setTimerFlag({TimCtlBFlag.wgm2, cs0})
  timer2.actuatePwm(mcuFreq, pwmDuty, pwmFreq, pwmPre)


proc timer1CompaIsr() {.isr(Timer1CompAVect).} =
  ## This proc right here implements the ISR for the Timer1 interrupt handling.
  portB.togglePin(tim1Led)


proc loop =
  # Let us enable the interrupts and initialize all the timers.
  sei()
  initCompareMatchTimer0()
  initCtcInterruptTimer1()
  initPwmTimer2()
  while true:
    discard


when isMainModule:
  loop()
