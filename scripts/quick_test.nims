#!/usr/bin/env -S nim e --hints:off --stackTrace:off

import std/parseopt
import std/strutils
import std/os


const 
  shortFlags = {'a', 'c', 'h', 'f', 'v'}
  longFlags  = @["all", "clean", "help", "flash", "verbose"]
  usage = """
Builds and optionally uploads the example contained within the PROJECT 
sub-directory, of the avr_io project.
This script removes and installs the library from scratch.
Usage: quick_test [-a] [-c] [-h] [-f] [-v] [-t TARGET] PROJECT
  -a, --all
      builds or clears all targets, PROJECT is not needed with this flag
  -h, --help 
      shows this help message
  -c, --clean
      cleans the project instead of building it
  -f, --flash
      flashes the compiler output after building it
  -v, --verbose
      makes the build more verbose
  -t, --target=TARGET
      builds the specified target for multi-target projects
"""


var
  all     = false
  clean   = false
  flash   = false
  verbose = false
  target  = ""
  project = ""
  argn    = 0


proc doBuild(projectDir, target: string, flash, verbose: bool) =
  let output = gorge("nimble dump avr_io")
  if "Error" notin output:
    exec("nimble uninstall -i -y avr_io")

  exec("rm -rf ~/.nimble/pkgs2/avr_io*")
  exec("nimble install -y")

  let v = if verbose: "--verbose" else: ""

  withDir projectDir:
    exec("nimble clear")
    exec("nimble $# build $#" % [v, target])
    if flash:
      exec("nimble $# flash" % v)


proc patchNimsArgs(): string =
  var nims = false
  var args: seq[string]
  for i in 0..paramCount():
    if nims: args.add(paramStr(i))  
    if paramStr(i).endsWith(".nims"): nims = true

  result = args.join(" ")
  if result == "":
    echo "A project must be specified"
    quit(1)


proc main() =
  var p = initOptParser(patchNimsArgs(), shortFlags, longFlags)
  for kind, opt, val in getopt(p):
    case p.kind
    of cmdEnd:
      break
    of cmdLongOption:
      case opt 
      of "all":     all     = true
      of "clean":   clean   = true
      of "flash":   flash   = true
      of "target":  target  = val
      of "verbose": verbose = true
      of "help":    echo usage; quit(0)
      of "hints":   discard
      else:
        echo "Unsupported long option $#" % opt
        quit(1)

    of cmdShortOption:
      case opt 
      of "a": all     = true
      of "c": clean   = true
      of "f": flash   = true
      of "t": target  = val
      of "v": verbose = true
      of "h": echo usage; quit(0)
      else:
        echo "Unsupported long option $#" % opt
        quit(1)

    of cmdArgument:
      project = opt
      inc argn
      if argn > 1:
        echo "Too many arguments ($#, last one: $#), only 1 needed" % [$argn, opt]
        quit(1)

  if all:
    for kind, d in walkDir("./examples"):
      if kind != pcDir: continue
      if clean: 
        withDir d:
          exec("nimble clear")
      else:
        doBuild(d, target, flash, verbose)
    quit(0)

  if clean:
    withDir ("examples/$#" % project):
      exec("nimble clear")
    quit(0)

  if argn == 0:
    echo "A project must be specified"
    quit(1)

  let projectDir = "examples/$#" % project
  if not dirExists(projectDir):
    echo "The passed project does not exist"
    quit(1)

  echo "Building project '$#'" % project
  doBuild(projectDir, target, flash, verbose)

main()
