#!/usr/bin/env -S nim e --hints:off --stackTrace:off

import std/parseopt
import std/strutils
import std/os


const 
  shortFlags = {'a', 'c', 'r', 'h', 'f', 'v'}
  longFlags  = @["all", "clean", "reinstall", "help", "flash", "verbose"]
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
  -r, --reinstall
      remove and reinstall the avr_io library on the system
  -f, --flash
      flashes the compiler output after building it
  -v, --verbose
      makes the build more verbose
  -s, --skip=PROJECT
      skips the specified project, use with `all`
  -t, --target=TARGET
      builds the specified target for multi-target projects
"""


var
  all     = false
  clean   = false
  flash   = false
  verbose = false
  skip    = ""
  target  = ""
  project = ""
  argn    = 0


proc install() =
  let output = gorge("nimble dump avr_io")
  if "Error" notin output:
    exec("nimble uninstall -i -y avr_io")

  exec("rm -rf ~/.nimble/pkgs2/avr_io*")
  exec("nimble install -y")


proc doBuild(dir, target: string, flash, verbose, reinstall: bool) =
  if reinstall:
    install()

  let v = if verbose: "--verbose" else: ""

  withDir dir:
    exec("nimble clear")
    exec("nimble $# build $#" % [v, target])
    if flash:
      exec("nimble $# flash" % v)


proc patchNimsArgs(): string =
  # Needed pre-nim v2.2.2
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
      of "all":       all     = true
      of "clean":     clean   = true
      of "reinstall": install(); quit(0)
      of "flash":     flash   = true
      of "skip":      skip    = val
      of "target":    target  = val
      of "verbose":   verbose = true
      of "help":      echo usage; quit(0)
      else:
        echo "Unsupported long option $#" % opt
        quit(1)

    of cmdShortOption:
      case opt 
      of "a": all     = true
      of "c": clean   = true
      of "r": install(); quit(0)
      of "f": flash   = true
      of "s": skip    = val
      of "t": target  = val
      of "v": verbose = true
      of "h": echo usage; quit(0)
      else:
        echo "Unsupported short option $#" % opt
        quit(1)

    of cmdArgument:
      project = opt
      inc argn
      if argn > 1:
        echo "Too many arguments ($#, last one: $#), only 1 needed" % [$argn, opt]
        quit(1)

  if all:
    var first = true
    for kind, d in walkDir("./examples"):
      if kind != pcDir: continue
      if skip == d.extractFilename(): continue
      if clean: 
        withDir d:
          exec("nimble clear")
      else:
        if first:
          doBuild(d, target, flash, verbose, true)
          first = false
        else:
          doBuild(d, target, flash, verbose, false)
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
  doBuild(projectDir, target, flash, verbose, true)

main()
