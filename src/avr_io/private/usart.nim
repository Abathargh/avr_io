## The usart module provides a series of utilities to interface with the USART 
## peripherals on AVR chips.

import mapped_io
import bitops

type
  Usart* {.byref.} = object
    ## The Usart object models a USART interface, 
    ## abstracting the registers away  
    baudLo: MappedIoRegister[uint8]
    baudHi: MappedIoRegister[uint8]
    ctlA: MappedIoRegister[uint8]
    ctlB: MappedIoRegister[uint8]
    ctlC: MappedIoRegister[uint8]
    udr:  MappedIoRegister[uint8]

  CtlAFlag* = enum
    ## Valid flags for the 'A' control and status register 
    ## of the USART peripheral. Use as a bit field. 
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
    ## Valid flags for the 'B' control and status register 
    ## of the USART peripheral. Use as a bit field.
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
    ## Valid flags for the 'C' control and status register 
    ## of the USART peripheral. Use as a bit field.
    ucpol
    ucsz0
    ucsz1
    usbs
    upm0
    upm1
    umsel0
    umsel1

  CtlCFlags* = set[CtlCFlag]

  Flags = CtlAFlags | CtlBFlags | CtlCFlags


template baudRate*(baud: uint32, freq: uint32 = 16000000'u32): uint16 =
  ## Generates the correct value to feed to the Usart initializers
  ## starting from the baud rate.
  uint16(freq div (16 * baud)) - 1


template toBitMask*(f: Flags): uint8 =
  ## Converts a bit field containing flags to be used with a control 
  ## and status register to an 8-bit integer. 
  cast[uint8](f)


template toBitSet*[T: Flags](u: uint8): T =
  ## Converts an integer representing a control and status register 
  ## value to a bit field.
  cast[T](u)


type character* = uint8 | char | cchar ## A valid nim or c-compatible \
  ## character type


proc initUart*(usart: Usart; baud: uint16; ctlA: CtlAFlags; ctlB: CtlBFlags; ctlC: CtlCFlags) =
  ## Initializes the Usart peripheral to be used with the specified flags and 
  ## baud rate. Use the `baudRate` template to generate a valid input for that 
  ## parameter.
  usart.baudHi[] = uint8(baud shr 8)
  usart.baudLo[] = uint8(baud)
  usart.ctlA[] = toBitMask(ctlA)
  usart.ctlB[] = toBitMask(ctlB)
  usart.ctlC[] = toBitMask(ctlC)


proc setCtlFlags*(usart: Usart; flags: Flags) =
  ## Sets the passed flags of the specific Usart control register.  
  when flags is CtlAFlags:
    usart.ctlA.setMask(toBitMask(flags))
  elif flags is CtlBFlags:
    usart.ctlB.setMask(toBitMask(flags))
  elif flags is CtlCFlags:
    usart.ctlC.setMask(toBitMask(flags))


proc clearCtlFlags*(usart: Usart; flags: Flags) =
  ## Clears the passed flags of the specific Usart control register.  
  when flags is CtlAFlags:
    usart.ctlA.clearMask(toBitMask(flags))
  elif flags is CtlBFlags:
    usart.ctlB.clearMask(toBitMask(flags))
  elif flags is CtlCFlags:
    usart.ctlC.clearMask(toBitMask(flags))


template sendByte*(usart: Usart; c: character) =
  ## Sends a single byte via Usart.
  while udre notin toBitSet[CtlAFlags](usart.ctlA[]): discard
  usart.udr[] = uint8(c)


proc sendBytes*(usart: Usart; s: openArray[character]) =
  ## Sends an array of bytes via Usart.
  for ch in s:
    usart.sendByte(ch)


proc sendString*(usart: Usart; s: cstring|string) =
  ## Sends a string via Usart.
  for ch in s:
    usart.sendByte(uint8(ch))


proc sendString*[S](usart: Usart; s: array[S, character]) = 
  ## Sends a string-encoded array of bytes via Usart.
  for ch in s:
    if ch == '\0':
      break
    usart.sendByte(uint8(ch))


proc sendInt*(usart: Usart, data: uint16) =
  ## Sends up-to-9 bits of data via Usart.
  usart.ctlB.clearBit(txb8.ord)
  if bitand(data, 0x0100) != 0:
    usart.ctlB.setBit(txb8.ord)

  while udre notin toBitSet[CtlAFlags](usart.ctlA[]): discard
  usart.udr[] = uint8(bitand(data, 0x00ff))


template readByte*(usart: Usart): uint8 =
  while rxc notin toBitSet[CtlAFlags](usart.ctlA[]): discard
  usart.udr[]


template readInt*(usart: Usart): uint16 =
  while rxc notin toBiteSet[CtlAFlags](usart.ctlA[]): discard
  discard


proc readLine*[S: static[int]](usart: Usart; buf: var array[S, character]): int =
  var c = 0
  var b = usart.readByte()
  while char(b) != '\n' and c < S-1: 
    buf[c] = cchar(b)
    b = usart.readByte()
    inc c
  buf[c] = '\0'
  c-1


proc readNBytes*[S: static[int]](usart: Usart; n: int; buf: var array[S, cchar]): int =
  var c = 0
  let b = usart.readByte()
  while c < n and c < S:
    buf[c] = b
    b = usart.readByte()
    inc c
  c

  
proc readNBytesUnsafe*[S: static[int]](usart: Usart; n: int; buf: var array[S, cchar]) =
  var c = 0
  let b = usart.readByte()
  while c < n:
    buf[c] = b
    b = usart.readByte()
    inc c

