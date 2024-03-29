## Utilities to interact with program memory in AVR chips. This module 
## provides primitives useful to store data in program memory, retrieve it and 
## manipulate it.

import macros
import tables

# TODOs:
# - [ ] support for far operations
#   - [ ] type FarProgramMemory*[T] = distinct T
#   - [ ] add atmega1284 support (registers/interrupts) once we're at it?
#   - [ ] unify types? memcpy_P/PF may be used for pm[] accesses for S > 4B
# - [x] compile time replace in progmem objects (fields -> .fields in C)
# - [ ] wrap other _P and _PF functions in pgmspace.h

type ProgramMemory*[T] = distinct T ## \
  ## An handle to data store in program memory.

template pmPtr[T](pm: ProgramMemory[T]): ptr T =
  unsafeAddr T(pm)

template pmPtrU16[T](pm: ProgramMemory[T]): uint16 =
  cast[uint16](unsafeAddr pm)

template pmPtrOff[S; T](pm: ProgramMemory[array[S, T]]; off: int): ptr T =
  unsafeAddr array[S, T](pm)[off]

template pmPtrOffU16[S; T](pm: ProgramMemory[array[S, T]], off: int): uint16 =
  cast[uint16](unsafeAddr array[S, T](pm)[off])

proc readByteNear(a: uint16): uint8 
  {.importc: "pgm_read_byte", header:"<avr/pgmspace.h>".}

proc readWordNear(a: uint16): uint16
  {.importc: "pgm_read_word", header:"<avr/pgmspace.h>".}

proc readDWordNear(a: uint16): uint32 
  {.importc: "pgm_read_dword", header:"<avr/pgmspace.h>".}

proc readFloatNear(a: uint16): float32 
  {.importc: "pgm_read_float", header:"<avr/pgmspace.h>".}

proc memCompare[T](s1, s2: ptr T, s: int): int
  {.importc: "memcmp_P", header: "<avr/pgmspace.h>".} 

proc memCopy[T](dest, src: ptr T; len: csize_t): ptr T 
  {.importc: "memcpy_P", header: "<avr/pgmspace.h>".}

proc strNCompare[T](dest, src: ptr T; len: csize_t): int
  {.importc: "strncmp_P", header: "<avr/pgmspace.h>".} 

proc strNCopy[T](dest, src: ptr T; len: csize_t): ptr T 
  {.importc: "strncpy_P", header: "<avr/pgmspace.h>".}

proc strStr[T](dest, src: ptr T): int
  {.importc: "strstr_P", header: "<avr/pgmspace.h>".}


template len*[S; T](pm: ProgramMemory[array[S, T]]): untyped = S ## \
  ## Returns the length of a program memory array.


template `[]`*[T](pm: ProgramMemory[T]): T =
  ## Dereference operator used to access data stored in program memory. 
  ## Note that this must generate a copy of said data, in order to make it 
  ## available to the user. This can be used for numbers and for objects 
  ## without loss of generality.
  when T is SomeNumber and sizeof(T) <= 4:
    when typeof(T) is float32:
      readFloatNear(pmPtrU16(pm))
    elif sizeof(T) == 1:
      readByteNear(pmPtrU16(pm))
    elif sizeof(T) == 2:
      readWordNear(pmPtrU16(pm))
    elif sizeof(T) == 4:
      readDWordNear(pmPtrU16(pm))   
  else:
    var e {.noInit.} : T 
    discard memCopy(addr e, pmPtr(pm), csize_t(sizeof(T))) 
    e

template `[]`*[S: static[int]; T](pm: ProgramMemory[array[S, T]]; i: int): T =
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
      discard memCopy(addr e, pmPtrOff(pm, i), csize_t(sizeof(T)))
      e


