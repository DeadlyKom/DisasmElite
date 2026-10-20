                module Scanner
                module DrawDangerAndMissileIndicators
; -----------------------------------------
; Индикаторы опасности и готовности ракеты для разных экранов
; исходный диапазон #99A4..#9A39
; In:
;   7104 текущий сигнал, 70E8/70EA щиты, D047 ракета, 70E3 вид
; Out:
;   индикаторы выведены, 7104 возвращён к 4 для следующего кадра
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Нулевое 7104 означает отсутствие полёта, пустой щит задаёт сигнал 2, кроме специального 63
;   При 63 бит 1 счётчика 99A3 чередует чёрный 0 и красный 2
;   Для видов 0..3 опасность занимает 2×2 атрибута, ракета получает PAPER=4 вместо состояния 1
;   Для прочих видов выводятся пары символов 21/22 либо 23/24, на время печати XOR C по адресу(D04B)
;   заменяется NOP и восстанавливается в A9
;   Общий выход 9A3A устанавливает базовый зелёный сигнал 4
; -----------------------------------------
                ASSERT $ == #99A4
                ; проверка полёта перед выводом индикаторов
Entry:          LD HL, FlightState.FlightStatus
                LD A, (HL)
                AND A
                RET Z                                                           ; выход, если корабль находится на станции

                ; проверка щитов, пустой щит задаёт красный сигнал
                LD A, (GaugeState + FGaugeState.FrontShield.Current)
                AND A
                JR Z, CheckOverride                                             ; переход, если передний щит пуст, проверить возможность красного сигнала

                LD A, (GaugeState + FGaugeState.RearShield.Current)
                AND A
                JR NZ, CheckBlink                                               ; переход, если задний щит непуст, сохранить текущий сигнал

                ; специальное состояние 63 имеет приоритет над пустыми щитами
CheckOverride:  LD A, (HL)
                CP #63
                JR Z, CheckBlink                                                ; переход, если задан специальный сигнал 63, не заменять его красным

                LD (HL), #02
                ; проверка мигания, бит 1 счётчика задаёт фазу по два вызова
CheckBlink:     LD A, (HL)
                CP #63
                JR NZ, SelectLayout                                             ; переход, если специальное мигание не задано, использовать текущий цвет

                LD HL, CockpitBlink
                INC (HL)
                BIT 1, (HL)
                JR NZ, RedPhase                                                 ; переход, если бит 1 счётчика мигания установлен, выбрать красную фазу

                XOR A
                JR SelectLayout

RedPhase:       LD A, #02
                ; выбор полного либо компактного индикатора по номеру вида
SelectLayout:   LD D, A
                LD A, (FlightState.View)
                CP #04
                JR NC, DrawCompact                                              ; переход, если открыт информационный экран, вывести компактную пару символов

                ; запись четырёх атрибутов полного индикатора
                LD HL, Memory.Attributes + 17 * 32 + 8                          ; верхняя пара атрибутов индикатора опасности
                LD (HL), D
                INC HL
                LD (HL), D
                LD HL, Memory.Attributes + 18 * 32 + 8                          ; нижняя пара атрибутов индикатора опасности
                LD (HL), D
                INC HL
                LD (HL), D
                CALL Game.Scanner.ResetDangerIndicator.Entry
                ; расчёт PAPER ракеты, состояние 1 заменяется зелёным 4
                LD A, (AimState)
                CP #01
                JR NZ, MissileColor                                             ; переход, если состояние ракеты не равно 1, сохранить его цветовой код

                LD A, #04
MissileColor:   ADD A, A
                ADD A, A
                ADD A, A
                ADD A, #07
                LD (MissileAttr), A
                RET

                ; временное отключение XOR печати и позиция компактного индикатора
DrawCompact:    LD HL, (GlyphPatch)
                LD (HL), #00
                LD HL, #011B
                LD (TextColumn), HL
                ; проверка группы экранов, начиная с 9 выбирается пара 23/24
                CP #09
                JR NC, PrintPair                                                ; переход, если номер экрана не меньше 9, вывести пару символов 23/24

                ; проверка красной опасности для пары 21/22
                LD A, D
                AND A
                JR Z, ReplaceBlack                                              ; переход, если сигнал чёрной фазы равен 0, заменить его цветом 2 для пары 23/24

                CP #02
                JR NZ, CompactColor                                             ; переход, если сигнал не красный, использовать цветной фон пары 23/24

                LD A, #21
                CALL Game.Interface.DispatchTextToken.Entry
                LD A, #22
                CALL Game.Interface.DispatchTextToken.Entry
                LD D, #17
                JR StoreColor

                ; чёрная фаза заменяется цветом 2 для второй пары
ReplaceBlack:   LD D, #02
                ; расчёт атрибута компактного индикатора как 10+сигнал
CompactColor:   LD A, #10
                ADD A, D
                LD D, A
                ; печать пары 23/24 с сохранением атрибута
PrintPair:      PUSH DE
                LD A, #23
                CALL Game.Interface.DispatchTextToken.Entry
                LD A, #24
                CALL Game.Interface.DispatchTextToken.Entry
                POP DE
                ; два атрибута и восстановление XOR печати перед общим выходом
StoreColor:     LD HL, Memory.Attributes + 32 + 28                              ; компактный индикатор, строка 1, столбцы 28 и 29
                LD (HL), D
                INC HL
                LD (HL), D
                LD HL, (GlyphPatch)
                LD (HL), #A9
                ASSERT $ == #9A3A
                endmodule
                endmodule
