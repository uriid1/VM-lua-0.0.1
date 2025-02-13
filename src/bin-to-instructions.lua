local fsVm = require('src.fs-vm')
local vm = require('src.core')
local binSep = require('src.bin-sep')

local function binToInstructions(filePath)
  local data = fsVm.readBin(filePath)

  -- Указатель на текущую позицию в данных
  local pos = 1

  -- Чтение заголовка (4 байта)
  local header, newPos = string.unpack('>I4', data, pos)
  pos = newPos

  -- Проверка магического числа
  if header ~= binSep.header then
    error('Invalid data format: incorrect header')
  end

  -- Восстановление данных
  local instructions = {}
  while pos <= #data do
    local instruction = {}

    -- Чтение опкода (1 байт)
    local opcode, newPos = string.unpack('>I1', data, pos)
    pos = newPos
    table.insert(instruction, opcode)

    -- Аргументы
    while true do
      -- Типа аргумента (1 байт)
      local argType, newPos = string.unpack('>I1', data, pos)
      pos = newPos

      if argType == vm.opcodes.ENDI then
        break

      elseif argType == binSep.register then
        local register, newPos = string.unpack('>I1', data, pos)
        pos = newPos
        table.insert(instruction, register)

      elseif argType == binSep.number then
        -- Число (4 байта)
        local num, newPos = string.unpack('>I4', data, pos)
        pos = newPos
        table.insert(instruction, num)

      elseif argType == binSep.string then
        -- Строка (2 байта длины + байты строки)
        local strLen, newPos = string.unpack('>I2', data, pos)
        pos = newPos

        local str, newPos = string.unpack('>c' .. strLen, data, pos)
        pos = newPos
        table.insert(instruction, str)

      else
        error('Invalid binary separator?: ' .. argType)
      end
    end

    table.insert(instructions, instruction)
  end

  return instructions
end

return binToInstructions
