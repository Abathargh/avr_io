proc escapeStrseq*(s: string): string =
  # Escape special chars so that they will still appear as such
  # in the generated c code
  var r: string = newStringOfCap(s.len)
  for ch in s:
    case ch:
      of char(0) .. char(31):
        r.addEscapedChar(ch)
      else:
        r.add(ch)
  r


proc substStructFields*(s: string): (string, int) =
  # Hand-rolled FSM-based struct parsing proc, which turns an object literal 
  # into its C struct-literal equivalent. This works with nested struct 
  # literals too.

  # Given an object literal `t = foo(a: 1, b: "test")
  # Calling $`t` in a quote do block will yield something like:
  #   `(a: 1, b: 2)` 
  # Which should be transposed in its C99 analogue using designated 
  # initializers:
  #   `{.a=1, .b=2}`
  # Note that nested object literals will be of the following form:
  #   `(a: 1, b: (c: 3, d: 4))`
  # Which should become:
  #   `{.a=1, .b={.c=3, .d=4}}`
  type
    stateEnum = enum
      spaceParsing
      nameParsing
      colonParsing
      valueParsing

  var 
    state = spaceParsing
    output = ""
    idx = 0

  while idx < (s.len() - 1):
    inc idx
    let ch = s[idx]
    case state:
      of spaceParsing:
        case ch:
          of ' ':
            continue
          else:
            output &= "." & ch
            state = nameParsing
      of nameParsing:
        case ch:
          of ':':
            state = colonParsing
          else:
            output &= ch
      of colonParsing:
        case ch:
          of ' ':
            continue
          of '(':
            let (inner, size) = substStructFields(s[idx..^1])
            output &= "="
            output &= inner
            inc idx, size - 1
            state = valueParsing
          else:
            output &= "="
            output &= ch
            state = valueParsing
      of valueParsing:
        case ch:
          of ')':
            return ("{" & output & "}", idx)
          of ',':
            output &= ", "
            state = spaceParsing
          else:
            output &= ch

  ("{" & output & "}", idx)
