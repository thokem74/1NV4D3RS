extends Node2D
var effect: PickupEffect
var age: float = 0
func _process(dt: float) -> void:
 age += dt
 position.y += 65*dt
 if position.y > 380: queue_free()
 queue_redraw()
func _draw() -> void:
 if effect == null: return
 draw_rect(Rect2(-9,-9,18,18),Color("111b32"))
 draw_rect(Rect2(-9,-9,18,18),effect.tint,false,1.5)
 var glyph: String = {"rapid":"R","spread":"W","shield":"S","repair":"+"}[effect.kind]
 draw_string(ThemeDB.fallback_font,Vector2(-5,5),glyph,HORIZONTAL_ALIGNMENT_LEFT,-1,13,effect.tint)
 draw_arc(Vector2.ZERO,13+sin(age*5),0,TAU,24,Color(effect.tint,0.3),1)
