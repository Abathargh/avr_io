## Various utilities aimed at interacting with the system itself, like 
## interacting with elf sections, or jumping to the application reset handler.

import std/strutils
import std/macros

import ./private/codegen

template jumpToApplication*() =
  ## Jumps to the main application reset handler.
  ## AVR bootloaders are stored at the end of the program memory, 
  ## and applications are usually stored at the beginning.
  asm """
    jmp 0000
  """


proc jumpTo*(address: uint8) {.inline.} =
  ## Jumps to the procedure stored in the passed address.
  ## Useful when handling more than one applications in program memory.
  asm """
    mov ZH, %B0
    mov ZL, %A0
    ijmp
    :
    : "r" (`address`)
    : "r30", "r31"
  """


template useIntBootTable* =
  ## Switch the interrupt vectors location to the beginning of the bootloader
  ## section within the flash memory.
  MCUCR.setBit(0'u8)
  MCUCR.setBit(1'u8)


template useIntAppTable* =
  ## Switch the interrupt vectors location to the beginning of the flash
  ## memory.
  MCUCR.setBit(0'u8)
  MCUCR.clearMask(0x03)


template section_attr(sct, rval: string): string =
  "static $# $# __attribute__((__used__, section(\"" & sct & "\"))) = " & 
    escapeStrseq(rval)


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
  expectKind(lnode[0], nnkIdent)

  # Let us retrieve the name and the rval of the let statement
  let name = lnode[0]
  let rval = lnode[2]

  quote do:
    when typeOf(`rval`) is SomeNumber:
      const s = $`rval`
    elif typeOf(`rval`) is string:
      const s = `rval`
    elif typeOf(`rval`) is array:
      const s = multiReplace($`rval`, ("[", "{"), ("]", "}"))
    elif typeOf(`rval`) is object:
      const (s, _) = substStructFields(($`rval`))
    else:
      static:
        error "'section' can only be used to annotate let statements " &
          "containing literal rvalues, or compile-time function calls " &
          "returning literal rvalues, got '$#'" % $`rval`.typeOf 

    let `name` {.importc, codegenDecl: section_attr(`s`, s)}: 
      `rval`.typeof
