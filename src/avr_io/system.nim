import macros

template jumpToApplication*() =
  asm """
    jmp 0000
  """

template section_attr(s: string): string =
  "$1 $2 $3 __attribute__((section(" & s & ")))"


macro section*(s: static[string]; c: untyped): untyped =
  var cnode = c
  if c.kind == nnkConstSection:
    cnode = c[0]
  expectKind(cnode, nnkConstDef)

  # Two cases: either the const definition has no pragma or 
  # it has some. Handle the two cases accordingly.

  # No pragma case
  if cnode[0].kind == nnkIdent:
    var p = newNimNode(nnkPragmaExpr).add(
      copyNimNode(cnode[0]),
      newNimNode(nnkPragma).add(
        newIdentNode("importc"),
        newNimNode(nnkExprColonExpr).add(
          newIdentNode("codegenDecl"),
          newLit(section_attr(s))
        )
      )
    )

    cnode[0] = p
  cnode
