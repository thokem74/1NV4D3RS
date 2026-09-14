extends SceneTree
var failures: int = 0
func check(condition: bool, message: String) -> void:
 if not condition:
  push_error(message)
  failures += 1
func _initialize() -> void:
 call_deferred("run")
func run() -> void:
 var game = load("res://scenes/main.tscn").instantiate()
 root.add_child(game)
 await process_frame
 game.start_run()
 game.set_process(false)
 game.world.process_mode = Node.PROCESS_MODE_DISABLED
 game.spawn_queue.clear()
 game.wave_delay = 0
 game.player.invulnerable = 999
 for kind in 4:
  var data := {"kind":kind,"position":Vector2(200,100),"phase":0.0,"motion":kind%3,"fire_delay":0.1}
  game.spawn_enemy(data)
  var enemy = game.actors.get_child(-1)
  enemy.target = game.player.position
  enemy._process(0.2)
  check(enemy.diving if kind == 2 else game.bullets.get_child_count()>0,"enemy behavior %d" % kind)
  enemy.position = Vector2(200,100)
  var previous: int = game.score
  for hit in enemy.stats.health:
   game.spawn_bullet(enemy.position,Vector2.ZERO,false)
   game.collisions()
   await process_frame
  check(game.score>previous,"enemy kill awards score")
 for b in game.bullets.get_children(): b.queue_free()
 await process_frame
 game.wave = 299
 game.next_wave()
 game.wave_delay = 0
 var boss = game.boss
 for i in 600:
  boss._process(1.0/60)
  for b in game.bullets.get_children(): b._process(1.0/60)
  if i%30==0: await process_frame
 check(game.bullets.get_child_count()<=64,"late boss projectile cap")
 for b in game.bullets.get_children(): check(b.velocity.length()<=155.01,"late projectile speed cap")
 var previous: int = game.score
 for hit in boss.hp: boss.hit()
 await process_frame
 check(game.score>previous and not is_instance_valid(game.boss),"boss death and score")
 # Input events exercise bindings independently of physical hardware.
 var pad := InputEventJoypadButton.new()
 pad.button_index = JOY_BUTTON_A
 pad.pressed = true
 Input.parse_input_event(pad.duplicate())
 Input.flush_buffered_events()
 check(Input.is_action_pressed("fire"),"controller fire binding")
 pad.pressed = false
 Input.parse_input_event(pad.duplicate())
 Input.flush_buffered_events()
 var key := InputEventKey.new()
 key.physical_keycode = KEY_A
 key.pressed = true
 Input.parse_input_event(key.duplicate())
 Input.flush_buffered_events()
 check(Input.is_action_pressed("move_left"),"keyboard movement binding")
 key.pressed = false
 Input.parse_input_event(key.duplicate())
 Input.flush_buffered_events()
 print("Connected controllers: ",Input.get_connected_joypads())
 game.show_title()
 game.queue_free()
 await process_frame
 await root.get_node("Audio").shutdown()
 print("PASS: combat and input integration" if failures==0 else "FAIL: combat integration")
 quit(0 if failures==0 else 1)
