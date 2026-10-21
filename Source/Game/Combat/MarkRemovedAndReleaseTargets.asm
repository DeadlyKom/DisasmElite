                module Combat
                module MarkRemovedAndReleaseTargets
; -----------------------------------------
; пометка изменения сцены и снятие ракетных целей
; исходный диапазон #B73D..#B742
; In:
;   IX, удаляемый объект
;   память ObjectIndex, его номер
; Out:
;   установлен LaserThreshold.7, сняты связанные цели
; Corrupt:
;   HL, DE, BC, AF, IY
; Note:
; Game.Flight.RaiseLaserThreshold.Entry выставляет флаг изменения, затем хвост Game.Combat.ReleaseMissileTargets.Entry очищает ракетные связи.
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
