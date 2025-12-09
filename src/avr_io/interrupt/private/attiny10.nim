type
  VectorInterrupt* = enum
    Int0Vect      = 1,
    PCInt0Vect    = 2,
    Tim0CaptVect  = 3,
    Tim0OvfVect   = 4,
    Tim0CompAVect = 5,
    Tim0CompBVect = 6,
    AnaCompVect   = 7,
    WdtVect       = 8,
    VlmVect       = 9,
    AdcVect       = 10,
