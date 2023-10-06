# Minetest Library Mod: Detect wielded item (of players)

Minetest doesn't include any callback for a player wielding an item. You can
check for that with polling, like this mod uses. You can use this mod as a
library to add a callback, or just as a reference for your own work.

## API

Also see the doc comments in `init.lua`

* `detect_wielditem.register_begin_wield(callback(Player, Item))`
    * Register to be called back when the player first starts wielding a new
    item.
* `detect_wielditem.register_while_wielding(callback(Player, Item))`
    * Register to be called back periodically and told what the player is
    wielding. Can be triggered at the same time as a `begin_wield`.
* `detect_wield_item.get_interval`
    * Returns the polling interval that the mod uses, in case you need to know
    how long the player has been holding something for.
