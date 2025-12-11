# For each supported mcu, try to compile a simple led blink with the first
# available port, progmem and ISRs - also, check progmem and ISR codegen

import std/[dirs, enumerate, strformat, streams, strutils]
import std/[os, osproc, tables, unittest]


# The following preamble code is adapted from avrman/compiler.nim

let cwd = os.get_current_dir()
let avrman_flags = """
--os:standalone --cpu:avr --mm:none --threads:off --define:release --opt:none
--define:$# --passC:"-mmcu=$#" --passL:"-mmcu=$#" --cc:gcc
--avr.standalone.gcc.options.linker:"-static"
--avr.standalone.gcc.exe:avr-gcc
--avr.standalone.gcc.linkerexe:avr-gcc
--noNimblePath
--skipParentCfg
--path:""" & cwd & """/src
-o:$#.elf $#
"""

const
  cmd = "nim"
  first = "c"
  panic_override = """
proc exit(code: int) {.importc, header: "<stdlib.h>", cdecl.}
{.push stack_trace: off, profiler:off.}
proc rawoutput(s: string) = discard
proc panic(s: string) =
  rawoutput(s)
  while true:
    discard
  exit(1)
{.pop.}
"""

const temp_main = """
import avr_io

let pmtest {.progmem.} = 7'u8

proc test_isr() {.isr(cast[VectorInterrupt](1)).} =
  discard

proc main =
  let pin = pmtest[]
  $#.as_output_pin(pin)
  while true:
    $#.toggle_pin(pin)

when is_main_module:
  main()
"""

let mcu_map = (proc(): Table[string, string] =
  for kind, path in walk_dir("./src/avr_io/private"):
    let (_, name, _) = split_file(path)
    if ($name).starts_with("at"):
      let hi_name = ($name).to_upper_ascii
      var lo_name = ($name)
      if  lo_name.starts_with("atmegas"):
        lo_name.delete(6..6) # deletes the "s" as the chips are similar
      result[lo_name] = fmt"USING_{hi_name}"
)()


when hostOS == "windows":
  let
    flags = avrman_flags + """--gcc.options.always:"-w -fmax-errors=3")"""
else:
  let
    flags = avrman_flags


proc generate_main(mcu: string): string =
  for line in fmt"../src/Avr_io/private/{mcu}.nim".lines:
    let idx = line.find("PORT")
    if  idx != -1:
      let letter = line[idx + "PORT".len]
      let port   = fmt"port{letter}"
      return temp_main % [port, port]


template with_temp_project(mcu: string, body: untyped): untyped =
  let current = os.get_current_dir()
  try:
    create_dir("temp")
    setCurrentDir("temp")
    writeFile("panicoverride.nim", panic_override)
    writeFile("main.nim", generate_main(mcu))
    body
  finally:
    setCurrentDir(current)
    removeDir("temp")

type
  CompileOutcome = object
    output: string
    code:   int
    cb_out: seq[(string, bool)]

  FnCallback = proc(args: seq[string]): (string, bool)

proc wrap_process(cmd: string, args: open_array[string]): (string, string, int) =
  let process = startProcess(cmd, args = args, options = {poUsePath})
  let stdout  = process.outputStream.readAll()
  let stderr  = process.errorStream.readAll()
  let code    = process.waitForExit()
  process.close()

  (stdout, stderr, code)


proc compile_file*(mcu: string,
                   fns: seq[FnCallback],
                   fn_args: seq[seq[string]]): CompileOutcome =
  let
    mcu_flag     = mcu_map[mcu]
    (_, name, _) = splitFile("main.nim")
    full_cmd     = flags % [mcu_flag, mcu, mcu, name, "main.nim"]
    args         = @[first] & full_cmd.split_whitespace()

  with_temp_project(mcu):
    let (stdout, stderr, code) = wrap_process(cmd, args)
    result.output = stdout
    result.code = code

    if code != 0:
      result.output &= stderr
      return

    for idx, fn in enumerate(fns):
      result.cb_out.add fn(@["main.elf"] & fn_args[idx])


proc objdump(file: string, section = ".text"): (string, int) =
  const objdump = "avr-objdump"
  let   args    = ["-D", "-j", section, file]

  let (stdout, stderr, code) = wrap_process(objdump, args)
  ((if code != 0: stderr else: stdout), code)


proc check_isr(args: seq[string]): (string, bool) =
  let (output, code) = objdump(args[0])
  if code != 0:
    return (output, false)

  let full_name = "<__vector_1>"
  (output, full_name in output)


proc check_pms(args: seq[string]): (string, bool) =
  let (output, code) = objdump(args[0])
  if code != 0:
    return (output, false)

  let full_name = fmt"<{args[1]}>:"
  (output, full_name in output)


template with_dir*(dir: string; body: untyped): untyped =
  let curr = os.get_current_dir()
  try:
    set_current_dir(dir)
    body
  finally:
    set_current_dir(curr)


suite "compilation":
  test "simple main":
    for mcu in mcu_map.keys:
      let outcome = compile_file(mcu, @[check_isr.FnCallback, check_pms],
                                 @[@[], @["pmtest"]])

      checkpoint fmt"testing {mcu}"
      check outcome.code == 0

      if outcome.code != 0:
        echo outcome.output
        break

      check outcome.cb_out.len == 2
      if outcome.cb_out.len != 2:
        echo outcome.output
        break

      let (out_isr, isr_ok) = outcome.cb_out[0]
      check isr_ok == true
      if not isr_ok:
        echo out_isr
        break

      let (out_pms, pms_ok) = outcome.cb_out[1]
      check pms_ok == true
      if not pms_ok:
        echo out_pms
        break

suite "examples and peripherals":
  test "compilation with basic IO and peripherals":
    for kind, d in walk_dir("./examples"):
      if kind == pc_dir:
        with_dir(d):
          let proj = d.extract_filename
          let main = fmt"src/{proj}.nim"
          let (_, stderr, code) = wrap_process(
            "nim", ["c", "--noNimblePath", fmt"--path={cwd}/src", main])

          checkpoint fmt"testing {d}"
          check code == 0
          if code != 0:
            echo stderr

  test "progmem":
      const pm_symbols = [
        "testFloat", "testInt1", "testInt2", "testInt3", "testStr", "testArr",
        "testObj1", "testObj2", "testObj3", "testObj4", "testArrObj",
        "testNonInitArr"
      ]

      with_dir("./examples/progmem"):
        let (_, stderr, code) = wrap_process(
          "nim", ["c", "--noNimblePath", "--opt:none", fmt"--path={cwd}/src",
          "src/progmem.nim"])

        checkpoint fmt"testing progmem generation"
        check code == 0
        if code != 0:
          echo stderr

        let (text, ocode) = objdump("./src/progmem")
        check ocode == 0
        if ocode != 0:
          echo text

        for pm_symbol in pm_symbols:
          let full_name = fmt"<{pm_symbol}>:"
          check full_name in text

  test "system & bootloaders":
    const section_name = ".metadata"
    with_dir("./examples/bootloader"):
      let (_, stderr, code) = wrap_process(
        "nim", ["c", "--noNimblePath", fmt"--path={cwd}/src",
        "src/application.nim"])

      checkpoint fmt"testing elf section generation"
      check code == 0
      if code != 0:
        echo stderr

      let (metadata, ocode) = objdump("./src/application", section_name)
      check ocode == 0
      if ocode != 0:
        echo metadata

      check "<header>" in metadata
