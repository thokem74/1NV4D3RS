extends Node2D
const PLAYER = preload("res://scenes/player.tscn")
const ENEMY = preload("res://scenes/enemy.tscn")
const BOSS = preload("res://scenes/boss.tscn")
const PICKUP = preload("res://scenes/pickup.tscn")
const EFFECT = preload("res://scenes/effect.tscn")
var generator := WaveGenerator.new()
var rng := RandomNumberGenerator.new()
var world: Node2D
var actors: Node2D
var bullets: Node2D
var pickups: Node2D
var effects: Node2D
var ui: CanvasLayer
var player: Node2D
var boss: Node2D
var scoring := ScoreKeeper.new()
var score: int:
 get: return scoring.total
 set(value):
  scoring.total = value
var wave: int = 0
var run_seed: int = 0
var state: String = "title"
var wave_delay: float = 0
var shake: float = 0
var hit_stop: float = 0
var spawn_queue: Array[Dictionary] = []
var spawn_timer: float = 0
var shot_sound_cooldown: float = 0
func _ready() -> void:
 get_tree().auto_accept_quit = false
 process_mode = Node.PROCESS_MODE_ALWAYS
 add_child(preload("res://scenes/starfield.tscn").instantiate())
 world = Node2D.new()
 world.process_mode = Node.PROCESS_MODE_PAUSABLE
 add_child(world)
 for key in ["actors","bullets","pickups","effects"]:
  var n := ProjectileSpawner.new() if key == "bullets" else Node2D.new()
  world.add_child(n)
  set(key,n)
 var post := CanvasLayer.new()
 post.layer = 0
 add_child(post)
 var screen := ColorRect.new()
 screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
 var material := ShaderMaterial.new()
 material.shader = preload("res://shaders/neon.gdshader")
 screen.material = material
 post.add_child(screen)
 ui = preload("res://scenes/ui.tscn").instantiate()
 add_child(ui)
 ui.start_requested.connect(start_run)
 ui.resume_requested.connect(resume)
 ui.title_requested.connect(show_title)
 ui.title()
func clean() -> void:
 for container in [actors,bullets,pickups,effects]:
  for node in container.get_children():
   container.remove_child(node)
   node.queue_free()
 player = null
 boss = null
 spawn_queue.clear()
 world.position = Vector2.ZERO
 world.process_mode = Node.PROCESS_MODE_PAUSABLE
 shake = 0
 hit_stop = 0
func start_run() -> void:
 get_tree().paused = false
 clean()
 scoring.reset()
 wave = 0
 run_seed = int(Time.get_unix_time_from_system()) % 1000000
 for arg in OS.get_cmdline_user_args():
  if arg.begins_with("--seed="): run_seed = int(arg.trim_prefix("--seed="))
 rng.seed = run_seed
 player = PLAYER.instantiate()
 player.position = Vector2(320,312)
 actors.add_child(player)
 player.shot.connect(player_shot)
 player.engine_trail.connect(func(origin):
  var trail := EFFECT.instantiate()
  trail.position = origin
  trail.is_trail = true
  trail.setup(Color("ff70bc"),2)
  trail.life = 0.2
  effects.add_child(trail))
 player.dashed.connect(func(): Audio.play("dash"); shake = maxf(shake,2))
 player.damaged.connect(func(): impact(player.position,Color("ff70bc"),5); Audio.play("hit"))
 player.died.connect(end_run)
 ui.panel.hide()
 state = "playing"
 next_wave()
func show_title() -> void:
 get_tree().paused = false
 clean()
 state = "title"
 ui.title()
func resume() -> void:
 if state != "paused": return
 get_tree().paused = false
 state = "playing"
 ui.panel.hide()
func end_run() -> void:
 state = "over"
 Settings.record(score)
 ui.game_over(score,wave)
 get_tree().paused = true
