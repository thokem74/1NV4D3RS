extends Node2D
var velocity := Vector2.ZERO
var hostile: bool = false
var radius: float = 3.0
func _process(dt: float) -> void:
 position += velocity * dt
 if position.y < -20 or position.y > 385 or position.x < -30 or position.x > 670: queue_free()
 queue_redraw()
func _draw() -> void:
 var c := Color("ff70bc") if hostile else Color("8af6ff")
 draw_line(-velocity.normalized()*7,Vector2.ZERO,Color(c,0.16),7)
 draw_rect(Rect2(-2,-4,4,8),c)
 draw_rect(Rect2(-1,-3,2,4),Color("fff2ed"))
