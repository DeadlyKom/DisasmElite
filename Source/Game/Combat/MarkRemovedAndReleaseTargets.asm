                module Combat
                module MarkRemovedAndReleaseTargets
; -----------------------------------------
; пометка изменения сцены и снятие ракетных целей
; исходный диапазон #B73D..#B742
; In:
;   IX, удаляемый объект
;   память 9CB4, его номер
; Out:
;   установлен FABA.7, сняты связанные цели
; Corrupt:
;   HL, DE, BC, AF, IY
; Note:
; 9389 выставляет флаг изменения, затем хвост B5DF очищает ракетные связи.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #B73D
                ; пометка изменения сцены перед снятием ракетных целей
Entry:          CALL Game.Flight.RaiseLaserThreshold.Entry
                JP Game.Combat.ReleaseMissileTargets.Entry
                ; проверка исходного конца фрагмента
                ASSERT $ == #B743
                endmodule
                endmodule
