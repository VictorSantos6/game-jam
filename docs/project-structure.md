# Project Structure

This project uses a mirrored scene/script layout for fast navigation during the jam.

## Top-level

- `assets/`: raw game content (audio, textures, models).
- `scenes/`: `.tscn` files grouped by gameplay domain.
- `src/`: `.gd` scripts grouped by the same gameplay domain.
- `common/`: shared rendering/theme resources.

## Domain mapping

Keep scenes and scripts in matching domains:

- `scenes/actors/players` <-> `src/actors/players`
- `scenes/actors/enemies` <-> `src/actors/enemies`
- `scenes/objects/collectibles` <-> `src/objects/collectibles`
- `scenes/ui` <-> `src/ui`
- `scenes/core` <-> `src/core`

## Audio split

- `assets/audio/music`: background music.
- `assets/audio/sfx`: gameplay sound effects.
- `assets/audio/ui`: menu/HUD sounds.

## Conventions

- Prefer one main script per scene root node.
- Keep manager scripts in `src/core`.
- Use snake_case filenames for scripts and scenes.
- Add new files to existing domain folders before creating new domains.
