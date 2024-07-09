## A incredibly simple application that showcases how to store data in a 
## specific elf section within the binary.

# We want to put the metadata section just at the end of the application 
# section in program memory.
{.passL: "-Wl,--section-start=.metadata=0xDFE8".}

import avr_io
import delay


proc constFill[T](size: static[int], val: T): array[size, T] =
  for e in result.mitems:
    e = val

const
  led = 0'u8
  headerSize = 24

# Let us reserve a slot of program memory where to keep the hash of this 
# application, together with its size and the .text section address. This will 
# be filled up by a script in the post build phase. 
let header {.section(".metadata").} = static: constFill(headerSize, 0'u8)


proc loop() =
  initDelayTimer()

  portA.asOutputPin(led)
  portA.clearPin(led)
  while true:
    portA.togglePin(led)
    delayMs(2000)

when isMainModule:
  loop()
