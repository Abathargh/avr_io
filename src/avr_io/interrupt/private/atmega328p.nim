type
   VectorInterrupt* = enum
      Int0Vect         = 1,
      Int1Vect         = 2,
      PCInt0Vect       = 3,
      PCInt1Vect       = 4,
      PCInt2Vect       = 5,
      WdtVect          = 6,
      Timer2CompAVect  = 7,
      Timer2CompBVect  = 8,
      Timer2OvfVect    = 9,
      Timer1CaptVect   = 10,
      Timer1CompAVect  = 11,
      Timer1CompBVect  = 12,
      Timer1OvfVect    = 13,
      Timer0CompAVect  = 14,
      Timer0CompBVect  = 15,
      Timer0OvfVect    = 16,
      SpiStcVect       = 17,
      Usart0RxVect     = 18,
      Usart0UdreVect   = 19,
      Usart0TxVect     = 20,
      AdcVect          = 21,
      EeReadyVect      = 22,
      AnalogCompVect   = 23,
      TwiVect          = 24,
      SpmReadyVect     = 25

