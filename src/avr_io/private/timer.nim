## The timer module provides a series of utilities to interface with the timer
## peripherals on AVR chips.

import mapped_io


type
  Timer8BitPwm* {.byref.} = object
    ## The Timer8BitPwm object models a timer interface for 8-bit timers, with 
    ## PWM support. 8-bit timers have 8-bit counter capabilities.
    tccra*: MappedIoRegister[uint8]
    tccrb*: MappedIoRegister[uint8]
    tcnt*:  MappedIoRegister[uint8]
    ocra*:  MappedIoRegister[uint8]
    ocrb*:  MappedIoRegister[uint8]
    timsk*: MappedIoRegister[uint8]
    tifr*:  MappedIoRegister[uint8]

  Timer16BitPwm* {.byref.} = object
    ## The Timer16BitPwm object models a timer interface for 16-bit timers, 
    ## with PWM support. 16-bit timers have 16-bit counter capabilities.
    tccra*: MappedIoRegister[uint8]
    tccrb*: MappedIoRegister[uint8]
    tccrc*: MappedIoRegister[uint8]
    tcnt*:  MappedIoRegister[uint16]
    tcnth*: MappedIoRegister[uint8]
    tcntl*: MappedIoRegister[uint8]
    ocra* : MappedIoRegister[uint16]
    ocrah*: MappedIoRegister[uint8]
    ocral*: MappedIoRegister[uint8]
    ocrb* : MappedIoRegister[uint16]
    ocrbh*: MappedIoRegister[uint8]
    ocrbl*: MappedIoRegister[uint8]
    icr* : MappedIoRegister[uint16]
    icrh*:  MappedIoRegister[uint8]
    icrl*:  MappedIoRegister[uint8]
    timsk*: MappedIoRegister[uint8]
    tifr*:  MappedIoRegister[uint8]

  Timer16Bit3ComparePwm* {.byref.} = object
    ## The Timer16BitPwm object models a timer interface for 16-bit timers, 
    ## with PWM support. 16-bit timers have 16-bit counter capabilities.
    tccra*: MappedIoRegister[uint8]
    tccrb*: MappedIoRegister[uint8]
    tccrc*: MappedIoRegister[uint8]
    tcnt*:  MappedIoRegister[uint16]
    tcnth*: MappedIoRegister[uint8]
    tcntl*: MappedIoRegister[uint8]
    ocra* : MappedIoRegister[uint16]
    ocrah*: MappedIoRegister[uint8]
    ocral*: MappedIoRegister[uint8]
    ocrb* : MappedIoRegister[uint16]
    ocrbh*: MappedIoRegister[uint8]
    ocrbl*: MappedIoRegister[uint8]
    icr* : MappedIoRegister[uint16]
    icrh*:  MappedIoRegister[uint8]
    icrl*:  MappedIoRegister[uint8]
    timsk*: MappedIoRegister[uint8]
    tifr*:  MappedIoRegister[uint8]
    gtccr*: MappedIoRegister[uint8]

  Timer8BitPwmAsync* {.byref.} = object
    ## The Timer8BitPwmAsync object models a timer interface for 8-bit timers, 
    ## with PWM and async support. 8-bit timers have 8-bit counter 
    ## capabilities.
    tccra*: MappedIoRegister[uint8]
    tccrb*: MappedIoRegister[uint8]
    tcnt*:  MappedIoRegister[uint8]
    ocra*:  MappedIoRegister[uint8]
    ocrb*:  MappedIoRegister[uint8]
    assr*:  MappedIoRegister[uint8]
    timsk*: MappedIoRegister[uint8]
    tifr*:  MappedIoRegister[uint8]
    gtccr*: MappedIoRegister[uint8]

  Timer10bitHiSpeed* {.byref.} = object
    ## The Timer10bitHiSpeed object models a timer interface for high speed, 
    ## 10-bit timers, with PWM support.
    tccra*: MappedIoRegister[uint8]
    tccrb*: MappedIoRegister[uint8]
    tccrc*: MappedIoRegister[uint8]
    tccrd*: MappedIoRegister[uint8]
    tccre*: MappedIoRegister[uint8]
    tcnt*:  MappedIoRegister[uint8]
    tch*:   MappedIoRegister[uint8]
    ocra*:  MappedIoRegister[uint8]
    ocrb*:  MappedIoRegister[uint8]
    ocrc*:  MappedIoRegister[uint8]
    ocrd*:  MappedIoRegister[uint8]
    timsk*: MappedIoRegister[uint8]
    tifr*:  MappedIoRegister[uint8]
    dt*:    MappedIoRegister[uint8]


  Timer* = Timer8BitPwm | Timer16BitPwm | Timer16Bit3ComparePwm | 
    Timer8BitPwmAsync | Timer10bitHiSpeed

  TimCtlAFlag* = enum
    ## Valid flags for the 'A' control register of the timer peripheral. Use 
    ## as a bit field.
    wgm0
    wgm1
    reserved1
    reserved2
    comb0
    comb1
    coma0
    coma1

  TimCtlAFlags* = set[TimCtlAFlag]

  TimCtlA3CompFlag* = enum
    ## Valid flags for the 'A' control register of the 16-bit timer peripheral 
    ## with 3 independent output compare units. Use as a bit field.
    wgm0
    wgm1
    comc0
    comc1
    comb0
    comb1
    coma0
    coma1

  TimCtlA3CompFlags* = set[TimCtlA3CompFlag]

  TimCtlA10Flag* = enum
    ## Valid flags for the 'A' control register of the high speed 10-bit timer 
    ## peripheral.
    pwmb
    pwma
    focb
    foca
    comb0
    comb1
    coma0
    coma1

  TimCtlA10Flags* = set[TimCtlA10Flag]

  TimCtlBFlag* = enum
    ## Valid flags for the 'B' control register of the timer peripheral. Use 
    ## as a bit field.
    cs0
    cs1
    cs2
    wgm2
    reserved1
    reserved2
    focb
    foca

  TimCtlBFlags* = set[TimCtlBFlag]

  TimCtlB16Flag* = enum
    ## Valid flags for the 'B' control register of the 16-bit timer peripheral. 
    ## Use as a bit field.
    cs0
    cs1
    cs2
    wgm2
    wgm3
    reserved1
    ices
    icnc

  TimCtlB16Flags* = set[TimCtlB16Flag]

  TimCtlB10Flag* = enum
    ## Valid flags for the 'B' control register of the high speed 10-bit timer 
    ## peripheral.
    cs0
    cs1
    cs2
    cs3
    dtps0
    dtps01
    psr
    pwmx

  TimCtlB10Flags* = set[TimCtlB10Flag]

  TimCtlCFlag* = enum
      ## Valid flags for the 'C' control register of the timer peripheral. Use 
    ## as a bit field.
    reserved1
    reserved2
    reserved3
    reserved4
    reserved5
    reserved6
    focb
    foca

  TimCtlCFlags* = set[TimCtlCFlag]

  TimCtlC3CompFlag* = enum
      ## Valid flags for the 'C' control register of the timer peripheral. Use 
    ## as a bit field.
    reserved1
    reserved2
    reserved3
    reserved4
    reserved5
    focc
    focb
    foca

  TimCtlC3CompFlags* = set[TimCtlC3CompFlag]

  TimCtlC10Flag* = enum
    ## Valid flags for the 'C' control register of the high speed 10-bit timer 
    ## peripheral.
    pwmd
    focd
    comd0
    comd1
    comb0s
    comb1s
    coma0s
    coma1s

  TimCtlC10Flags* = set[TimCtlC10Flag]

  TimCtlD10Flag* = enum
    ## Valid flags for the 'D' control register of the high speed 10-bit timer 
    ## peripheral.
    wgm0
    wgm1
    fpf
    fpac
    fpes
    fpnc
    fpen
    fpie

  TimCtlD10Flags* = set[TimCtlD10Flag]

  TimCtlE10Flag* = enum
    ## Valid flags for the 'E' control register of the high speed 10-bit timer 
    ## peripheral.
    ocoe0
    ocoe1
    ocoe2
    ocoe3
    ocoe4
    ocoe5
    enhc4
    tlock

  TimCtlE10Flags* = set[TimCtlE10Flag]

  TimskFlag* = enum
    ## Valid flags for interrupt mask register of the timer peripheral. Use as 
    ## a bit field.
    toie
    ociea
    ocieb
    reserved1
    reserved2
    reserved3
    reserved4
    reserved5

  TimskFlags* = set[TimskFlag]


  Timsk16Flag* = enum
    ## Valid flags for the interrupt mask register of the 16-bit timer 
    ## peripheral. Use as a bit field.
    toie
    ociea
    ocieb
    reserved1
    reserved2
    icie
    reserved3
    reserved4

  Timsk16Flags* = set[Timsk16Flag]

  Timsk3CompFlag* = enum
    ## Valid flags for the interrupt mask register of the 16-bit timer 
    ## peripheral with 3 independent output compare units. Use as a bit field.
    toie
    ociea
    ocieb
    ociec
    reserved1
    icie
    reserved2
    reserved3

  Timsk3CompFlags* = set[Timsk3CompFlag]

  Timsk10Flag* = enum
    ## Valid flags for the interrupt mask register of the high speed 10-bit 
    ## timer peripheral. Use as a bit field.
    reserved1
    reserved2
    toie
    reserved3
    reserved4
    ocieb
    ociea
    ocied


  Timsk10Flags* = set[Timsk10Flag]

  TifrFlag* = enum
    ## Valid flags for the interrupt flag register of the timer peripheral. 
    ## Use as a bit field.
    tov
    ocfa
    ocfb
    reserved1
    reserved2
    reserved3
    reserved4
    reserved5

  TifrFlags* = set[TifrFlag]

  Tifr16Flag* = enum
    ## Valid flags for the interrupt flag register of the 16-bit timer 
    ## peripheral. Use as a bit field.
    tov
    ocfa
    ocfb
    reserved1
    reserved2
    icf
    reserved3
    reserved4

  Tifr16Flags* = set[Tifr16Flag]

  Tifr3CompFlag* = enum
    ## Valid flags for the interrupt flag register of the 16-bit timer 
    ## peripheral with 3 independent output compare units. Use as a bit field.
    tov
    ocfa
    ocfb
    ocfc
    reserved1
    icf
    reserved2
    reserved3

  Tifr3CompFlags* = set[Tifr3CompFlag]

  Tifr10Flag* = enum
    ## Valid flags for the interrupt flag register of the high speed 10-bit 
    ## timer peripheral. Use as a bit field.
    reserved1
    reserved2
    tov
    reserved3
    reserved4
    ocfb
    ocfa
    ocfd

  Tifr10Flags* = set[Tifr10Flag]

  AssrFlag* = enum
    ## Valid flags for the asynchronous status register of the timer 
    ## peripheral. Use as a bit field.
    tcrbub
    tcraub
    ocrbub
    ocraub
    tcnub
    as_flag
    exclk
    reserved1

  AssrFlags* = set[AssrFlag]

  GtccrFlag* = enum
    ## Valid flags for the the general timer/counter control register of 
    ## the timer peripheral. Use as a bit field.
    psrsync
    psrasy
    reserved1
    reserved2
    reserved3
    reserved4
    reserved5
    tsm

  GtccrFlags* = set[GtccrFlag]

  T8PwmFlags* = TimCtlAFlags | TimCtlBFlags | TimskFlags | TifrFlags
  
  T16PwmFlags* = TimCtlAFlags | TimCtlB16Flags | Timsk16Flags | Tifr16Flags
  
  T8PwmAsyncFlags* = TimCtlAFlags | TimCtlBFlags | TimskFlags | TifrFlags |
    AssrFlags | GtccrFlags
  
  T10Flags* = TimCtlA10Flags | TimCtlB10Flags | TimCtlC10Flags | 
    TimCtlD10Flags | TimCtlE10Flags | Timsk10Flags | Tifr10Flags

  T163ChanFlags* = TimCtlA3CompFlags | TimCtlBFlags | TimCtlC3CompFlags | 
    Timsk3CompFlags | Tifr3CompFlags | GtccrFlags


