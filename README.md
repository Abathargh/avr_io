# avr_io - nim register bindings and utilities for AVR microcontrollers

avr_io is a library written to make it easy to program AVR 
microcontrollers in nim. 

The library has a focus on low/no runtime costs, and it offers:

- Type-safe register bindings for AVR microcontrollers and an ergonomic 
  pin/port API.
- Interrupt service routine tagging, and interrupt-related utilities.
- Macro-based program memory storage support (aka `progmem`).
- Utilities for embedding data in elf sections, writing bootloaders.
- Partial support for peripherals for some chips (uart, timers, ports).


Any project using this library must use avr-gcc as its C backend.

**NOTE: the contents of the library are experimental, APIs may break before 
a v1.0 release!**

<!-- TOC -->
* [avr_io - nim register bindings and utilities for AVR microcontrollers](#avr_io---nim-register-bindings-and-utilities-for-avr-microcontrollers)
  * [Requirements](#requirements)
  * [Support](#support)
  * [Install](#install)
  * [Testing](#testing)
    * [Using `avr_io` in unit tests](#using-avr_io-in-unit-tests)
  * [Documentation](#documentation)
  * [License](#license)
<!-- TOC -->

## Requirements

- nim >= 2.0.10
- avr-gcc and avr-libc installed on your machine and available in your path.


## Support

The nim modules that offer IO register mappings and ISR definitions are 
generated using the `atdf` chips description files as a reference. 

The library supports most `attiny` and `atmega` chips, except for ones from 
the `avrxmega` and `avr1` families. The former uses the new Port API which is 
not currently supported by this library, while the latter devices are only 
supported at the assembler-level by `avr-gcc`.

Since `avr_io` makes heavy usage of c codegen, `avr1` devices are not planned 
to be supported.

For a full list of supported targets, you can run:

```terminal
./scripts/supported.nims
```

Or to check if a specific chip is supported (e.g. atmega644):

```terminal
./scripts/supported.nims atmega644
```

The library is currently tested with:
  - avr-gcc  15.2.0
  - binutils 2.45
  - avr-libc 2.2.1

## Install

```bash
nimble install avr_io
```

In order to compile a project with this library, please follow 
[the setup instructions](https://github.com/Abathargh/avr_io/wiki/Setting-up-your-project)
pointed out in the wiki.

## Testing

Run the `avr_io` test suite by executing the following command:

```terminal
./scripts/run_tests.nims
```

### Using `avr_io` in unit tests

In case you want to perform unit tests on modules import `avr_io`, a special 
symbol must be defined when calling such tests, using 
`--define:AVRIO_TESTING`.

## Documentation

There are three main documentation sources for this project:
- [The wiki](https://github.com/Abathargh/avr_io/wiki) hosted within the 
avr_io GitHub page.
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
LICENSE).
