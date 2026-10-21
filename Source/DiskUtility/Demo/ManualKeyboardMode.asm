; -----------------------------------------
; Ручной режим внутри корутины
; исходный диапазон #EA0F..#EA1C
; In:
;   стек демо и физическая клавиатура
; Out:
;   каждый кадр передаёт реальные клавиши игре
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Восстанавливает JP DiskUtility.Demo.ResumeJump→ResumePoint, затем бесконечно ReadKeyboard/YieldToGame
;   V обрабатывается общим YieldToGame и позволяет вернуться к сценарию
; -----------------------------------------
                ; восстановление обычного возврата корутины перед ручным циклом
ManualControl:  LD HL, ResumePoint
                LD (ResumeJump+1), HL
                ; реальные клавиши передаются игре при каждой уступке кадра
                CALL ReadKeyboard
                CALL YieldToGame
                JR ManualControl
