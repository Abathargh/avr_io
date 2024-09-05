# bootloader

A simple bootloader that verifies the integrity of an application before 
launching it.

The configuration is set to use an ATMega644 with an Atmel ICE programmer, 
but it should work on any other ATMega MCU, with other programmers.

It showcases how to interact with the elf sections that will be generated 
within the final binary, how to upload a bootloader at the correct address, 
and how to validate an application and jump to it.

The application consist of just a single blink loop, that contains its own 
SHA1 hash within its program memory, that can be used by the bootloader to 
check for its corruption.

The application SHA1 hash, together with some additional information, is 
embedded within the application by a `harlock` script, as originally explained 
within [this article](https://antima.it/en/harlock-a-small-language-to-handle-hex-and-elf-files/).

## Fuse bits

In order to put the bootloader within the boot sector, a specific 
configuration is needed for the fuse bits:

|Extended|High|Low|
|-|-|-|
|FF|18|E2|

Which, among other things, yields a boot start address of $7000 
(word-addressed), or of 0xE000 (byte-addressed).
This can be set by making the '.text' elf section start from that address 
through linker flags, as shown in the `passL` configuration contained in the 
`bootloader.nim` file.

**Note that this setup is specific for an ATMega644, and you should change the 
values according to the MCU you will use.**

You can automatically set up these fuse valeus by running:

```bash
nimble fuse
```

## Dependencies

- ```avr-gcc```
- ```avr-libc```
- ```avrdude```
- ```srec_cat```
- [```harlock```](https://github.com/Abathargh/harlock)

## Building the project

To build the project, just run:

```bash
nimble build
```

This will:

- Build the bootloader (hex + elf).
- Build the application (hex + elf).
- Embed the SHA1 hash of the application within its `.metadata` section and 
at its equivalent address in the generated hex file.
- Join the bootloader and application hex files.

Additional targets:

```bash
nimble clear       # cleans the artifacts from a previous build
nimble flash       # flashes the .hex file onto the ATMega644
nimble fuse        # sets up the fusesto the correct values to run the app
```
