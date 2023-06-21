import macros
import strutils

# TODOs: 
# - [ ] support for far operations
#   - [ ] type FarProgramMemory*[T] = distinct T
#   - [ ] add atmega1284 support (registers/interrupts) once we're at it?
# - [x] unify types? memcpy_P/PF may be used to solve pm[] accesses for sizes > 4B
#   - [ ] unify progmem defs and allow 1+ defs in one block
#   - [ ] compile time replace in progmem objects (fields -> .fields in C)
# - [ ]wrap other _P and _PF functions in pgmspace.h

type ProgramMemory*[T] = distinct T

template pgmPtr[T](pm: ProgramMemory[T]): ptr T =
  unsafeAddr T(pm)

template pgmPtrU16[T](pm: ProgramMemory[T]): uint16 =
  cast[uint16](unsafeAddr pm)

template pgmPtrOffset[S; T](pm: ProgramMemory[array[S, T]]; offset: int): ptr T =
  unsafeAddr array[S, T](pm)[offset]

template pgmPtrOffsetU16[S; T](pm: ProgramMemory[array[S, T]], offset: int): uint16 =
  cast[uint16](unsafeAddr array[S, T](pm)[offset])


proc readByteNear(a: uint16): uint8 {.importc: "pgm_read_byte", header:"<avr/pgmspace.h>".}
proc readWordNear(a: uint16): uint16 {.importc: "pgm_read_word", header:"<avr/pgmspace.h>".}
proc readDWordNear(a: uint16): uint32 {.importc: "pgm_read_dword", header:"<avr/pgmspace.h>".}
proc readFloatNear(a: uint16): float32 {.importc: "pgm_read_float", header:"<avr/pgmspace.h>".}
proc memCompare[T](s1, s2: ptr T, s: int): int {.importc: "memcmp_P", header: "<avr/pgmspace.h>".} 
proc memCountCopy() {.importc: "memccpy_P", header: "<avr/pgmspace.h>".}
proc memCopy[T](dest, src: ptr T; len: csize_t) {.importc: "memcpy_P", header: "<avr/pgmspace.h>".}
proc strCat() {.importc: "strcat_P", header: "<avr/pgmspace.h>".}
proc strCompare() {.importc: "strcmp_P", header: "<avr/pgmspace.h>".} 
proc strCopy() {.importc: "strcpy_P", header: "<avr/pgmspace.h>".}
proc strNCompare() {.importc: "strncmp_P", header: "<avr/pgmspace.h>".} 
proc strNCat() {.importc: "strncat_P", header: "<avr/pgmspace.h>".}
proc strNCopy() {.importc: "strncpy_P", header: "<avr/pgmspace.h>".}
proc strStr() {.importc: "strstr_P", header: "<avr/pgmspace.h>".} 

template `[]`*[T](pm: ProgramMemory[T]): T =
  when typeof(T) is float32:
    readFloatNear(pgmPtrU16(pm))
  elif sizeof(T) == 1:
    readByteNear(pgmPtrU16(pm))
  elif sizeof(T) == 2:
    readWordNear(pgmPtrU16(pm))
  elif sizeof(T) == 4:
    readDWordNear(pgmPtrU16(pm))
  else:
    var e: T
    memCopy(addr e, pgmPtr(pm), csize_t(sizeof(T)))
    e

template len*[S; T](pm: ProgramMemory[array[S, T]]): untyped = S

template `[]`*[S; T](pm: ProgramMemory[array[S, T]]; offset: int): T =
  when typeof(T) is float32:
    readFloatNear(pgmPtrOffsetU16(pm, offset))
  else:
    when sizeof(T) == 1:
      readByteNear(pgmPtrOffsetU16(pm, offset))
    elif sizeof(T) == 2:
      readWordNear(pgmPtrOffsetU16(pm, offset))
    elif sizeof(T) == 4:
      readDWordNear(pgmPtrOffsetU16(pm, offset))
    else:
      var e: T
      memCopy(addr e, pgmPtrOffset(pm, offset), sizeof(T))
      e

iterator progmemIter*[S: static[int]; T](pm: ProgramMemory[array[S, T]]): T =
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
    when typeOf(`v`) is SomeNumber:
      const s = $`v`
    else:
      const s = multiReplace(($`v`), ("(", "{"), (")", "}"))
    let `n` {.importc, codegenDecl: wrapC(s), global, noinit.}: 
      ProgramMemory[`v`.typeof]

macro progmemArray*(n, v: untyped): untyped =
  quote do:
    const s = multiReplace(($`v`), ("[", "{"), ("]", "}"))
    let `n` {.importc, codegenDecl: wrapC(s), global, noinit.}: ProgramMemory[array[`v`.len, `v`[0].typeof]]

macro progmemArray*(n: untyped; t: type; s: static[int]): untyped =
  quote do:
    let `n` {.importc, codegenDecl: wrapC("", false), global, noinit.}: ProgramMemory[array[`s`, `t`]]

macro progmemString*(n: untyped; val: static[string]): untyped =
  quote do:
    let `n` {.importc, codegenDecl: wrapC("\""&`val`&"\""), global, noinit.}: ProgramMemory[array[`val`.len, uint8]]
