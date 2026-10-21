                module Circles
                module ComputeLeftEdgeMask
; -----------------------------------------
; расчёт экранного адреса и маски левой границы
; исходный диапазон #89D4..#89EE
; смысловое имя ComputeLeftEdgeMask
; In: BC — C содержит Y, AF — A содержит X
; Out: H/E — адрес левого байта, B — маска, HL — тот же адрес
; Corrupt: HL, DE — E, BC, AF
; ROM Rom.PixelFromA возвращает адрес и смещение пикселя, SET7,H выбирает буфер
; Для заливки B=#FF сдвигается вправо на смещение+1
; Для контура Game.Circles.BuildLeftContourPixelMask.Entry циклически выбирает один бит
; Два байта SET7,H патчатся в NOP/NOP при выводе непосредственно на экран
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #89D4
                ; преобразование левой координаты X/Y через ROM
Entry:          LD B, C
                LD C, A
                LD A, B
                CALL Rom.PixelFromA
BufferOpcode    EQU $                                                           ; двухбайтовый SET 7,H либо NOP/NOP, выбор буфера левого края
                SET 7, H
                LD B, A
                LD A, (CircleState.OutlineOnly)
                AND A
                LD A, B
                JP NZ, Game.Circles.BuildLeftContourPixelMask.Entry             ; переход, если выбран контур, рассчитать одиночную левую маску

                ; создание сплошной маски левого края сдвигами #FF
                LD B, #FF
                INC A
ShiftLeftMask:  SRL B
                DEC A
                JR NZ, ShiftLeftMask                                            ; переход, если остались сдвиги сплошной левой маски

                LD E, L
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #89EF
                endmodule
                endmodule
