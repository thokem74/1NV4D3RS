class_name WaveGenerator
extends RefCounted
var rng := RandomNumberGenerator.new()
var config: DifficultyConfig = preload("res://resources/difficulty.tres")
func generate(wave: int, run_seed: int) -> Array[Dictionary]:
 rng.seed = run_seed + wave * 7919
 var result: Array[Dictionary] = []
 if wave % 5 == 0: return result
 var budget := mini(12 + wave * 3, config.max_enemies)
 var columns := 9
 var shape := rng.randi_range(0, 2)
 for i in budget:
  var row := i / columns
  var col := i % columns
  var kind := 0 if wave == 1 else rng.randi_range(0, mini(3, wave - 1))
  var y := 58.0 + row * 27.0
  if shape == 1: y += absf(col - 4) * 5
  if shape == 2: y += (col % 2) * 12
  result.append({"kind": kind, "position": Vector2(112 + col * 52, y), "phase": rng.randf_range(0, TAU), "fire_delay": 1.8 + i * 0.19, "motion": shape})
 return result
