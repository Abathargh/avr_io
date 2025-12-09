type
  VectorInterrupt* = enum
    Int0Vect       = 1,
    IoPinsVect     = 2,
    Timer1CmpaVect = 3,
    Timer1CmpbVect = 4,
    Timer1Ovf1Vect = 5,
    Timer0Ovf0Vect = 6,
    UsiStrtVect    = 7,
    UsiOvfVect     = 8,
    EeRdyVect      = 9,
    AnaCompVect    = 10,
    AdcVect        = 11,
