## A simple application running on an ATMega328P-based Arduino Uno using data 
## in program memory. It shows hot to interact with said data, sending it via 
## USART to another device.

import avr_io
import avr_io/progmem
import avr_io/interrupt

import volatile
import strutils


# The `progmem` macro allows the user to define a new symbol containing many 
# kinds of data
progmem(testFloat, 11.23'f32)             # like floats
progmem(testInt1,  12'u8)                 # 8-bit integers
progmem(testInt2,  13'u16)                # 16-bit integers
progmem(testInt3,  14'u32)                # 32-bit integers
progmem(testStr, "test progmem string\n") # or even strings


# Objects can also be stored in program memory. Note that if strings are 
# needed, the `cstring` type must be used, as the `string` type is  currently 
# not supported in progmem objects.
type 
  foo = object
    f1: int16
    f2: float32

  bar = object
    b1: bool 
    b2: cstring 

progmem(testObj1, foo(f1: 42'i16, f2: 45.67))
progmem(testObj2, bar(b1: true, b2: "test string in object\n"))


# The `progmemArray` macro allows the user to define a new symbol containing 
# an array of values. note that the type of the data is inferred from the 
# first element of the array, as normal.
progmemArray(testArr, [116'u8, 101, 115, 116, 32, 97, 114, 114, 97, 121, 10])


proc initTimer0() =
  # Same as in the arduino_uno_blink example.
  OCR0A[]  = 250
  TCCR0A.setBit(1)
  TCCR0B.setBit(2)
  TIMSK0.setBit(1)


# Global state, used to check if the ISR has been invoked
var read = false

proc timer0_compa_isr() {.isr(Timer0CompAVect).} =
  # Simple ISR being executed when the timer expires, every 4ms
  volatileStore(addr read, true)


proc sendAsBitstring[T: SomeNumber | bool](usart: Usart; num: T) =
  # If the data being sent is a number, this changes it to its bitstring 
  # representation and sends it through usart.
  when T is float32:
    usart.sendString("float ")
  elif T is uint8 or T is bool:
    usart.sendString("uint8 ")
  elif T is uint16:
    usart.sendString("uint16 ")
  else:
    usart.sendString("uint32 ")
  
  var b = cast[uint32](num)
  for i in 0..31:
    let wd = 31u32 - uint32(i)
    let sh = 1'u32 shl wd
    usart.sendByte(uint8('0') + uint8((b and sh) shr wd))
  usart.sendByte('\n')

proc sendProgmemVar(usart: Usart) =
  # To get the contents of a progmem variable, you just dereference said 
  # variable through the `[]` operator. Note that here, the values are used as  
  # temporaries.
  usart.sendAsBitstring(testFloat[])
  usart.sendAsBitstring(testInt1[])
  usart.sendAsBitstring(testInt2[])
  usart.sendAsBitstring(testInt3[])

  # Same thing for progmem objects! Dereference and then access the fields.
  usart.sendAsBitstring(testObj1[].f1)
  usart.sendAsBitstring(testObj1[].f2)
  usart.sendAsBitstring(testObj2[].b1)
  usart.sendString(testObj2[].b2)

  # Progmem arrays can also be indexed, passing an offset works too. 
  usart.sendByte(testArr[0])
  usart.sendByte(testArr[1])
  usart.sendByte(testArr[2])
  usart.sendByte(testArr[3])
  usart.sendByte('\n')

  # They can also be iterated, which is easier and safer.
  for num in progmemIter(testArr):
    usart.sendByte(num)
    
  # Or you can just dereference them and get a copy of the whole array.
  usart.sendBytes(testArr[])

  # Note that this works for progmem strings too: dereferencing one will yield 
  # an array[S, cchar].
  usart.sendString(testStr[])


proc loop =  
  sei()
  initTimer0()
  const baud = baudRate(9600'u32)
  usart0.initUart(baud, {}, {txen}, {ucsz1, ucsz0})
  
  while true:
    if volatileLoad(addr read):
      sendProgmemVar(usart0)
      volatileStore(addr read, false)
      
when isMainModule:
  loop()
