import macros

# TODO: atmega1284? type FarProgramMemory*[T] = distinct T
type ProgramMemoryInteger = SomeUnsignedInt | float32
type ProgramMemory*[T: ProgramMemoryInteger] = distinct T
type ProgramMemoryArray*[S: static[int]; T: ProgramMemoryInteger] = distinct array[S, T]

template pgmPtr[T](pm: ProgramMemory[T]): uint16 =
  cast[uint16](unsafeAddr pm)

template pgmPtr[S; T](pm: ProgramMemoryArray[S, T]): uint16 =
  cast[uint16](unsafeAddr pm)

proc readByteNear(a: uint16): uint8 {.importc: "pgm_read_byte", header:"<avr/pgmspace.h>".}
proc readWordNear(a: uint16): uint16 {.importc: "pgm_read_word", header:"<avr/pgmspace.h>".}
proc readDWordNear(a: uint16): uint32 {.importc: "pgm_read_dword", header:"<avr/pgmspace.h>".}
proc readFloatNear(a: uint16): float32 {.importc: "pgm_read_float", header:"<avr/pgmspace.h>".}

template read*[T](pm: ProgramMemory[T]): T =
  when typeof(T) is float32:
    readFloatNear(pgmPtr(pm))
  else:
    when sizeof(T) == 1:
      readByteNear(pgmPtr(pm))
    elif sizeof(T) == 2:
      readWordNear(pgmPtr(pm))
    elif sizeof(T) == 4:
      readDWordNear(pgmPtr(pm))
    else:
      static:
         error("unsupported size for ProgramMemory.read")

template `[]`*[S; T](pm: ProgramMemoryArray[S, T]; offset: int): T =
  when typeof(T) is float32:
    readFloatNear(pgmPtr(pm) + uint16(offset))
  else:
    when sizeof(T) == 1:
      readByteNear(pgmPtr(pm) + uint16(offset))
    elif sizeof(T) == 2:
      readWordNear(pgmPtr(pm) + uint16(offset))
    elif sizeof(T) == 4:
      readDWordNear(pgmPtr(pm) + uint16(offset))
    else:
      static:
         error("unsupported size for ProgramMemory.read")

iterator progmemIter*[S; T](pm: ProgramMemoryArray[S, T]): T =
  var i = 0
  while i < S:
    yield pm[i]
    inc i

macro progmem*(n, v: untyped): untyped =
  quote do:
    let `n` {.importc, codegenDecl: "static const $# $# PROGMEM", global.}: 
      ProgramMemory[typeOf(`v`)] = ProgramMemory(`v`)

macro progmemArray*(n, v: untyped; size: static[int]): untyped =
  quote do:
    let `n` {.importc, codegenDecl: "static const $# $# PROGMEM", global.}: ProgramMemoryArray[size, `v`] = `v`

macro progmemString*(n: untyped; val: static[string]): untyped =
  quote do:
    let `n` {.importc, codegenDecl: "static const $# $# PROGMEM = \"" & `val` & "\"", global.}: ProgramMemoryArray[`val`.len, uint8]