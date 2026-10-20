                module Objects
                module SpawnMissile
; -----------------------------------------
; создание ракеты игрока либо ракеты исходного объекта
; исходный диапазон #B99F..#B9E6
; In:
;   BC - C код цели, ноль выбирает запуск исходным объектом
;   IX - исходный объект для C=0
; Out:
;   Z при успешном создании, NZ при отсутствии места, IX слот ракеты
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   при C!=0 сначала пробуется выделенный слот #6159, затем шесть обычных
;   путь игрока сохраняет C через инициализацию и задаёт начальные дробные координаты
;   при C=0 дочерняя ракета получает скорость игрока #70E6 дополнительно к своей
;   IX+25 получает код цели, IX+26 bit0 отмечает ракету
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #B99F
Entry:          LD A, C
                AND A
                JR Z, ObjectMissile                                             ; переход, если C=0 и ракету запускает исходный объект

                ; проверка выделенного ракетного слота #6048 + #0111
                LD IX, Memory.Station
                LD DE, Memory.Missile - Memory.Station
                ADD IX, DE
                LD A, (IX+FSpaceObject.Energy)
                AND A
                JR Z, PlayerMissile                                             ; переход, если выделенный слот ракеты свободен

                CALL Game.Objects.FindFreeObjectSlot.Entry
                RET NZ                                                          ; выход, если ни выделенный, ни обычный слот не удалось получить

PlayerMissile:  LD A, #01
                PUSH BC
                CALL Game.Flight.SetSelectedLineMetadata.Entry
                POP BC
                LD A, #6A
                LD (IX+FSpaceObject.Z.Fraction), A
                LD A, #29
                LD (IX+FSpaceObject.Y.Fraction), A
                LD A, #80
                LD (IX+FSpaceObject.Y.SignHigh), A
                LD A, C
                JR StoreTarget

ObjectMissile:  LD A, #01
                CALL Game.Objects.SpawnFromObject.Entry
                RET NZ                                                          ; выход, если дочернюю ракету не удалось создать

                LD A, (FlightState.Speed)
                ADD A, (IX+FSpaceObject.Speed)
                LD (IX+FSpaceObject.Speed), A
                ; сохранение кода цели и признака ракеты
StoreTarget:    LD (IX+FSpaceObject.Target), C
                SET OBJ_MISSILE_BIT, (IX+FSpaceObject.Flags2)
                XOR A
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #B9E7
                endmodule
                endmodule
