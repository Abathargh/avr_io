#!/usr/bin/env -S nim e --hints:off --stackTrace:off

import std/[os, strformat]

for kind, f in walkDir("./tests"):
  if kind != pcFile: continue
  exec(fmt"nim r {f}")


