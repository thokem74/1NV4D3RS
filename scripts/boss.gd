extends Node2D
signal struck(origin: Vector2)
signal fire(origin: Vector2, direction: Vector2)
signal destroyed(enemy: Node2D)
var hp: int = 80
var max_hp: int = 80
var variant: int = 0
var elapsed: float = 0
var fire_timer: float = 2.0
var warning: float = 0
var target := Vector2(320,315)
var flash: float = 0
var volley: int = 0
func configure(wave: int) -> void:
 variant = (wave / 5 - 1) % 2
 max_hp = 55 + wave*5
 hp = max_hp
 position = Vector2(320,75)
func _process(dt: float) -> void:
 elapsed += dt
 flash = maxf(0,flash-dt)
 position.x = 320 + sin(elapsed*0.65)*190
 fire_timer -= dt
 warning = clampf(1.0-fire_timer/0.8,0,1)
 if fire_timer <= 0:
  volley += 1
  fire_timer = 1.35 if variant == 0 else 1.6
  if variant == 0:
   for i in 7:
    fire.emit(position+Vector2(0,20),Vector2.DOWN.rotated((i-3)*0.19 + sin(volley)*0.1))
  else:
   for side in [-1,1]:
    var origin := position+Vector2(side*32,12)
    var aim := (target-origin).normalized()
    for i in 3: fire.emit(origin,aim.rotated((i-1)*0.15))
 queue_redraw()
func hit() -> void:
 hp -= 1
 flash = 0.07
 if hp > 0: struck.emit(position)
 if hp <= 0:
  destroyed.emit(self)
  queue_free()
func _draw() -> void:
 var c := Color("ff70bc") if variant == 0 else Color("a58bff")
 if flash > 0 and not Settings.values.reduced_flashes: c = Color.WHITE
 draw_rect(Rect2(-28,-16,56,32),c)
 draw_rect(Rect2(-45,-5,16,24),c)
 draw_rect(Rect2(29,-5,16,24),c)
 draw_rect(Rect2(-18,-9,36,15),Color("11172d"))
 draw_rect(Rect2(-12,-5,8,7),Color("ffe08a"))
 draw_rect(Rect2(4,-5,8,7),Color("ffe08a"))
 draw_rect(Rect2(-11,12,22,9),c)
 if warning > 0: draw_arc(Vector2.ZERO,53,0,TAU*warning,40,Color("ffe08a"),2)
