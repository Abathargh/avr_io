## A simple application running on an ATMega328P-based Arduino Uno using data 
## in program memory. It shows how to interact with said data, sending it via 
## USART to another device.

import avr_io
import avr_io/progmem
import avr_io/interrupt

import volatile


# The `progmem` macro allows the user to store many kinds of data into program 
# memory. Note that a let statement is required. The type of the data is 
# inferred from the first element when using arrays.
let
  testFloat {.progmem.} = 11.23'f32               # like floats
  testInt1  {.progmem.} = 12'u8                   # 8-bit integers
  testInt2  {.progmem.} = 13'u16                  # 16-bit integers
  testInt3  {.progmem.} = 14'u32                  # 32-bit integers
  testStr   {.progmem.} = "test progmem string\n" # or even strings
  testArr   {.progmem.} = [116'u8, 101, 115, 116, # and arrays too
                           32, 97, 114, 114, 97,
                           121, 10]


# Objects can also be stored in program memory.
type 
  foo = object
    f1: int16
    f2: float32

  bar = object
    b1: bool
    b2: cstring # in objects, we must use cstring

  foobar = object
    fb1: bool
    fb2: foo

  barfoo = object
    bf1: int
    bf2: bar

  arr_elem = object
    i: int
    f: float

let 
  testObj1   {.progmem.} = foo(f1: 42'i16, f2: 45.67)
  testObj2   {.progmem.} = bar(b1: true, b2: "test string in object\n")
  testObj3   {.progmem.} = foobar(fb1: false, fb2: foo(f1: 21, f2: 77.0))
  testObj4   {.progmem.} = barfoo(bf1: 69, bf2: bar(b1: false, b2: "inner\n"))
  testArrObj {.progmem.} = [arr_elem(i: 1, f: 0.1), arr_elem(i: 2, f: 0.2)]


# Note: usage of {.progmem.} are type-checked, and only plain value types are
# accepted by the library. Try uncommenting the following line:
# let pm_seq {.progmem.} = @[12]


# To reserve a block of program memory of size `size`, containing objects of
# type `type`, use the `progmem_array(type, size)` macro. This is particularly
# useful when wanting to embed metadata within your binaries.
progmem_array(testNonInitArr, uint8, 10)


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
    usart.write("float ")
  elif T is uint8 or T is bool:
    usart.write("uint8 ")
  elif T is uint16:
    usart.write("uint16 ")
  else:
    usart.write("uint32 ")
  
  var b = cast[uint32](num)
  for i in 0..31:
    let wd = 31u32 - uint32(i)
    let sh = 1'u32 shl wd
    usart.write(uint8('0') + uint8((b and sh) shr wd))
  usart.write('\n')

proc sendProgmemVar(usart: Usart) =
  # To get the contents of a progmem variable, you just dereference said 
  # variable through the `[]` operator. Note that here, the values are used as  
  # temporaries.
  usart.sendAsBitString(testFloat[])
  usart.sendAsBitString(testInt1[])
  usart.sendAsBitString(testInt2[])
  usart.sendAsBitString(testInt3[])

  # Same thing for progmem objects! Dereference and then access the fields.
  usart.sendAsBitString(testObj1[].f1)
  usart.sendAsBitString(testObj1[].f2)

  usart.sendAsBitString(testObj2[].b1)
  usart.write(testObj2[].b2)

  usart.sendAsBitString(testObj3[].fb1)
  usart.sendAsBitString(testObj3[].fb2.f1)
  usart.sendAsBitString(testObj3[].fb2.f2)

  usart.sendAsBitString(testObj4[].bf1)
  usart.sendAsBitString(testObj4[].bf2.b1)
  usart.write(testObj4[].bf2.b2)

  # Progmem arrays can also be indexed, passing an offset works too.
  usart.write(testArr[0])
  usart.write(testArr[1])
  usart.write(testArr[2])
  usart.write(testArr[3])
  usart.write('\n')

  # They can also be iterated, which is easier and safer.
  for num in progmemIter(testArr):
    usart.write(num)

  # Or you can just dereference them and get a copy of the whole array.
  usart.write(testArr[])
  usart.write(testNonInitArr[])
  usart.write('\n')

  # Note that this works for progmem strings too: dereferencing one will yield
  # an array[S, cchar].
  usart.write(testStr[])

  # we can also use some notable procs and operators on progmem types

  # you can use len on any valid progmem array (including strings)
  usart.write_line("testArrObj.len = ")
  usart.sendAsBitString(testArrObj.len.uint8)

  # and also use `==` and `!=`
  if testInt1 == 12'u8:
    usart.write("12 matches")

  if testStr == "test progmem string\n":
    usart.write_line("string match")

  if testStr != "test wrong string\n":
    usart.write_line("string not matching")

  if testInt3 != 42'u32:
    usart.write_line("testInt3 is not 42")

  # you can also use `in` but only for progmem strings
  if "string" in testStr:
    usart.write_line("testStr contains the substring 'string'")

  if "wrong" notin testStr:
    usart.write_line("testStr does not contain the substring 'wrong'")

proc loop =  
  sei()
  initTimer0()
  const baud = baudRate(9600)
  usart0.initUart(baud, {}, {txen}, {ucsz1, ucsz0})
  
  while true:
    if volatileLoad(addr read):
      sendProgmemVar(usart0)
      volatileStore(addr read, false)
      
when isMainModule:
  loop()
