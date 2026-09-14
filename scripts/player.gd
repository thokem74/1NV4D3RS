extends Node2D
signal shot(origin: Vector2, direction: Vector2)
signal engine_trail(origin: Vector2)
signal dashed
signal damaged
signal died
var health: int = 3
var shield: bool = false
var rapid: float = 0.0
var spread: float = 0.0
var invulnerable: float = 0.0
var dash_cooldown: float = 0.0
var dash_time: float = 0.0
var facing: float = 1.0
var shot_timer: float = 0.0
var trail_timer: float = 0.0
func _process(dt: float) -> void:
 rapid = maxf(0, rapid - dt)
 spread = maxf(0, spread - dt)
 invulnerable = maxf(0, invulnerable - dt)
 dash_cooldown = maxf(0, dash_cooldown - dt)
 dash_time = maxf(0, dash_time - dt)
 shot_timer -= dt
 var axis := Input.get_axis("move_left", "move_right")
 if absf(axis) > 0.1: facing = signf(axis)
 if Input.is_action_just_pressed("dash") and dash_cooldown <= 0:
  dash_time = 0.17
  dash_cooldown = 1.2
  invulnerable = maxf(invulnerable, 0.22)
  dashed.emit()
 position.x = clampf(position.x + (facing * 660.0 if dash_time > 0 else axis * 260.0) * dt, 20, 620)
 if Input.is_action_pressed("fire") and shot_timer <= 0:
  shot_timer = 0.095 if rapid > 0 else 0.22
  shot.emit(position + Vector2(0, -13), Vector2.UP)
  if spread > 0:
   shot.emit(position + Vector2(-5, -8), Vector2(-0.23, -1).normalized())
   shot.emit(position + Vector2(5, -8), Vector2(0.23, -1).normalized())
 trail_timer -= dt
 if trail_timer <= 0:
  trail_timer = 0.04
  engine_trail.emit(position + Vector2(0,15))
 queue_redraw()
func hit() -> void:
 if invulnerable > 0: return
 invulnerable = 1.3
 if shield: shield = false
 else: health -= 1
 damaged.emit()
 if health <= 0: died.emit()
func collect(effect: PickupEffect) -> void:
 match effect.kind:
  "rapid": rapid = effect.duration
  "spread": spread = effect.duration
  "shield": shield = true
  "repair": health = mini(3, health + 1)
func _draw() -> void:
 var color := Color("8af6ff")
 if invulnerable > 0:
  if Settings.values.reduced_flashes: color.a = 0.65
  elif int(invulnerable * 20) % 2 == 0: color.a = 0.35
 draw_colored_polygon(PackedVector2Array([Vector2(0,-13),Vector2(4,-5),Vector2(4,0),Vector2(12,5),Vector2(12,10),Vector2(3,7),Vector2(0,10),Vector2(-3,7),Vector2(-12,10),Vector2(-12,5),Vector2(-4,0),Vector2(-4,-5)]),color)
 draw_rect(Rect2(-2,-5,4,8),Color("131b3f"))
 draw_rect(Rect2(-3,11,6,6 + sin(Time.get_ticks_msec()*0.04)*3),Color("ff70bc"))
 if shield: draw_arc(Vector2.ZERO,19,0,TAU,32,Color("56e8ef"),1.5)
 if dash_time > 0:
  for i in 4: draw_rect(Rect2(-facing * (18+i*9), 0, 5, 6),Color(0.3,0.9,1,0.5-i*0.1))
