import volatile

type MappedIoRegister* = distinct ptr uint16

template `[]`*(p: MappedIoRegister): uint16 =
  volatile.volatileLoad((ptr uint16)p)

template `[]=`*(p: MappedIoRegister, v: uint16) =
  volatile.volatileStore((ptr uint16)p, v)

