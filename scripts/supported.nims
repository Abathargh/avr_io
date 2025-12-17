#!/usr/bin/env -S nim e --hints:off --stackTrace:off

import std/[algorithm, enumerate, os, sequtils, sets, strutils, strformat]


proc parent(path: string): string =
  let splitted = path.split("/")
  splitted[0 .. ^2].join("/")


proc extract_name(path: string): string =
  let splitted = path.split("/")
  splitted[^1].split(".")[0]


proc patchNimsArgs(): seq[string] =
  # Needed pre-nim v2.2.2
  var nims = false
  for i in 0..paramCount():
    if nims: result.add(paramStr(i))
    if paramStr(i).endsWith(".nims"): nims = true


let mcus = (proc(): OrderedSet[string] =
  let root = project_dir().parent
  let dir  = fmt"{root}/src/avr_io/private/"
  for file_name in list_files(dir):
    var name = file_name.extract_name
    if name.starts_with("at"):
      if  name.starts_with("atmegas"):
        name.delete(6..6) # deletes the "s" as the chips are similar
      result.incl name
)()


proc main() =
  let args = patchNimsArgs()
  case args.len:
  of 0:
    let max_len = mcus.to_seq.map(proc(s: string): int = s.len).max
    let sorted  = mcus.to_seq.sorted()
    var str = ""
    for (ctr, chip) in enumerate(1, sorted):
      str &= fmt"{chip.alignLeft(max_len)} "
      if ctr mod 5 == 0: str &= "\n"
    echo str
  of 1: echo if args[0] in mcus: "supported" else: "not supported"
  else: echo "usage: ./scripts/supported [chip]"


main()
