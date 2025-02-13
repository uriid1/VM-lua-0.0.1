# VM-lua-0.0.1
Попытка сделать простую VM

Запуск примеров
```bash
lua vm run examples/game.asm
```
Или
```bash
./vm run examples/game.asm
```

Компиляция в байт-код
```bash
./vm build examples/game.asm game.bin
```
После компайла запуск аналогичен запуску любого примера.

# Описание инструкций
src/core.lua
