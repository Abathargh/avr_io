import macros


template jumpToApplication*() =
  ## Jumps to the main application reset handler.
  ## AVR bootloaders are stored at the end of the program memory, 
  ## and applications are usually stored at the beginning.
  asm """
    jmp 0000
  """


template section_attr(s: string): string =
  "$# $# __attribute__((section(\"" & s & "\")))"


macro section*(s: static[string]; l: untyped): untyped =
  ## Specifies the elf section where to store the passed let defined symbol.
  ## This macro applies a series of pragmas to the symbol, that are
  ## necessary to make it possible to store its contents in the specified 
  ## section. 
  ## Use as a macro pragma.
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
  else:
    # TODO pragma case
    error("Cannot use this pragma with other pragmas")
  orig
