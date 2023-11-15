## The mapped_io module implements datatypes for IO registers and a series of 
## basic operations on those registers.

import bitops
import volatile

type MappedIoRegister*[T: uint8|uint16] = distinct uint16 ## \
  ## A register that can either contain a byte-sized or word-sized datum.

template ioPtr[T](a: MappedIoRegister[T]): ptr T = 
  cast[ptr T](a)

template `[]`*[T](p: MappedIoRegister[T]): T =
  ## Dereference operator overload, that allows to read from a memory-mapped 
  ## register.
  volatile.volatileLoad(ioPtr[T](p))

template `[]=`*[T](p: MappedIoRegister[T]; v: T) =
  ## Dereference and assignment operator overload, that allows to write into a 
  ## memory-mapped register.
  volatile.volatileStore(ioPtr[T](p), v)

template setBit*[T](p: MappedIoRegister[T]; b: uint8) =
  ## Sets a single bit of the specified register,
  p[] = 1'u8 shl b

type
  Port* = object
    ## An AVR Port, with direction input and output registers.
    direction: MappedIoRegister[uint8]
    output: MappedIoRegister[uint8]
    input: MappedIoRegister[uint8]

template asOutputPin*(p: Port, pin: uint8) =
  ## Sets the specified pin in the port as an output pin.
  p.direction[] = bitor(p.direction[], 1'u8 shl pin) 

template asInputPin*(p: Port, pin: uint8) =
  ## Sets the specified pin in the port as an input pin.
  p.direction[] = bitand(p.direction[], bitnot(1'u8 shl pin)) 

template asOutputPort*(p: Port) =
  ## Sets the specified port as an output port.
  p.direction[] = 0xFF

template asInputPort*(p: Port) =
  ## Sets the specified port as an input port.
  p.direction[] = 0x00

template setupWithMask*(p: Port, mask: uint8) =
  ## Setups the port with the high bits in the passed mask.
  p.direction[] = setMasked(p.direction[], mask)

template setupWithClearedMask*(p: Port, mask: uint8) =
  ## Setups the port by clearing it with the high bits in the passed mask.
  p.direction[] = clearMasked(p.direction[], mask)

template asInputPullupPin*(p: Port, pin: uint8) =
  ## Sets the specified pin in the port as an input pullup pin.
  p.asInputPin(pin)
  p.setPin(pin)

template disablePullup*(p: Port, pin: uint8) =
  ## Disables pullup mode for the spcified pin in the port.
  p.clearPin(pin)

template setPin*(p: Port, pin: uint8) =
  ## Sets the specified pin in the port to high.
  p.output[] = bitor(p.output[], 1'u8 shl pin) 

template clearPin*(p: Port, pin: uint8) =
  ## Clears the specified pin in the port to low.
  p.output[] = bitand(p.output[], bitnot(1'u8 shl pin)) 

template togglePin*(p: Port, pin: uint8) = 
  ## Toggles the specified pin in the port.
  p.output[] = bitxor(p.output[], 1'u8 shl pin)

template readPin*(p: Port, pin: uint8): uint8 =
  ## Reads the value for specified pin in the port.
  bitand(p.input[], 1'u8 shl pin) shr pin

template setPort*(p: Port) =
  ## Sets all the pins in the port to high.
  p.output[] = 0xff 

template clearPort*(p: Port) =
  ## Clears all the pins in the port to low.
  p.output[] = 0x00 

template setPortValue*(p: Port, val: uint8) =
  ## Sets the port to the specified value.
  p.output[] = val 

template readPort*(p: Port): uint8 =
  ## Reads the value from the spcified port.
  p.input[]

template setMask*(p: Port, mask: uint8) =
  ## Sets the port to the high bits in the passed mask.
  p.output[] = setMasked(p.output[], mask)

template clearMask*(p: Port, mask: uint8) =
  ## Clears the pin in the port with bits set to one in the mask.
  p.output[] = clearMasked(p.output[], mask)

template readMask*(p: Port, mask: uint8): uint8 =
  ## Reads the bits from the port with bits set to one in the mask.
  masked(p.input[], mask)
