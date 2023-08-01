# arduino_uno_blink

A simple example of using the avr_io library to blink the builtin led of an Arduino Uno, 
using a timer-based delay with an interrupt service routine.

## Dependencies

- ```avr-gcc``
- ```avr-libc```
- ```avrdude```

## Building the project

To build the project, just run:

```bash
nimble build
```

Additional targets:

```bash
nimble clean       # cleans the artifacts from a previous build
nimble flash       # flashes the .hex file onto the Arduino Uno
nimble flash_debug # flashes the .elf file onto the Arduino Uno
```

Notice that the specified port is the default one for an Arduino on Linux, change it 
accordingly to your system.
