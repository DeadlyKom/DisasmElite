                module Objects
                module FindFreeObjectSlot
; -----------------------------------------
; поиск свободного слота среди шести обычных объектов
; исходный диапазон #B936..#B949
; In:
;   регистровых параметров нет
; Out:
;   DE=39
;   IX - первый свободный слот и Z=1, либо последний проверенный слот и Z=0
; Corrupt:
;   DE, BC, AF, IX
; Note:
;   проверяются Memory.Objects,Game.Data.ObjectPool.Ship2,Game.Data.ObjectPool.Ship3,Game.Data.ObjectPool.Ship4,Game.Data.ObjectPool.Ship5,Game.Data.ObjectPool.Ship6
;   свободен слот с FSpaceObject.Energy=0, станция Memory.Station и ракета Memory.Missile исключены
;   при отсутствии слота INC B после DJNZ устанавливает NZ, значение A не является кодом ошибки
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #B936
                ; поиск свободного слота, станция и последний ракетный слот исключены
Entry:          LD IX, Memory.Station
                LD DE, FSpaceObject
                LD B, #06
CheckSlot:      ADD IX, DE
                LD A, (IX+FSpaceObject.Energy)
                AND A
                RET Z                                                           ; выход, если энергия проверяемого слота равна 0

                DJNZ CheckSlot

                ; формирование NZ после исчерпания всех шести слотов
                INC B
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #B94A
                endmodule
                endmodule