template toBitMask*(f: typed): uint8 =
  ## Converts a bit field containing flags to be used with a control 
  ## and status register to an 8-bit integer. 
  cast[uint8](f)


template setTimerFlag*(timer: Timer8BitPwm; flags: T8PwmFlags) =
  ## Sets the passed flags of the specific timer register for 8-bit PWM timers.
  when flags is TimCtlAFlags:
    timer.tccra.setMask(toBitMask(flags))
  elif flags is TimCtlBFlags:
    timer.tccrb.setMask(toBitMask(flags))
  elif flags is TimskFlags:
    timer.timsk.setMask(toBitMask(flags))
  elif flags is TifrFlags:
    timer.tifr.setMask(toBitMask(flags))


template setTimerFlag*(timer: Timer16BitPwm; flags: T16PwmFlags) =
  ## Sets the passed flags of the specific timer register for 16-bit PWM 
  ## timers.
  when flags is TimCtlAFlags:
    timer.tccra.setMask(toBitMask(flags))
  elif flags is TimCtlB16Flags:
    timer.tccrb.setMask(toBitMask(flags))
  elif flags is TimCtlCFlags:
    timer.tccrc.setMask(toBitMask(flags))
  elif flags is Timsk16Flags:
    timer.timsk.setMask(toBitMask(flags))
  elif flags is Tifr16Flags:
    timer.tifr.setMask(toBitMask(flags))


