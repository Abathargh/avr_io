import macros
import strutils

# TODOs: 
# - [ ] support for far operations
#   - [ ] type FarProgramMemory*[T] = distinct T
#   - [ ] add atmega1284 support (registers/interrupts) once we're at it?
# - [x] unify types? memcpy_P/PF may be used to solve pm[] accesses for sizes > 4B
#   - [ ] unify progmem defs and allow 1+ defs in one block
#   - [x] compile time replace in progmem objects (fields -> .fields in C)
# - [ ] wrap other _P and _PF functions in pgmspace.h

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
proc memCopy[T](dest, src: ptr T; len: csize_t): ptr T {.importc: "memcpy_P", header: "<avr/pgmspace.h>".}
proc strNCompare[T](dest, src: ptr T; len: csize_t): int {.importc: "strncmp_P", header: "<avr/pgmspace.h>".} 
proc strNCopy[T](dest, src: ptr T; len: csize_t) {.importc: "strncpy_P", header: "<avr/pgmspace.h>".}
proc strStr[T](dest, src: ptr T): int {.importc: "strstr_P", header: "<avr/pgmspace.h>".} 

template len*[S; T](pm: ProgramMemory[array[S, T]]): untyped = S

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
    var e {.noInit.} : T 
    discard memCopy(addr e, pgmPtr(pm), csize_t(sizeof(T))) 
    e
    
template `[]`*[S: static[int]; T](pm: ProgramMemory[array[S, T]]; offset: int): T =
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
      var e {.noInit.} : T 
      discard memCopy(addr e, pgmPtrOffset(pm, offset), csize_t(sizeof(T)))
      e

iterator progmemIter*[S: static[int]; T](pm: ProgramMemory[array[S, T]]): T =
  var i = 0
  while i < S:
    yield pm[i]
    inc i

iterator progmemIter*[S: static[int]](pm: ProgramMemory[array[S, cchar]]): cchar =
  var i = 0
  while i < S and pm[i] != '\0':
    yield pm[i]
    inc i

proc escapeStrseq(s: string): string =
  # Escape special chars so that they will still appear as such
  # in the generated c code
  var r: string = newStringOfCap(s.len)
  for ch in s:
    case ch:
      of char(0) .. char(31):
        r.addEscapedChar(ch)
      else:
        r.add(ch)
  r

template wrapC(s: static[string] = "", equal: bool = true): static[string] =
  when equal:
    "static const $# $# __attribute__((__progmem__)) = " & escapeStrseq(s)
  else:
    "static const $# $# __attribute__((__progmem__))"
  
proc substStructFields(s: string): string =
  # Hand-rolled FSM-based struct parsing proc, since it is not
  # possible to use the 're' module at compile-time
  # TODO modify to accept objects as params to objects
  type
    stateEnum = enum
      spaceParsing
      nameParsing
      colonParsing
      valueParsing

  var state = spaceParsing
  var output = ""

  for ch in s[1 .. ^2]:
    case state:
      of spaceParsing:
        case ch:
          of ' ':
            continue
          else:
            output &= "." & ch
            state = nameParsing
      of nameParsing:
        case ch:
          of ':':
            state = colonParsing
          else:
            output &= ch
      of colonParsing:
        case ch:
          of ' ':
            continue
          else:
            output &= "="
            output &= ch
            state = valueParsing
      of valueParsing:
        case ch:
          of ',':
            output &= ", "
            state = spaceParsing
          else:
            output &= ch

  "{" & output & "}"
    
macro progmem*(n, v: untyped): untyped =
  quote do:
    when typeOf(`v`) is SomeNumber:
      const s = $`v`
      let `n` {.importc, codegenDecl: wrapC(s), global, noinit.}: ProgramMemory[`v`.typeof]
    elif typeof(`v`) is string:
      let `n` {.importc, codegenDecl: wrapC("\""&`v`&"\""), global, noinit.}: ProgramMemory[array[`v`.len + 1, cchar]]
    else:
      const s = substStructFields(($`v`))
      let `n` {.importc, codegenDecl: wrapC(s), global, noinit.}: ProgramMemory[`v`.typeof]

macro progmemArray*(n, v: untyped): untyped =
  quote do:
    const s = multiReplace(($`v`), ("[", "{"), ("]", "}"))
    let `n` {.importc, codegenDecl: wrapC(s), global, noinit.}: ProgramMemory[array[`v`.len, `v`[0].typeof]]

macro progmemArray*(n: untyped; t: type; s: static[int]): untyped =
  quote do:
    let `n` {.importc, codegenDecl: wrapC("", false), global, noinit.}: ProgramMemory[array[`s`, `t`]]
