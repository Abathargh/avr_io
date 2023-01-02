import bitops
import volatile


type MappedIoRegister8* = distinct ptr uint8
type MappedIoRegister16* = distinct ptr uint16

template `[]`*(p: MappedIoRegister8): uint8 =
  volatile.volatileLoad((ptr uint8)p)

template `[]=`*(p: MappedIoRegister8, v: uint8) =
  volatile.volatileStore((ptr uint8)p, v)

template `[]`*(p: MappedIoRegister16): uint16 =
  volatile.volatileLoad((ptr uint16)p)

template `[]=`*(p: MappedIoRegister16, v: uint16) =
  volatile.volatileStore((ptr uint16)p, v)

template ioPtr8(a: uint16): ptr uint8 = 
  cast[ptr uint8](a)

template ioPtr16(a: uint16): ptr uint16 = 
  cast[ptr uint16](a)

type
  Port* = object
    direction: MappedIoRegister8
    output: MappedIoRegister8
    input: MappedIoRegister8

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
