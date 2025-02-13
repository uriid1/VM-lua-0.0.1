local binSep = require('src.bin-sep')

local function readFile(filePath)
  local fd = io.open(filePath, 'r')
  if not fd then
    error("Error open: " .. filePath)
  end

  local source = fd:read('all')
  fd:close()

  return source
end

local function writeBin(filePath, bin)
  local fd = io.open(filePath, 'wb')
  if not fd then
    error("Error open: " .. filePath)
  end

  fd:write(bin)
  fd:close()
end

local function readBin(filePath)
  local fd = io.open(filePath, 'rb')
  if not fd then
    error("Error open: " .. filePath)
  end

  local source = fd:read('*a')
  fd:close()

  return source
end

local function isBin(filePath)
  local fd = io.open(filePath, "rb")
  if not fd then
    error("Error open: " .. filePath)
  end

  local data = fd:read(4)
  local header = string.unpack('>I4', data)
  fd:close()

  return header == binSep.header
end

return {
  readFile = readFile,
  writeBin = writeBin,
  readBin = readBin,
  isBin = isBin,
}
