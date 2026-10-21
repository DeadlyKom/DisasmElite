                module Combat
                module AnimateIntroAndObjectPipeline
; -----------------------------------------
; вход демонстрационного вращения и общий конвейер боевого кадра
; исходный диапазон #9CAF..#9CBA
; In:
;   объект демонстрации либо текущее состояние полёта
; Out:
;   обновлена демонстрация либо боевой кадр
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
; Game.Combat.AnimateIntroAndObjectPipeline.Entry переходит в Game.Motion.AnimateIntroObject.Entry. Байты MissionPhase/ActiveShips/ObjectIndex содержат фазу второй миссии, число кораблей и номер объекта.
; Отдельный Game.Combat.AnimateIntroAndObjectPipeline.CombatFrame вызывает цикл объектов Game.Combat.UpdateAllSpaceObjects.Entry и хвостовым переходом обрабатывает лазер/ECM.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9CAF
                ; переход к демонстрационному вращению
Entry:          JP Game.Motion.AnimateIntroObject.Entry

                ; данные миссии, числа кораблей и текущего номера
                ; миссия 2 CLOAKING DEVICE, отдельный рабочий байт хранит фазу появления и подбора миссионного предмета
                ; описание в Docs/Manual.md, раздел mission-2
MissionPhase    DB #00                                                          ; фаза появления особых кораблей второй миссии
ActiveShips     DB #00                                                          ; число живых управляемых кораблей среди шести обычных слотов
ObjectIndex     DB #00                                                          ; номер обрабатываемого объекта, 8..1
                ; отдельный вход боевого кадра, объекты перед оружием
CombatFrame:    CALL Game.Combat.UpdateAllSpaceObjects.Entry
                JP Game.Combat.ProcessLaserAndEcm.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #9CBB
                endmodule
                endmodule
