extends Node2D
var stars: Array[Vector3] = []
var elapsed: float = 0
func _ready() -> void:
 var rng := RandomNumberGenerator.new()
 rng.seed = 1459
 for i in 105: stars.append(Vector3(rng.randf_range(0,640),rng.randf_range(0,360),rng.randf_range(0.2,1)))
func _process(dt: float) -> void:
 elapsed += dt
 queue_redraw()
func _draw() -> void:
 draw_rect(Rect2(0,0,640,360),Color("070c1b"))
 for i in 7:
  draw_circle(Vector2(480,120),180-i*19,Color(0.09,0.08,0.22,0.055))
 for s in stars:
  var p := Vector2(s.x,fmod(s.y+elapsed*(8+s.z*20),360))
  draw_rect(Rect2(p,Vector2.ONE*(2 if s.z > 0.85 else 1)),Color(0.4+s.z*0.4,0.65,0.9,0.25+s.z*0.5))
 for x in range(0,641,40): draw_line(Vector2(x,290),Vector2(320+(x-320)*1.7,360),Color(0.1,0.5,0.6,0.09))
 for y in [300,315,337,359]: draw_line(Vector2(0,y),Vector2(640,y),Color(0.1,0.5,0.6,0.09))
