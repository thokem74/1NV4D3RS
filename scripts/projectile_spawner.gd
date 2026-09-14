class_name ProjectileSpawner
extends Node2D
const PROJECTILE = preload("res://scenes/projectile.tscn")
func spawn(origin: Vector2, velocity: Vector2, hostile: bool, cap: int = 64) -> void:
 var count := 0
 for child in get_children():
  if child.hostile == hostile and not child.is_queued_for_deletion(): count += 1
 if count >= (cap if hostile else 100): return
 var projectile := PROJECTILE.instantiate()
 projectile.position = origin
 projectile.velocity = velocity
 projectile.hostile = hostile
 add_child(projectile)
