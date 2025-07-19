## The mapped_io module implements datatypes for IO registers and a series of 
## basic operations on those registers.
## Note: this operations are safe

import std/volatile
import std/bitops
import std/macros


type
  RegisterValue = uint8 | uint16
  StaticPin = static int
  PinInt = StaticPin | RegisterValue

  MappedIoRegister*[T: RegisterValue] = distinct uint16 ## \
    ## A register that can either contain a byte-sized or word-sized datum.


template ioPtr[T](a: MappedIoRegister[T]): ptr T =
  cast[ptr T](a)

template pin_value[T](n: PinInt): T =
  const hi = (sizeof(T) * 8) - 1
  when n is static:
    when not (n >= 0 and n <= hi):
      static:
        const name = if T.typeof is uint8: "8-bit" else: "16-bit"
        error "index " & $n & " out of bounds, a "& name &" pin must be 0 <= x <= " & $hi
    n.T
  else:
    when not defined(danger): bitand(n.T, hi.T)
    else: n.T

template `[]`*[T](p: MappedIoRegister[T]): T =
  ## Dereference operator overload, that allows to read from a memory-mapped 
  ## register.
  var res {.noinit.}: T
  res = volatile.volatileLoad(ioPtr[T](p))
  res

template `[]=`*[T](p: MappedIoRegister[T]; v: T) =
  ## Dereference and assignment operator overload, that allows to write into a 
  ## memory-mapped register.
  volatile.volatileStore(ioPtr[T](p), v)

template setBit*[T](p: MappedIoRegister[T]; b: PinInt) =
  ## Sets a single bit of the specified register.
  p[] = bitor(p[], 1.T shl pin_value[T](b))

template clearBit*[T](p: MappedIoRegister[T]; b: PinInt) =
  ## Clears a single bit of the specified register.
  p[] = bitand(p[], bitnot(1.T shl pin_value[T](b)))

template toggleBit*[T](p: MappedIoRegister[T]; b: PinInt) =
  ## Toggles a single bit of the specified register.
  p[] = bitxor(p[], 1.T shl pin_value[T](b))

template readBit*[T](p: MappedIoRegister[T]; b: PinInt): T =
  ## Reads the value for the specified bit in the register.
  const bit = pin_value[T](b)
  bitand(p[], 1'u8 shl bit) shr bit

template setMask*[T](p: MappedIoRegister[T]; mask: T) =
  ## Sets the reister bits that are high in the passed mask.
  p[] = setMasked(p[], mask)

template clearMask*[T](p: MappedIoRegister[T]; mask: T) =
  ## Clears the reister bits that are high in the passed mask.
  p[] = clearMasked(p[], mask)

type
  Port* = object
    ## An AVR Port, with direction input and output registers.
    direction: MappedIoRegister[uint8]
    output: MappedIoRegister[uint8]
    input: MappedIoRegister[uint8]

template asOutputPin*(p: Port, pin: uint8) =
  ## Sets the specified pin in the port as an output pin.
  p.direction[] = bitor(p.direction[], 1'u8 shl pin_value[uint8](pin))

template asInputPin*(p: Port, pin: uint8) =
  ## Sets the specified pin in the port as an input pin.
  p.direction[] = bitand(p.direction[], bitnot(1'u8 shl pin_value[uint8](pin)))

template asOutputPort*(p: Port) =
  ## Sets the specified port as an output port.
  p.direction[] = 0xFF

template asInputPort*(p: Port) =
  ## Sets the specified port as an input port.
  p.direction[] = 0x00

template setupWithMask*(p: Port; mask: uint8) =
  ## Setups the port with the high bits in the passed mask.
  p.direction[] = setMasked(p.direction[], mask)

template setupWithClearedMask*(p: Port; mask: uint8) =
  ## Setups the port by clearing it with the high bits in the passed mask.
  p.direction[] = clearMasked(p.direction[], mask)

template asInputPullupPin*(p: Port; pin: uint8) =
  ## Sets the specified pin in the port as an input pullup pin.
  p.asInputPin(pin)
  p.setPin(pin)

template disablePullup*(p: Port; pin: uint8) =
  ## Disables pullup mode for the spcified pin in the port.
  p.clearPin(pin)

template setPin*(p: Port; pin: uint8) =
  ## Sets the specified pin in the port to high.
  p.output[] = bitor(p.output[], 1'u8 shl pin_value[uint8](pin))

template clearPin*(p: Port; pin: uint8) =
  ## Clears the specified pin in the port to low.
  p.output[] = bitand(p.output[], bitnot(1'u8 shl pin_value[uint8](pin)))

template togglePin*(p: Port; pin: uint8) = 
  ## Toggles the specified pin in the port.
  p.output[] = bitxor(p.output[], 1'u8 shl pin_value[uint8](pin))

template readPin*(p: Port; pin: uint8): uint8 =
  ## Reads the value for specified pin in the port.
  const val = pin_value[uint8](pin)
  bitand(p.input[], 1'u8 shl val) shr val

template setPort*(p: Port) =
  ## Sets all the pins in the port to high.
  p.output[] = 0xff 

template clearPort*(p: Port) =
  ## Clears all the pins in the port to low.
  p.output[] = 0x00 

template setPortValue*(p: Port; val: uint8) =
  ## Sets the port to the specified value.
  p.output[] = val 

template readPort*(p: Port): uint8 =
  ## Reads the value from the spcified port.
  p.input[]

template setMask*(p: Port; mask: uint8) =
  ## Sets the port to the high bits in the passed mask.
  p.output[] = setMasked(p.output[], mask)

template clearMask*(p: Port; mask: uint8) =
  ## Clears the pin in the port with bits set to one in the mask.
  p.output[] = clearMasked(p.output[], mask)

template readMask*(p: Port; mask: uint8): uint8 =
  ## Reads the bits from the port with bits set to one in the mask.
  masked(p.input[], mask)
