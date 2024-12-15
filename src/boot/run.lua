---@type WidgetSign
---@diagnostic disable-next-line: assign-type-mismatch
local sign = component.proxy("") -- sign uuid

---@type SizeableModulePanel
---@diagnostic disable-next-line: assign-type-mismatch
local panel = component.proxy("") -- sizeable panel uuid

local encoder = panel:getModule(2, 1)
local btnAccept = panel:getModule(2, 0)
---@type SquareMicroDisplayModule
---@diagnostic disable-next-line: assign-type-mismatch
local display = panel:getModule(1, 1)

local filePath = "iconData"
local idSave = "lastID.lua"

event.listen(encoder)
event.listen(btnAccept)

local iconID = 1

---@type string
local iconTable = {}

local gameIcons = computer.media:getGameIcons(999, 0)

for _, value in pairs(gameIcons) do
	iconTable[value.id] = value.iconName
end

local function readDataFromFile()
	if filesystem.exists(filePath) and filesystem.isFile(filePath) then
		---@type table<integer, string>
		---@diagnostic disable-next-line: assign-type-mismatch
		local data = filesystem.doFile(filePath)

		for key, value in pairs(data) do
			iconTable[key] = value
		end
	end

	if filesystem.exists(idSave) and filesystem.isFile(idSave) then
		---@diagnostic disable-next-line: cast-local-type
		iconID = filesystem.doFile(idSave)
	end
end

readDataFromFile()

local function saveName()
	local name = sign:getPrefabSignData():getTextElement("Name")
	if iconTable[iconID] and iconTable[iconID]:len() > 0 and iconTable[iconID] ~= name then
		computer.beep(0.2)
		print(string.format("Tried changing name of icon ID %d from '%s' to '%s'", iconID, iconTable[iconID], name))
		return
	end
	if name and name:len() > 0 then
		iconTable[iconID] = name
	end
end

local function setIcon(id)
	local prefab = sign:getPrefabSignData()
	-- prefab:setTextElement("Name", "")
	prefab:setIconElement("Icon", id)
	prefab:setTextElement("Name", iconTable[id] or "")

	sign:setPrefabSignData(prefab)
	display:setText(id)
end

local function serialize(array)
    local serialized = {}
    for i, value in pairs(array) do
		if value and value:len() > 0 then
			table.insert(serialized, string.format('\n\t[%d]="%s"', i, value))
		else
			table.insert(serialized, string.format('\n\t[%d]=""', i))
		end
    end
    return "return {" .. table.concat(serialized, ",") .. "\n}"
end

local canChange = true

event.registerListener(event.filter{sender = encoder}, function (event, sender, value)
	if not canChange then
		return
	end
	canChange = false
	saveName()
	iconID = iconID + value
	if iconID < 1 then
		iconID = 1
	end
	setIcon(iconID)
	canChange = true
end)

local startTime = computer.millis()

event.registerListener(event.filter{sender = btnAccept}, function (...)
	if (computer.millis() - startTime) < 1000 then
		return
	end
	startTime = computer.millis()

	saveName()

	local content = serialize(iconTable)
	local file = filesystem.open(filePath, "w")
	file:write(content)
	file:close()

	file = filesystem.open(idSave, "w")
	file:write("return " .. iconID)
	file:close()

	print("Saved")
end)

setIcon(iconID)

event.loop()