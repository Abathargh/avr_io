import volatile

type 
  Counter = object
    threshold: int
    ctr: int

proc newCounter*(threshold: int): Counter =
  return Counter(threshold: threshold, ctr: 0)

proc `inc`*(c: var Counter) =
  let count = volatileLoad(addr c.ctr)
  volatileStore(addr c.ctr, count + 1)  

proc checkThreshold*(c: var Counter): bool =
  let count = volatileLoad(addr c.ctr)
  count == c.threshold

proc reset*(c: var Counter) =
  volatileStore(addr c.ctr, 0)
