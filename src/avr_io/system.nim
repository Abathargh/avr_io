## Various utilities aimed at interacting with the system itself, like 
## interacting with elf sections, or jumping to the application reset handler.

import strutils
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


proc applySectionPragmas(node: NimNode, s: string): NimNode =
  # Applies the specific pragmas to the let variable definition-
  # It needs to be exportc and to have the proper attribute generated to 
  # indicate the section where to store the data through the usage of
  # __attribute__((section(...))) avr-gcc only.
  expectKind(node, nnkPragma)
  node.add(
    newIdentNode("exportc"),
    newNimNode(nnkExprColonExpr).add(
      newIdentNode("codegenDecl"),
      newLit(section_attr(s))
    )
  )


macro section*(s: static string; l: untyped): untyped =
  ## Specifies the elf section where to store the passed let defined symbol.
  ## This macro applies a series of pragmas to the symbol, that are
  ## necessary to make it possible to store its contents in the specified 
  ## section. 
  ## Use as a macro pragma.
  var
    orig = l
    lnode = orig
  
  if l.kind == nnkLetSection:
    lnode = l[0]
  expectKind(lnode, nnkIdentDefs)

  # Two cases: either the let definition has no pragma or 
  # it has some. Handle the two cases accordingly.
  if lnode[0].kind == nnkIdent:
    var p = newNimNode(nnkPragmaExpr).add(
      copyNimNode(lnode[0]),
      newNimNode(nnkPragma).applySectionPragmas(s)
    )
    lnode[0] = p
  elif lnode[0].kind == nnkPragmaExpr:
    lnode[0] = lnode[0].applySectionPragmas(s)
  else:
    error("Unexpected node kind $#" % $lnode[0].kind)
  orig
