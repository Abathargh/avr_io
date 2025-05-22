## Utilities to interact with program memory in AVR chips. This module 
## provides primitives useful to store data in program memory, retrieve it and 
## manipulate it.

import std/strutils
import std/macros

import ./private/codegen

type ProgramMemory[T] = distinct T ## \
  ## An handle to data store in program memory.

template pm_ptr[T](pm: ProgramMemory[T]): ptr T =
  addr T(pm)

template pm_ptr_u16[T](pm: ProgramMemory[T]): uint16 =
  cast[uint16](addr pm)

template pm_ptr_off[S; T](pm: ProgramMemory[array[S, T]]; off: int): ptr T =
  addr array[S, T](pm)[off]

template pmPtrOffU16[S; T](pm: ProgramMemory[array[S, T]], off: int): uint16 =
  cast[uint16](addr array[S, T](pm)[off])

proc readByteNear(a: uint16): uint8
  {.importc: "pgm_read_byte", header:"<avr/pgmspace.h>".}

proc readWordNear(a: uint16): uint16
  {.importc: "pgm_read_word", header:"<avr/pgmspace.h>".}

proc readDWordNear(a: uint16): uint32
  {.importc: "pgm_read_dword", header:"<avr/pgmspace.h>".}

proc readFloatNear(a: uint16): float32
  {.importc: "pgm_read_float", header:"<avr/pgmspace.h>".}

proc pm_memcmp[T](s1, s2: pointer, s: int): int
  {.importc: "memcmp_P", header: "<avr/pgmspace.h>".}

proc pm_memcpy[T](dest, src: ptr T; len: csize_t)
  {.importc: "memcpy_P", header: "<avr/pgmspace.h>".}

proc pm_strncpy[T](dest, src: ptr T; len: csize_t): ptr T
  {.importc: "strncpy_P", header: "<avr/pgmspace.h>".}

proc pm_strlen(src: ptr cchar): int
  {.importc: "strlen_P", header: "<avr/pgmspace.h>".}

proc pm_strstr[T](dest, src: ptr T): int
  {.importc: "strstr_P", header: "<avr/pgmspace.h>".}

template len*[S; T](pm: ProgramMemory[array[S, T]]): untyped = S ## \
  ## Returns the length of a program memory array.

template len*[T](pm: ProgramMemory[string|cstring]): untyped = pm.len ## \
  ## Returns the length of a program memory array.

template `[]`*[T](pm: ProgramMemory[T]): T = ## \
  ## Dereference operator used to access data stored in program memory. 
  ## Note that this must generate a copy of said data, in order to make it 
  ## available to the user. This can be used for numbers and for objects 
  ## without loss of generality.

  var res {.noInit.}: T

  when T is SomeNumber and sizeof(T) <= 4:
    when typeof(T) is float32:
      res = readFloatNear(pm_ptr_u16(pm))
    elif sizeof(T) == 1:
      res = readByteNear(pm_ptr_u16(pm)).T
    elif sizeof(T) == 2:
      res = readWordNear(pm_ptr_u16(pm)).T
    elif sizeof(T) == 4:
      res = readDWordNear(pm_ptr_u16(pm)).T
  else:
    when typeof(T) is array and sizeof(T) != 0:
      pm_memcpy(addr res[0], pm_ptr_off(pm, 0), sizeof(T).csize_t)
    else:
      pm_memcpy(addr res, pm_ptr(pm), T.sizeof.csize_t)
  res

template `[]`*[S: static int; T](pm: ProgramMemory[array[S, T]]; i: int): T =
  ## Dereference operator used to access elements of an array stored in
  ## program memory. Note that this must generate a copy of said data, in
  ## order to make it available to the user.
  when compileOption("rangeChecks"):
    if i < 0 and i >= S:
      quit(1)

  when typeof(T) is float32:
    readFloatNear(pmPtrOffU16(pm, i))
  else:
    when sizeof(T) == 1:
      readByteNear(pmPtrOffU16(pm, i))
    elif sizeof(T) == 2:
      readWordNear(pmPtrOffU16(pm, i))
    elif sizeof(T) == 4:
      readDWordNear(pmPtrOffU16(pm, i))
    else:
      var e {.noInit.} : T
      discard pm_memcpy(addr e, pm_ptr_off(pm, i), csize_t(sizeof(T)))
      e

template `==`*[T](d: T, pm: ProgramMemory[T]): bool =
  pm_memcmp(addr d, pm_ptr(pm), sizeof(T)) == 0

template `!=`*[T](d: T, pm: ProgramMemory[T]): bool =
  pm_memcmp(addr d, pm_ptr(pm), sizeof(T)) != 0

template `in`*[T](d: string|cstring, pm: ProgramMemory[string|cstring]): bool =
  not pm_strstr(addr cstring(d)[0], pm).isNil

template readFromAddress*[T](a: uint16) : T =
  ## Reads from a program memory address directly.
  ## To be used when in need of accessing progmem data that was not initialized 
  ## by the current application.
  when T is SomeNumber and sizeof(T) <= 4:
    when typeof(T) is float32:
      readFloatNear(a)
    else:
      when sizeof(T) == 1:
        readByteNear(a).T
      elif sizeof(T) == 2:
        readWordNear(a).T
      elif sizeof(T) == 4:
        readDWordNear(a).T
  else:
    let p = cast[ptr T](a)
    var e {.noInit.} : T
    discard pm_memcpy(addr e, p, csize_t(sizeof(T)))
    e

