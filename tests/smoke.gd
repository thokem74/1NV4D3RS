extends SceneTree
var checks: int = 0
func check(value: bool, message: String) -> void:
 if not value:
  push_error("FAIL: " + message)
  quit(1)
  assert(value,message)
 checks += 1
func _initialize() -> void:
 call_deferred("run")
func run() -> void:
 var preferences = root.get_node("Settings")
 preferences.storage_path = "user://test-pilot.cfg"
 var game = load("res://scenes/main.tscn").instantiate()
 root.add_child(game)
 await process_frame
 check(game.state == "title", "title loads")
 game.start_run()
 game.set_process(false)
 game.world.process_mode = Node.PROCESS_MODE_DISABLED
 var p = game.player
 check(p.health == 3 and game.wave == 1,"new run")
 Input.action_press("move_left")
 p._process(10)
 Input.action_release("move_left")
 check(p.position.x == 20,"left boundary")
 Input.action_press("move_right")
 p._process(10)
 Input.action_release("move_right")
 check(p.position.x == 620,"right boundary")
 Input.action_press("dash")
 p._process(0.01)
 Input.action_release("dash")
 await process_frame
 check(p.dash_cooldown > 1 and p.invulnerable > 0,"dash grants protection")
 var hp: int = p.health
 p.hit()
 check(p.health == hp,"dash blocks damage")
 p._process(1.4)
 p.hit()
 p.hit()
 check(p.health == 2,"damage grace blocks repeat hits")
 for kind in ["rapid","spread","shield","repair"]: p.collect(load("res://resources/%s.tres" % kind))
 check(p.health == 3 and p.shield and p.rapid == 10 and p.spread == 10,"all pickup effects")
 p._process(3)
 p.collect(load("res://resources/rapid.tres"))
 check(p.rapid == 10,"duplicate refreshes")
 p._process(11)
 check(p.rapid == 0 and p.spread == 0,"weapon effects expire")
 p.hit()
 check(not p.shield and p.health == 3,"shield absorbs damage")
 var gen = game.generator
 check(gen.generate(8,42) == gen.generate(8,42),"seed reproducibility")
 check(gen.generate(8,42) != gen.generate(8,43),"seed variation")
 for wave in range(1,301):
  var entries = gen.generate(wave,42)
  check(entries.size() <= gen.config.max_enemies,"enemy cap")
  for data in entries:
   check(data.position.x >= 40 and data.position.x <= 600 and data.position.y < 235,"spawn bounds")
 game.wave_delay = 0
 for i in 100: game.enemy_shot(Vector2(100,100),Vector2.DOWN)
 check(game.bullets.get_child_count() == gen.config.max_hostile_projectiles,"hostile cap")
 game.wave = 4
 game.next_wave()
 check(game.boss.variant == 0 and game.wave == 5,"first boss")
 game.boss.queue_free()
 await process_frame
 game.wave = 9
 game.next_wave()
 check(game.boss.variant == 1,"alternate boss")
 for child in game.actors.get_children():
  if child != p: child.queue_free()
 await process_frame
 game.spawn_queue.clear()
 game.wave_delay = 0
 game.hit_stop = 0
 game._process(0.016)
 await process_frame
 check(game.wave == 11 and game.bullets.get_child_count() == 0,"wave completion clears bullets")
 game.state = "paused"
 paused = true
 game.resume()
 check(not paused and game.state == "playing","resume")
 game.ui.settings_menu(false)
 await process_frame
 check(game.ui.column.get_child_count() == 8,"settings menu builds")
 var settings = root.get_node("Settings")
 var old_best: int = settings.best
 var old_values: Dictionary = settings.values.duplicate()
 settings.record(12345)
 settings.set_option("music",0.35)
 settings.load_settings()
 check(settings.best >= 12345 and is_equal_approx(settings.values.music,0.35),"persistence")
 settings.best = old_best
 settings.values = old_values
 settings.save()
 p.invulnerable = 0
 p.health = 1
 p.hit()
 check(game.state == "over" and paused,"game over")
 game.start_run()
 check(game.player.health == 3 and game.score == 0 and not paused,"restart resets")
 game.show_title()
 check(game.actors.get_child_count() == 0 and game.bullets.get_child_count() == 0,"cleanup")
 DirAccess.remove_absolute(preferences.storage_path)
 game.queue_free()
 await process_frame
 print("PASS: %d checks" % checks)
 await root.get_node("Audio").shutdown()
 quit()
