# PrdUI

World of Warcraft Classic (TBC) AddOn.

- Clean
- Few options
- Sane defaults
- Nonintrusive

Apart from a UI redesign, it also boasts quality-of-life modules:

- Coordinates
- Notepad
- Spell range indicator
- Sell all vendor trash with one click
- LFG chat filter
- Fishing sound enhancement

![PrdUI screenshot](./screenshot.jpg)

## Installation

### Versions

The latest stable version is available at https://github.com/prodhe/prdui.

A bleeding edge development version is available as well (in a separate development branch of the source), but that one may or may not be stable for actual usage.

### Download

Download the zip file and extract the `PrdUI` folder in `World of Warcraft\_classic_\Interface\AddOns`.

While in-game, type `/pui` for options.

## Settings

### Range

`/pui range <spell>` - Disable or set spell to check when in range

This will display the name of the chosen spell if the target is valid and within range. The text is
briefly shown and will only popup again if the state is changed, i.e. in-or-out of range or a new target.

The range check works for all kinds of spells currently known to the active player and the spell chosen is saved per character.

#### Example

`/pui range`

Clear and disable the spell range check.

`/pui range Auto Shot`

`/pui range Frostbolt`

### Chat filter

`/pui filter <pattern>` - Disable or set LFG chat filter using Lua pattern matching

By default on each login, this will be disabled and empty. By setting a pattern matching filter,
every message on the global LookingForGroup will be parsed and lower-case matched. If it passes,
it will be printed to the default chat channel in the Blizzard default format.

Check out the [Lua documentation on patterns](http://www.lua.org/manual/5.4/manual.html#6.4.1) if you would want to get fancy.

#### Example

`/pui filter`

Clear and disable the filter. This is the default upon each reload.

`/pui filter .*`

Matches any character (`.`) zero or more times (`*`), ie everything.

`/pui filter ony`

Matches every message containing the string `ony`.

`/pui filter z[fg]`

Matches every message with `z` and then directly followed by either `f` or `g`.
