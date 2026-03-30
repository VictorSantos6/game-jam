extends AudioStreamPlayer2D

func _ready() -> void:
    # Ensure playback is active and loop by restarting when finished
    if not is_connected("finished", Callable(self, "_on_finished")):
        connect("finished", Callable(self, "_on_finished"))

    if not is_playing():
        play()

    # Ensure the Music bus stays at a normal volume (0 dB)
    _enforce_bus_volume()

    # periodic guard: ensure bus volume stays correct
    var t := Timer.new()
    t.one_shot = false
    t.wait_time = 1.0
    add_child(t)
    t.start()
    t.timeout.connect(_enforce_bus_volume)

func _process(_delta: float) -> void:
    if not is_playing():
        play()

func _on_finished() -> void:
    # Immediate replay to simulate looping for streams without loop flag
    play()

func _enforce_bus_volume() -> void:
    var idx := AudioServer.get_bus_index("Music")
    if idx >= 0:
        AudioServer.set_bus_volume_db(idx, 0.0)
