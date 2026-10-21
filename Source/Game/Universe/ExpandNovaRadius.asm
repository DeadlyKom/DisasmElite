                module Universe
                module ExpandNovaRadius
; -----------------------------------------
; расширение экранного радиуса солнца при сверхновой
; исходный диапазон #75C0..#75E0
; In:
;   память MissionNotice, признак сверхновой
;   память Game.Flight.MainGameLoop.NovaRadius, предыдущий расширенный радиус
;   память CircleState.Radius, текущая проекция
; Out:
;   CircleState.Radius/Game.Flight.MainGameLoop.NovaRadius, радиус увеличен на 2
;   FlightState.PlayerDead, признак гибели при переполнении
; Corrupt:
;   AF
; Note:
; Первый шаг берёт проекционный радиус, последующие продолжают сохранённое расширение.
; Переполнение и точное получение нуля переводят игрока в гибель, радиус обнуляется.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #75C0
                ; проверка режима сверхновой и источника радиуса
Entry:          LD A, (MissionNotice)
                AND A
                RET Z                                                           ; выход, если сверхновая не активна

                LD A, (Game.Flight.MainGameLoop.NovaRadius)
                AND A
                JR NZ, GrowRadius                                               ; переход, если предыдущий радиус уже задан

                LD A, (CircleState.Radius)
                ; расчёт расширения и проверка предела
GrowRadius:     ADD A, #02
                JR Z, KillPlayer                                                ; переход, если прибавление двух дало ноль

                JR NC, StoreRadius                                              ; переход, если прибавление двух не переполнило байт

                ; установка гибели при достижении предельного радиуса
KillPlayer:     LD A, #01
                LD (FlightState.PlayerDead), A
                XOR A
StoreRadius:    LD (CircleState.Radius), A
                LD (Game.Flight.MainGameLoop.NovaRadius), A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #75E1
                endmodule
                endmodule
