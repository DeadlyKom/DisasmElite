; -----------------------------------------
; Сопровождение станции с переходом к новому старту
; исходный диапазон #E7FA..#E819
; In:
;   IX=Keyboard
; Out:
;   при расстоянии станции<24 переход DiskUtility.Demo.BackupPilot, иначе продолжение наведения
; Corrupt:
;   HL, DE, BC, AF, IY
; Note:
;   X/Y/Z совпадают в первых девяти байтах объекта, солнца и планеты
;   Каждый проход проверяет LaunchPending, наводится AimNearBody, уступает кадр и выбирает действия
; -----------------------------------------
                ; сопровождение станции, включая защиту и выбор обзорного экрана
FollowStation:  CALL CheckRestart
                CALL AimNearBody
                CALL YieldWithBrake
                CALL ChooseAction
                ; после возобновления проверяются существование станции и порог 24
                LD IY, Memory.Station
                LD A, (IY + FSpaceObject.Energy)
                AND A
                JR Z, FollowStation                                             ; переход, если станция отсутствует, продолжить цикл сопровождения

                LD DE, #0024
                CALL CompareRange
                JR C, BackupPilot                                               ; переход, если станция ближе 24, обновить снимок и начать новый старт

                JR FollowStation
