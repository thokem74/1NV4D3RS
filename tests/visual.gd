extends SceneTree
func _initialize() -> void:
 call_deferred("run")
func snapshot(path: String) -> void:
 await process_frame
 await RenderingServer.frame_post_draw
 root.get_texture().get_image().save_png(path)
func run() -> void:
 var game = load("res://scenes/main.tscn").instantiate()
 root.add_child(game)
 await snapshot("/tmp/invaders-title.png")
 game.ui.settings_menu(false)
 await snapshot("/tmp/invaders-settings.png")
 root.size = Vector2i(1024,768)
 await snapshot("/tmp/invaders-settings-4x3.png")
 root.size = Vector2i(1280,720)
 game.start_run()
 game.player.invulnerable = 999
 Input.action_press("fire")
 for i in 250: await process_frame
 Input.action_release("fire")
 await snapshot("/tmp/invaders-game.png")
 game.wave = 4
 for e in game.actors.get_children():
  if e != game.player: e.queue_free()
 game.spawn_queue.clear()
 await process_frame
 game.next_wave()
 for i in 130: await process_frame
 await snapshot("/tmp/invaders-boss.png")
 game.show_title()
 game.queue_free()
 await process_frame
 await root.get_node("Audio").shutdown()
 quit()
