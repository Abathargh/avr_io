# TODO: IST attributes (block, non block, naked, aliasof)

import macros

when defined(USING_ATMEGA644):
  include interrupt/private/atmega644
else:
  static:
    error "undefined architecture"


template vectorDecl(n: int): string =
  "$1  __vector_" & $n & "$3 __attribute__((__signal__,__used__,__externally_visible__)); $1 __vector_" & $n & "$3"


macro isr*(v: static[VectorInterrupt], p: untyped): untyped =
  var pnode = p
  if p.kind == nnkStmtList:
    pnode = p[0]
  expectKind(pnode, nnkProcDef)
  addPragma(pnode, newIdentNode("exportc"))
  addPragma(pnode, newNimNode(nnkExprColonExpr).add(newIdentNode("codegenDecl"), newLit(vectorDecl(ord(v)))))
  pnode

proc sei*() =
  asm """
    sei 
		:
		:
		: "memory"
  """

proc cli*() =
  asm """
    cli
		:
		:
		: "memory"
  """
