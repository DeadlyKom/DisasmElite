                module Extensions
                module DrawCircleAndProtectScratchStack
; -----------------------------------------
; вывод кругового объекта и защищённый вызов боевого обработчика
; исходный диапазон #F8D7..#F90D
; смысловое имя DrawCircleAndProtectScratchStack
; In: параметры круга в #861A..#861D, для #F8E4 Z — результат внешней проверки
; Out: первый вход возвращает A=(#861D), второй продолжает бой либо вызывает #9E66
; Corrupt: HL, DE, BC, AF и буфер экрана по контрактам вызываемых процедур
; #F8E4 при Z=0 сразу переходит к #9D38
; При Z=1 48 байтов #40F0..#411F сохраняются в #FFD0..#FFFF, стек меняется на #4120
; После #9E66 байты и исходный SP восстанавливаются, выполняется EI
; #F90A — самомодифицируемый операнд LD SP,nn
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #F8D7
                ; рисование круга, завершение экранного буфера и копирование на экран
Entry:          CALL Game.Circles.SelectCircleBackBuffer.Entry
                CALL Game.Screen.DrawFilledCircle.Entry
                CALL Game.Screen.CopyFlightView.Entry
                LD A, (CircleState.Radius)
                RET

                ; дополнительный вход с проверкой внешнего результата
NextOrFinish:   JP NZ, Game.Combat.UpdateAllSpaceObjects.ProcessSlot            ; переход, если внешняя проверка дала ненулевой результат, продолжить по #9D38

                ; сохранение SP и 48 байтов области временного стека
                LD (SavedSP), SP
                DI
                LD HL, ScratchStack
                LD DE, ScratchBackup
                LD BC, #0030
                LDIR
                ; вызов боевого обработчика со стеком #4120
                LD SP, ScratchStack + #0030
                CALL Game.Combat.FinishObjectFrame.Entry
                DI
                ; восстановление сохранённых байтов после повторного запрета прерываний
                LD HL, ScratchBackup
                LD BC, #0030
                LD DE, ScratchStack
                LDIR
                ; восстановление SP из собственного операнда
SavedSP         EQU $ + 1                                                       ; операнд восстановления исходного SP
                LD SP, #0000
                EI
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #F90E
                endmodule
                endmodule