proc readFromAddress*[T](a: uint16) : T =
  ## Reads from a program memory address directly-
  ## To be used when in need of accessing progmem data that was not initialized 
  ## by the current application.
  when T is SomeNumber and sizeof(T) <= 4:
    when typeof(T) is float32:
      readFloatNear(a)
    else:
      when sizeof(T) == 1:
        readByteNear(a)
      elif sizeof(T) == 2:
        readWordNear(a)
      elif sizeof(T) == 4:
        readDWordNear(a)
  else:
    let p = cast[ptr T](a)
    var e {.noInit.} : T 
    discard memCopy(addr e, p, csize_t(sizeof(T)))
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


proc wrapC(s: string = "", equal: bool = true, is_str: bool = false): string =
  var s = s
  if is_str:
    s = "\"" & s & "\""

  if equal:
    "static const $# $# __attribute__((__progmem__)) = " & escapeStrseq(s)
  else:
    "static const $# $# __attribute__((__progmem__))"


proc substStructFields(s: string): string =
  # Hand-rolled FSM-based struct parsing proc, since it is not possible to 
  # use the 're' module at compile-time. TODO modify to accept objects as 
  # params to objects - this may requires some parsing action? 
  # TODO if an open ( is met, go back to identifier and call recursively
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


template substBraces(s: static[string]): string =
  # Cannot use strutils.multiReplace; importing strutils causes the following
  # error: 
  #  `.choosenim/toolchains/nim-2.0.0/lib/pure/unicode.nim(849, 36) Error: 
  #  type mismatch: got 'int32' for 'RuneImpl(toLower(ar)) - 
  # RuneImpl(toLower(br))' but expected 'int'`
  var r: string = newStringOfCap(s.len)
  for c in s:
    case c 
      of '[':
        r.add('{')
      of ']':
        r.add('}')
      else:
        r.add(c)
  r


proc eval(n: NimNode): (string, NimNode)


proc eval_obj(nc: NimNode): (string, NimNode) =
  var s = "{"
  if nc.kind != nnkObjConstr:
    error "Expected object construction, got: " & $nc.kind

  for i in 1 ..< nc.len:
    let 
      nameNode = nc[i][0]
      valNode  = nc[i][1]
      (value, _) = eval(valNode)

    s.add("." & nameNode.strVal() & "=" & value)
    if i != nc.len - 1:
      s.add(", ")
  s.add("}")
  (s, nc[0])


proc eval_array(an: NimNode): (string, NimNode) =
  var s = "{"
  if an.kind != nnkBracket:
    error "Expected array literal, got: " & $an.kind

  var node_type: NimNode = nil

  for i in 0 ..< an.len:
    let valNode = an[i]
    let (value, node_type_eval) = eval(valNode)

    if node_type == nil:
      node_type = node_type_eval

    s.add(value)
    if i != an.len - 1:
      s.add(", ")
  
  s.add("}")
  (s, newNimNode(nnkBracketExpr).add(
      newIdentNode("array"),
      newLit(an.len-1),
      node_type
  ))


const
  nnkTable = {
    nnkCharLit:      "char",
    nnkIntLit:       "int",
    nnkInt8Lit:      "int8",
    nnkInt16Lit:     "int16",
    nnkInt32Lit:     "int32",
    nnkInt64Lit:     "int64",
    nnkUIntLit:      "uint",
    nnkUInt8Lit:     "uint8",
    nnkUInt16Lit:    "uint16",
    nnkUInt32Lit:    "uint32",
    nnkUInt64Lit:    "uint64",
    nnkFloatLit:     "float",
    nnkFloat32Lit:   "float32", 
    nnkFloat64Lit:   "float64",
    nnkStrLit:       "string", 
    nnkRStrLit:      "string",
    nnkTripleStrLit: "string"
  }.toTable


