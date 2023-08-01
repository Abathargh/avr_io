# progmem

An example application showcasing how to interact with progmem data.

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

Once you have flashed the sketch, you can verify that the Arduino Uno is sending 
the progmem data through the serial port.
