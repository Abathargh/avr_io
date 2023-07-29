import mapped_io

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

template baudRate*(baud: int, freq: int = 16000000): uint16 =
  ## Generates the correct value to feed to the Usart initializers
  ## starting from the baud rate.
  (freq div (16 * baud)) - 1

template toBitMask*(f: Flags): uint8 =
  ## Converts a bit field containing flags to be used with a control 
  ## and status register to an 8-bit integer. 
  cast[uint8](f)

template toBitSet*[T: Flags](u: uint8): T =
  ## Converts an integer representing a control and status register 
  ## value to a bit field.
  cast[T](u)

type character = uint8 | char | cchar

proc initUart*(usart: Usart; baud: uint16; ctlA: CtlAFlags; ctlB: CtlBFlags; ctlC: CtlCFlags) =
  ## Initializes the Usart peripheral to be used with the specified flags and baud rate.
  ## USe the `baudRate` template to generate a valid input for that parameter.
  usart.baudHi[] = uint8(baud shr 8)
  usart.baudLo[] = uint8(baud)
  usart.ctlA[] = toBitMask(ctlA)
  usart.ctlB[] = toBitMask(ctlB)
  usart.ctlC[] = toBitMask(ctlC)

proc sendByte*(usart: Usart; c: character) =
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
    
