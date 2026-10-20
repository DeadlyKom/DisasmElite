                module Objects
                module SpawnShipDebris
; -----------------------------------------
; создание одного обломка с изменением ориентации и сохранением родителя
; исходный диапазон #BB55..#BB74
; In:
;   AF - A модель
;   IX - родитель
; Out:
;   IX сохранён, Z при успехе либо NZ при отсутствии слота
; Corrupt:
;   HL, DE, BC, AF, IY
; Note:
;   новый слот создаётся #B91E, #BA27 меняет его ориентацию
;   IX+26=#0A, IX+20 bit6 сброшен, IX+1D bit7 включает постоянное вращение
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #BB55
                ; создание обломка и временный выбор его IX через обмен с вершиной стека
Entry:          PUSH IX
                CALL Game.Objects.SpawnFromObject.Entry
                EX (SP), IX
                POP HL
                RET NZ                                                          ; выход, если новый обломок не удалось создать

                PUSH HL
                EX (SP), IX
                CALL Game.Objects.AlternateSpawnAxes.Entry
                LD A, #0A
                LD (IX+FSpaceObject.Flags2), A
                RES OBJ_ACTIVE_BIT, (IX+FSpaceObject.Flags)
                SET 7, (IX+FSpaceObject.Roll)
                POP IX
                XOR A
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #BB75
                endmodule
                endmodule
