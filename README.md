# avr_io - nim register bindings and utilities for AVR microcontrollers

This library provides a series of bindings for memory-mapped registers, 
peripherals, and many other functionalities related to AVR microcontrollers.

Any project using this library must use avr-gcc as its C backend.

**NOTE: the contents of the library are highly experimental, they are not 
recomended for use in production code, APIs may break at any time!**

- [avr\_io - nim register bindings and utilities for AVR microcontrollers](#avr_io---nim-register-bindings-and-utilities-for-avr-microcontrollers)
  - [Support](#support)
  - [Install](#install)
  - [Documentation](#documentation)
  - [License](#license)


## Support

The nim modules that offer IO register mappings and ISR definitions are 
generated using the chips' datasheets as a reference. 

The library currently supports the following chips:

- ATMega16U4
- ATMega32U4
- ATMega328P
- ATMega640
- ATMega644
- ATMega1280
- ATMega1281
- ATMega2560
- ATMega2561

## Install

```bash 
nimble install avr_io
```

## Documentation

There are three main documentation sources for this project:
- [The wiki](https://github.com/Abathargh/avr_io/wiki) hosted within the 
avr_io github page.
- The examples contained within the `examples` directory, that hosts a series 
of nimble projects ready to use and to be consulted, going quite thoroughly 
in detail on how to use the library.
- The in-comment documentation.

You can generate the documentation for this module and its submodules by 
running the following command from the root directory of the project:

```bash
nim doc --project --index:on -d:USING_ATMEGA328P --outdir:docs src/avr_io.nim
```

Note that you have to specify the microcontroller you are using, like when 
setting up the library.

## License

This library is licensed under the [BSD 3-Clause "New" or "Revised" License](
#LICENSE.md).
