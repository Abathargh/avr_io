# progmem

An example application showcasing how to interact the timer peripherals on an 
ATMega328p MCU. This is compatible with the Arduino Uno board.

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

## Check the results

Three pins are used as the output for three different waveforms managed by 
the timers:

| Timer  | Port/Pin | Mode            | Frequency |
|--------|----------|-----------------|-----------|
| Timer0 | PORTD[6] | CTC             | 2 MHz     |
| Timer1 | PORTB[5] | CTC + Interrupt | 125 Hz    |
| Timer2 | PORTD[3] | PWM 20%         | 1 MHz     |