iterator progmemIter*[S: static int; T](pm: ProgramMemory[array[S, T]]): T =
  ## Iterator that can be used to safely traverse program memory arrays.
  ## Note that this must generate a copy of each element iterated, in order to 
  ## make it available to the user. 
  var i = 0
  while i < S:
    yield pm[i]
    inc i

iterator progmemIter*[S: static int](pm: ProgramMemory[array[S, cchar]]): cchar =
  ## Iterator that can be used to safely traverse program memory cchar arrays.
  ## Note that this must generate a copy of each element iterated, in order to 
  ## make it available to the user. 
  var i = 0
  while i < S and pm[i] != '\0':
    yield pm[i]
    inc i


proc wrapC*(s: string = "", equal: bool = true, is_str: bool = false): string =
  var s = s
  if is_str:
    s = "\"" & s & "\""

  if equal:
    "static const $# $# __attribute__((__progmem__)) = " & escapeStrseq(s)
  else:
    "static const $# $# __attribute__((__progmem__))"


macro progmem*(l: untyped): untyped =
  ## Stores the value contained in the let expression tagged with this macro 
  ## pragma in program memory.
  
  # First, let's check if we are in a let section and if everything checks out 
  # with reference to where we are in the AST.
  var lnode = if l.kind == nnkLetSection: l[0] else: l

  expectKind(lnode, nnkIdentDefs)
  expectKind(lnode[0], nnkIdent)

  # Let us retrieve the name and the rval of the let statement
  let name = lnode[0]
  let rval = lnode[2]
  let name_str = $name

  quote do:
    const (msg, ok) = get_type_repr(`name_str`, `rval`)
    when not ok and typeof(`rval`) is not string:
      static: error msg

    when typeof(`rval`) is SomeNumber:
      let `name` {.importc, codegenDecl: wrapC(msg), global, noinit.}:
        ProgramMemory[`rval`.typeof]
    elif typeof(`rval`) is string or typeof(`rval`) is cstring:
      let `name` {.importc, codegenDecl: wrapC(msg, true, true), global,
        noinit.}: ProgramMemory[array[`rval`.len + 1, cchar]]
    elif typeof(`rval`) is array:
      let `name` {.importc, codegenDecl: wrapC(msg), global, noinit.}:
        ProgramMemory[array[`rval`.len, `rval`[0].typeof]]
    elif typeof(`rval`) is object:
      let `name` {.importc, codegenDecl: wrapC(msg), global, noinit.}:
        ProgramMemory[`rval`.typeof]
    elif typeof(`rval`) is ref object:
      static:
        error "'progmem' cannot be used with ref objects"
    else:
      static:
        error "'progmem' can only be used to annotate let statements " &
          "containing literal rvalues, or compile-time function calls " &
          "returning literal rvalues, got '$#'" % $`rval`.typeof

macro progmem*(n, v: untyped): untyped =
  ## Stores the value `v` in program memory, and creates a new symbol `n`
  ## through which it is possible to access it.

  let name = $n
  template deprecation_warning(name, val: typed): string =
    const pos = instantiationInfo()
    "`progmem($#, $#)` used in " % [$name, $val] &
    "$#($#:$#) " % [pos.filename, $pos.line, $pos.column] &
    "is deprecated, use `let $# {.progmem.} = $#`" % [$name, $val]

  quote do:
    static: warning deprecation_warning(`name`, $`v`)
    when typeof(`v`) is SomeNumber:
      const s = $`v`
      let `n` {.importc, codegenDecl: wrapC(s), global, noinit.}:
        ProgramMemory[`v`.typeof]
    elif typeof(`v`) is string:
      let `n` {.importc, codegenDecl: wrapC(`v`, true, true), global, noinit.}:
        ProgramMemory[array[`v`.len + 1, cchar]]
    elif typeof(`v`) is object:
      const (s, _) = substStructFields(($`v`))
      let `n` {.importc, codegenDecl: wrapC(s), global, noinit.}:
        ProgramMemory[`v`.typeof]
    else:
      static: error "'progmem' can only be used to annotate let statements " &
          "containing literal rvalues, or compile-time function calls " &
          "returning literal rvalues, got '$#'" % $`v`.typeof

macro progmemArray*(n, v: untyped): untyped =
  ## Stores the array `v` in program memory, and creates a new symbol `n`
  ## through which it is possible to access it.
  quote do:
    const s = multiReplace($`v`, ("[", "{"), ("]", "}"))
    let `n` {.importc, codegenDecl: wrapC(s), global, noinit.}: 
      ProgramMemory[array[`v`.len, `v`[0].typeof]]

macro progmemArray*(n: untyped; t: type; s: static int): untyped =
  ## Creates a new non-initialized program memory array, of size `s`, 
  ## containing elements of type `t`, and creates a new symbol `n` through 
  ## which it is possible to access it.
  quote do:
    let `n` {.importc, codegenDecl: wrapC("", false), global, noinit.}: 
      ProgramMemory[array[`s`, `t`]]
