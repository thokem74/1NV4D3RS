extends Node2D
signal struck(origin: Vector2)
signal fire(origin: Vector2, direction: Vector2)
signal destroyed(enemy: Node2D)
var config: DifficultyConfig = preload("res://resources/difficulty.tres")
var stats: EnemyStats
var hp: int
var anchor := Vector2.ZERO
var phase: float = 0
var motion: int = 0
var elapsed: float = 0
var fire_timer: float = 3
var warning: float = 0
var flash: float = 0
var wave: int = 1
var target := Vector2(320,315)
var diving: bool = false
var dive_velocity := Vector2.ZERO
func configure(data: Dictionary, level: int) -> void:
 stats = load("res://resources/enemy_%d.tres" % data.kind)
 hp = stats.health
 anchor = data.position
 position = anchor
 phase = data.phase
 motion = data.motion
 fire_timer = data.fire_delay
 wave = level
func _process(dt: float) -> void:
 elapsed += dt
 flash = maxf(0,flash-dt)
 fire_timer -= dt
 if diving:
  position += dive_velocity*dt
  if position.y > 345:
   diving = false
   fire_timer = 2.5
 else:
  var speed := minf(0.6 + wave*0.025, config.max_formation_speed / 32.0)
  var offset := Vector2(sin(elapsed*speed)*32, sin(elapsed*1.2+phase)*4)
  if motion == 1: offset.y += sin(elapsed*0.7+phase)*8
  if motion == 2: offset.x = sin(elapsed*speed+floor(anchor.y/27)*0.5)*32
  position = anchor + offset
 if fire_timer <= 0.65 and fire_timer > 0: warning = 1.0-fire_timer/0.65
 else: warning = 0
 if fire_timer <= 0:
  fire_timer = maxf(1.6,stats.fire_interval-wave*0.035) + fmod(phase,0.7)
  if stats.kind == 2 and not diving:
   diving = true
   dive_velocity = (target-position).normalized()*minf(125+wave*2,170)
  else:
   fire.emit(position+Vector2(0,10),(target-position).normalized() if stats.kind == 1 else Vector2.DOWN)
 queue_redraw()
func hit() -> void:
 hp -= 1
 flash = 0.08
 if hp > 0: struck.emit(position)
 if hp <= 0:
  destroyed.emit(self)
  queue_free()
func _draw() -> void:
 if stats == null: return
 var patterns := [ ["00100100","00011000","00111100","01111110","11011011","10100101"], ["00011000","00111100","01111110","11011011","01111110","00100100"], ["10000001","11000011","01111110","00111100","00011000","00100100"], ["00111100","01111110","11111111","11011011","11111111","10100101"] ]
 var c := Color.WHITE if flash > 0 and not Settings.values.reduced_flashes else stats.tint
 var rows: Array = patterns[stats.kind]
 for y in rows.size():
  for x in 8:
   if rows[y][x] == "1": draw_rect(Rect2(x*3-12,y*3-9,3,3),c)
 if warning > 0:
  draw_line(Vector2(-9,14),Vector2(-9+18*warning,14),Color("ffe08a"),2)
  if stats.kind == 2 and not diving:
   draw_line(Vector2(0,18),(target-position).normalized()*42,Color(1,0.85,0.5,warning*0.5),1)
 if stats.kind == 3: draw_line(Vector2(-10,-13),Vector2(-10+20.0*hp/stats.health,-13),stats.tint,2)