template setTimerFlag*(timer: Timer16Bit3ComparePwm; flags: T163ChanFlags) =
  ## Sets the passed flags of the specific timer register for 16-bit PWM timers 
  ## with 3 output channels.
  when flags is TimCtlAFlags:
    timer.tccra.setMask(toBitMask(flags))
  elif flags is TimCtlBFlags:
    timer.tccrb.setMask(toBitMask(flags))
  elif flags is TimCtlCFlags:
    timer.tccrc.setMask(toBitMask(flags))
  elif flags is TimskFlags:
    timer.timsk.setMask(toBitMask(flags))
  elif flags is TifrFlags:
    timer.tifr.setMask(toBitMask(flags))
  elif flags is GtccrFlags:
    timer.gtccr.setMask(toBitMask(flags))


template setTimerFlag*(timer: Timer8BitPwmAsync; flags: T8PwmAsyncFlags) =
  ## Sets the passed flags of the specific timer register for 8-bit PWM timers 
  ## with async support.
  when flags is TimCtlAFlags:
    timer.tccra.setMask(toBitMask(flags))
  elif flags is TimCtlBFlags:
    timer.tccrb.setMask(toBitMask(flags))
  elif flags is AssrFlags:
    timer.assr.setMask(toBitMask(flags))
  elif flags is TimskFlags:
    timer.timsk.setMask(toBitMask(flags))
  elif flags is TifrFlags:
    timer.tifr.setMask(toBitMask(flags))
  elif flags is GtccrFlags:
    timer.gtccr.setMask(toBitMask(flags))


