                module Extensions
                module DrawCircleAndProtectScratchStack
; -----------------------------------------
; вывод кругового объекта и защищённый вызов боевого обработчика
; исходный диапазон #F8D7..#F90D
; смысловое имя DrawCircleAndProtectScratchStack
; In: CircleState.OffsetY, OffsetX, Flags и Radius, для NextOrFinish Z является результатом внешней проверки
; Out: первый вход возвращает A=(CircleState.Radius), второй продолжает бой либо вызывает Game.Combat.FinishObjectFrame.Entry
; Corrupt: HL, DE, BC, AF и буфер экрана по контрактам вызываемых процедур
; Game.Extensions.DrawCircleAndProtectScratchStack.NextOrFinish при Z=0 сразу переходит к Game.Combat.UpdateAllSpaceObjects.ProcessSlot
; при Z=1 копирует 48 байтов ScratchStack в ScratchBackup и устанавливает SP сразу за ScratchStack
; После Game.Combat.FinishObjectFrame.Entry байты и исходный SP восстанавливаются, выполняется EI
; Game.Extensions.DrawCircleAndProtectScratchStack.SavedSP — самомодифицируемый операнд LD SP,nn
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
NextOrFinish:   JP NZ, Game.Combat.UpdateAllSpaceObjects.ProcessSlot            ; переход, если внешняя проверка дала ненулевой результат, продолжить по Game.Combat.UpdateAllSpaceObjects.ProcessSlot

                ; сохранение SP и 48 байтов области временного стека
                LD (SavedSP), SP
                DI
                LD HL, ScratchStack
                LD DE, ScratchBackup
                LD BC, #0030
                LDIR
                ; вызов боевого обработчика со стеком ScratchStack + 48
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
