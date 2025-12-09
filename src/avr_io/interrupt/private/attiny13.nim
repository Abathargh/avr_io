type
  VectorInterrupt* = enum
    Int0Vect      = 1,
    PCInt0Vect    = 2,
    Tim0OvfVect   = 3,
    EeRdyVect     = 4,
    AnaCompVect   = 5,
    Tim0CompAVect = 6,
    Tim0CompBVect = 7,
    WdtVect       = 8,
    AdcVect       = 9,
