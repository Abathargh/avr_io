switch("os", "standalone")
switch("cpu", "avr")
switch("gc", "none")
switch("threads", "off")
switch("stackTrace", "off")
switch("lineTrace", "off")
switch("define", "release")
switch("define", "USING_ATMEGA328P")
switch("passC", "-mmcu=atmega328p -DF_CPU=16000000")
switch("passL", "-mmcu=atmega328p -DF_CPU=16000000")
switch("nimcache", ".nimcache")

switch("avr.standalone.gcc.options.linker", "-static")
switch("avr.standalone.gcc.exe", "avr-gcc")
switch("avr.standalone.gcc.linkerexe", "avr-gcc")

when defined(windows):
  switch("gcc.options.always", "-w -fmax-errors=3")
