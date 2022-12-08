# TODO: IST attributes (block, non block, naked, aliasof)

when defined(USING_ATMEGA644):
  include avr_io/interrupt/private/atmega644
else:
  echo "undefined architecture"


template vectorDecl*(interrupt: VectorInterrupt): string =
  const n = $ord(interrupt)
  "$1  __vector_" & n & "$3 __attribute__((__signal__,__used__,__externally_visible__)); $1 __vector_" & n & "$3"

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
