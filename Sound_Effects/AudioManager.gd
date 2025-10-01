extends Node

@onready var sfx_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var bgm_player: AudioStreamPlayer = AudioStreamPlayer.new()

var playlist: Array[AudioStream] = []
var playlist_index: int = 0
var playlist_loop: bool = true   # วน playlist ทั้งหมด

func _ready():
	add_child(sfx_player)
	add_child(bgm_player)

	# กำหนด bus ที่จะใช้
	sfx_player.bus = "SFX"
	bgm_player.bus = "BGM"

	# เช็กว่าเพลงจบหรือยัง
	bgm_player.finished.connect(_on_bgm_finished)

func play_sfx(stream: AudioStream) -> void:
	if stream:
		sfx_player.stream = stream
		sfx_player.play()

func play_bgm(stream: AudioStream, loop: bool = true) -> void:
	if stream:
		if loop and stream is AudioStreamOggVorbis:
			stream.loop = loop
		bgm_player.stream = stream
		bgm_player.play()

func play_bgm_list(music_list: Array[AudioStream], loop_playlist: bool = true) -> void:
	if music_list.size() == 0:
		return
	
	playlist = music_list
	playlist_index = 0
	playlist_loop = loop_playlist
	_play_current_in_playlist()

func _play_current_in_playlist() -> void:
	if playlist_index < playlist.size():
		var stream: AudioStream = playlist[playlist_index]
		if stream is AudioStreamOggVorbis:
			stream.loop = false  # ไม่วนใน track เดียว ให้เปลี่ยนไปเพลงต่อแทน
		bgm_player.stream = stream
		bgm_player.play()

func _on_bgm_finished() -> void:
	playlist_index += 1
	if playlist_index >= playlist.size():
		if playlist_loop:
			playlist_index = 0
		else:
			return  # หยุดเมื่อเล่นครบ
	
	_play_current_in_playlist()

func stop_bgm() -> void:
	bgm_player.stop()
	playlist.clear()
	playlist_index = 0
