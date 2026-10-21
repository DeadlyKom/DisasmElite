                module Flight
                module ClearNearbyShipSlots
; -----------------------------------------
; Удаление семи соседних объектов
; исходный диапазон #9509..#9526
; In:
;   объекты по Memory.Station с шагом 39
; Out:
;   станции снимается bit2 поля 21, семь последующих полей 22 обнуляются,CombatState.Danger=0
; Corrupt:
;   DE, BC, AF, IX
; Note:
;   Станция в первом слоте Memory.Station остаётся, IX после семи шагов равен Memory.Missile
;   SoundState.Mode, Duration и DataCursor содержат активное состояние звука, режим, DE и указатель данных HL
; -----------------------------------------
                ASSERT $ == #9509
                ; снятие враждебности станции и признака атаки
Entry:          LD IX, Memory.Station
                RES OBJ_HOSTILE_BIT, (IX+FSpaceObject.Hostility)
                XOR A
                LD (CombatState.Danger), A
                LD DE, FSpaceObject
                LD B, #07
ClearShip:      ADD IX, DE
                LD (IX+FSpaceObject.Energy), A
                DJNZ ClearShip

                RET

                ; состояние звукового эффекта между кадрами
SoundData       FSoundState {
                    #00,                                                        ; FSoundState.Mode, 0 тишина, 1 скользящий тон, 2 тон из данных, остальные значения шум
                    #0000,                                                      ; FSoundState.Duration, сохранённые DE, назначение D/E зависит от звукового режима
                    #0000                                                       ; FSoundState.DataCursor, сохранённый HL, адрес следующего отсчёта либо параметр тона
                }
                ASSERT $ - SoundData == FSoundState

                ; прежние имена указывают на поля экземпляра SoundData
Mode            EQU SoundData.Mode                                              ; поле FSoundState.Mode
Duration        EQU SoundData.Duration                                          ; поле FSoundState.Duration
DataCursor      EQU SoundData.DataCursor                                        ; поле FSoundState.DataCursor
                ASSERT $ == #9527
                endmodule
                endmodule
