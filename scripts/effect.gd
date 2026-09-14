extends Node2D
var pieces: Array[Dictionary] = []
var life: float = 0.5
var is_trail: bool = false
var tint := Color("56e8ef")
func setup(color: Color, amount: int = 16) -> void:
 tint = color
 for i in amount:
  var a := randf()*TAU
  pieces.append({"p":Vector2.ZERO,"v":Vector2.from_angle(a)*randf_range(25,115),"size":randf_range(1,3)})
func _process(dt: float) -> void:
 life -= dt
 for p in pieces:
  p.p += p.v*dt
  p.v *= exp(-3*dt)
 if life <= 0: queue_free()
 queue_redraw()
func _draw() -> void:
 for p in pieces: draw_rect(Rect2(p.p,Vector2.ONE*p.size),Color(tint,clampf(life*2,0,1)))
 if not is_trail: draw_arc(Vector2.ZERO,(0.5-life)*65,0,TAU,24,Color(tint,life),1)
