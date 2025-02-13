-- Разделители типов [регистр, строка, число] в бинарном файле

local binSep = {
  header = 0xFE000000, -- 4 байта
  register = 1,
  number = 2,
  string = 3,
}

return binSep
