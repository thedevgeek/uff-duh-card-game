class_name UffDuhCard
extends RefCounted

var a: int
var b: int

func _init(value_a: int, value_b: int) -> void:
a = value_a
b = value_b

func matches(value: int) -> bool:
return a == value or b == value

func other_side(value: int) -> int:
if a == value:
return b
if b == value:
return a
return -1

func pip_total() -> int:
return a + b

func to_text() -> String:
return "%d%d" % [a, b]
