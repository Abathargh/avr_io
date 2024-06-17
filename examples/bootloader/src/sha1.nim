## Hand-rolled SHA1 implementation, since checksums/sha1 is too big for an 
## ATMega644 and it cannot be imported anyways because of a known bug 
## on platforms where ints are 16-bit wide.

const
  digestSize      = 5
  digestByteSize* = 20
  blockSize       = 64

type Sha1Ctx* = object
  H: array[digestSize, uint32]

  bIdx: uint8
  blocks: array[blockSize, uint8]
  lengthLSB: uint32
  lengthMSB: uint32


template f0(B, C, D: uint32): uint32 =
  (B and C) or ((not B) and D)

template f1(B, C, D: uint32): uint32 =
  B xor C xor D

template f2(B, C, D: uint32): uint32 =
  (B and C) or (B and D) or (C and D)

template f3(B, C, D: uint32): uint32 =
  B xor C xor D

template Sn(w: uint32; n: int): uint32 =
  (w shl n) or (w shr (32 - n))


proc processBlock(ctx: var Sha1Ctx) = 
  const
    mask = 0x0000000F'u32
    K = [
      0x5A827999'u32,
      0x6ED9EBA1'u32,
      0x8F1BBCDC'u32,
      0xCA62C1D6'u32,
    ]

  var 
    A = ctx.H[0]
    B = ctx.H[1]
    C = ctx.H[2]
    D = ctx.H[3]
    E = ctx.H[4]
    W: array[16, uint32]
  
  for t in 0..<len(W):
    W[t] = 
      uint32(ctx.blocks[t * 4])     shl 24 or
      uint32(ctx.blocks[t * 4 + 1]) shl 16 or
      uint32(ctx.blocks[t * 4 + 2]) shl 8  or
      uint32(ctx.blocks[t * 4 + 3])

  for t in 0'u32..79:
    let s = t and mask
    if t >= 16:
      W[s] = (
        W[(s + 13) and mask] xor 
        W[(s + 8 ) and mask] xor 
        W[(s + 2 ) and mask] xor 
        W[s]
      ).Sn(1)
    
    let temp = case t:
      of 0..19:
        A.Sn(5) + f0(B, C, D) + E + W[s] + K[0]
      of 20..39:
        A.Sn(5) + f1(B, C, D) + E + W[s] + K[1]
      of 40..59:
        A.Sn(5) + f2(B, C, D) + E + W[s] + K[2]
      of 60..79:
        A.Sn(5) + f3(B, C, D) + E + W[s] + K[3]
      else:
        assert false
        0'u32
    
    E = D
    D = C
    C = B.Sn(30)
    B = A
    A = temp
  
  ctx.H[0] += A
  ctx.H[1] += B
  ctx.H[2] += C
  ctx.H[3] += D
  ctx.H[4] += E
  ctx.bIdx = 0


proc padMessage(ctx: var Sha1Ctx) =
  ctx.blocks[ctx.bIdx] = 0x80
  inc ctx.bIdx

  if ctx.bIdx > 55:
    for i in ctx.bIdx..<blockSize:
      ctx.blocks[i] = 0
    ctx.processBlock()

  for i in ctx.bIdx..55:
    ctx.blocks[i] = 0

  const 
    baseMsb = 56
    baseLsb = 60
  
  for i in 0'u8..3:
    ctx.blocks[baseMsb+i] = uint8(ctx.lengthMSB shr (8'u8*(3'u8-i)))
    ctx.blocks[baseLsb+i] = uint8(ctx.lengthLSB shr (8'u8*(3'u8-i)))


proc initCtx*(ctx: var Sha1Ctx) =
  ctx.bIdx      = 0
  ctx.lengthLSB = 0
  ctx.lengthLSB = 0
  ctx.H[0] = 0x67452301'u32
  ctx.H[1] = 0xEFCDAB89'u32
  ctx.H[2] = 0x98BADCFE'u32
  ctx.H[3] = 0x10325476'u32
  ctx.H[4] = 0xC3D2E1F0'u32


proc append*(ctx: var Sha1Ctx; b: uint8): bool = 
  ctx.blocks[ctx.bIdx] = b
  inc ctx.bIdx
  inc ctx.lengthLSB, 8
  
  if ctx.lengthLSB == 0:
    inc ctx.lengthMSB
    if ctx.lengthMSB == 0:
      return false

  if ctx.bIdx == blockSize:
    ctx.processBlock()

  return true


proc compute*(ctx: var Sha1Ctx, d: var array[digestByteSize, uint8])=
  ctx.padMessage()
  ctx.processBlock()

  for i in 0..<digestByteSize:
    d[i] = uint8(ctx.H[i div 4] shr (8 * (3 - (i and 3))))
