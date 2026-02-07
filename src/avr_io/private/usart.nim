## The usart module provides a series of utilities to interface with the USART 
## peripherals on AVR chips.
## Warning: *Experimental API*.

when not declared(bitor):
  import bitops

when not declared(MappedIoRegister):
  import mapped_io

when not declared(round):
  import math

type
  BaseUsart* {.byref.} = object 
    ## The BaseUsart object models a USART interface, abstracting the 
    ## registers away.
    baudLo: MappedIoRegister[uint8]
    baudHi: MappedIoRegister[uint8]
    ctlA: MappedIoRegister[uint8]
    ctlB: MappedIoRegister[uint8]
    ctlC: MappedIoRegister[uint8]
    udr:  MappedIoRegister[uint8]
  
  UsartFlow* {.byref.} = object 
    ## The UsartFlow object models a USART interface, abstracting the 
    ## registers away.
    baudLo: MappedIoRegister[uint8]
    baudHi: MappedIoRegister[uint8]
    ctlA: MappedIoRegister[uint8]
    ctlB: MappedIoRegister[uint8]
    ctlC: MappedIoRegister[uint8]
    ctlD: MappedIoRegister[uint8]
    udr:  MappedIoRegister[uint8]

  Usart* = BaseUsart | UsartFlow

  CtlAFlag* = enum
    ## Valid flags for the 'A' control and status register of the USART 
    ## peripheral. Use as a bit field.
    mpcm
    u2x
    upe
    dor
    fe
    udre 
    txc
    rxc

  CtlAFlags* = set[CtlAFlag]

  CtlBFlag* = enum
    ## Valid flags for the 'B' control and status register of the USART 
    ## peripheral. Use as a bit field.
    txb8
    rxb8
    ucsz2
    txen
    rxen
    udrie
    txcie
    rxcie

  CtlBFlags* = set[CtlBFlag]

  CtlCFlag* = enum
    ## Valid flags for the 'C' control and status register of the USART 
    ## peripheral. Use as a bit field.
    ucpol
    ucsz0
    ucsz1
    usbs
    upm0
    upm1
    umsel0
    umsel1

  CtlCFlags* = set[CtlCFlag]

  CtlDFlag* = enum
    ## Valid flags for the 'D' control and status register of the USART 
    ## peripheral. Use as a bit field.
    rtsen
    ctsen

  CtlDFlags* = set[CtlDFlag]

  Flags = CtlAFlags | CtlBFlags | CtlCFlags | CtlDFlags

  UsartMode* = enum
    ## Usart operating mode, used to generate baud rates.
    AsyncNormal = 16
    AsyncDouble = 8
    SynchMaster = 2

