# PrdUI

World of Warcraft Classic AddOn.

- Clean
- Few options
- Sane defaults
- Nonintrusive

Apart from a UI redesign, it also boasts quality-of-life modules such as coordinates, notepad and spell range indicator.

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

`/pui range <spellname>` - Show or set spell to check when in range

This will display the name of the chosen spell if the target is valid and within range. The text is
briefly shown and will only popup again if the state is changed, i.e. in-or-out of range or a new target.

The range check works for all kinds of spells currently known to the active player and the spell chosen is saved per character.

#### Example

`/pui range Auto Shot`
`/pui range Frostbolt`
