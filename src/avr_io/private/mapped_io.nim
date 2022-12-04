import volatile


type MappedIoRegister8* = distinct ptr uint8
type MappedIoRegister16* = distinct ptr uint

template `[]`*(p: MappedIoRegister8): uint8 =
  volatile.volatileLoad((ptr uint8)p)

template `[]=`*(p: MappedIoRegister8, v: uint8) =
  volatile.volatileStore((ptr uint16)p, v)

template `[]`*(p: MappedIoRegister16): uint16 =
  volatile.volatileLoad((ptr uint16)p)

template `[]=`*(p: MappedIoRegister16, v: uint16) =
  volatile.volatileStore((ptr uint16)p, v)

template ioPtr8(a: uint8): ptr uint8 = 
  cast[ptr uint8](a)

template ioPtr16(a: uint16): ptr uint16 = 
  cast[ptr uint16](a)
