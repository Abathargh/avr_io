# Package

version       = "0.1.0"
author        = "mar"
description   = "Simple application showcasing the usart features."
license       = "BSD-3-Clause"
srcDir        = "src"
bin           = @["usart", "usart9bits"]


# Dependencies

requires "nim >= 2.0.6"
requires "avr_io >= 0.3.0"

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

task clear, "Deletes the previously built compiler artifacts":
  for b in bin:
    rmFile(b & ".elf")
    rmFile(b & ".hex")
    rmFile(b & ".bin")
  rmDir(".nimcache")

task flash, "Loads the compiled binary onto the MCU":
  for b in bin:
    if fileExists(b & ".hex"):
      exec("avrdude -c arduino -b 115200 -P /dev/ttyACM0 -p m328p -U flash:w:" & b & ".hex:i")
      break

task flash_debug, "Loads the elf binary onto the MCU":
  for b in bin:
    if fileExists(b & ".elf"):
      exec("avrdude -c stk500v2 -D -b 115200 -P /dev/ttyACM0 -p m328p -U flash:w:" & b & ".elf:e")
      break