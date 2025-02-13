local vm = require('src/core')

local function lexer(program, opts)
  opts = opts or {}

  local instructions = {}

  for line in program:gmatch('[^\n]+') do
    -- Пропуск комментариев
    if line:find('^%s*;') then
      goto continue

    -- Удаление комментариев
    elseif line:find('%s*;') then
      line = line:gsub('%s*;.+', '')
    end

    -- Обработка меток
    --
    local isLabel = line:sub(1, 1) == '.'
    if isLabel then
      local label = line:match('(%.[%w_]+)')
      table.insert(instructions, label)

      goto continue
    end

    -- Опкод
    --
    local opcode = line:match('(%u+)')

    -- Если задан несуществующий опкод
    if not vm.opcodes[opcode] then
      error('invalid opcode: '..tostring(opcode))
    end

    local instruction = {}
    if opts.bin then
      -- Не берем числовое представление для компиляции
      instruction[1] = opcode
    else
      instruction[1] = vm.opcodes[opcode]
    end

    -- Декодирование аргументов опкода
    local strArgs = line:gsub(opcode..'%s*', '')
    for arg in strArgs:gmatch('%s*([^,]+)') do
      -- Определяем чем является аргумент
      -- Регистр
      if vm.registers[arg] then
        table.insert(instruction, arg)

      -- Строка
      elseif arg:find('^\"(.+)\"') then
        table.insert(instruction, arg:match('^\"(.+)\"'))

      -- Метка
      elseif arg:sub(1, 1) == '.' then
        table.insert(instruction, arg)

      -- Число
      elseif tonumber(arg) then
        table.insert(instruction, tonumber(arg))
      end
    end

    table.insert(instructions, instruction)

    ::continue::
  end

  return instructions
end

return lexer
