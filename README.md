# Game Jam — Godot Project

Short Godot game created for a game jam. This repository contains scenes, scripts, and assets for the project.

## Quick start
- Open Godot and load the project by selecting `project.godot` at the repo root.
- Run the main scene (open `scenes/main_menu.tscn` or use the project Run button).

## Project layout (top-level)
- `scenes/` — Godot scene files (.tscn) grouped by feature (core, actors, levels, UI).
- `src/` — GDScript source files organized by subsystem.
- `assets/` — Audio, fonts, textures, models and other resources.
- `project.godot` — Godot project file.

## Development notes
- This project targets Godot (open the project with the matching Godot version you used).
- Edit scenes in the `scenes/` folder and logic in `src/`.

## Useful files
- Main menu: `scenes/main_menu.tscn`
- Game manager: `src/core/game_manager.gd`

## Contact
If you need changes to this README or want me to expand it (contributing guide, controls, build/export steps), tell me what sections you want added.
# Signal — Game Jam Project

Short game prototype used during a game jam. Open this project in Godot and run `res://scenes/main_menu.tscn` to start.

**Requirements**
- Godot 4.x (open `project.godot` with your Godot editor)

**Run**
- Open the project in Godot and press Play (or open the `main_menu.tscn` scene).

**Project structure (important)**
- `scenes/` — contains UI and level scenes
- `scenes/levels/` — level scenes (introduction, tutorial, level1, level2, ending)
- `src/` — GDScript source (core systems, actors, objects)
- `assets/audio/` — music and SFX

**What I changed recently**
- Removed `scenes/levels/level3.tscn` and updated level lists and menus.
- Added sequential level progression with persistent saves: `src/core/progression.gd` (saves to `user://progress.cfg`). Only the introduction is unlocked by default; completing a level unlocks the next.
- Updated `src/core/level_manager.gd` to show a dialog when attempting locked levels and to respect saved progression.
- Updated `src/core/pole.gd` and `src/core/connection_complete.gd` so completing a level unlocks progress and Escape also advances the completion overlay.
- Added `src/core/music.gd` and attached it to `scenes/core/music.tscn` to keep background music playing, enforce the Music bus volume, and restart playback when the stream finishes.
- Increased the Music node audible area (`attenuation_db` / `max_distance`) so music is heard from farther away.

**Troubleshooting**
- Progress not saving: check Godot output for messages like `Failed to save progression` and ensure the game can write to `user://` (on desktop this is a folder in Godot's user data; permissions may block saving).
- Music fades or stops: the runtime enforces the Music bus volume and restarts playback, but if fades persist consider re-importing the audio as OGG/WAV and enabling looping in the importer.

**Useful commands**
- Commit changes locally:
```
git add -A
git commit -m "Sequential progression, remove level3, fix music looping"
```

If you want, I can commit these changes for you, or tweak messaging, unlock behavior, or switch the Music node to a non-attenuated global player. Tell me which you'd like next.
