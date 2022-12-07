# TODO: IST attributes (block, non block, naked, aliasof)

const vectorDecl* = "$1  __$2$3 __attribute__((__signal__,__used,__externally_visible)); $1 __$2$3"

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
