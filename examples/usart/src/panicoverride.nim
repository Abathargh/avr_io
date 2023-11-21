proc exit(code: int) {.importc, header: "<stdlib.h>", cdecl.}

{.push stack_trace: off, profiler:off.}

proc rawoutput(s: string) = discard

proc panic(s: string) =
  rawoutput(s)
  while true:
    discard
  exit(1)

{.pop.}
