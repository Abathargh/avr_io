## The timer module provides a series of utilities to interface with the timer
## peripherals on AVR chips.

import mapped_io
import macros


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
    tcnth*: MappedIoRegister[uint8]
    tcntl*: MappedIoRegister[uint8]
    ocrah*: MappedIoRegister[uint8]
    ocral*: MappedIoRegister[uint8]
    ocrbh*: MappedIoRegister[uint8]
    ocrbl*: MappedIoRegister[uint8]
    icrh*: MappedIoRegister[uint8]
    icrl*: MappedIoRegister[uint8]
    timsk*: MappedIoRegister[uint8]
    tifr*: MappedIoRegister[uint8]

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
    gtccr*:  MappedIoRegister[uint8]

  Timer* = Timer8BitPwm | Timer16BitPwm | Timer8BitPwmAsync

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

  TimskFlag* = enum
    ## Valid flags register of the timer peripheral. Use 
    ## as a bit field. 
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
    toie
    ociea
    ocieb
    reserved1
    reserved2
    icie
    reserved3
    reserved4

  Timsk16Flags* = set[Timsk16Flag]

  TifrFlag* = enum
    toie
    ociea
    ocieb
    reserved1
    reserved2
    reserved3
    reserved4
    reserved5

  TifrFlags* = set[TifrFlag]

  Tifr16Flag* = enum
    toie
    ociea
    ocieb
    reserved1
    reserved2
    icf
    reserved3
    reserved4

  Tifr16Flags* = set[Tifr16Flag]

  AssrFlag* = enum
    tcrbub
    tcraub
    ocrbub
    ocraub
    tcnuub
    as_flag
    exclk
    reserved1

  AssrFlags* = set[AssrFlag]

  GtccrFlag* = enum
    psrsync
    psrasy
    reserved1
    reserved2
    reserved3
    reserved4
    reserved5
    tsm

  GtccrFlags* = set[GtccrFlag]

  TFlags* = TimCtlAFlags | TimCtlBFlags | TimCtlB16Flags | TimCtlCFlags | 
    TimskFlags | Timsk16Flags | TifrFlags | Tifr16Flags | AssrFlag | GtccrFlag


template toBitMask*(f: TFlags): uint8 =
  ## Converts a bit field containing flags to be used with a control 
  ## and status register to an 8-bit integer. 
  cast[uint8](f)


template setTimerFlag*(timer: Timer8BitPwm; flags: TFlags) =
  when flags is TimCtlAFlags:
    timer.tccra.setMask(toBitMask(flags))
  elif flags is TimCtlBFlags:
    timer.tccrb.setMask(toBitMask(flags))
  elif flags is TimskFlags:
    timer.timsk.setMask(toBitMask(flags))
  elif flags is TifrFlags:
    timer.tifr.setMask(toBitMask(flags))
  else:
    static: error "unsupported flagset for the passed timer"


template setTimerFlag*(timer: Timer16BitPwm; flags: TFlags) =
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
  else:
    static: error "unsupported flagset for the passed timer"


template setTimerFlag*(timer: Timer8BitPwmAsync; flags: TFlags) =
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
  else:
    static: error "unsupported flagset for the passed timer"


template clearTimerFlag*(timer: Timer8BitPwm; flags: TFlags) =
  when flags is TimCtlAFlags:
    timer.tccra.clearMask(toBitMask(flags))
  elif flags is TimCtlBFlags:
    timer.tccrb.clearMask(toBitMask(flags))
  elif flags is TimskFlags:
    timer.timsk.clearMask(toBitMask(flags))
  elif flags is TifrFlags:
    timer.tifr.clearMask(toBitMask(flags))
  else:
    static: error "unsupported flagset for the passed timer"


template clearTimerFlag*(timer: Timer16BitPwm; flags: TFlags) =
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
  else:
    static: error "unsupported flagset for the passed timer"


template clearTimerFlag*(timer: Timer8BitPwmAsync; flags: TFlags) =
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
  else:
    static: error "unsupported flagset for the passed timer"


template actuatePwm*(timer: Timer; freq, pwmDuty, pwmFreq, prescaler: uint32) =
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
