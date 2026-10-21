                module Galaxy
                module PrintTargetDistance
; -----------------------------------------
; Печать ненулевого расстояния до выбранной планеты
; исходный диапазон #E107..#E122
; In:
;   GalaxyState.Distance = расстояние в десятых
; Out:
;   Напечатаны подпись BF, число с дробной цифрой и суффикс C3
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Нулевое расстояние пропускает значение и переходит к переводу строки Game.Galaxy.FinishDistanceLine.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E107
                ; вывод расстояния только для цели, отличной от текущей системы
Entry:          LD HL, (GalaxyState.Distance)
                LD A, H
                OR L
                JR Z, Game.Galaxy.FinishDistanceLine.Entry                      ; переход, если расстояние до цели нулевое, пропустить числовое поле

                LD A, #BF
                CALL Game.Trade.PrintMainTokenColon.Entry
                LD A, #04
                LD (NumberWidth), A
                LD HL, (GalaxyState.Distance)
                SCF
                CALL Game.Economy.PrintWordDecimal.Entry
                CALL Game.Text.PrintInlineToken.Entry
                DB #C3                                                          ; аргумент вызываемой процедуры из потока команд
                ; проверка исходного конца фрагмента
                ASSERT $ == #E123
                endmodule
                endmodule
