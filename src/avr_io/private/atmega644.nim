include avr_io/private/mapped_io 

const
  DDRA*  = MappedIoRegister(cast[ptr uint16](0x21))
  PORTA* = MappedIoRegister(cast[ptr uint16](0x22))
