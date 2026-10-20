; -----------------------------------------
; Полёт к солнцу с проверкой близкой станции
; исходный диапазон #E7CE..#E7F9
; In:
;   IX=4700
; Out:
;   цикл наведения и выбора действия либо переход FollowStation
; Corrupt:
;   HL, DE, BC, AF, IY
; Note:
;   X/Y/Z совпадают в первых девяти байтах объекта, солнца и планеты
;   При сумме координат солнца<0888 и существующей станции ближе 24 выбирается FollowStation
;   Остальные итерации ChooseBody,YieldWithBrake,ChooseAction сохраняют управление сценарием
; -----------------------------------------
                ; проверка перезапуска и порога расстояния до солнца
ApproachBody:   CALL CheckRestart
                LD DE, #0888
                LD IY, FlightState.Sun
                CALL CompareRange
                JR NC, AimAndYield                                              ; переход, если солнце дальше порога 0888, продолжить обычное наведение

                ; близкое солнце позволяет проверить существование и расстояние станции
                LD IY, Memory.Station
                LD DE, #0024
                LD A, (IY + FSpaceObject.Energy)
                AND A
                JR Z, AimAndYield                                               ; переход, если слот станции пуст, продолжить обычное наведение

                CALL CompareRange
                JR C, FollowStation                                             ; переход, если станция ближе 24, перейти к её сопровождению

                ; наведение, уступка кадра и выбор действия повторяются циклом
AimAndYield:    CALL ChooseBody
                CALL YieldWithBrake
                CALL ChooseAction
                JR ApproachBody
