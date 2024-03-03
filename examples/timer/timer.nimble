# Package

version       = "0.1.0"
author        = "mar"
description   = "Simple application showcasing the timer features."
license       = "BSD-3-Clause"
srcDir        = "src"
bin           = @["timer"]


# Dependencies

requires "nim >= 2.0.0"
requires "avr_io >= 0.2.0"

after build:
  when defined(windows):
    mvFile(bin[0] & ".exe", bin[0] & ".elf")
  else:
    mvFile(bin[0], bin[0] & ".elf")
  exec("avr-objcopy -O ihex " & bin[0] & ".elf " & bin[0] & ".hex")
  exec("avr-objcopy -O binary " & bin[0] & ".elf " & bin[0] & ".bin")

task clear, "Deletes the previously built compiler artifacts":
  rmFile(bin[0] & ".elf")
  rmFile(bin[0] & ".hex")
  rmFile(bin[0] & ".bin")
  rmDir(".nimcache")
task flash, "Loads the compiled binary onto the MCU":
  exec("avrdude -c arduino -b 115200 -P /dev/ttyACM0 -p atmega328p -U flash:w:" & bin[0] & ".hex:i")

task flash_debug, "Loads the elf binary onto the MCU":
  exec("avrdude -c arduino -b 115200 -P /dev/ttyACM0 -p atmega328p -U flash:w:" & bin[0] & ".elf:e")
