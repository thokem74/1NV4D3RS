extends Node
func _ready() -> void:
 bind("move_left", [KEY_A, KEY_LEFT], JOY_BUTTON_DPAD_LEFT)
 bind("move_right", [KEY_D, KEY_RIGHT], JOY_BUTTON_DPAD_RIGHT)
 bind("fire", [KEY_SPACE], JOY_BUTTON_A)
 bind("dash", [KEY_SHIFT], JOY_BUTTON_B)
 bind("pause_game", [KEY_ESCAPE], JOY_BUTTON_START)
 for side in [-1, 1]:
  var e := InputEventJoypadMotion.new()
  e.axis = JOY_AXIS_LEFT_X
  e.axis_value = side
  InputMap.action_add_event("move_left" if side < 0 else "move_right", e)
func bind(action: String, keys: Array, button: int) -> void:
 InputMap.add_action(action, 0.22)
 for key in keys:
  var e := InputEventKey.new()
  e.physical_keycode = key
  InputMap.action_add_event(action, e)
 var pad := InputEventJoypadButton.new()
 pad.button_index = button
 InputMap.action_add_event(action, pad)
