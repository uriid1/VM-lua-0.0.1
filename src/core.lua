-----------------------------------
-- Маленькая виртуальная машина
-----------------------------------
local vm = {}

-- Регистры
vm.registers = {
  PC = 1,  -- Счётчик команд
  SP = 0,  -- Указатель стека

  -- Регистры общего назначения
  AX = 0,
  BX = 0,
  CX = 0,
  DX = 0,
  EX = 0,
}

vm.registersCode = {
  AX = 0xE1,
  BX = 0xE2,
  CX = 0xE3,
  DX = 0xE4,
  EX = 0xE5,
}

-- Регистр флагов
vm.registers.FLAGS = {
  ZF = false,  -- Zero Flag
  SF = false,  -- Sign Flag
  CF = false,  -- Carry Flag
  OF = false,  -- Overflow Flag
}

local function resetFlags()
  vm.registers.FLAGS.ZF = false
  vm.registers.FLAGS.SF = false
  vm.registers.FLAGS.CF = false
  vm.registers.FLAGS.OF = false
end

vm.opcodes = {
  -- Базовые операции с регистрами
  LOAD = 0x01,   -- Загрузка значения в регистр
  STORE = 0x02,  -- Запись значения из регистра в память по адресу
  MOV = 0x03,    -- Копирование значения из одного регистра в другой
  ADD = 0x04,    -- Сложение
  SUB = 0x05,    -- Вычитание
  MUL = 0x06,    -- Умножение
  DIV = 0x07,    -- Деление
  MOD = 0x08,    -- Остаток от деления
  INC = 0x09,    -- Увеличение регистра на 1
  DEC = 0x0A,    -- Уменьшение регистра на 1
  RND = 0x1A,    -- Записать случайное число в регистр

  -- Условные и безусловные переходы
  JMP = 0xA0,    -- Безусловный переход
  JZ = 0xA1,     -- Переход, если A == 0
  JNZ = 0xA2,    -- Переход, если A != 0
  JG = 0xA3,     -- Переход, если A > 0
  JGE = 0xA4,    -- Переход, если A >= 0
  JL = 0xA5,     -- Переход, если A < 0
  JLE = 0xA6,    -- Переход, если A <= 0

  -- Операции сравнения
  CMP = 0xA7,    -- Сравнение A с B или значением

  -- Стековые операции
  CALL = 0xB0,   -- Вызов функции
  RET = 0xB1,    -- Возврат из функции
  RETURN = 0xB2, -- Запись значения в переменную VM, которая хранит значения из функций

  -- Ввод/Вывод
  PRINTNL = 0xC0,  -- Печать значения из регистра на новой строке
  PRINT = 0xC1,    -- Печать значения из регистра в строку
  READN = 0xC2,    -- Чтение числа с клавиатуры
  READS = 0xC3,    -- Чтение строки с клавиатуры

  -- Операции с памятью
  LOADM = 0xD0,    -- Загрузка значения из памяти в регистр
  STOREM = 0xD1,   -- Запись значения из регистра в память

  -- Выход из программы с заданным кодом
  EXIT = 0xFF,
  -- Код начала программы (нужен для парсинга бинаря)
  START = 0xFE,
  -- Код конца инструкции
  ENDI = 0xFD,
}

-- Память (инструкции и данные)
vm.memory = {}
-- Метки для функций
vm.labels = {}
-- Стек вызовов
vm.callStack = {}
-- Переменная для возврата значения из функций
vm.last_return_value = nil

-- Сбор меток с простановкой адресов
function vm.processLabels(program)
  local addr = 1
  for _, instruction in ipairs(program) do
    if type(instruction) == 'string' and instruction:sub(1, 1) == '.' then
      -- Это метка, запоминаем её адрес
      vm.labels[instruction] = addr
    else
      addr = addr + 1
    end
  end
end

-- Загрузка программы и замена меток
function vm.loadProgram(program)
  vm.memory = {}

  local addr = 1

  for _, instruction in ipairs(program) do
    if type(instruction) == 'table' then
      -- Заменяем метку на реальный адрес
      for i = 2, #instruction do
        if type(instruction[i]) == 'string' and vm.labels[instruction[i]] then
          instruction[i] = vm.labels[instruction[i]]
        end
      end

      vm.memory[addr] = instruction
      addr = addr + 1
    end
  end
end

