                module Interface
                module DispatchResetCommander
; -----------------------------------------
; Вектор восстановления начального командира
; исходный диапазон #D033..#D035
; In:
;   Нет параметров
; Out:
;   Переход в D298
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Самостоятельного RET нет, D298 копирует шаблон и заново создаёт рынок
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D033
Entry:          JP Game.Missions.RatingBountyDamageAndNewCommander.ResetCommander
                ; проверка исходного конца фрагмента
                ASSERT $ == #D036
                endmodule
                endmodule
