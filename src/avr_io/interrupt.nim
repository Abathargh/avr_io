# TODO: IST attributes (block, non block, naked, aliasof)

import macros

when defined(USING_ATMEGA328P):
  include interrupt/private/atmega328p
elif defined(USING_ATMEGA644):
  include interrupt/private/atmega644
else:
  static:
    error "undefined architecture"


template vectorDecl(n: int): string =
  "$1  __vector_" & $n & "$3 __attribute__((__signal__,__used__,__externally_visible__)); $1 __vector_" & $n & "$3"


macro isr*(v: static[VectorInterrupt], p: untyped): untyped =
  ## Turns the passed procedure into an interrupt serrvice routine.
  ## This macro applies a series of pragmas to the procedure, that are
  ## necessary to map it to the specified interrupt handle.
  ## Use as a macro pragma.
  var pnode = p
  if p.kind == nnkStmtList:
    pnode = p[0]
  expectKind(pnode, nnkProcDef)
  addPragma(pnode, newIdentNode("exportc"))
  addPragma(pnode, newNimNode(nnkExprColonExpr).add(newIdentNode("codegenDecl"), newLit(vectorDecl(ord(v)))))
  pnode

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
