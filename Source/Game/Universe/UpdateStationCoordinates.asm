                module Universe
                module UpdateStationCoordinates
; -----------------------------------------
; обновление станционного слота и проверка его рабочего диапазона
; исходный диапазон #7861..#7891
; In:
;   память 711D, режим присутствия станции
;   слот 6048, станция
; Out:
;   IX, станционный слот
;   711D сбрасывается при допустимом положении
;   энергия станции F0 через общий хвост 7892
; Corrupt:
;   HL, DE, BC, AF, IY
; Note:
; Если режим нулевой и слот живой, ничего не меняет. Для пустого слота включает 711D=FF.
; 5F11 пересчитывает положение и обслуживает особые объекты/перенос станции.
; Ненулевые старшие модули координат или IX+26.7 оставляют дальний режим.
; При допустимых координатах фрагмент продолжается в установку энергии F0.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #7861
                ; проверка режима станции и занятости её слота
Entry:          LD A, (FlightState.StationFar)
                AND A
                LD IX, Memory.Station
                JR NZ, UpdateStation                                            ; переход, если режим станции уже активен

                LD A, (IX+FSpaceObject.Energy)
                AND A
                RET NZ                                                          ; выход, если слот станции уже занят

                DEC A
                LD (FlightState.StationFar), A
                ; пересчёт станции и проверка старших разрядов координат
UpdateStation:  CALL Game.Extensions.UpdateStationAndSpecialShips.Entry
                LD A, (IX+FSpaceObject.Z.SignHigh)
                AND #7F
                RET NZ                                                          ; выход, если старшая часть модуля Z ненулевая

                LD A, (IX+FSpaceObject.X.SignHigh)
                AND #7F
                RET NZ                                                          ; выход, если старшая часть модуля X ненулевая

                LD A, (IX+FSpaceObject.Y.SignHigh)
                AND #7F
                RET NZ                                                          ; выход, если старшая часть модуля Y ненулевая

                ; проверка специального флага и возврат в ближний режим
CheckNearFlag:  BIT OBJ_FAR_BIT, (IX+FSpaceObject.Flags2)
                RET NZ                                                          ; выход, если специальный старший флаг станции установлен

                XOR A
                LD (FlightState.StationFar), A
                ; проверка исходного конца фрагмента
                ASSERT $ == #7892
                endmodule
                endmodule
