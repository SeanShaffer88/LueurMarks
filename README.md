# LueurMarks

LueurMarks is a small, modular companion for [Lueur](https://www.curseforge.com/wow/addons/lueur). It places one contextual micro-icon beside the soft-target frame: a quest marker, loot bag, or service marker. It does not replace Lueur or modify Blizzard frames beyond attaching its own overlay.

## Install

Copy the `LueurMarks` folder (including `LueurMarks.toc` and `Modules/`) into `World of Warcraft/_retail_/Interface/AddOns/`. Lueur must be installed and enabled. The TOC currently targets the WoW: Forever client interface build `120000`.

## Use

- `/lueurmarks` — show status and help
- `/lueurmarks toggle` — enable or disable icons
- `/lueurmarks size 18` — set icon size (10–36)
- `/lueurmarks offset 4 0` — adjust placement relative to the soft-target frame

Settings are saved per account. Module priority is Quest, Loot, then Service; only the highest-priority matching icon is shown. Hover an icon for its short description.

## Modules and detection

Each module registers a resolver using `LueurMarks:RegisterModule(name, callback, priority)`. The callback receives the active soft-target unit token and GUID, and may return `{ icon = texturePath, tooltip = optionalText }`, `{ atlas = atlasName, tooltip = optionalText }`, or `nil`. Lower priority numbers run first. A failing resolver is reported once through the WoW error handler without preventing other modules from running.

Quest state uses the current Gossip quest lists and requires the target to be flagged as a quest giver. Loot detection marks dead, non-player units that Blizzard identifies as lootable. These details are client/API-dependent; the addon intentionally does not guess solely from creature names. Repair/anvil NPC IDs can be added to the tables in `Modules/Service.lua`; Blizzard does not expose a universally reliable pre-interaction repair/anvil capability query for every soft target. Exact Lueur frame global names vary by version, so the overlay checks Lueur's `LueurSoftTargetFrame` first and then Blizzard's `SoftTargetFrame` globals.

## License

See [LICENSE](LICENSE).
