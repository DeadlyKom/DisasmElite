                module Screen
                module SelectScreen
; -----------------------------------------
; смена экранного режима с сохранением кабины
; In:
;   BC, C содержит новый режим
; Out:
;   AF, A содержит новый режим
;   байт FlightState.View обновлён
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   режимы 0..3 являются видами полёта, режимы от 4 информационными экранами
;   повторный выбор уже открытого экрана от 7 снимает адрес возврата и очищает события
;   при активной стыковке Game.Screen.RestrictDockingView.Entry разрешает только передний вид или информационный экран
;   переход из вида полёта к экрану меню проваливается в Game.Screen.SaveCockpit.Entry и сохраняет кабину
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #815D
                ; проверка повторного выбора текущего экрана
Entry:          LD A, (FlightState.View)
                LD B, A
                CP C
                JR NZ, CheckDockView                                            ; переход, если выбран другой режим

                LD A, C
                CP #07
                JR C, CheckDockView                                             ; переход, если повторно выбран режим ниже 7

                POP HL
                JR Game.Screen.HandleScreenKeys.ClearEvents

                ; проверка ограничения вида во время стыковки
CheckDockView:  LD A, (JumpMode)
                AND A
                LD A, C
                JR NZ, Game.Screen.RestrictDockingView.Entry                    ; переход, если активен стыковочный туннель

StoreView:      LD (FlightState.View), A
                ; проверка необходимости сохранить приборную панель
                LD A, B
                CP #04
                LD A, C
                RET NC                                                          ; выход, если прежний режим уже был информационным

                CP #04
                RET C                                                           ; выход, если новый режим остаётся видом полёта, иначе далее Game.Screen.SaveCockpit.Entry без команды перехода

                ASSERT $ == #817E
                endmodule
                endmodule