proc eval(n: NimNode): (string, NimNode) {.compileTime.} =
  result = case n.kind
  of nnkCharLit..nnkUInt64Lit:   ($n.intVal, newIdentNode(nnkTable[n.kind]))
  of nnkFloatLit..nnkFloat64Lit: ($n.floatVal, newIdentNode(nnkTable[n.kind]))
  of nnkStrLit..nnkTripleStrLit: ("\"" & n.strVal & "\"", newIdentNode(nnkTable[n.kind]))
  of nnkObjConstr: eval_obj(n)
  of nnkBracket: eval_array(n)
  of nnkIdent: 
    if n.strVal != "true" and n.strVal != "false":
      raise newException(
        ValueError, 
        "Invalid value for eval: " & $n.kind & " (" & $n.strVal & ")")
    (n.strVal, newIdentNode("bool"))
  else:
    raise newException(ValueError, "Invalid value for eval: " & $n.kind)


macro progmem*(l: untyped): untyped =
  ## Stores the value contained in the let expression tagged with this macro 
  ## pragma in program memory. Use only with literals.
  
  # First, let's check if we are in a let section and if everything checks out 
  # with reference to where we are in the AST.
  var 
    orig = l
    lnode = if l.kind == nnkLetSection: 
        l[0] 
      else: 
        orig
  
  expectKind(lnode, nnkIdentDefs)
  expectKind(lnode[0], nnkIdent)

  # Let's evaluate the string representation of the literal that we want, and 
  # make it C-compliant, togethwer with the actual type of the nim node.
  let 
    rval = lnode[2]
    (str_val, node_type) = eval(rval)
    is_string = node_type.kind == nnkIdent and node_type.strVal == "string"
    wrapped = wrapC(str_val, true, is_string)

  # Adding the pragmas to the AST
  var p = newNimNode(nnkPragmaExpr).add(
    copyNimNode(lnode[0]),
    newNimNode(nnkPragma).add(
      newIdentNode("importc"),
      newIdentNode("global"),
      newIdentNode("noinit"),
      newNimNode(nnkExprColonExpr).add(
        newIdentNode("codegenDecl"),
        newLit(wrapped)
      )
    )
  )
  lnode[0] = p

  if lnode[1].kind == nnkEmpty:
    # No type provided in the let statement, let's add it
    lnode[1] = newNimNode(nnkBracketExpr).add(
      newIdentNode("ProgramMemory"),
      node_type
    )
  else:
    # Type provided in the let statement, let's use that
    lnode[1] = newNimNode(nnkBracketExpr).add(
      newIdentNode("ProgramMemory"),
      lnode[1]
    )

  lnode[2] = newNimNode(nnkEmpty)  
  orig


macro progmem*(n, v: untyped): untyped =
  ## Stores the value `v` in program memory, and creates a new symbol `n` 
  ## through which it is possible to access it. 
  quote do:
    when typeOf(`v`) is SomeNumber:
      const s = $`v`
      let `n` {.importc, codegenDecl: wrapC(s), global, noinit.}: 
        ProgramMemory[`v`.typeof]
    elif typeof(`v`) is string:
      let `n` {.importc, codegenDecl: wrapC(`v`, true, true), global, noinit.}: 
        ProgramMemory[array[`v`.len + 1, cchar]]
    else:
      const s = substStructFields(($`v`))
      let `n` {.importc, codegenDecl: wrapC(s), global, noinit.}: 
        ProgramMemory[`v`.typeof]


macro progmemArray*(n, v: untyped): untyped =
  ## Stores the array `v` in program memory, and creates a new symbol `n`
  ## through which it is possible to access it.
  quote do:
    const s = substBraces($`v`)
    let `n` {.importc, codegenDecl: wrapC(s), global, noinit.}: 
      ProgramMemory[array[`v`.len, `v`[0].typeof]]


macro progmemArray*(n: untyped; t: type; s: static[int]): untyped =
  ## Creates a new non-initialized program memory array, of size `s`, 
  ## containing elements of type `t`, and creates a new symbol `n` through 
  ## which it is possible to access it.
  quote do:
    let `n` {.importc, codegenDecl: wrapC("", false), global, noinit.}: 
      ProgramMemory[array[`s`, `t`]]
