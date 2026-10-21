                module Circles
                module ComputeRightEdgeMask
; -----------------------------------------
; расчёт экранного адреса и маски правой границы
; исходный диапазон #89EF..#8A15
; смысловое имя ComputeRightEdgeMask
; In: BC — B содержит левую маску, C содержит Y, AF — A содержит X
; Out: HL — правый адрес, B восстановлен, C — правая маска
; Corrupt: HL, BC — C, AF, CircleState.LeftMask
; Левая маска сохраняется в CircleState.LeftMask на время ROM Rom.PixelFromA
; Для заливки #FF сдвигается влево 8-смещение раз, для контура используется RLC
; Два байта SET7,H также переключаются патчером буфер/экран
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #89EF
                ; сохранение левой маски и преобразование правой координаты
Entry:          PUSH AF
                LD A, B
                LD (CircleState.LeftMask), A
                POP AF
                LD B, C
                LD C, A
                LD A, B
                CALL Rom.PixelFromA
BufferOpcode    EQU $                                                           ; двухбайтовый SET 7,H либо NOP/NOP, выбор буфера правого края
                SET 7, H
                SUB #08
                ; расчёт числа сдвигов правого края, 8-пиксельное смещение
                NEG
                LD C, A
                LD A, (CircleState.OutlineOnly)
                AND A
                LD A, C
                JP NZ, Game.Circles.BuildRightContourPixelMask.Entry            ; переход, если выбран контур, рассчитать одиночную правую маску

                LD C, #FF
ShiftRightMask: SLA C
                DEC A
                JR NZ, ShiftRightMask                                           ; переход, если остались сдвиги сплошной правой маски

                LD A, (CircleState.LeftMask)
                LD B, A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #8A16
                endmodule
                endmodule
