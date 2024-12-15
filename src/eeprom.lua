local config = {
	diskUUID = "", -- disk UUID
	bootFile = "/boot/run.lua"
}

event.ignoreAll()
event.clear()

filesystem.initFileSystem("/dev")

if #filesystem.children("/dev") < 1 then
	computer.log(4, "Failed to find filesystem! Please insert a drive or floppy with FicsIt-OS installed!")
	computer.beep(0.2)
	return
end

if #config.diskUUID > 0 then
	filesystem.mount("/dev/" .. config.diskUUID, "/")

	if not filesystem.exists(config.bootFile) then
		computer.log(4, "Failed to load boot file! " .. config.bootFile)
		computer.beep(0.2)
		return
	end

	local func = filesystem.loadFile(config.bootFile)

	if func then
		computer.beep(5)
		func()
	end
else
	for _, device in ipairs(filesystem.children("/dev")) do
		print(device)
	end
end
