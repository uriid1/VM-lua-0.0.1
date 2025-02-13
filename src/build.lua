local vm = require('src/core')
local binSep = require('src.bin-sep')

local function build(instructions)
  -- Препроцесс меток
  vm.processLabels(instructions)
  vm.loadProgram(instructions)

  -- Заголовок файла (магическое число и версия)
  local compiled = string.pack(">I4", binSep.header)

  -- Проход по памяти VM для обработки строк и регистров
  for i = 1, #vm.memory do
    -- Проход по аргументам
    for j = 1, #vm.memory[i] do
      local arg = vm.memory[i][j]

      -- Опкод
      if vm.opcodes[arg] then
        compiled = compiled .. string.pack(">I1", vm.opcodes[arg])

      -- Регистры
      elseif vm.registersCode[arg] then
        compiled = compiled .. string.pack(">I1", binSep.register) .. string.pack(">I1", vm.registersCode[arg])

      elseif type(arg) == 'number' then
        compiled = compiled .. string.pack(">I1", binSep.number) .. string.pack(">I4", arg)

      elseif type(arg) == 'string' then
        compiled = compiled .. string.pack(">I1", binSep.string) .. string.pack(">s2", arg)

      end
    end

    compiled = compiled .. string.pack(">I1", vm.opcodes.ENDI)
  end

  return compiled
end

return build
