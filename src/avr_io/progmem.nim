## Utilities to interact with program memory in AVR chips. This module 
## provides primitives useful to store data in program memory, retrieve it and 
## manipulate it.
## Note: only non-managed value-types can be stored in progmem, this is
## enforced and type-checked at compile-time.

import std/strutils
import std/macros

import ./private/codegen

type
  ProgramMemory[T] = distinct T ## \
    ## An handle to data store in program memory.
  ProgmemArray[S: static int; T] = ProgramMemory[array[S, T]] ## \
    ## An handle to specifically store arrays program memory.
  ProgmemString[S: static int] =  ProgramMemory[array[S, cchar]] ## \
    ## An handle to specifically store array of cchars in program memory.
  StringType = string | cstring # \
    ## Any string type

template pm_ptr[T](pm: ProgramMemory[T]): ptr T =
  addr T(pm)

template pm_ptr_off[S; T](pm: ProgmemArray[S, T]; off: int): ptr T =
  addr array[S, T](pm)[off]

proc readByteNear(a: pointer): uint8
  {.importc: "pgm_read_byte", header:"<avr/pgmspace.h>".}

proc readWordNear(a: pointer): uint16
  {.importc: "pgm_read_word", header:"<avr/pgmspace.h>".}

proc readDWordNear(a: pointer): uint32
  {.importc: "pgm_read_dword", header:"<avr/pgmspace.h>".}

proc readFloatNear(a: pointer): float32
  {.importc: "pgm_read_float", header:"<avr/pgmspace.h>".}

proc pm_memcpy[T](dest, src: ptr T; len: csize_t)
  {.importc: "memcpy_P", header: "<avr/pgmspace.h>".}

template len*[S; T](pm: ProgmemArray[S, T]): auto = ## \
  ## Returns the length of a program memory array.
  when T is cchar:
    S - 1
  else:
    S

template `[]`*[T](pm: ProgramMemory[T]): T = ## \
  ## Dereference operator used to access data stored in program memory. 
  ## Note that this must generate a copy of said data, in order to make it 
  ## available to the user. This can be used for numbers and for objects 
  ## without loss of generality.

  var res {.noInit.}: T

  when T is SomeNumber and sizeof(T) <= 4:
    when typeof(T) is float32:
      res = readFloatNear(pm.addr).T
    elif sizeof(T) == 1:
      res = readByteNear(pm.addr).T
    elif sizeof(T) == 2:
      res = readWordNear(pm.addr).T
    elif sizeof(T) == 4:
      res = readDWordNear(pm.addr).T
  else:
    when typeof(T) is array and sizeof(T) != 0:
      pm_memcpy(addr res[0], pm_ptr_off(pm, 0), sizeof(T).csize_t)
    else:
      pm_memcpy(addr res, pm_ptr(pm), T.sizeof.csize_t)
  res

template `[]`*[S: static int; T](pm: ProgmemArray[S, T]; i: int): T =
  ## Dereference operator used to access elements of an array stored in
  ## program memory. Note that this must generate a copy of said data, in
  ## order to make it available to the user.
  when compileOption("rangeChecks"):
    if i < 0 and i >= S:
      quit(1)

  var res {.noInit.}: T

  when typeof(T) is float32:
    res = readFloatNear(pm_ptr_off(pm, i)).T
  else:
    when sizeof(T) == 1:
      res = readByteNear(pm_ptr_off(pm, i)).T
    elif sizeof(T) == 2:
      res = readWordNear(pm_ptr_off(pm, i)).T
    elif sizeof(T) == 4:
      res = readDWordNear(pm_ptr_off(pm, i)).T
    else:
      pm_memcpy(addr res, pm_ptr_off(pm, i), csize_t(sizeof(T)))
  res

