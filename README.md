[![Discord][SVG-Discord]][Discord]
[![PayPal][SVG-PayPal]][PayPal]
[![Release][SVG-Release]][Release]
[![CustomNames][SVG-CustomNames]][CustomNames]  
# CustomNames_Blizzard
Adds Blizzard default unit frame support for [CustomNames](https://www.curseforge.com/wow/addons/libcustomnames).

[//]: # (Links)

[Discord]: https://discord.com/invite/v3gYmYamGJ (Join the Discord)
[PayPal]: https://ko-fi.com/jodsderechte (Donate via PayPal)
[Release]: https://github.com/Jods-GH/CustomNames_Blizzard/releases/latest (Latest release)
[CustomNames]: https://github.com/Jods-GH/CustomNames

[//]: # (Images)
[SVG-Discord]: https://img.shields.io/badge/Discord-7289da?logo=discord&logoColor=fff&style=flat-square
[SVG-PayPal]: https://custom-icon-badges.demolab.com/badge/-Support-lightgrey?style=flat-square&logo=kofi&color=222222
[SVG-CustomNames]: https://badgen.net/github/release/Jods-GH/CustomNames?style=flat-square
[SVG-Release]: https://badgen.net/github/release/Jods-GH/CustomNames_Blizzard?style=flat-square

## Frame support

Uses existing CustomNames aliases on Blizzard player, pet, target, target-of-target,
focus, focus-target, party, party-pet, compact party/raid, boss, and arena frames
where those frames are available. Nameplates are excluded. No separate settings
or saved-variable database is required; configure names in CustomNames.

The implementation discovers frames as Blizzard loads them and guards APIs that
are absent on older clients. Retail and Classic branches are targeted, but every
client/frame combination still requires in-game validation. Restricted names keep
Blizzard's display. Font, color, positioning, and visibility remain Blizzard-owned.
Alias additions, edits, and removals refresh tracked frames immediately.

## Validation

Run `python tests/test_names.py` with Python and `lupa` installed for mocked Lua
checks of replacement, restoration, NPC aliases, formatted updates, late frame
creation, restricted values, and nameplate exclusion.

Before releasing each supported client, test with only CustomNames and this plugin:

- Load and reload; inspect every available frame family, including arena and bosses.
- Add, edit, and remove player, cross-realm, pet, and NPC aliases.
- Swap targets, enter vehicles, summon pets, and change party/raid membership.
- Switch grouped and ungrouped raid layouts and available Edit Mode layouts.
- Enter and leave combat; check for Lua errors, blocked actions, and stale labels.
- Confirm click targeting, unit menus, long names, and hidden names still work.

Mock checks do not establish combat/taint safety or verify client frame layouts.
