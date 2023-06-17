import macros
import strutils

# TODO: atmega1284? type FarProgramMemory*[T] = distinct T
type PmNumber = SomeUnsignedInt | float32
type ProgramMemory*[T: PmNumber] = distinct T
type ProgramMemoryArray*[S: static[int]; T: PmNumber] = distinct array[S, T]

template pgmPtr[T](pm: ProgramMemory[T]): uint16 =
  cast[uint16](unsafeAddr pm)

template pgmPtr[S; T](pm: ProgramMemoryArray[S, T], offset: int): uint16 =
  cast[uint16](unsafeAddr array[S, T](pm)[offset])

proc readByteNear(a: uint16): uint8 {.importc: "pgm_read_byte", header:"<avr/pgmspace.h>".}
proc readWordNear(a: uint16): uint16 {.importc: "pgm_read_word", header:"<avr/pgmspace.h>".}
proc readDWordNear(a: uint16): uint32 {.importc: "pgm_read_dword", header:"<avr/pgmspace.h>".}
proc readFloatNear(a: uint16): float32 {.importc: "pgm_read_float", header:"<avr/pgmspace.h>".}

template `[]`*[T](pm: ProgramMemory[T]): T =
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

template len*[S; T](pm: ProgramMemoryArray[S, T]): untyped =
  array[S, T](pm).len

template `[]`*[S; T](pm: ProgramMemoryArray[S, T]; offset: int): T =
  when typeof(T) is float32:
    readFloatNear(pgmPtr(pm, offset))
  else:
    when sizeof(T) == 1:
      readByteNear(pgmPtr(pm, offset))
    elif sizeof(T) == 2:
      readWordNear(pgmPtr(pm, offset))
    elif sizeof(T) == 4:
      readDWordNear(pgmPtr(pm, offset))
    else:
      static:
         error("unsupported size for ProgramMemory.read")

iterator progmemIter*[S; T](pm: ProgramMemoryArray[S, T]): T =
  var i = 0
  while i < S:
    yield pm[i]
    inc i

template wrapC(s: static[string] = "", equal: bool = true): static[string] =
  when equal:
    "static const $# $# PROGMEM = " & s
  else:
    "static const $# $# PROGMEM"
    
macro progmem*(n, v: untyped): untyped =
  quote do:
    let `n` {.importc, codegenDecl: wrapC($`v`), global, noinit.}: 
      ProgramMemory[`v`.typeof]

macro progmemArray*(n, v: untyped): untyped =
  quote do:
    const s = multiReplace(($`v`), ("[", "{"),("]", "}"))
    let `n` {.importc, codegenDecl: wrapC(s), global, noinit.}: ProgramMemoryArray[`v`.len, `v`[0].typeof]

macro progmemArray*(n: untyped; t: type; s: static[int]): untyped =
  quote do:
    let `n` {.importc, codegenDecl: wrapC("", false), global, noinit.}: ProgramMemoryArray[`s`, `t`]

macro progmemString*(n: untyped; val: static[string]): untyped =
  quote do:
    let `n` {.importc, codegenDecl: wrapC("\""&`val`&"\""), global, noinit.}: ProgramMemoryArray[`val`.len, uint8]
