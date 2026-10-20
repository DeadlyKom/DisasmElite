                module Objects
                module SpawnAtPlayer
; -----------------------------------------
; поиск слота и общий вход создания объекта около игрока
; исходный диапазон #B94A..#B94F
; In:
;   AF - A индекс модели
; Out:
;   IX - новый слот при успехе, NZ при отсутствии слота
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   тип временно сохранён в C, FindFreeObjectSlot его не изменяет
;   после LD A,C выполнение без RET продолжается в #B950
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #B94A
Entry:          LD C, A
                CALL Game.Objects.FindFreeObjectSlot.Entry
                RET NZ                                                          ; выход, если среди шести обычных слотов нет свободного

                LD A, C
                ; проверка исходного конца фрагмента
                ASSERT $ == #B950
                endmodule
                endmodule
