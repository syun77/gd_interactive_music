extends Node2D

@onready var interactive_player = $InteractivePlayer
@onready var stem_player = $StemPlayer
@onready var stem_sync = stem_player.stream as AudioStreamSynchronized

enum eStem {
	DRUM_BASS = 0,
	DRUM2 = 1,
	LEAD = 2,
}

func _ready() -> void:
	set_layer_db(eStem.LEAD, -96, 0)
	set_layer_db(eStem.DRUM2, -96, 0)

func _on_btn_intro_pressed() -> void:
	interactive_player.set("parameters/switch_to_clip", "Intro")

func _on_btn_main_pressed() -> void:
	interactive_player.set("parameters/switch_to_clip", "Main")

# レイヤーごとの音量を「線形ゲインでフェード」→ 設定時に dB へ変換
func set_layer_db(i: eStem, db_target: float, t := 2.0):
	if stem_sync == null:
		return

	# 現在値（dB）→ 線形へ
	var db_from := 0.0
	if stem_sync.has_method("get_sync_stream_volume"):
		db_from = stem_sync.get_sync_stream_volume(i)

	var lin_from := db_to_linear(db_from)
	var lin_to   := db_to_linear(db_target)

	# 0 は -inf dB になってしまうので小さな値で下駄を履かせる
	const EPS := 1e-5
	lin_from = max(lin_from, EPS)
	lin_to   = max(lin_to,   EPS)

	var tw := get_tree().create_tween()
	tw.tween_method(
		func(lin):
			# 補間は線形ゲイン、設定は dB
			var db := linear_to_db(max(lin, EPS))
			stem_sync.set_sync_stream_volume(i, db),
		lin_from, lin_to, t
	)

func _on_btn_1_pressed() -> void:
	set_layer_db(eStem.DRUM_BASS, 0)

func _on_btn_2_pressed() -> void:
	set_layer_db(eStem.DRUM2, 0)

func _on_btn_3_pressed() -> void:
	set_layer_db(eStem.LEAD, 0)

func _on_btn_4_pressed() -> void:
	set_layer_db(eStem.DRUM_BASS, -96)

func _on_btn_5_pressed() -> void:
	set_layer_db(eStem.DRUM2, -96)

func _on_btn_6_pressed() -> void:
	set_layer_db(eStem.LEAD, -96)
