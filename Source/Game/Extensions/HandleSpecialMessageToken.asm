                module Extensions
                module HandleSpecialMessageToken
; -----------------------------------------
; обработка токена #DC и разрешение двух дополнительных проверок
; исходный диапазон #5E1A..#5E35
; смысловое имя HandleSpecialMessageToken
; In: AF — A содержит номер сообщения
; Out: хвостовой переход в принтер Game.Text.PrintMainToken.Entry или печать сообщения #52 через Game.Text.PrintDescriptionToken.Entry
; Corrupt: HL, DE, BC, AF по контракту вызываемых принтеров
; Для токена #DC CheckMineralLifeColony проверяет живую колонию и запас минералов
; Только при живой колонии возвращаются A=0 и Z=1, открываются ColonyGate и MineralGate
; Для остальных токенов либо при отказе проверки в обе команды записывается RET
; LD A,#C9 и обе записи не меняют Z, выбор сообщения использует результат той же проверки
; Исходный номер сообщения сохраняется на стеке до выбора окончательного принтера
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #5E1A
                ; проверка специального токена и сохранение исходного номера сообщения
                ; миссия 4 MINERAL LIFE, проверка колонии выбирает название минералов и переключает ограничения продажи
                ; описание в Docs/Manual.md, раздел mission-4
Entry:          PUSH AF
                SUB #DC
                CALL Z, Game.Text.CheckMineralLifeColony.Entry                  ; вызов, если токен равен #DC, проверить живую колонию и запас минералов
                JR Z, ApplyGates                                                ; переход, если токен #DC и колония жива, записать NOP из A=0

                LD A, #C9
                ; обновление двух исполняемых точек разрешения, NOP либо RET
ApplyGates:     LD (Game.Extensions.AttributeVectorAndEnergyBomb.ColonyGate), A
                LD (Game.Travel.GetSalePriceAndMissionFlags.MineralGate), A
                JR Z, ShowColony                                                ; переход, если проверка токена #DC и живой колонии дала Z=1, вывести сообщение #52

                POP AF
                JP Game.Text.PrintMainToken.Entry

ShowColony:     POP AF
                LD A, #52
                JP Game.Text.PrintDescriptionToken.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #5E36
                endmodule
                endmodule