function vm.run()
  while true do
    local pc = vm.registers.PC
    local instruction = vm.memory[pc]

    if not instruction then
      break
    end

    local opcode = instruction[1]
    local arg1 = instruction[2]
    local arg2 = instruction[3]
    local arg3 = instruction[4]

    -- LOAD REG, [REG or val]
    if opcode == vm.opcodes.LOAD then
      local register = arg1
      local value = vm.registers[arg2] or arg2

      vm.registers[register] = value

    -- STORE addr REG
    elseif opcode == vm.opcodes.STORE then
      local addr = arg1
      local register = arg2
      local storeVal = vm.registers[register]

      vm.memory[addr] = storeVal

    -- MOV REG, [REG or val]
    elseif opcode == vm.opcodes.MOV then
      local register = arg1
      local value = vm.registers[arg2] or arg2

      vm.registers[register] = value

    -- ADD REG, [REG or val]
    elseif opcode == vm.opcodes.ADD then
      local register = arg1
      local value = vm.registers[arg2] or arg2

      vm.registers[register] = vm.registers[register] + value

    -- SUB REG, [REG or val]
    elseif opcode == vm.opcodes.SUB then
      local register = arg1
      local value = vm.registers[arg2] or arg2

      vm.registers[register] = vm.registers[register] - value

    -- MUL REG, [REG or val]
    elseif opcode == vm.opcodes.MUL then
      local register = arg1
      local value = vm.registers[arg2] or arg2

      vm.registers[register] = vm.registers[register] * value

    -- DIV REG, [REG or val]
    elseif opcode == vm.opcodes.DIV then
      local register = arg1
      local value = vm.registers[arg2] or arg2

      vm.registers[register] = vm.registers[register] / value

    -- MOD REG, [REG or val]
    elseif opcode == vm.opcodes.MOD then
      local register = arg1
      local value = vm.registers[arg2] or arg2

      vm.registers[register] = vm.registers[register] % value

    -- INC REG
    elseif opcode == vm.opcodes.INC then
      local register = arg1

      vm.registers[register] = vm.registers[register] + 1

    -- DEC REG
    elseif opcode == vm.opcodes.DEC then
      local register = arg1

      vm.registers[register] = vm.registers[register] - 1

    -- RND REG min max
    elseif opcode == vm.opcodes.RND then
      local register = arg1
      local min = arg2
      local max = arg3

      vm.registers[register] = math.random(min, max)

    -- CALL .LABEL, REG
    elseif opcode == vm.opcodes.CALL then
      local addr = arg1
      local register = arg2

      table.insert(vm.callStack, vm.registers.PC + 1)
      vm.registers.PC = addr - 1

      -- Если передан регистр, запоминаем, куда вернуть значение
      if register then
        vm.registers['RETURN_TO'] = register
      end

    -- RET
    elseif opcode == vm.opcodes.RET then
      if #vm.callStack == 0 then
        error('Error: RET without CALL')
      end

      -- Возвращаем значение в нужный регистр
      local return_reg = vm.registers['RETURN_TO']
      if return_reg then
        vm.registers[return_reg] = vm.last_return_value
      end
      vm.registers.PC = table.remove(vm.callStack) - 1

    -- JMP addr
    elseif opcode == vm.opcodes.JMP then
      local addr = arg1
      vm.registers.PC = addr - 1

    -- JZ addr or JZ REG
    elseif opcode == vm.opcodes.JZ then
      local arg = arg1  -- Адрес или регистр

      -- Если аргумент — это регистр, проверяем его значение на ноль
      if vm.registers[arg] ~= nil then
        if vm.registers[arg] == 0 then
          vm.registers.PC = arg2 - 1
        end
      else
        -- Если аргумент — это адрес, проверяем флаг ZF
        if vm.registers.FLAGS.ZF then
          vm.registers.PC = arg - 1
        end
      end

    -- JNZ addr or JNZ REG
    elseif opcode == vm.opcodes.JNZ then
      local arg = arg1  -- Адрес или регистр

      -- Если аргумент — это регистр, проверяем его значение на ноль
      if vm.registers[arg] ~= nil then
        if vm.registers[arg] ~= 0 then
          vm.registers.PC = arg2 - 1
        end
      else
        -- Если аргумент — это адрес, проверяем флаг ZF
        if not vm.registers.FLAGS.ZF then
          vm.registers.PC = arg - 1
        end
      end

    -- JG addr or JG REG
    elseif opcode == vm.opcodes.JG then
      local arg = arg1  -- Адрес или регистр

      -- Если аргумент — это регистр, проверяем его значение
      if vm.registers[arg] ~= nil then
        if vm.registers[arg] > 0 then
          vm.registers.PC = arg2 - 1
        end
      else
        -- Если аргумент — это адрес, проверяем флаги
        if not vm.registers.FLAGS.ZF and (vm.registers.FLAGS.SF == vm.registers.FLAGS.OF) then
          vm.registers.PC = arg - 1
        end
      end

    -- JGE addr or JGE REG
    elseif opcode == vm.opcodes.JGE then
      local arg = arg1  -- Адрес или регистр

      -- Если аргумент — это регистр, проверяем его значение
      if vm.registers[arg] ~= nil then
        if vm.registers[arg] >= 0 then
          vm.registers.PC = arg2 - 1
        end
      else
        -- Если аргумент — это адрес, проверяем флаги
        if vm.registers.FLAGS.SF == vm.registers.FLAGS.OF then
          vm.registers.PC = arg - 1
        end
      end

    -- JL addr or JL REG
    elseif opcode == vm.opcodes.JL then
      local arg = arg1  -- Адрес или регистр

      -- Если аргумент — это регистр, проверяем его значение
      if vm.registers[arg] ~= nil then
        if vm.registers[arg] < 0 then
          vm.registers.PC = arg2 - 1
        end
      else
        -- Если аргумент — это адрес, проверяем флаги
        if vm.registers.FLAGS.SF ~= vm.registers.FLAGS.OF then
          vm.registers.PC = arg - 1
        end
      end

    -- JLE addr or JLE REG
    elseif opcode == vm.opcodes.JLE then
      local arg = arg1

      -- Если аргумент — это регистр, проверяем его значение
      if vm.registers[arg] ~= nil then
        if vm.registers[arg] <= 0 then
          vm.registers.PC = arg2 - 1
        end
      else
        -- Если аргумент — это адрес, проверяем флаги
        if vm.registers.FLAGS.ZF or (vm.registers.FLAGS.SF ~= vm.registers.FLAGS.OF) then
          vm.registers.PC = arg - 1
        end
      end

    -- CMP REG [REG or val]
    elseif opcode == vm.opcodes.CMP then
      local op1 = vm.registers[arg1] or arg1  -- Первый операнд (регистр или значение)
      local op2 = vm.registers[arg2] or arg2  -- Второй операнд (регистр или значение)
      local result = op1 - op2

      -- Обновляем флаги
      resetFlags()
      vm.registers.FLAGS.ZF = (result == 0)
      vm.registers.FLAGS.SF = (result < 0)
      -- Для беззнакового сравнения
      vm.registers.FLAGS.CF = (op1 < op2)
      -- Для знакового переполнения
      vm.registers.FLAGS.OF = (result > 0x7FFFFFFF or result < -0x80000000)

    -- PRINT REG
    elseif opcode == vm.opcodes.PRINT then
      local register = arg1

      io.write(vm.registers[register])

    -- PRINTNL REG
    elseif opcode == vm.opcodes.PRINTNL then
      local register = arg1
      if not register then
        io.write('\n')
      else
        io.write(vm.registers[register], '\n')
      end

    -- RETURN REG
    elseif opcode == vm.opcodes.RETURN then
      local register = arg1

      vm.last_return_value = vm.registers[register]

    -- LOADM REG, addr
    elseif opcode == vm.opcodes.LOADM then
      local register = arg1  -- Регистр, в который загружаем значение
      local addr = arg2      -- Адрес в памяти

      -- Запись значения из памяти в регистр
      vm.registers[register] = vm.memory[addr]

    -- STOREM addr, REG
    elseif opcode == vm.opcodes.STOREM then
      local addr = arg1      -- Адрес в памяти
      local register = arg2  -- Регистр, из которого берем значение

      -- Запись значения из регистра в память
      vm.memory[addr] = vm.registers[register]

    -- READN REG
    elseif opcode == vm.opcodes.READN then
      local register = arg1

      -- Чтение числа с клавиатуры
      vm.registers[register] = io.read("*n")

    -- READN REG
    elseif opcode == vm.opcodes.READN then
      local register = arg1

      -- Чтение строки с клавиатуры
      vm.registers[register] = io.read()

    -- EXIT int
    elseif opcode == vm.opcodes.EXIT then
      local exitCode = arg1
      os.exit(exitCode)

    else
      error('Invalid opcode: ' .. opcode)
    end

    vm.registers.PC = vm.registers.PC + 1
  end
end

return vm
