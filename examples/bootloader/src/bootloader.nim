## A simple bootloader that verifies the integrity of an application before 
## launching it.

# We want to put this application in the boot section.
{.passL: "-Wl,--section-start=.text=0xE000".}

import volatile
import avr_io
import bitops
import delay
import sha1


const 
  ledPin = 0'u8

  # The application stores a series of data in program memory, at a specific
  # offset, which in this example is known in advance. This is located at the 
  # very end of the non-boot section.
  metadataBase   = 0xdfe8'u16
  textAddrOffset = metadataBase + 0
  textSizeOffset = metadataBase + 2
  sha1HashOffset = metadataBase + 4
  sha1HashSize   = 20'u8


proc helloBlink() =
  # A 4 Hz blink used to signal that our bootloader started up.
  for _ in 0..7:
    portA.togglePin(ledPin)
    delayMs(250)
  portA.clearPin(ledPin)


proc errorBlink() =
  # A 10 Hz blink used to signal that our verification has ended negatively.
  while true:
    portA.togglePin(ledPin)
    delayMs(100)
  portA.clearPin(ledPin)


proc checkHash(d: array[digestByteSize, uint8]): bool =
  # Check that the computed hash is the same as the one included within the 
  # program memory section.
  for i in 0'u16..<sha1HashSize:
    let b = readFromAddress[uint8](sha1HashOffset+i)
    if d[i] != b:
      return false
  return true


proc loop() =
  # Since we are using interrupts within our bootloader, let us specify that 
  # we want to use the boot interrupt vector table. 
  MCUCR.setBit(0'u8)
  MCUCR.setBit(1'u8)

  initDelayTimer()
  portA.asOutputPin(ledPin)
  portA.clearPin(ledPin)

  helloBlink()

  var ctx = Sha1Ctx()
  ctx.initCtx()

  let textAddr = readFromAddress[uint16](textAddrOffset)
  let textSize = readFromAddress[uint16](textSizeOffset)

  for i in 0'u16..<textSize:
    let b = readFromAddress[uint8](textAddr+i)
    if not ctx.append(b):
      errorBlink()

  var digest: array[digestByteSize, uint8]
  ctx.compute(digest)

  if checkHash(digest):
    # Switch back to the application interrupt vector table.
    MCUCR.setBit(0'u8)
    MCUCR.clearMask(0x03)
    jumpToApplication()
 
  errorBlink()

when isMainModule:
  loop()