template readFromAddress*[T](a: uint16) : T =
  ## Reads from a program memory address directly.
  ## To be used when in need of accessing progmem data that was not initialized
  ## by the current application.
  when T is SomeNumber and sizeof(T) <= 4:
    when typeof(T) is float32:
      readFloatNear(cast[pointer](a))
    else:
      when sizeof(T) == 1:
        readByteNear(cast[pointer](a)).T
      elif sizeof(T) == 2:
        readWordNear(cast[pointer](a)).T
      elif sizeof(T) == 4:
        readDWordNear(cast[pointer](a)).T
  else:
    var e {.noInit.} : T
    discard pm_memcpy(addr e, cast[pointer](a), csize_t(sizeof(T)))
    e

iterator progmemIter*[S: static int; T](pm: ProgmemArray[S, T]): T =
  ## Iterator that can be used to safely traverse program memory arrays.
  ## Note that this must generate a copy of each element iterated, in order to 
  ## make it available to the user.

  template loop_condition(idx: int): bool =
    when T is cchar: i < S and pm[i] != '\0'
    else: i < S

  var i = 0
  while loop_condition(i):
    yield pm[i]
    inc i

iterator progmemIter*[S: static int](pm: ProgmemString[S]): cchar =
  ## Iterator that can be used to safely traverse program memory cchar arrays.
  ## Note that this must generate a copy of each element iterated, in order to 
  ## make it available to the user. 

template `==`*[S: static int; T](d: array[S, T], pm: ProgmemArray[S, T]): bool =
  ## Efficiently checks for equality between an in-memory array and one in
  ## program memory.

  if d.len != pm.len:
    return false

  var idx = 0
  for idx, elem in progmemIter(pm):
    if s[idx] != elem: return false
    inc idx
  true

proc `==`*[S: static int](d: StringType, pm: ProgmemString[S]): bool =
  ## Efficiently checks for equality between an in-memory string and one in
  ## program memory.

  if d.len != pm.len:
    return false

  var idx = 0
  for elem in progmemIter(pm):
    if d[idx] != elem: return false
    inc idx
  true

template `==`*[T](d: T, pm: ProgramMemory[T]): bool =
  ## Checks for equality between an in-memory datum and one in program memory.
  d == pm[]

template `==`*[S: static int](pm: ProgmemString[S], d: StringType): bool =
  ## Efficiently checks for equality between an in-memory string and one in
  ## program memory.
  d == pm

template `==`*[T](pm: ProgramMemory[T], d: T): bool =
  ## Checks for equality between an in-memory datum and one in program memory.
  d == pm

template `!=`*[T](d: T, pm: ProgramMemory[T]): bool =
  ## Checks for inequality between an in-memory datum and one in program memory.
  not (d == pm)

template `!=`*[T](pm: ProgramMemory[T], d: T): bool =
  ## Checks for inequality between an in-memory datum and one in program memory.
  not (d == pm)

proc `in`*[S: static int](sub: StringType, pm: ProgmemString[S]): bool =
  ## Efficiently checks that a substring is contained in the passed program
  ## memory string.
  let
    tot_len = pm.len
    sub_len = sub.len

  for idx in 0..(tot_len - sub_len):
    var jdx = 0
    while jdx < sub_len and pm[idx + jdx] == sub[jdx]:
      inc jdx

    if jdx == sub_len:
      return true
  false

template `in`*[S: static int](pm: ProgmemString[S], sub: StringType): bool =
  ## Efficiently checks that a substring is contained in the passed program
  ## memory string.
  sub in pm

template `notin`*[S: static int](sub: StringType, pm: ProgmemString[S]): bool =
  ## Efficiently checks that a substring is not contained in the passed program
  ## memory string.
  not (sub in pm)

template `notin`*[S: static int](pm: ProgmemString[S], sub: StringType): bool =
  ## Efficiently checks that a substring is not contained in the passed program
  ## memory string.
  not (sub in pm)

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
    const (msg, ok) = get_type_repr(`name_str`, `rval`, true)
    when not ok:
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
