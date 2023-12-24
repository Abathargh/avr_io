# Package

version       = "0.1.0"
author        = "mar"
description   = "A project showing how to write a bootloader + application for an ATMega chip using the avr_io nim library."
license       = "BSD-3-Clause"
srcDir        = "src"
bin           = @["bootloader", "application"]


# Dependencies

requires "nim >= 2.0.0"
requires "avr_io >= 0.2.0"

after build:
  for b in bin: 
    when defined(windows):
      if not fileExists(b & ".exe"): 
        continue
      mvFile(b & ".exe", b & ".elf")
    else:
      if not fileExists(b):
        continue
      mvFile(b, b & ".elf")
    exec("avr-objcopy -O ihex " & b & ".elf " & b & ".hex")
    exec("avr-objcopy -O binary " & b & ".elf " & b & ".bin")
    if b == "application":
      exec("harlock ./scripts/embed " & b)
  exec("srec_cat " & bin[0] & ".hex -I " & bin[1] & ".hex -I -o full_app.hex -I")
  exec("avr-objcopy -O binary -I ihex full_app.hex full_app.bin")


task clear, "Deletes the previously built compiler artifacts":
  for b in bin:
    rmFile(b & ".elf")
    rmFile(b & ".hex")
    rmFile(b & ".bin")
  rmDir(".nimcache")
  rmFile("full_app.hex")
  rmFile("full_app.bin")

task flash, "Loads the compiled binary onto the MCU":
  if fileExists("full_app.hex"):
    exec("avrdude -c atmelice -p m644 -U flash:w:full_app.hex:i")

task fuse, "Initialize the correct fuses to run the application":
  exec("avrdude -c atmelice -p m644 -U lfuse:w:0xe2:m -U hfuse:w:0x18:m -U efuse:w:0xff:m
