class_name Progression

const SAVE_PATH := "user://progress.cfg"

static func _default_unlocked() -> Array:
    return [
        "res://scenes/levels/introduction.tscn",
    ]

static func get_unlocked_scenes() -> Array:
    var cfg := ConfigFile.new()
    if cfg.load(SAVE_PATH) != OK:
        return _default_unlocked()
    return cfg.get_value("progress", "unlocked", _default_unlocked())

static func is_unlocked(scene_path: String) -> bool:
    var unlocked := get_unlocked_scenes()
    return scene_path in unlocked

static func unlock_scene(scene_path: String) -> void:
    var unlocked := get_unlocked_scenes()
    if scene_path in unlocked:
        return
    unlocked.append(scene_path)
    var cfg := ConfigFile.new()
    cfg.set_value("progress", "unlocked", unlocked)
    var err := cfg.save(SAVE_PATH)
    if err != OK:
        push_error("Failed to save progression to %s (error %d)" % [SAVE_PATH, err])
