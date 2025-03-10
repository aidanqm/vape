local isfile = isfile or function(file)
	local suc, res = pcall(function()
		return readfile(file)
	end)
	return suc and res ~= nil and res ~= ''
end
local delfile = delfile or function(file)
	writefile(file, '')
end

local function downloadFile(path, func)
	if not isfile(path) then
		local suc, res = pcall(function()
			return game:HttpGet('https://raw.githubusercontent.com/aidanqm/vape/'..readfile('newvape/profiles/commit.txt')..'/'..select(1, path:gsub('newvape/', '')), true)
		end)
		if not suc or res == '404: Not Found' then
			error(res)
		end
		if path:find('.lua') then
			res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
		end
		writefile(path, res)
	end
	return (func or readfile)(path)
end

local function wipeFolder(path)
	if not isfolder(path) then return end
	for _, file in pairs(listfiles(path)) do
		if not file:find('loader') then
			if isfile(file) and select(1, readfile(file):find('--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.')) == 1 then
				delfile(file)
			end
		end
	end
end

for _, folder in {'newvape', 'newvape/games', 'newvape/profiles', 'newvape/assets', 'newvape/libraries', 'newvape/guis'} do
	if not isfolder(folder) then
		makefolder(folder)
	end
end

if not shared.VapeDeveloper then
	local _, subbed = pcall(function()
		if request then
			local response = request({
				Url = "https://github.com/NTDCore/VapeV4ForRoblox",
				Method = "GET"
			})
			if response.Success then
				return response.Body
			end
		elseif syn and syn.request then
			local response = syn.request({
				Url = "https://github.com/NTDCore/VapeV4ForRoblox",
				Method = "GET"
			})
			if response.Success then
				return response.Body
			end
		end
		return game:HttpGet('https://github.com/NTDCore/VapeV4ForRoblox')
	end)
	local commit = subbed and subbed:find('currentOid')
	commit = commit and subbed:sub(commit + 13, commit + 52) or nil
	commit = commit and #commit == 40 and commit or 'main'
	if commit == 'main' or (isfile('newvape/profiles/commit.txt') and readfile('newvape/profiles/commit.txt') or '') ~= commit then
		wipeFolder('newvape')
		wipeFolder('newvape/games')
		wipeFolder('newvape/guis')
		wipeFolder('newvape/libraries')
	end
	writefile('newvape/profiles/commit.txt', commit)
end

local success, result = pcall(function()
	if request then
		local response = request({
			Url = "https://raw.githubusercontent.com/aidanqm/vape/main/main.lua",
			Method = "GET"
		})
		if response.Success then
			writefile('newvape/main.lua', response.Body)
			return loadstring(response.Body, 'main')()
		end
	elseif syn and syn.request then
		local response = syn.request({
			Url = "https://raw.githubusercontent.com/aidanqm/vape/main/main.lua",
			Method = "GET"
		})
		if response.Success then
			writefile('newvape/main.lua', response.Body)
			return loadstring(response.Body, 'main')()
		end
	end
	
	if isfile('newvape/main.lua') then
		return loadstring(readfile('newvape/main.lua'), 'main')()
	end
	
	error("Failed to load main.lua")
end)

if not success then
	warn("Failed to load Vape: " .. tostring(result))
end

return success and result or nil