template baudRate*(baud: typed, freq = 16000000'f, mode = AsyncNormal): uint16 =
  ## Generates the correct value to feed to the Usart initializers starting 
  ## from the baud rate. You can and should specify the frequency and the 
  ## mode of operation of your usart peripheral to get the exact baud rate 
  ## generated. Note that this defaults to a F_CPU = 16e6 in async normal mode.
  const factor = mode.ord
  const rate   = (freq / (factor * baud.float)).round - 1
  rate.uint16

template toBitMask*(f: Flags): uint8 =
  ## Converts a bit field containing flags to be used with a control 
  ## and status register to an 8-bit integer. 
  cast[uint8](f)


template toBitSet*[T: Flags](u: uint8): T =
  ## Converts an integer representing a control and status register 
  ## value to a bit field.
  cast[T](u)


proc initUart*(usart: Usart; baud: uint16; ctlA: CtlAFlags; ctlB: CtlBFlags; ctlC: CtlCFlags) =
  ## Initializes the Usart peripheral to be used with the specified flags and 
  ## baud rate. Use the `baudRate` template to generate a valid input for that 
  ## parameter.
  usart.baudHi[] = uint8(baud shr 8)
  usart.baudLo[] = uint8(baud)
  usart.ctlA[] = toBitMask(ctlA)
  usart.ctlB[] = toBitMask(ctlB)
  usart.ctlC[] = toBitMask(ctlC)


proc initUart*(usart: UsartFlow; baud: uint16; ctlA: CtlAFlags; ctlB: CtlBFlags; ctlC: CtlCFlags, ctlD: CtlDFlags) =
  ## Initializes the Usart peripheral to be used with the specified flags and 
  ## baud rate. Use the `baudRate` template to generate a valid input for that 
  ## parameter.
  usart.baudHi[] = uint8(baud shr 8)
  usart.baudLo[] = uint8(baud)
  usart.ctlA[] = toBitMask(ctlA)
  usart.ctlB[] = toBitMask(ctlB)
  usart.ctlC[] = toBitMask(ctlC)
  usart.ctlD[] = toBitMask(ctlD)


template setCtlFlags*(usart: Usart; flags: Flags) =
  ## Sets the passed flags of the specific Usart control register.
  when flags is CtlAFlags:
    usart.ctlA.setMask(toBitMask(flags))
  elif flags is CtlBFlags:
    usart.ctlB.setMask(toBitMask(flags))
  elif flags is CtlCFlags:
    usart.ctlC.setMask(toBitMask(flags))
  elif flags is CtlDFlags:
    usart.ctlD.setMask(toBitMask(flags))


template clearCtlFlags*(usart: Usart; flags: Flags) =
  ## Clears the passed flags of the specific Usart control register.
  when flags is CtlAFlags:
    usart.ctlA.clearMask(toBitMask(flags))
  elif flags is CtlBFlags:
    usart.ctlB.clearMask(toBitMask(flags))
  elif flags is CtlCFlags:
    usart.ctlC.clearMask(toBitMask(flags))
  elif flags is CtlDFlags:
    usart.ctlD.clearMask(toBitMask(flags))


type
  u8* = uint8 | char | cchar ## A valid nim or c-compatible \
    ## character type

  Iterable = concept
    iterator items(s: Self): u8


proc write*(usart: Usart; c: u8) =
  ## Sends a single byte via Usart.
  while udre notin toBitSet[CtlAFlags](usart.ctlA[]): discard
  usart.udr[] = uint8(c)


proc write*(usart: Usart; s: open_array[u8]) =
  ## Sends an array of bytes via Usart.
  for ch in s:
    usart.write(uint8(ch))


proc write*(usart: Usart; s: Iterable) =
  ## Sends data via Usart iterating over the collection.
  for ch in s.items:
    usart.write(ch)


proc write*(usart: Usart; s: string) =
  ## Sends a string via Usart.
  for ch in s:
    usart.write(uint8(ch))


proc write*(usart: Usart; s: cstring) =
  ## Sends a cstring via Usart.
  for ch in s:
    usart.write(uint8(ch))


proc write_line*(usart: Usart; s: open_array[char]) =
  ## Sends an array of bytes plus a newline character via Usart.
  for ch in s:
    usart.write(uint8(ch))
  usart.write('\n')


proc write_line*(usart: Usart; s: Iterable) =
  ## Sends data plus a newline character via Usart iterating over the 
  ## collection.
  for ch in s:
    usart.write(uint8(ch))
  usart.write('\n')


proc write_string*(usart: Usart; s: open_array[char]) =
  ## Sends a string-encoded array of bytes via Usart.
  for ch in s:
    if ch == '\0': break
    usart.write(uint8(ch))


proc write_string_ln*(usart: Usart; s: open_array[char]) =
  ## Sends a string-encoded array of bytes via Usart, adding a \n at the end.
  usart.write_string(s)
  usart.write('\n')


proc write_int*(usart: Usart, data: uint16) =
  ## Sends up-to-9 bits of data via Usart.
  while udre notin toBitSet[CtlAFlags](usart.ctlA[]): discard
  usart.ctlB.clearBit(txb8.ord)
  if bitand(data, 0x0100) != 0:
    usart.ctlB.setBit(txb8.ord)
  usart.udr[] = uint8(bitand(data, 0x00ff))


template read*(usart: Usart): uint8 =
  ## Reads a single byte via Usart.
  while rxc notin toBitSet[CtlAFlags](usart.ctlA[]): discard
  usart.udr[]


template read_isr*(usart: Usart): uint8 =
  ## Reads a single byte via Usart, can be called in an ISR.
  usart.udr[]


proc read_int*(usart: Usart): uint16 =
  ## Reads up-to-0 bits of data via Usart. Note that this will return a 9-bit 
  ## chunk of data encoded into a 16-bit unsigned integer. If an error raises 
  ## while communicating, the 10-th bit of thie returned integer will be set 
  ## to `1`.
  while rxc notin toBitSet[CtlAFlags](usart.ctlA[]): discard
  if {fe, dor, upe} <= toBitSet[CtlAFlags](usart.ctlA[]):
    return 1'u16 shl 10
  let msb = usart.ctlB.readBit(rxb8.ord)
  bitor(uint16(msb) shl 8, uint16(usart.udr[]))


proc read_line*[S: static int](usart: Usart; buf: var array[S, u8]): int =
  ## Reads bytes via Usart until a newline character (`\n`) is read. Returns 
  ## the number of read bytes.
  var c = 0
  var b = usart.read()
  while char(b) != '\n' and c < S-1: 
    buf[c] = cchar(b)
    b = usart.read()
    inc c
  buf[c] = '\0'
  c-1


proc read_bytes*[S: static int](usart: Usart; n: int; buf: var open_array[u8]): int =
  ## Reads `n` bytes via Usart, truncated to the lenght of the buffer.
  ## Returns the number of read bytes.
  var c = 0
  var b = usart.read()
  while c < n and c < S:
    buf[c] = cchar(b)
    b = usart.read()
    inc c
  c