template setTimerFlag*(timer: Timer10bitHiSpeed; flags: T10Flags) =
  ## Sets the passed flags of the specific timer register for 10-bit high 
  ## speed  timers.
  when flags is TimCtlA10Flags:
    timer.tccra.setMask(toBitMask(flags))
  elif flags is TimCtlB10Flags:
    timer.tccrb.setMask(toBitMask(flags))
  elif flags is TimCtlC10Flags:
    timer.tccrc.setMask(toBitMask(flags))
  elif flags is TimCtlD10Flags:
    timer.tccrd.setMask(toBitMask(flags))
  elif flags is TimCtlE10Flags:
    timer.tccre.setMask(toBitMask(flags))
  elif flags is Timsk10Flags:
    timer.timsk.setMask(toBitMask(flags))
  elif flags is Tifr10Flags:
    timer.tifr.setMask(toBitMask(flags))


template clearTimerFlag*(timer: Timer8BitPwm; flags: T8PwmFlags) =
  ## Clears the passed flags of the specific timer register for 8-bit PWM 
  ## timers.
  when flags is TimCtlAFlags:
    timer.tccra.clearMask(toBitMask(flags))
  elif flags is TimCtlBFlags:
    timer.tccrb.clearMask(toBitMask(flags))
  elif flags is TimskFlags:
    timer.timsk.clearMask(toBitMask(flags))
  elif flags is TifrFlags:
    timer.tifr.clearMask(toBitMask(flags))


