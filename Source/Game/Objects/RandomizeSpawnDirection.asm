                module Objects
                module RandomizeSpawnDirection
; -----------------------------------------
; выбор двух случайных старших компонент направления
; исходный диапазон #BA83..#BA93
; In:
;   IX - слот объекта
; Out:
;   старшие байты FSignWord.SignHigh компонент FSpaceObject.AxisX.X и FSpaceObject.AxisX.Y получают random AND #87
; Corrupt:
;   AF
; Note:
;   знак и три младших бита компоненты случайны, остальные биты нулевые
;   генератор Game.Combat.NextRandomByte.Entry сохраняет HL и BC, адрес слота не меняется
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #BA83
Entry:          CALL Game.Combat.NextRandomByte.Entry
                AND #87
                LD (IX+FSpaceObject.AxisX.X+FSignWord.SignHigh), A
                CALL Game.Combat.NextRandomByte.Entry
                AND #87
                LD (IX+FSpaceObject.AxisX.Y+FSignWord.SignHigh), A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #BA94
                endmodule
                endmodule
