extends "res://objects/modules/cgc/variants/cgc_fairway_parkour_boss.gd"

func _ready() -> void:
	%MoleUI.hide()
	%NodeViewer.node = MOLE_COG.instantiate()
	mole_games.assign(%MoleGames.get_children())
	golf_doors.assign(%GolfDoors.get_children())

func body_entered(body: Node3D) -> void:
	if body is Player and not game_started:
		start_game()

func start_game() -> void:
	Util.get_player().game_timer_tick = false
	Util.stuck_lock = true
	hookup_moles()
	game_started = true

	tween = Sequence.new([
		LerpFunc.new(AudioManager.set_music_volume, 3.0, 0.0, -80.0)
	]).as_tween(self)

	Util.stop_player_safe()
	await CameraTransition.from_current(self, %DialogueCam, 3.0).s_done
	ball_speak("Better be quick, or you're going back to the playground.")
	%FenceBlockGroup.position.y = 0
	%BallAnim.play(&"dialogue")
	await %BallAnim.animation_finished
	%DialogueBall.hide()
	await CameraTransition.from_current(self, %MolePreviewCam, 1.0).s_done
	%FenceGate.play_close_anim()
	await Task.delay(2.0)
	await CameraTransition.from_current(self, Util.get_player().camera.camera, 3.0).s_done
	Util.resume_player_safe()

	quota = quota  # Reset the label text via the setter
	%MoleUI.show()
	make_game_timer()

	for golf_door: Node3D in golf_doors:
		adjust_golf_speed(golf_ball_speed, golf_door)

	spawn_new_mole()
	start_golfs()

	AudioManager.set_music(BOSS_MUSIC)
	AudioManager.set_music_volume(0.0)

	# Give a free win if you're somehow still here after 5 minutes
	sanity_task = Task.delayed_call(self, 60 * 5, mole_hit)
	Util.get_player().game_timer_tick = true

func make_game_timer(timer_time: int = GameTimeBase) -> void:
	game_timer = Util.run_timer(timer_time, Control.PRESET_BOTTOM_RIGHT)
	game_timer.timer.timeout.connect(lose_game)

func start_golfs() -> void:
	for golf_door in %GolfDoors.get_children():
		golf_door.start_off = false
		golf_door.stopped = false
		golf_door.delay_ball(randf_range(0.1, 0.5))
		golf_door.golf_ball.show()
		golf_door.golf_ball.get_node("SFX").play()
	golf_ball_speed = BASE_GOLF_SPD

func adjust_golf_speed(value: float, golf_door: Node3D) -> void:
	golf_door.speed = value

func spawn_new_mole() -> void:
	var mole_game: MoleStompGame = RandomService.array_pick_random("mole_boss", mole_games)
	var mole: MoleHole = mole_game.get_random_mole()
	mole.force_cog_mole = true
	mole.mole_cog_boost_time = 2.75
	mole_task = Task.delayed_call(self, randf_range(mole_popup_time_range.x, mole_popup_time_range.y), spawn_new_mole)

func hookup_moles() -> void:
	for mole_game: MoleStompGame in mole_games:
		mole_game.s_managed_red_hit.connect(mole_hit)
		mole_game.start_game()
		for mole_hole: MoleHole in mole_game.get_all_moles():
			# Gears too big
			mole_hole.get_node("CogGears").process_material.initial_velocity_min = 2.5
			mole_hole.get_node("CogGears").process_material.initial_velocity_max = 5.0

func mole_hit() -> void:
	quota -= 1
	%MoleHitSFX.play()
	golf_ball_speed += get_spd_increment()
	if quota <= 0:
		win_game()
	else:
		if game_timer:
			set_timer_to_time(game_timer.timer.time_left + GameTimeIncPerMole)
		else:
			set_timer_to_time(GameTimeBase)

func win_game() -> void:
	Util.stuck_lock = false
	cancel_mole_task()
	cancel_sanity_task()
	for mole_game: MoleStompGame in mole_games:
		mole_game.disable_moles()
		mole_game.timer.stop()
	%MoleUI.hide()
	if game_timer:
		game_timer.queue_free()
		game_timer = null
	%BossChestGroup.make_chests()
	s_game_won.emit()
	%FenceBlockGroup.position.y = -100
	tween = Sequence.new([
		LerpFunc.new(AudioManager.set_music_volume, 2.0, 0.0, -80.0)
	]).as_tween(self)
	await tween.finished
	AudioManager.stop_music()
	AudioManager.set_music_volume(0.0)
	Util.get_player().stats.charge_active_item(2)

func lose_game() -> void:
	# Remove half of their health if they lose
	# While this can't directly kill them very easily,
	# they will probably get ran over by a golf ball and die from that
	Util.get_player().last_damage_source = "the Fairway Fiend"
	Util.get_player().quick_heal(-maxi(ceili(Util.get_player().stats.hp * 0.5), 5))
	# Restart the timer and reset the quota.
	quota = start_quota
	game_timer.queue_free()
	make_game_timer(GameTimeBase)
	game_timer.scale_pop()
	AudioManager.play_sound(SFX_LOSE)
	golf_ball_speed = BASE_GOLF_SPD

	ui_tween = Sequence.new([
		LerpProperty.new(%RemainingLabel, ^"scale", 0.2, Vector2.ONE * 1.2).interp(Tween.EASE_OUT),
		LerpProperty.new(%RemainingLabel, ^"scale", 0.2, Vector2.ONE * 1.0).interp(Tween.EASE_IN),
	]).as_tween(self)

func set_timer_to_time(timer_time: int) -> void:
	if game_timer:
		game_timer.queue_free()
	make_game_timer(timer_time)
	game_timer.scale_pop()
	AudioManager.play_sound(SFX_TIMER_CHANGE)

func cancel_mole_task() -> void:
	if mole_task:
		mole_task = mole_task.cancel()

func cancel_sanity_task() -> void:
	if sanity_task:
		sanity_task = sanity_task.cancel()

func _exit_tree() -> void:
	cancel_mole_task()
	cancel_sanity_task()

func ball_speak(phrase: String) -> void:
	# Create a new speech bubble
	speech_bubble = load('res://objects/misc/speech_bubble/speech_bubble.tscn').instantiate()
	speech_bubble.target = %DialogueNode
	speech_bubble.set_font(load('res://fonts/vtRemingtonPortable.ttf'))
	%DialogueNode.add_child(speech_bubble)
	speech_bubble.set_text(phrase)
	AudioManager.play_sound(SFX_TALK)

func remove_ball_speak() -> void:
	if speech_bubble and is_instance_valid(speech_bubble) and not speech_bubble.is_queued_for_deletion():
		speech_bubble.finished.emit()
		speech_bubble = null

# I CALL THINE MIGHTLY NERF HAMMER UPON THY GOLF BALL -cm37
func get_spd_increment() -> float:
	if Util.on_easy_floor():
		return 0.02
	return 0.04
