                module Text
                module DrawCharacter8x8
; -----------------------------------------
; Вывод восьмистрочного символа в экран Spectrum
; исходный диапазон #D4E1..#D545
; In:
;   AF, A = код от 20, D045/D046 = символьные координаты
; Out:
;   Курсор X увеличен, символ выведен в 4000 либо C000
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   X увеличивается до рисования, при X>=32 переносится в 1 и увеличивается Y, адрес шрифта
;   получает из 5DFB, смещение глифа=(A-20)*8, пиксельный адрес строится по нелинейной раскладке
;   Spectrum, D50A является старшим байтом базы экрана, продолжение через 5DF0
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D4E1
                ; увеличение текстовой колонки с переносом на следующую строку после 31
Entry:          PUSH AF
                LD HL, TextColumn
                INC (HL)
                LD A, (HL)
                CP #20
                JR C, GlyphAddress                                              ; переход, если после увеличения колонка меньше 32, перенос строки не нужен

                LD A, #01
                LD (HL), A
                CALL Game.Trade.IncrementTextRow.Entry
                ; расчёт восьмистрочного адреса глифа и соответствующего пиксельного адреса экрана
GlyphAddress:   POP AF
                CALL Game.Extensions.SelectCharacterFont.Entry
                SUB #20
                LD C, A
                LD B, #00
                SLA C
                RL B
                SLA C
                RL B
                SLA C
                RL B
                ADD HL, BC
                PUSH HL
                ; старший байт 40 в операнде заменяется на C0 при печати в буфер полётного вида
ScreenHigh      EQU $ + 2                                                       ; старший байт адреса экрана в операнде LD HL
                LD HL, Memory.Screen
                LD A, (TextRow)
                CP #10
                JP NC, BottomThird                                              ; переход, если строка текста не меньше 16, выбрать нижнюю треть экрана

                CP #08
                JP NC, MiddleThird                                              ; переход, если строка текста не меньше 8, выбрать среднюю треть экрана

                LD B, A
                JP RowOffset

BottomThird:    SUB #10
                LD B, A
                LD DE, #1000
                ADD HL, DE
                JP RowOffset

MiddleThird:    SUB #08
                LD B, A
                LD DE, #0800
                ADD HL, DE
RowOffset:      LD C, #00
                SRL B
                RR C
                SRL B
                RR C
                SRL B
                RR C
                ADD HL, BC
                LD B, #00
                LD A, (TextColumn)
                LD C, A
                ADD HL, BC
                JP Game.Extensions.UpdateStationAndFinishGlyph.FinishGlyph
                ; проверка исходного конца фрагмента
                ASSERT $ == #D546
                endmodule
                endmodule
