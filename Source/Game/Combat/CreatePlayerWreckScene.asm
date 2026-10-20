                module Combat
                module CreatePlayerWreckScene
; -----------------------------------------
; очистка объектных слотов и создание сцены обломков
; исходный диапазон #B618..#B63B
; In:
;   текущее состояние полёта
; Out:
;   восемь слотов освобождены, созданы объекты действий 16 и 15
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
; Ставится звуковой запрос 7128.2 и передний вид 70E3=0.
; Все восемь байтов энергии обнуляются, затем диспетчер создаёт два набора обломков.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #B618
                ; подготовка звука и вида сцены обломков
Entry:          LD HL, FlightState.SoundRequests
                SET SND_BLAST_BIT, (HL)
                XOR A
                LD (FlightState.View), A
                LD IX, Memory.Station - FSpaceObject                            ; позиция перед станцией, цикл прибавляет размер слота до первого доступа
                ; очистка энергии всех восьми слотов
                LD DE, FSpaceObject
                LD B, #08
ClearSlot:      ADD IX, DE
                LD (IX+FSpaceObject.Energy), A
                DJNZ ClearSlot

                LD A, #16
                CALL Game.Objects.DispatchObjectAction.Entry
                LD A, #15
                CALL Game.Objects.DispatchObjectAction.Entry
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #B63C
                endmodule
                endmodule
