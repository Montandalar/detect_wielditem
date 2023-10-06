local POLL_INTERVAL = 0.1
do 
	local got = minetest.settings:get("detect_wielditem.poll_interval") 
	if got then
		POLL_INTERVAL = tonumber(got)
	end
end

local REGISTER_EXAMPLE_CALLBACK = true
detect_wielditem = {}
local registered_callbacks = {}

local function example_callback(player, item)
	if item:get_name() == "default:dirt" then
		minetest.chat_send_player(player:get_player_name(),
			"You're holding dirt.")
	end
end

local function poll_wielditems()
	for _, player in pairs(minetest.get_connected_players()) do
		local item = player:get_wielded_item()
		for _, callback in pairs(registered_callbacks) do
			callback(player, item)
		end
	end
	minetest.after(POLL_INTERVAL, poll_wielditems)
end

local function register_wielditem_callback(callback)
	local callback_t = type(callback)
	if callback_t ~= "function" then
		error("[detect_wielditem] Attempt to register callback that isn't"
			.. "a function. Type was:"
			.. callback_t)
	end

	table.insert(registered_callbacks, callback)
end

detect_wielditem.register_wielditem_callback = register_wielditem_callback

if REGISTER_EXAMPLE_CALLBACK then
	detect_wielditem.register_wielditem_callback(example_callback)
end

minetest.log("action", "[detect_wielditem] Interval: " .. tostring(POLL_INTERVAL))
minetest.after(POLL_INTERVAL, poll_wielditems)
