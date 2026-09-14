extends Node
signal changed
var values := {"master": 0.8, "music": 0.55, "effects": 0.8, "shake": 0.7, "reduced_flashes": false, "fullscreen": false}
var best: int = 0
var storage_path: String = "user://pilot.cfg"
func _ready() -> void:
 load_settings()
func load_settings() -> void:
 var c := ConfigFile.new()
 if c.load(storage_path) == OK:
  for key in values:
   var v = c.get_value("settings", key, values[key])
   if typeof(v) == typeof(values[key]):
    values[key] = clampf(v, 0.0, 1.0) if v is float else v
  var score_value = c.get_value("scores", "best", 0)
  best = maxi(0, score_value) if score_value is int else 0
 apply()
func set_option(key: String, value: Variant) -> void:
 values[key] = value
 apply()
 save()
func apply() -> void:
 if DisplayServer.get_name() != "headless":
  DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if values.fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
 changed.emit()
func save() -> void:
 var c := ConfigFile.new()
 for key in values: c.set_value("settings", key, values[key])
 c.set_value("scores", "best", best)
 c.save(storage_path)
func record(score: int) -> void:
 best = maxi(best, score)
 save()
