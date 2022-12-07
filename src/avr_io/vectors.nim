# TODO: IST attributes (block, non block, naked, aliasof)

type 
   VectorInterrupt = enum
      Int0Vect         = 1,
      Int1Vect         = 2,
      Int2Vect         = 3,
      PCInt0Vect       = 4,
      PCInt1Vect       = 5,
      PCInt2Vect       = 6,
      PCInt3Vect       = 7,
      WdtVect          = 8,
      Timer2CompAVect  = 9,
      Timer2CompBVect  = 10,
      Timer2OvfVect    = 11,
      Timer1CaptVect   = 12,
      Timer1CompAVect  = 13,
      Timer1CompBVect  = 14,
      Timer1OvfVect    = 15,
      Timer0CompAVect  = 16,
      Timer0CompBVect  = 17,
      Timer0OvfVect    = 18,
      SpiStcVect       = 19,
      Usart0RxVect     = 20,
      Usart0UdreVect   = 21,
      Usart0TxVect     = 22,
      AnalogCompVect   = 23,
      AdcVect          = 24,
      EeReadyVect      = 25,
      TwiVect          = 26,
      SpmReadyVect     = 27


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
