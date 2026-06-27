export type config = {
	downloadTime: number
}

local gitreq = {}
gitreq.__index = gitreq

local function request(url: string): string?
	return game:HttpGet(url)
end

function gitreq:fetch(path: string): any
	assert(typeof(path) == "string", "#1 expected a string")
	assert(path:sub(1, 1) == "@", "'path' must starts with '@'")
	path = path:sub(2, -1)
	
	local split = path:split("/")
	
	local function shift()
		local str = split[1]
		return (typeof(str) == "string") and (#str > 0) and table.remove(split, 1)
	end
	
	local owner = assert(shift(), "can't find the 'git owner'")
	local repo = assert(shift(), "can't find the 'git repository'")
	
	local dir = table.concat(split, "/")
	assert(#dir > 0, `invalid format, the directory is missing '{owner}/{repo}/MISSING'`)
	
	local url = `https://raw.githubusercontent.com/{owner}/{repo}/refs/heads/main/{dir}`
	local success, result = pcall(request, url)
	
	if not (success and typeof(result) == "string") then
		error(`failed to fetch the url '{url}:\n\t{result}'`)
		return
	end
	
	return loadstring(result, `={path}\n`)()
end

function gitreq.new(config: config): gitreq
	assert(typeof(config) == "table", "#1 expected a table")
	
	return setmetatable({
		downloadTime = assert(typeof(config.downloadTime) == "number", "'config.downloadTime' expected a number")
	}, gitreq)
end

return gitreq
