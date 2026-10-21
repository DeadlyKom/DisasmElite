                module Wireframe
                module AdvanceNormalFlags
; -----------------------------------------
; переход к следующему байту признаков нормали
; исходный диапазон #AE26..#AE34
; In:
;   память Game.Extensions.DrawCompressedEdges.FlagsStream, текущая запись признаков
; Out:
;   HL, следующая запись
;   BC, 3 при новом модуле, иначе 0
;   AF, Z при повторном использовании модуля
; Corrupt:
;   нет дополнительных регистров
; Note:
; Вход Game.Wireframe.AdvanceNormalFlags.StoreFlags общий с переходом вершин, но нормали продвигают поток признаков на один байт.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #AE26
                ; поиск следующего признака нормали
Entry:          LD BC, #0003
                LD HL, (Game.Extensions.DrawCompressedEdges.FlagsStream)
                INC HL
                ; обновление указателя и проверка повторного использования координат
StoreFlags:     LD (Game.Extensions.DrawCompressedEdges.FlagsStream), HL
                BIT 0, (HL)
                RET NZ                                                          ; выход, если бит 0 новой записи требует следующую тройку модулей

                LD C, B
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #AE35
                endmodule
                endmodule