template clearTimerFlag*(timer: Timer16BitPwm; flags: T16PwmFlags) =
  ## Clears the passed flags of the specific timer register for 16-bit PWM 
  ## timers.
  when flags is TimCtlAFlags:
    timer.tccra.clearMask(toBitMask(flags))
  elif flags is TimCtlB16Flags:
    timer.tccrb.clearMask(toBitMask(flags))
  elif flags is TimCtlCFlags:
    timer.tccrc.clearMask(toBitMask(flags))
  elif flags is Timsk16Flags:
    timer.timsk.clearMask(toBitMask(flags))
  elif flags is Tifr16Flags:
    timer.tifr.clearMask(toBitMask(flags))


template clearTimerFlag*(timer: Timer8BitPwmAsync; flags: T8PwmAsyncFlags) =
  ## Clears the passed flags of the specific timer register for 8-bit PWM 
  ## timers with async support.
  when flags is TimCtlAFlags:
    timer.tccra.clearMask(toBitMask(flags))
  elif flags is TimCtlBFlags:
    timer.tccrb.clearMask(toBitMask(flags))
  elif flags is AssrFlags:
    timer.assr.clearMask(toBitMask(flags))
  elif flags is TimskFlags:
    timer.timsk.clearMask(toBitMask(flags))
  elif flags is TifrFlags:
    timer.tifr.clearMask(toBitMask(flags))
  elif flags is GtccrFlags:
    timer.gtccr.clearMask(toBitMask(flags))


template clearTimerFlag*(timer: Timer10bitHiSpeed; flags: T10Flags) =
  ## Sets the passed flags of the specific timer register for 10-bit high 
  ## speed  timers.
  when flags is TimCtlA10Flags:
    timer.tccra.clearMask(toBitMask(flags))
  elif flags is TimCtlB10Flags:
    timer.tccrb.clearMask(toBitMask(flags))
  elif flags is TimCtlC10Flags:
    timer.tccrc.clearMask(toBitMask(flags))
  elif flags is TimCtlD10Flags:
    timer.tccrd.clearMask(toBitMask(flags))
  elif flags is TimCtlE10Flags:
    timer.tccre.clearMask(toBitMask(flags))
  elif flags is Timsk10Flags:
    timer.timsk.clearMask(toBitMask(flags))
  elif flags is Tifr10Flags:
    timer.tifr.clearMask(toBitMask(flags))


template actuatePwm*(timer: Timer; freq, pwmDuty, pwmFreq, prescaler: uint32) =
  ## Actuates a PWM with the spcific frequency and duty cycle passed. 
  ## Note that this uses both output compare registers for the timer in use, 
  ## and that the duty cycle resolution is less the higher the frequency is.
  const f  = (freq div (prescaler * pwmFreq) - 1)
  const dt = ((pwmDuty * f) div 100)
  when timer is Timer8BitPwm or timer is Timer8BitPwmAsync:
    timer.ocra[] = f.uint8
    timer.ocrb[] = dt.uint8
  else:
    timer.ocrah[] = (f.uint16 shr 8).uint8
    timer.ocral[] = f.uint8
    timer.ocrbh[] = (dt.uint16 shr 8).uint8
    timer.ocrbl[] = dt.uint8
