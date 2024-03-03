# progmem

An example application showcasing how to interact the usart peripherals.
This project actually includes two sub-application, one showcasing a basic 
way to use the Usart peripheral, and another showing it in 9-bit mode.

## Dependencies

- ```avr-gcc```
- ```avr-libc```
- ```avrdude```

## Building the project

To build the project, just run:

```bash
nimble build
```

Additional targets:

```bash
nimble clear       # cleans the artifacts from a previous build
nimble flash       # flashes the .hex file onto the Arduino Uno
nimble flash_debug # flashes the .elf file onto the Arduino Uno
```

Notice that the specified port is the default one for an Arduino on Linux, 
change it accordingly to your system.

Once you have flashed the sketch, you can verify that the Arduino Uno is 
sending the progmem data through the serial port.

## Check the results

Once the application is uploaded onto the board, you can test it out using 
the `serial_read` python script included wihtin this example project 
`scripts` directory.

```bash
nimble build
nimble flash
./scripts/serial_test
```

Note that this requires a `python3` installation, together with the 
`pyserial` library.