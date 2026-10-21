                module Text
                module DrawProjectedSunAndTextDispatch
DescCommand:    EQU MainCommand+2                                               ; перекрывающийся вход LD L,0 для таблицы описаний
; -----------------------------------------
; Вывод проекции светила и таблица управляющих кодов текста
; исходный диапазон #D7B9..#D87E
; In:
;   Состояние проекции для Game.Text.DrawProjectedSunAndTextDispatch.Entry, A=управляющий код для Game.Text.DrawProjectedSunAndTextDispatch.MainCommand/Game.Text.DrawProjectedSunAndTextDispatch.DescCommand
; Out:
;   Проекция обработана либо выполнена команда форматирования
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Game.Text.DrawProjectedSunAndTextDispatch.Entry сохраняет IX/IY, выбирает IX=Game.Flight.MainGameLoop.BodyZ или Game.Flight.MainGameLoop.BodyX и вызывает Game.Extensions.CompareObjectCoordinateDepth.Entry до 3 раз, Game.Text.DrawProjectedSunAndTextDispatch.MainCommand/Game.Text.DrawProjectedSunAndTextDispatch.DescCommand выбирают
;   младший байт адреса из двух следующих таблиц, JP (HL) передаёт поток в страницу #D8, далее размещены обработчики
;   денег, имени, топлива, галактики и имён планет
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D7B9
                ; проекция светила рисуется до трёх раз с сохранением исходных IX и IY
Entry:          CALL Game.Universe.ProjectCelestialBody.Entry
                AND A
                RET Z                                                           ; выход, если проекция светила не требует вывода, закончить обработку

                PUSH IX
                LD IX, Game.Flight.MainGameLoop.BodyZ
                LD A, (FlightState.View)
                CP #02
                JR C, CompareSectors                                            ; переход, если номер вида меньше 2, использовать первый набор координат проекции

                LD IXL, #7A
CompareSectors: PUSH IY
                LD IY, Game.Flight.MainGameLoop.BodyX-FCoordinate
                CALL Game.Extensions.CompareObjectCoordinateDepth.Entry
                CALL NZ, Game.Extensions.CompareObjectCoordinateDepth.Entry     ; вызов, если обработчик сектора светила вернул ненулевой результат, обработать следующий сектор
                CALL NZ, Game.Extensions.CompareObjectCoordinateDepth.Entry     ; вызов, если повторный обработчик сектора вернул ненулевой результат, обработать третий сектор
                POP IY
                POP IX
                RET

; JP C из Game.Text.PrintMainToken.Entry выбирает MainCommand, LD HL, #2EF2 и следующий NOP задают L=#F2
; после DEC L/LD H,#D7 получается база таблицы управляющих команд основной печати
; вариант исполнения Game.Text.DrawProjectedSunAndTextDispatch.MainCommand, LD HL,#2EF2
; JP C из Game.Text.PrintDescriptionByte.Entry выбирает DescCommand, LD L, #00 и DEC L дают базу второй таблицы команд
; вариант исполнения Game.Text.DrawProjectedSunAndTextDispatch.DescCommand, LD L,#00
; нулевой байт операнда Game.Text.DrawProjectedSunAndTextDispatch.DescCommand исполняется как NOP при основном входе
MainCommand:    DB #21, #F2, #2E, #00                                           ; перекрывающиеся команды, байты сохранены буквально
                ; управляющий код выбирает младший байт адреса, старший всегда D8
                DEC L
                LD H, #D7
                LD D, #00
                LD E, A
                ADD HL, DE
                LD L, (HL)
                LD H, #D8
                JP (HL)

                ; токен 0 основной таблицы выбирает RET в конце Game.Text.CapitalizeNextLetterAndTextCommands.Entry
                DB #84                                                          ; #D7F1..#D7F1
                ; таблица MainCommand содержит 14 младших адресов команд, следующая таблица DescCommand содержит 32
                ; обе таблицы содержат младшие байты адресов, старшая часть всегда #D8
                DB #4B, #6A, #72, #2E, #37, #AE, #22, #33                       ; #D7F2..#D7F9
                DB #B4, #E5, #57, #84, #84, #84, #AE, #33                       ; #D7FA..#D801
                DB #72, #2E, #E5, #E9, #B7, #7B, #BA, #BD                       ; #D802..#D809
                DB #C0, #B4, #A9, #84, #84, #57, #84, #85                       ; #D80A..#D811
                DB #7F, #84, #C3, #C6, #F3, #1F, #1F, #C9                       ; #D812..#D819
                DB #84, #84, #EF, #84, #84                                      ; #D81A..#D81E
                JP Game.Trade.Wait36Interrupts.Entry

                ; управляющие команды печати денег, имени пилота и остатка топлива
PrintCashLine:  LD A, #C5
                CALL Game.Trade.PrintMainTokenColon.Entry
                CALL Game.Economy.FinishWordDecimal.PrintCash
                LD A, #E2
                JR PrintWithEol

                LD HL, State.Name
                JR PrintString

                LD A, #00
                JR Game.Text.CapitalizeNextLetterAndTextCommands.StoreCaseMode

                LD A, #69
                CALL Game.Trade.PrintMainTokenColon.Entry
                CALL Game.Text.PrintInlineToken.Entry
                DB #20                                                          ; параметр предыдущего вызова, не исполняется как инструкция
                LD A, (State.Fuel)
                CALL Game.Economy.PrintBytePrice.Entry
                LD A, #C3
PrintWithEol:   JP Game.Trade.PrintTokenNewline.Entry

                ; управляющие команды номера галактики и названий текущей и выбранной систем
PrintGalaxy:    LD A, #02
                LD (NumberWidth), A
                LD A, (State.Galaxy)
                INC A
                JP Game.Economy.PrintByteInteger.Entry

                LD HL, State.GalaxySeed
                LD DE, GalaxyState.WorkingSeed
                LD BC, #0006
                LDIR
                CALL Game.Galaxy.GenerateSystemName.Entry
                LD HL, GalaxyState.GeneratedName
                JR PrintString

                CALL Game.Text.CapitalizeNextLetterAndTextCommands.Entry
                LD HL, GalaxyState.CurrentName
                JR PrintString

                CALL Game.Text.CapitalizeNextLetterAndTextCommands.Entry
                LD HL, GalaxyState.TargetName
PrintString:    JP Game.Trade.PrintZeroTerminatedString.Entry

                CALL Game.Trade.SetInlineTextColumn.Entry
                DB #04                                                          ; параметр предыдущего вызова, не исполняется как инструкция
                ; проверка исходного конца фрагмента
                ASSERT $ == #D87F
                endmodule
                endmodule
