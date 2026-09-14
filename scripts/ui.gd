extends CanvasLayer
signal start_requested
signal resume_requested
signal title_requested
var panel: PanelContainer
var column: VBoxContainer
var hud: Label
var banner: Label
var boss_bar: ProgressBar
var footer: Label
func _ready() -> void:
 process_mode = Node.PROCESS_MODE_ALWAYS
 var theme := Theme.new()
 theme.default_font_size = 14
 theme.set_color("font_color","Label",Color("d0e9f2"))
 theme.set_color("font_color","Button",Color("8af6ff"))
 for state in ["normal","hover","pressed","focus"]:
  var box := StyleBoxFlat.new()
  box.bg_color = Color("152239") if state == "normal" else Color("25445b")
  box.border_color = Color("56e8ef") if state != "normal" else Color("294052")
  box.set_border_width_all(1)
  box.content_margin_top = 5
  box.content_margin_bottom = 5
  theme.set_stylebox(state,"Button",box)
 var root := Control.new()
 root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 root.mouse_filter = Control.MOUSE_FILTER_IGNORE
 root.theme = theme
 add_child(root)
 hud = Label.new()
 hud.position = Vector2(18,10)
 hud.add_theme_font_size_override("font_size",13)
 root.add_child(hud)
 banner = Label.new()
 banner.position = Vector2(0,185)
 banner.size.x = 640
 banner.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 banner.add_theme_color_override("font_color",Color("ffe08a"))
 root.add_child(banner)
 boss_bar = ProgressBar.new()
 boss_bar.position = Vector2(170,33)
 boss_bar.size = Vector2(300,5)
 boss_bar.show_percentage = false
 for key in ["background","fill"]:
  var bar_style := StyleBoxFlat.new()
  bar_style.bg_color = Color("ff70bc") if key == "fill" else Color("26324a")
  boss_bar.add_theme_stylebox_override(key,bar_style)
 root.add_child(boss_bar)
 boss_bar.size = Vector2(300,5)
 footer = Label.new()
 footer.position = Vector2(0,339)
 footer.size.x = 640
 footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 footer.add_theme_font_size_override("font_size",10)
 footer.modulate = Color("668397")
 root.add_child(footer)
 panel = PanelContainer.new()
 panel.position = Vector2(140,38)
 panel.size = Vector2(360,280)
 var style := StyleBoxFlat.new()
 style.bg_color = Color(0.025,0.05,0.1,0.96)
 style.border_color = Color("29465b")
 style.set_border_width_all(1)
 style.content_margin_left = 24
 style.content_margin_right = 24
 style.content_margin_top = 18
 style.content_margin_bottom = 18
 panel.add_theme_stylebox_override("panel",style)
 root.add_child(panel)
 column = VBoxContainer.new()
 column.add_theme_constant_override("separation",8)
 panel.add_child(column)
func clear_menu() -> void:
 for c in column.get_children():
  column.remove_child(c)
  c.queue_free()
 panel.size = Vector2(360,0)
 panel.visible = true
func label_text(text: String, size: int = 14, color: Color = Color("d0e9f2")) -> void:
 var l := Label.new()
 l.text = text
 l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
 l.add_theme_font_size_override("font_size",size)
 l.add_theme_color_override("font_color",color)
 column.add_child(l)
func button(text: String, callback: Callable, focus: bool = false) -> void:
 var b := Button.new()
 b.text = text
 b.pressed.connect(callback)
 column.add_child(b)
 if focus: focus_when_ready.call_deferred(b)
func title() -> void:
 clear_menu()
 hud.text = "1NV4D3RS / ORBITAL DEFENSE"
 boss_bar.hide()
 banner.text = ""
 label_text("1NV4D3RS",38,Color("8af6ff"))
 label_text("N E O N   A R C A D E   S U R V I V A L",10,Color("ff70bc"))
 label_text("ENDLESS SIGNAL. LAST DEFENDER.",12)
 label_text("BEST  %07d" % Settings.best,16,Color("ffe08a"))
 button("START RUN",func(): start_requested.emit(),true)
 button("SETTINGS",func(): settings_menu(false))
 button("QUIT",func(): Audio.quit_game())
 footer.text = "A / D  MOVE    SPACE  FIRE    SHIFT  DASH    •    CONTROLLER SUPPORTED"
func pause_menu() -> void:
 clear_menu()
 label_text("SIGNAL PAUSED",24,Color("8af6ff"))
 button("RESUME",func(): resume_requested.emit(),true)
 button("SETTINGS",func(): settings_menu(true))
 button("END RUN",func(): title_requested.emit())
func game_over(score: int, wave: int) -> void:
 clear_menu()
 label_text("SIGNAL LOST",30,Color("ff70bc"))
 label_text("SCORE  %07d     WAVE  %02d" % [score,wave],16)
 label_text("BEST  %07d" % Settings.best,16,Color("ffe08a"))
 button("TRY AGAIN",func(): start_requested.emit(),true)
 button("MAIN MENU",func(): title_requested.emit())
func settings_menu(from_pause: bool) -> void:
 clear_menu()
 label_text("SETTINGS",20,Color("8af6ff"))
 for key in ["master","music","effects","shake"]:
  var row := HBoxContainer.new()
  var l := Label.new()
  l.text = key.to_upper()
  l.custom_minimum_size.x = 95
  l.add_theme_font_size_override("font_size",11)
  row.add_child(l)
  var slider := HSlider.new()
  slider.custom_minimum_size = Vector2(190,18)
  slider.step = 0.05
  slider.max_value = 1.0
  slider.value = Settings.values[key]
  slider.value_changed.connect(func(v): Settings.set_option(key,v))
  row.add_child(slider)
  column.add_child(row)
  if key == "master": focus_when_ready.call_deferred(slider)
 for key in ["reduced_flashes","fullscreen"]:
  var check := CheckButton.new()
  check.text = key.replace("_"," ").capitalize()
  check.button_pressed = Settings.values[key]
  check.toggled.connect(func(v): Settings.set_option(key,v))
  column.add_child(check)
 button("BACK",func():
  if from_pause: pause_menu()
  else: title())
func update_hud(player: Node2D, score: int, wave: int, run_seed: int) -> void:
 hud.text = "SCORE %07d    WAVE %02d    HULL %s    DASH %s" % [score,wave,"◆".repeat(maxi(0,player.health)),"READY" if player.dash_cooldown<=0 else "%.1f" % player.dash_cooldown]
 footer.text = "SEED %d   •   %s%s%s" % [run_seed,"RAPID %.0fs   " % player.rapid if player.rapid>0 else "","SPREAD %.0fs   " % player.spread if player.spread>0 else "","SHIELD ACTIVE" if player.shield else "COLLECT: R RAPID / W SPREAD / S SHIELD / + REPAIR"]

func focus_when_ready(control: Control) -> void:
 if is_instance_valid(control) and control.is_inside_tree(): control.grab_focus()
