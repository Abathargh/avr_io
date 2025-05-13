## The interrupt module provides facilities to implement ISRs for AVR chips, 
## and to easily interact with interrupt-related procedures.

import macros

when defined(USING_ATMEGA16U4):
  include interrupt/private/atmega16u4_32u4
elif defined(USING_ATMEGA32U4):
  include interrupt/private/atmega16u4_32u4
elif  defined(USING_ATMEGA328P):
  include interrupt/private/atmega328p
elif defined(USING_ATMEGA644):
  include interrupt/private/atmega644
elif defined(USING_ATMEGA640):
  include interrupt/private/atmega64_128_256_01
elif defined(USING_ATMEGA1280):
  include interrupt/private/atmega64_128_256_01
elif defined(USING_ATMEGA1281): 
  include interrupt/private/atmega64_128_256_01
elif defined(USING_ATMEGA2560): 
  include interrupt/private/atmega64_128_256_01
elif defined(USING_ATMEGA2561):
  include interrupt/private/atmega64_128_256_01
else:
  static:
    error "undefined architecture"

type
  IsrFlag* = enum
    IsrBlock   = ""
    IsrNoBlock = "__attribute__((__interrupt__))"
    IsrNaked   = "__attribute__((__naked__))"
  IsrFlags* = set[IsrFlag]

template vectorDecl(n: int, flags: IsrFlags): string =
  var attrs = ""
  for flag in IsrFlag.items():
    if flag in flags:
      attrs &= " " & $flag
  "$1  __vector_" & $n &
  "$3 __attribute__((__signal__,__used__,__externally_visible__)); " &
   attrs & " $1 __vector_" & $n & "$3"

macro isrIm(v: static VectorInterrupt, f: static IsrFlags, p: typed): untyped =
  var pnode = p
  if p.kind == nnkStmtList:
    pnode = p[0]

  expectKind(pnode, nnkProcDef)
  for node in pnode:
    if node.kind == nnkFormalParams:
      if node.len != 1 or node[0].kind != nnkEmpty:
        error "an ISR must have the following signature `proc f()`"

  addPragma(pnode, newIdentNode("exportc"))
  addPragma(pnode,
    newNimNode(nnkExprColonExpr).add(
      newIdentNode("codegenDecl"), newLit(vectorDecl(ord(v), f))
    )
  )
  pnode

template isr*(v: VectorInterrupt, p: typed): untyped =
  ## Turns the passed procedure into an interrupt service routine.
  ## This macro applies a series of pragmas to the procedure, that are
  ## necessary to map it to the specified interrupt handle.
  ## Use as a macro pragma.
  isrIm(v, {}, p)

template isr*(v: VectorInterrupt, f: IsrFlags, p: typed): untyped =
  ## Turns the passed procedure into an interrupt service routine, with the
  ## specified ISR flags to alter its behaviour:
  ## - IsrBlock: default behaviour, interrupts will be disabled for the
  ##   duration of the ISR.
  ## - IsrNoBlock: interrupts will still be enabled during the ISR handling;
  ##   note that this adds minimal overhead; use when in need of nested
  ##   interrupts.
  ## - IsrNaked: no preamble or epilogue will be generated for the ISR.
  ##   This means that the registers and return instruction must be manually
  ##   handled.
  ## This macro applies a series of pragmas to the procedure, that are
  ## necessary to map it to the specified interrupt handle.
  ## Use as a macro pragma.
  isrIm(v, f, p)

template sei*() =
  ## Sets the global interrupt flag within the status register, 
  ## enabling interrupts.
  asm """
    sei 
    :
    :
    : "memory"
  """

template cli*() =
  ## Clears the global interrupt flag within the status register, 
  ## disabling interrupts.
  asm """
    cli
    :
    :
    : "memory"
  """

template atomic*(code: untyped): untyped =
  ## Executes the passed block atomically, i.e. with interrupts being disabled.
  ## It re-enables them once the block is closed.
  try:
    cli()
    code
  finally:
    sei()

template withInterrupts*(code: untyped) =
  ## Executes the passed block with interrupts enabled, disabling them once
  ## the block is closed.
  try:
    sei()
    code
  finally:
    cli()
