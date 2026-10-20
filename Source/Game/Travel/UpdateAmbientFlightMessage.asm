                module Travel
                module UpdateAmbientFlightMessage
; -----------------------------------------
; Выбор предупреждений и сообщения о заправке
; исходный диапазон #DB2E..#DB90
; In:
;   70FC, 711E, 7129 и состояние оборудования
; Out:
;   Выбран токен очереди либо уменьшен периодический таймер DA72
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   При энергии верхнего банка ниже 159 снимает маскировку и ставит предупреждение 64
;   При энергии от 159 проверяет сохранённый признак зоны черпаков, затем автопилот и миссии
;   Наличие черпаков и установленный SunScooping увеличивают топливо через SetFuelAndGauge
;   SunScooping устанавливается расчётом близости солнца и сбрасывается при старте новой системы
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DB2E
                ; проверка энергии верхнего банка, затем заправки, автопилота и миссионных сообщений
Entry:          LD A, (GaugeState + FGaugeState.Energy4.Current)
                CP #9F
                JR C, DropCloak                                                 ; переход, если энергия верхнего банка меньше 159, снять маскировку и запросить предупреждение

                LD A, (FlightState.SunScooping)
                AND A
                JR NZ, CheckScooping                                            ; переход, если сохранён признак зоны черпаков, проверить оборудование для заправки

                LD A, (FlightState.AutoDock)
                AND A
                JR NZ, DockingMessage                                           ; переход, если включена автоматическая стыковка, поставить соответствующее сообщение

                LD HL, FlightMessage.RepeatTimer
                LD A, (HL)
                AND A
                JR NZ, TickAmbient                                              ; переход, если таймер предупреждения ненулевой, уменьшить его

                LD A, #46
                LD (HL), A
                LD A, (State.Mission3)
                DEC A
                JR Z, MissionWarning                                            ; переход, если третья миссия имеет состояние 1, вывести её предупреждение

                LD A, (State.Mission1)
                AND A
                RET Z                                                           ; выход, если первая миссия не активна, дополнительное предупреждение не нужно

                LD A, (MissionNotice)
                AND A
                RET NZ                                                          ; выход, если служебный флаг D0BA ненулевой, повторное сообщение запрещено

                LD BC, #C202
                JR QueueAmbient

TickAmbient:    DEC (HL)
                RET

MissionWarning: LD BC, #0F03
                JR QueueAmbient

DockingMessage: LD BC, #7B05
                JR QueueAmbient

CheckScooping:  LD A, (State.FuelScoops)
                AND A
                RET Z                                                           ; выход, если топливный ковш отсутствует, заправка у звезды невозможна

                LD A, (State.Fuel)
                INC A
                CALL Game.Travel.SetFuelAndGauge.Entry
                LD BC, #A008
                JR QueueAmbient

                ; снятие маскировки и предупреждение при низкой энергии верхнего банка
DropCloak:      XOR A
                LD (CloakActive), A
                LD L, #07
                LD A, (FlightState.View)
                CP #04
                CALL C, Game.Extensions.AttributeVectorAndEnergyBomb.Entry      ; вызов, если показан полётный экран 0..3, вызвать специальный обработчик события
                LD BC, #640A
QueueAmbient:   JP @Game.Travel.SelectQueuedFlightMessage.SetLifetime
                ; проверка исходного конца фрагмента
                ASSERT $ == #DB91
                endmodule
                endmodule
