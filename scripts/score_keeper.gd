class_name ScoreKeeper
extends RefCounted
signal changed(total: int)
var total: int = 0
func reset() -> void:
 total = 0
 changed.emit(total)
func award(points: int) -> void:
 total += maxi(0,points)
 changed.emit(total)
