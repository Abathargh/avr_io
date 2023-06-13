# avr_io - nim mappings for AVR IO registers and ISRs

This library has the objective of collecting memory mappings of the IO hardware registers of AVR microcontrollers, and it's inspired by the avr/io headers from the avr-gcc suite. It must be used with avr-gcc as the C backend.

**NOTE: the contents of the library are highly experimental, they are not recomended for use in production code, APIs may break at any time!**

- [avr\_io - nim mappings for AVR IO registers and ISRs](#avr_io---nim-mappings-for-avr-io-registers-and-isrs)
  - [Support](#support)
  - [Setup](#setup)
    - [nim.cfg](#nimcfg)
    - [panicoverride.nim](#panicoverridenim)
  - [Usage](#usage)
    - [Accessing IO registers](#accessing-io-registers)
    - [Using Port objects](#using-port-objects)
    - [Defining interrupt service routines](#defining-interrupt-service-routines)
    - [Enabling/disabling interrupts](#enablingdisabling-interrupts)
    - [A complete example](#a-complete-example)


## Support

The nim modules that offer IO register mappings and ISR definitions are generated using the chips' datasheets as a reference. 

The library currently supports the following chips:

- ATMega328P
- ATMega644
- ATMega2560/1
- ATMega1280/1

## Setup

To use this library on an AVR chip, you will have to
- pass ```avr``` as the cpu option to the compiler;
- pass ```standalone``` as the os type.
- define a ```panicoverride.nim``` file.

Optionally you may want to:
- pass ```none``` as the gc (if you do not want to deal with dynamic memory, otherwise ```--gc:arc```, ```--gc:orc``` and ```-d:useMalloc``` are not a bad choice);


### nim.cfg

The following is a template nim.cfg file containing various flags that you can use a s a reference to set up a project

Note that you should pass the ```-mmcu``` and ```-DF_CPU``` flags according to the MCU you are using and the clock frequncy that you have set up.

You must also define the symbol ```USING_XXX``` where ```XXX``` is the name of the MCU you want to use.

For example, if I am using an atmega644 MCU, I would define the ```USING_ATMEGA664``` symbol in the nim.cfg file. 
 
 **NOTE: This syntax could change in the future.**


```cfg
os = "standalone"
cpu = "avr"
gc = "none" 
stackTrace = "off" 
lineTrace = "off" 
define = "release"
define = "USING_ATMEGA644"
passC = "-mmcu=atmega644 -DF_CPU=16000000"
passL = "-mmcu=atmega644 -DF_CPU=16000000"
nimcache=.nimcache

avr.standalone.gcc.options.linker = "-static" 
avr.standalone.gcc.exe = "avr-gcc"
avr.standalone.gcc.linkerexe = "avr-gcc"
```

When cross-compiling for AVR MCUs on Windows, the following option may be required:
```cfg
gcc.options.always = ""
```

### panicoverride.nim

When compiling with ```--os:standalone``` you must provide a ```panicoverride.nim``` file.

If you are not going to use echo, you do not need to provide a printf implementation, and the following panicoverride (a modified version of the original from the tests/avr directory within the nim sources) is more than enough:

```nim
proc exit(code: int) {.importc, header: "<stdlib.h>", cdecl.}

{.push stack_trace: off, profiler:off.}

proc rawoutput(s: string) = discard

proc panic(s: string) =
  rawoutput(s)
  exit(1)

{.pop.}
```

Note that any error caused by a failing bound-check, overflow, etc. will cause a call to the panic proc defined within the panicoverride.nim file. This makes it possible to use the panic proc for diagnostic purposes in debug builds.

Using ```---define:danger``` removes those checks.


## Usage

The following is a quick intro to the features of this library. Note that you can find some complete working examples within the ```examples``` directory.


### Accessing IO registers

As in the original avr/io.h header, you just import the top module and the only definitions that will be compiled will be the ones related to the specified MCU:


```nim
import avr_io

when isMainModule:
  DDRA[] = 1
  PORTA[] = 1
  while true: 
    discard
```

### Using Port objects

In order to interface with ports in a simpler way, a number of ```Port``` objects are available for each microcontroller. 

```Port``` objects are simple objects containing the direction, input and output register for a specific port:

```nim
type
  Port* = object
    direction: MappedIoRegister[uint8]
    output: MappedIoRegister[uint8]
    input: MappedIoRegister[uint8]
```

A series of templates are defined to simplify access in write and read mode to the specific port or a specific pin of a port:

```nim
import avr_io

const 
  blinkPin = 1'u8
  ctlPin = 2'u8

proc loop = 
  ## Assuming this MCU has a "portA" and a "portB" port
  portA.asOutputPin(blinkPin)
  portB.asOutputPin(ctlPin)
  portB.setPin(ctlPin)
  while true:
    portA.togglePin(blinkPin)
    # some delay
```

The following is the current complete Port API:

- ```asOutputPin*(p: Port, pin: uint8)```
- ```asInputPin*(p: Port, pin: uint8)```
- ```asOutputPort*(p: Port)```
- ```asInputPort*(p: Port)```
- ```setupWithMask*(p: Port, mask: uint8)```
- ```setupWithClearedMask*(p: Port, mask: uint8)```
- ```asInputPullupPin*(p: Port, pin: uint8)```
- ```disablePullup*(p: Port, pin: uint8)```
- ```setPin*(p: Port, pin: uint8)```
- ```clearPin*(p: Port, pin: uint8)```
- ```togglePin*(p: Port, pin: uint8)```
- ```readPin*(p: Port, pin: uint8): uint8```
- ```setPort*(p: Port)```
- ```clearPort*(p: Port)```
- ```setPortValue*(p: Port, val: uint8)```
- ```readPort*(p: Port): uint8```
- ```setMask*(p: Port, mask: uint8)```
- ```clearMask*(p: Port, mask: uint8)```
- ```readMask*(p: Port, mask: uint8): uint8```

### Defining interrupt service routines

When defining an ISR, you must associate your procedure with the specific interrupt, defined in ```avr_io/interrupt/private/{mcu_part_number}```. 

Every module tied to an MCU defines an enum type that describes each interrupt implemented by the MCU and maps it to the C name expected by avr-gcc. In order to map the interrupt to the avr-gcc handle, you can use the ```isr``` macro defined in ```avr_io/interrupt```.

The following example defines an ISR that handles the CompareA interrupt for Timer0 in an ATMega644:

```nim
import avr_io/interrupt

proc timer0_compa_isr() {.isr(Timer0CompAVect).} =
  discard
```

You can also write the same function with the following alternative syntax:

```nim
import avr_io/interrupt

isr(Timer0CompAVect):
  proc timer0_compa_isr() =
    discard
```


### Enabling/disabling interrupts

 The ```sei``` and ```cli``` procedures can be used to respectively enable and disable interrupts.

```nim
import volatile
import avr_io/interrupt

ctr: uint16 = 0

proc timer0_compa_isr() {.isr(Timer0CompAVect).} =
  let c = volatileLoad(addr ctr)
  volatileStore(addr ctr, c + 1)
  

proc loop() =
  sei()
  while true:
    let c = volatileLoad(addr ctr)
    if c > 250:
      cli()
```


### A complete example

The following example implements a simple interrupt-based application, that makes a LED connected on PA0 blink at f = 1 Hz:

```nim
import avr_io
import avr_io/interrupt

import bitops
import volatile

var ctr: uint16 = 0

proc initTimer0() =
  #[
    Timer0 in CTC mode, interrupt on compare match with OCR0A
    Prescaling the clock of a factor of 256.
    Considering:
      f = 16 MHz; f_tim0 = f/256 = 16 MHz / 256 = 62,5 KHz
      t_tim0 = 1/t_tim0 = 16 us;
      t_int = t_tim0 * OCR0A = 16 us * 250 = 4 ms
    This configuration raises an interrupt every 4 ms
  ]#
  OCR0A[]  = 250
  TCCR0A[] = 1 shl 1
  TCCR0B[] = 1 shl 2
  TIMSK0[] = 1 shl 1

proc timer0_compa_isr() {.isr(Timer0CompAVect).} =
  let c = volatileLoad(addr ctr)
  volatileStore(addr ctr, c + 1)

proc loop() = 
  sei()
  initTimer0()

  DDRA[]  = 1 shl 0
  PORTA[] = 0
  
  while true:
    # c > 250 => switch the led every 250 interrupts, or every 1s
    let c = volatileLoad(addr ctr)
    if c > 250:
      PORTB[] = bitxor(PORTB[], 1 shl 0)
      volatileStore(addr ctr, 0)

      
when isMainModule:
  loop()
```