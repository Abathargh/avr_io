import macros


template jumpToApplication*() =
  asm """
    jmp 0000
  """


template section_attr(s: string): string =
  "$# $# __attribute__((section(\"" & s & "\")))"


macro section*(s: static[string]; l: untyped): untyped =
  var orig = l
  var lnode = orig
  if l.kind == nnkLetSection:
    lnode = l[0]
  expectKind(lnode, nnkIdentDefs)

  # Two cases: either the let definition has no pragma or 
  # it has some. Handle the two cases accordingly.

  # No pragma case
  if lnode[0].kind == nnkIdent:
    var p = newNimNode(nnkPragmaExpr).add(
      copyNimNode(lnode[0]),
      newNimNode(nnkPragma).add(
        newIdentNode("exportc"),
        newNimNode(nnkExprColonExpr).add(
          newIdentNode("codegenDecl"),
          newLit(section_attr(s))
        )
      )
    )

    lnode[0] = p
  orig
