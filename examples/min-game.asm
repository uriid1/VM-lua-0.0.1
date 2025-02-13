;
; Пример игры угадай число
; 

RND AX, 1, 10 ; Записываем случайное число в EX (от 1 до 10)

; Цикл игры
.game_loop,
  ; Читаем число от пользователя в BX
  LOAD CX, "Введите число от 1 до 10: "
  PRINT CX
  READN BX

  CMP BX, AX      ; Сравниваем введённое число с загаданным
  JZ .win         ; Если BX == AX, переход к метке .win
  JG .greater     ; Если BX > AX, переход к метке .greater
  JL .less        ; Если BX < AX, переход к метке .less

; Если число больше загаданного
.greater
  LOAD CX, "Ваше число больше загаданного"
  PRINTNL CX
  JMP .game_loop

; Если число меньше загаданного
.less
  LOAD CX, "Ваше число меньше загаданного"
  PRINTNL CX
  JMP .game_loop

; Если число угадано
.win
  LOAD CX, "Вы угадали!"
  PRINTNL CX
  EXIT 0
