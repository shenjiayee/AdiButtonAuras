# AdiButtonAuras

This project is a temp-fix version.

Visit https://github.com/AdiAddons/AdiButtonAuras for more info.

It would be closed when the original author updates.

The original project references lib-ace3, but the latest release of ace3 (Release-r1294) still does not work.

So I changed some lines in lib-ace3. (`AceConfigDialog-3.0.lua` - after line 2002, add `Settings.RegisterAddOnCategory(subcategory)`)

And there are a few of (de)buff-ids need to be replaced with the dragon-flight one, but they are in `LibPlayerSpells-1.0` and `LibItemBuffs-1.0`.
So I did't folk the origin repo, but create a new repo with the packaged addons instead.

# Problem Still Remains

The configuration panel would not exist in the settings-category until you typed the slash cmd `/aba/` or `/adibuttonauras`.

The global var `INTERFACEOPTIONS_ADDONCATEGORIES` is nil now. It was used when aba-config loading, aba removes the fake cfg-panel from `INTERFACEOPTIONS_ADDONCATEGORIES` and generate a real panel from aba-config instead.

But I do not get a way to impl this function, so I just comment the codes about fake cfg-panel.

# More Info

It is 10.0.0 now. Some (de)buff-ids have changed.  They should be replaced with the dragon-flight version.

I will do it step by step.
