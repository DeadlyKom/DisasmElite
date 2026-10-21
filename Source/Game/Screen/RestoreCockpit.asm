                module Screen
                module RestoreCockpit
; -----------------------------------------
; восстановление приборной панели и боковых границ атрибутов
; In:
;   буферы Memory.Frame и Memory.CockpitAttrs содержат сохранённую кабину
; Out:
;   кабина в Memory.Screen + #1000, атрибуты в Memory.Attributes + #0200
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   после Game.Interface.DispatchClearView.Entry зануляются крайние столбцы всех 24 строк атрибутов
;   переносятся 2048 пиксельных байтов и 256 атрибутов
;   Game.Flight.ApplyMissionViewColour.Entry и Game.Flight.ApplyCloakingViewColour.Entry задают атрибуты двух полос, Game.Screen.PreviousCharacterRow.RestorePanel перерисовывает компас и сканер
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #804B
Entry:          CALL Game.Interface.DispatchClearView.Entry
                ; очистка левого и правого столбцов атрибутов
                LD DE, #001F
                LD B, #17
                LD A, #00
                LD HL, Memory.Attributes                                        ; левый верхний атрибут, начало очистки боковых границ
                LD (HL), A
DrawBorderRow:  ADD HL, DE
                LD (HL), A
                INC HL
                LD (HL), A
                DJNZ DrawBorderRow

                ADD HL, DE
                LD (HL), A
                ; восстановление пикселей нижней трети экрана
                LD DE, Memory.Screen + #1000                                    ; строка 128, начало пиксельного изображения кабины
                LD HL, Memory.Frame                                             ; сохранённые 2048 байтов пикселей кабины
                LD BC, #0800
                LDIR
                ; восстановление восьми строк атрибутов приборной панели
                LD DE, Memory.Attributes + 16 * 32                              ; атрибуты кабины, восемь строк начиная с 16
                LD HL, Memory.CockpitAttrs                                      ; сохранённые 256 атрибутов кабины
                LD BC, #0100
                LDIR
                CALL Game.Flight.ApplyMissionViewColour.Entry
                CALL Game.Flight.ApplyCloakingViewColour.Entry
                JP Game.Screen.PreviousCharacterRow.RestorePanel

                ASSERT $ == #8080
                endmodule
                endmodule
