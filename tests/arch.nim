import std/[sets, tables]
export sets


const arch_map*: Table[string, HashSet[string]] = {
  "avr2": [
    "attiny22", "attiny26", "at90s2313", "at90s2323", "at90s2333",
    "at90s2343", "at90s4414", "at90s4433", "at90s4434", "at90c8534", "at90s8515",
    "at90s8535"
  ].to_hash_set,

  "avr25": [
    "attiny13", "attiny13a", "attiny24", "attiny24a", "attiny25", "attiny261",
    "attiny261a", "attiny2313", "attiny2313a", "attiny43u", "attiny44",
    "attiny44a", "attiny45", "attiny48", "attiny441", "attiny461",
    "attiny461a", "attiny4313", "attiny84", "attiny84a", "attiny85",
    "attiny87", "attiny88", "attiny828", "attiny841", "attiny861",
    "attiny861a", "ata5272", "ata6616c", "at86rf401"
  ].to_hash_set,

  "avr3":  ["at76c711", "at43usb355"].to_hash_set,

  "avr31": ["atmega103", "at43usb320"].to_hash_set,

  "avr35": [
    "attiny167", "attiny1634", "atmega8u2", "atmega16u2", "atmega32u2",
    "ata5505", "ata6617c", "ata664251", "at90usb82", "at90usb162"
  ].to_hash_set,

  "avr4": [
    "atmega48", "atmega48a", "atmega48p", "atmega48pa", "atmega48pb",
    "atmega8", "atmega8a", "atmega8hva", "atmega88", "atmega88a", "atmega88p",
    "atmega88pa", "atmega88pb", "atmega8515", "atmega8535", "ata5795",
    "ata6285", "ata6286", "ata6289", "ata6612c", "at90pwm1", "at90pwm2",
    "at90pwm2b", "at90pwm3", "at90pwm3b", "at90pwm81"
  ].to_hash_set,

  "avr5": [
    "atmega16", "atmega16a", "atmega16hva", "atmega16hva2", "atmega16hvb",
    "atmega16hvbrevb", "atmega16m1", "atmega16u4", "atmega161", "atmega162",
    "atmega163", "atmega164a", "atmega164p", "atmega164pa", "atmega165",
    "atmega165a", "atmega165p", "atmega165pa", "atmega168", "atmega168a",
    "atmega168p", "atmega168pa", "atmega168pb", "atmega169", "atmega169a",
    "atmega169p", "atmega169pa", "atmega32", "atmega32a", "atmega32c1",
    "atmega32hvb", "atmega32hvbrevb", "atmega32m1", "atmega32u4",
    "atmega32u6", "atmega323", "atmega324a", "atmega324p", "atmega324pa",
    "atmega324pb", "atmega325", "atmega325a", "atmega325p", "atmega325pa",
    "atmega328", "atmega328p", "atmega328pb", "atmega329", "atmega329a",
    "atmega329p", "atmega329pa", "atmega3250", "atmega3250a", "atmega3250p",
    "atmega3250pa", "atmega3290", "atmega3290a", "atmega3290p", "atmega3290pa",
    "atmega406", "atmega64", "atmega64a", "atmega64c1", "atmega64hve",
    "atmega64hve2", "atmega64m1", "atmega64rfr2", "atmega640", "atmega644",
    "atmega644a", "atmega644p", "atmega644pa", "atmega644rfr2", "atmega645",
    "atmega645a", "atmega645p", "atmega649", "atmega649a", "atmega649p",
    "atmega6450", "atmega6450a", "atmega6450p", "atmega6490", "atmega6490a",
    "atmega6490p", "ata5790", "ata5790n", "ata5791", "ata6613c", "ata6614q",
    "ata5782", "ata5831", "ata8210", "ata8510", "ata5787", "ata5835",
    "ata5700m322", "ata5702m322", "at90pwm161", "at90pwm216", "at90pwm316",
    "at90can32", "at90can64", "at90scr100", "at90usb646", "at90usb647",
    "at94k", "m3000"
  ].to_hash_set,

  "avr51": [
    "atmega128", "atmega128a", "atmega128rfa1", "atmega128rfr2", "atmega1280",
    "atmega1281", "atmega1284", "atmega1284p", "atmega1284rfr2", "at90can128",
    "at90usb1286", "at90usb1287"
  ].to_hash_set,

  "avr6": [
    "atmega256rfr2", "atmega2560", "atmega2561", "atmega2564rfr2"
  ].to_hash_set

}.to_table
