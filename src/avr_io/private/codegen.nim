import std/typetraits
import std/strutils
import std/macros

template field_err(name, typ: string): string =
  "`$#` field of type `$#` not allowed" % [name, typ]

proc get_type_repr_impl(name: string; val: auto, string_ok: static bool):
  (string, bool)

template get_type_repr*(name: string; val: typed, string_ok: bool = false):
  (string, bool) =
  get_type_repr_impl(name, val, string_ok)

proc get_type_repr_impl(name: string; val: auto, string_ok: static bool):
  (string, bool) {.compiletime.} =
  ## Returns (value as a string, error msg, true if everything was ok)

  when typeof(val) is string and not string_ok:
    ("$#, use `cstring`" % field_err(name, $typeof(val)), false)
  elif typeof(val) is seq:
    ("$#, use arrays" % field_err(name, $typeof(val)), false)
  elif typeof(val) is ref:
    ("$#, use non-ref objects" % field_err(name, $typeof(val)), false)
  elif typeof(val) is array and sizeof(val) == 0:
    ("{}", true)
  elif typeof(val) is array and sizeof(typeof(val)) > 0:
    let
      def_arr_typ = val[0]
      (_, in_ok) = get_type_repr("element[0]", def_arr_typ)

    if not in_ok:
      return ("`$#[0]` of type `$#` not allowed" % [name, $typeof(val)], false)

    var arr_str = "{"
    for idx, element in val.pairs:
      # must be ok at this point, or we would have gotten a compiler error
      let (el_repr, _) = get_type_repr("element[$#]" % $idx, element)
      arr_str &= "$#$#" % [el_repr, if idx != val.len - 1: ", " else: ""]

    (arr_str & "}", true)

  elif typeof(val) is object:
    var idx = 0
    var obj_str = "{"
    var num_fields = 0

    for _ in val.fields():
      inc num_fields, 1

    for f_name, f_val in fieldPairs(val):
      let (f_msg, f_ok) = get_type_repr(f_name, f_val)
      if not f_ok:
        let i_fmt = [f_name, name, f_msg]
        return ("invalid field `$#` in `$#`: $#" % i_fmt, false)

      let comma = if idx != num_fields - 1: ", " else: ""
      obj_str &= ".$#=$#$#" % [f_name, f_msg, comma]
      inc idx, 1

    (obj_str & "}", true)
  elif typeof(val) is cstring:
    ("\"$#\"" % $val, true)
  else:
    ($val, true)


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
