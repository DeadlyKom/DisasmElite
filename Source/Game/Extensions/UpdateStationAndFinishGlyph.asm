                module Extensions
                module UpdateStationAndFinishGlyph
; -----------------------------------------
; обновление станции и отдельный хвост вывода знака
; исходный диапазон #5DC8..#5DFA
; смысловое имя UpdateStationAndFinishGlyph
; In: Game.Extensions.UpdateStationAndFinishGlyph.Entry получает FlightState.SpaceMode, для Game.Extensions.UpdateStationAndFinishGlyph.FinishGlyph HL — экран, на стеке адрес глифа перед возвратом
; Out: Game.Extensions.UpdateStationAndFinishGlyph.Entry при нулевом FlightState.SpaceMode передаёт управление Game.Universe.UpdateStationCoordinates.Entry, Game.Extensions.UpdateStationAndFinishGlyph.FinishGlyph выводит восемь строк знака
; Corrupt: для Game.Extensions.UpdateStationAndFinishGlyph.FinishGlyph HL, DE, BC, AF, для Game.Extensions.UpdateStationAndFinishGlyph.Entry по контракту расчёта станции
; перед FinishGlyph сохранены четыре восьмибайтовых знака дополнительного шрифта
; Game.Text.DrawCharacter8x8.Entry сохраняет адрес глифа через PUSH HL и передаёт поток в FinishGlyph, POP DE извлекает этот адрес
; Game.Extensions.UpdateStationAndFinishGlyph.FinishGlyph задаёт B=8 и вызывает Game.Text.XorCharacterScanlines.Entry, исходный XOR накладывает глиф, патч Game.Text.XorCharacterScanlines.XorOpcode=NOP разрешает перезапись
; Исходный снимок содержит OUT (#0F),A по Game.Extensions.UpdateStationAndFinishGlyph.AuxPortFirst и Game.Extensions.UpdateStationAndFinishGlyph.AuxPortNext, но Loader.Load до запуска игры заменяет обе пары байтов нулями
; На штатном пути вместо каждой команды выполняются два NOP, периферийного вывода здесь нет
; Без патча первый A был бы колонкой TextPosition, второй — последним записанным пиксельным байтом, полный порт равен A*256+#0F
; Историческое назначение отключённых команд не установлено, байты снимка сохраняются для точного восстановления диска
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #5DC8
                ; проверка режима перед расчётом координат станции
Entry:          LD A, (FlightState.SpaceMode)
                AND A
                RET NZ                                                          ; выход, если активно особое пространство и станция не обновляется

                JP Game.Universe.UpdateStationCoordinates.Entry

                ; четыре дополнительных восьмибайтовых знака, между двумя независимыми входами
ExtraGlyphs     DB #00, #00, #00, #00, #00, #08, #08, #10                       ; четыре дополнительных глифа, начало соответствует коду #2C
                DB #00, #00, #00, #00, #3E, #00, #00, #00                       ; данные #5DD8..#5DDF
                DB #00, #00, #00, #00, #00, #18, #18, #00                       ; данные #5DE0..#5DE7
                DB #00, #00, #02, #04, #08, #10, #20, #00                       ; данные #5DE8..#5DEF
                ; дополнительный вход печати с удалением служебного слова со стека
FinishGlyph:    POP DE
                LD B, #08
AuxPortFirst    OUT (#0F), A                                                    ; две команды NOP после патча загрузчиком
                CALL Game.Text.XorCharacterScanlines.Entry
AuxPortNext     OUT (#0F), A                                                    ; две команды NOP после патча загрузчиком
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #5DFB
                endmodule
                endmodule
