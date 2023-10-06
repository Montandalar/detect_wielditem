local REGISTER_EXAMPLE_CALLBACKS = true

local POLL_INTERVAL = 0.1
do
	local got = minetest.settings:get("detect_wielditem.poll_interval")
	if got then
		POLL_INTERVAL = tonumber(got)
	end
end

local META_KEY = 'detect_wielditem.prev'
detect_wielditem = {}
always_called_registered_callbacks = {}
on_change_called_registered_callbacks = {}

local function example_callback_always(player, item)
	if item:get_name() == "default:dirt" then
		minetest.chat_send_player(player:get_player_name(),
			"You're still holding dirt.")
	end
end

local function example_callback_on_changed(player, item)
	if item:get_name() == "default:cobble" then
		minetest.chat_send_player(player:get_player_name(),
			"You're now holding cobble.")
	end
end

local function update_player_meta(player, item)
	local meta = player:get_meta()
	if not meta:contains(META_KEY) then
		meta:set_string(META_KEY, item:to_string())
		return false
	end

	local meta_str = meta:get_string(META_KEY)
	local item_str = item:to_string()
	local prev = ItemStack(meta:get_string(META_KEY))
	local changed = not prev.equals(item)
	dbg()
	if changed then
		meta:set_string(META_KEY, item:to_string())
		return true
	else
		return false
	end
end

local function poll_wielditems()
	for _, player in pairs(minetest.get_connected_players()) do
		local item = player:get_wielded_item()
		local changed = update_player_meta(player, item)
		--minetest.chat_send_all(dump(changed))
		if changed then
			for _, callback in pairs(on_change_called_registered_callbacks) do
				callback(player, item)
			end
		end
		for _, callback in pairs(always_called_registered_callbacks) do
			callback(player, item)
		end
	end
	minetest.after(POLL_INTERVAL, poll_wielditems)
end

local function register_callback_preamble(callback)
	local callback_t = type(callback)
	if callback_t ~= "function" then
		error("[detect_wielditem] Attempt to register callback that isn't"
			.. "a function. Type was:"
			.. callback_t)
	end
end

--! Register to be called back about the item the player is wielding.
--! @param callback A function(player, item) to call when the player begins to
--! wield a stack
local function register_begin_wield(callback)
	register_callback_preamble(callback)
	table.insert(on_change_called_registered_callbacks, callback)
end
detect_wielditem.register_begin_wield = register_begin_wield

--! Register to be called back about the item the player is wielding periodically.
--! @param callback A function(player, item) to call periodically while the
--! player is wielding the stack. May be called at the same time as a
--! begin_wield callback.
local function register_while_wielding(callback)
	register_callback_preamble(callback)
	table.insert(always_called_registered_callbacks, callback)
end
detect_wielditem.register_while_wielding = register_while_wielding

if REGISTER_EXAMPLE_CALLBACKS then
	detect_wielditem.register_begin_wield(example_callback_on_changed)
	detect_wielditem.register_while_wielding(example_callback_always)
end

minetest.log("action", "[detect_wielditem] Interval: " .. tostring(POLL_INTERVAL))
minetest.after(POLL_INTERVAL, poll_wielditems)
