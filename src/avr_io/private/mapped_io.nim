import bitops
import volatile


type MappedIoRegister*[T: uint8|uint16] = distinct uint16

template ioPtr[T](a: MappedIoRegister[T]): ptr T = 
  cast[ptr T](a)

template `[]`*[T](p: MappedIoRegister[T]): T =
  volatile.volatileLoad(ioPtr[T](p))

template `[]=`*[T](p: MappedIoRegister[T]; v: T) =
  volatile.volatileStore(ioPtr[T](p), v)

template setBit*[T](p: MappedIoRegister[T]; b: uint8) =
  p[] = 1'u8 shl b

type
  Port* = object
    direction: MappedIoRegister[uint8]
    output: MappedIoRegister[uint8]
    input: MappedIoRegister[uint8]

template asOutputPin*(p: Port, pin: uint8) =
  p.direction[] = bitor(p.direction[], 1'u8 shl pin) 

template asInputPin*(p: Port, pin: uint8) =
  p.direction[] = bitand(p.direction[], bitnot(1'u8 shl pin)) 

template asOutputPort*(p: Port) =
  p.direction[] = 0xFF

template asInputPort*(p: Port) =
  p.direction[] = 0x00

template setupWithMask*(p: Port, mask: uint8) =
  p.direction[] = setMasked(p.direction[], mask)

template setupWithClearedMask*(p: Port, mask: uint8) =
  p.direction[] = clearMasked(p.direction[], mask)

template asInputPullupPin*(p: Port, pin: uint8) =
  p.asInputPin(pin)
  p.setPin(pin)

template disablePullup*(p: Port, pin: uint8) =
  p.clearPin(pin)

template setPin*(p: Port, pin: uint8) =
  p.output[] = bitor(p.output[], 1'u8 shl pin) 

template clearPin*(p: Port, pin: uint8) =
  p.output[] = bitand(p.output[], bitnot(1'u8 shl pin)) 

template togglePin*(p: Port, pin: uint8) = 
  p.output[] = bitxor(p.output[], 1'u8 shl pin)

template readPin*(p: Port, pin: uint8): uint8 =
  bitand(p.input[], 1'u8 shl pin) shr pin

template setPort*(p: Port) =
  p.output[] = 0xff 

template clearPort*(p: Port) =
  p.output[] = 0x00 

template setPortValue*(p: Port, val: uint8) =
  p.output[] = val 

template readPort*(p: Port): uint8 =
  p.input[]

template setMask*(p: Port, mask: uint8) =
  p.output[] = setMasked(p.output[], mask)

template clearMask*(p: Port, mask: uint8) =
  p.output[] = clearMasked(p.output[], mask)

template readMask*(p: Port, mask: uint8): uint8 =
  masked(p.input[], mask)
