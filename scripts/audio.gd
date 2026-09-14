extends Node
var music: AudioStreamPlayer
var voices: Array[AudioStreamPlayer] = []
var sounds: Dictionary = {}
var voice_index: int = 0
func _ready() -> void:
 process_mode = Node.PROCESS_MODE_ALWAYS
 for key in ["shoot","hit","explosion","pickup","dash","warning"]: sounds[key] = load("res://assets/audio/%s.wav" % key)
 music = AudioStreamPlayer.new()
 var stream: AudioStreamWAV = load("res://assets/audio/music.wav")
 stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
 stream.loop_end = stream.data.size()/2
 music.stream = stream
 add_child(music)
 for i in 16:
  var p := AudioStreamPlayer.new()
  add_child(p)
  voices.append(p)
 Settings.changed.connect(update_volume)
 update_volume()
 music.play()
func update_volume() -> void:
 music.volume_db = linear_to_db(maxf(0.00001,Settings.values.master*Settings.values.music))
 for p in voices: p.volume_db = linear_to_db(maxf(0.00001,Settings.values.master*Settings.values.effects*0.7))
func play(key: String) -> void:
 var p := voices[voice_index]
 voice_index = (voice_index+1)%voices.size()
 p.stream = sounds[key]
 p.pitch_scale = randf_range(0.95,1.05)
 p.play()

func _exit_tree() -> void:
 music.stop()
 music.stream = null
 for p in voices:
  p.stop()
  p.stream = null
 sounds.clear()

func shutdown() -> void:
 music.stop()
 for p in voices: p.stop()
 # Give the audio mixer time to release active playback references before exit.
 await get_tree().create_timer(0.15, true).timeout
func quit_game() -> void:
 await shutdown()
 get_tree().quit()
