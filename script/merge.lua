local en_path = "../en/localisation/english/"
local cn_path = "../cn/localisation/simp_chinese/"
local diff_path = "../diff/"

local function readfile(filename)
	local f = io.open(filename, "rb")
	if not f then
		return {}
	end
	local dict = {}
	for line in f:lines() do
		local key,dig,value = line:match("^ ([%w%._%-]+):(%d*) (.*)")
		if key then
			dict[key] = { d = dig , v = value }
		end
	end
	f:close()
	return dict
end

local function readdiff(filename)
	local diff = {}
	for line in io.lines(filename) do
		local command, key, dig, v = line:match("(%w+) +([%w%._-]+):(%d*) (.*)")
		local value = diff[key]
		if value == nil then
			value = {}
			diff[key] = value
		end
		value[command] = { d = dig, v = v }
	end
	return diff
end

local function merge(filename)
	local diff = readdiff(diff_path .. filename .. ".diff")
	local cn_filename = filename:gsub("_english", "_simp_chinese")
	local cn = readfile(cn_path ..  cn_filename)
	local f = io.open(cn_path .. cn_filename, "wb")
	for line in io.lines(en_path .. filename) do
		local key,dig,value = line:match("^ ([%w%._%-]+):(%d*) (.*)")
		if not key then
			if line:find "l_english" then
				line = line:gsub("english", "simp_chinese")
			end
			f:write(line, "\n")
		else
			local d = diff[key]
			if not d then
				-- not change
				if cn[key] == nil then
					print(filename, line, key)
				end
				f:write(" ", key, ":", dig, " ", cn[key].v, "\n")	-- use 2.1 translation
			elseif d.CHANGE then
				-- use new translation
				f:write(" ", key, ":", dig, " ", d.CHANGE.v, "\n")	-- use current translation
			elseif d.CN2 then
				f:write(" ", key, ":", dig, " ", d.CN2.v, "\n")	-- use 2.2 offical translation
			else
				f:write(line, "\n")	-- use english original text
			end
		end
	end
	f:close()
end

local list = {
"apocalypse_l_english.yml",
"dip_messages_l_english.yml",
"distant_stars_l_english.yml",
"event_chains_l_english.yml",
"events_2_l_english.yml",
"events_3_l_english.yml",
"events_4_l_english.yml",
"events_l_english.yml",
"gamepad_indicator_text_l_english.yml",
"horizonsignal_l_english.yml",
"l_english.yml",
"leviathans_l_english.yml",
"mandates_l_english.yml",
"marauder_l_english.yml",
"megacorp_l_english.yml",
"messages_l_english.yml",
"modifiers_2_l_english.yml",
"modifiers_3_l_english.yml",
"modifiers_l_english.yml",
"name_lists_l_english.yml",
"pop_factions_l_english.yml",
"prescripted_l_english.yml",
"projects_4_l_english.yml",
"projects_l_english.yml",
"synthetic_dawn_events_l_english.yml",
"technology_l_english.yml",
"traditions_l_english.yml",
"triggers_effects_l_english.yml",
"tutorial_l_english.yml",
"utopia_ascension_l_english.yml",
"utopia_l_english.yml",
"utopia_megastructures_l_english.yml",
}

for _,file in ipairs(list) do
	merge(file)
end