func _process(dt: float) -> void:
 if Input.is_action_just_pressed("pause_game"):
  if state == "playing":
   state = "paused"
   get_tree().paused = true
   ui.pause_menu()
  elif state == "paused": resume()
 if state != "playing": return
 if hit_stop > 0:
  hit_stop -= dt
  world.process_mode = Node.PROCESS_MODE_DISABLED
  return
 world.process_mode = Node.PROCESS_MODE_PAUSABLE
 shot_sound_cooldown -= dt
 shake = maxf(0,shake-dt*20)
 world.position = Vector2(randf_range(-shake,shake),randf_range(-shake,shake))*Settings.values.shake
 if wave_delay > 0:
  wave_delay -= dt
  if wave_delay <= 0:
   ui.banner.text = ""
  collisions()
  ui.update_hud(player,score,wave,run_seed)
  return
 spawn_timer -= dt
 if not spawn_queue.is_empty() and spawn_timer <= 0:
  spawn_enemy(spawn_queue.pop_front())
  spawn_timer = 0.045
 for e in actors.get_children():
  if e != player: e.target = player.position
 collisions()
 if state != "playing": return
 var enemy_count := actors.get_child_count()-1
 if enemy_count == 0 and spawn_queue.is_empty():
  scoring.award(wave*250)
  for b in bullets.get_children():
   b.queue_free()
  next_wave()
 ui.update_hud(player,score,wave,run_seed)
 ui.boss_bar.visible = is_instance_valid(boss)
 if is_instance_valid(boss): ui.boss_bar.value = 100.0*boss.hp/boss.max_hp
func next_wave() -> void:
 wave += 1
 wave_delay = 1.5
 ui.banner.text = "WAVE %02d  /  %s" % [wave,"HOSTILE FLAGSHIP" if wave%5==0 else "INCOMING SIGNAL"]
 if wave%5==0:
  boss = BOSS.instantiate()
  boss.configure(wave)
  boss.fire.connect(enemy_shot)
  boss.destroyed.connect(enemy_destroyed)
  boss.struck.connect(enemy_struck)
  actors.add_child(boss)
  Audio.play("warning")
 else:
  spawn_queue = generator.generate(wave,run_seed)
func spawn_enemy(data: Dictionary) -> void:
 var e := ENEMY.instantiate()
 e.configure(data,wave)
 e.fire.connect(enemy_shot)
 e.destroyed.connect(enemy_destroyed)
 e.struck.connect(enemy_struck)
 actors.add_child(e)
func player_shot(origin: Vector2, direction: Vector2) -> void:
 spawn_bullet(origin,direction*420,false)
 if shot_sound_cooldown <= 0:
  Audio.play("shoot")
  shot_sound_cooldown = 0.06
func enemy_shot(origin: Vector2, direction: Vector2) -> void:
 if state != "playing" or wave_delay > 0: return
 spawn_bullet(origin,direction*minf(90+wave*3,generator.config.max_bullet_speed),true)
func spawn_bullet(origin: Vector2, velocity: Vector2, hostile: bool) -> void:
 bullets.spawn(origin,velocity,hostile,generator.config.max_hostile_projectiles)
func enemy_destroyed(enemy: Node2D) -> void:
 var is_boss := enemy == boss
 scoring.award(2500+wave*100 if is_boss else enemy.stats.points)
 impact(enemy.position,Color("ff70bc") if is_boss else enemy.stats.tint,8 if is_boss else 2)
 Audio.play("explosion")
 if is_boss or rng.randf() < generator.config.pickup_chance:
  var p := PICKUP.instantiate()
  var kinds := ["rapid","spread","shield","repair"]
  p.effect = load("res://resources/%s.tres" % kinds[rng.randi_range(0,3)])
  p.position = enemy.position
  pickups.add_child(p)
func impact(origin: Vector2, color: Color, strength: float) -> void:
 var e := EFFECT.instantiate()
 e.position = origin
 e.setup(color,32 if strength>4 else 14)
 effects.add_child(e)
 shake = maxf(shake,strength)
 if strength >= 5: hit_stop = 0.045
func collisions() -> void:
 for b in bullets.get_children():
  if b.is_queued_for_deletion(): continue
  if b.hostile:
   if b.position.distance_to(player.position)<12:
    b.queue_free()
    player.hit()
    if state != "playing": return
  else:
   for e in actors.get_children():
    if e == player or e.is_queued_for_deletion(): continue
    var bounds := Vector2(45,20) if e == boss else Vector2(13,10)
    var diff: Vector2 = (b.position-e.position).abs()
    if diff.x<bounds.x+2 and diff.y<bounds.y+4:
     b.queue_free()
     e.hit()
     break
 for e in actors.get_children():
  if e != player and not e.is_queued_for_deletion() and e.position.distance_to(player.position)<22:
   player.hit()
   if state != "playing": return
 for p in pickups.get_children():
  if not p.is_queued_for_deletion() and p.position.distance_to(player.position)<21:
   player.collect(p.effect)
   p.queue_free()
   Audio.play("pickup")
   impact(p.position,p.effect.tint,1)

func _notification(what: int) -> void:
 if what == NOTIFICATION_WM_CLOSE_REQUEST: Audio.quit_game()

func enemy_struck(origin: Vector2) -> void:
 impact(origin,Color("ffe08a"),0.5)
 Audio.play("hit")
