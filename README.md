# Minetest Library Mod: Detect wielded item (of players)

Minetest doesn't include any callback for a player wielding an item. You can
check for that with polling, like this mod uses. You can also use this mod as a
library to add a callback for that if you prefer.


## API
`detect_wielditem.register_wielditem_callback(function(player, item))`

Provide a callback as a function that accepts a player (ObjectRef) and item
(ItemStack)
