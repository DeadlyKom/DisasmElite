                module Objects
                module SpawnPlayerDebris
; -----------------------------------------
; создание выбрасываемого около игрока обломка или груза
; исходный диапазон #BA9C..#BAE7
; In:
;   основной вход выбирает модель 3, внутренний Game.Objects.SpawnPlayerDebris.SpawnDebris принимает модель в A
; Out:
;   IX - новый объект, Z при успехе и NZ при отсутствии слота
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   после Game.Objects.SpawnAtPlayer.Entry сбрасывается OBJ_ACTIVE_BIT в FSpaceObject.Flags и задаётся случайное направление обломка
;   дробные X/Y равны (random AND 63) OR 16, знаки противоположны знакам направления
;   Z дробный равен 25, скорость (random AND31) OR8, угол LR случайный
;   используемый Game.Objects.InitializeAtPlayer.Entry содержит модификации инвентаря в Game.Extensions.CreateMissileOrMissionCraft.Entry, это не чистое создание слота
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #BA9C
Entry:          LD A, #03
SpawnDebris:    CALL Game.Objects.SpawnAtPlayer.Entry
                RET NZ                                                          ; выход, если не найден слот для выбрасываемого объекта

                CALL Game.Objects.RandomizeSpawnDirection.Entry
                RES OBJ_ACTIVE_BIT, (IX+FSpaceObject.Flags)
                CALL Game.Combat.NextRandomByte.Entry
                AND #3F
                OR #10
                LD (IX+FSpaceObject.X.Fraction), A
                LD A, (IX+FSpaceObject.AxisX.X+FSignWord.SignHigh)
                AND #80
                XOR #80
                LD (IX+FSpaceObject.X.SignHigh), A
                CALL Game.Combat.NextRandomByte.Entry
                AND #3F
                OR #10
                LD (IX+FSpaceObject.Y.Fraction), A
                LD A, (IX+FSpaceObject.AxisX.Y+FSignWord.SignHigh)
                AND #80
                XOR #80
                LD (IX+FSpaceObject.Y.SignHigh), A
                LD A, #19
                LD (IX+FSpaceObject.Z.Fraction), A
                CALL Game.Combat.NextRandomByte.Entry
                LD (IX+FSpaceObject.Roll), A
                CALL Game.Combat.NextRandomByte.Entry
                AND #1F
                OR #08
                LD (IX+FSpaceObject.Speed), A
                XOR A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #BAE8
                endmodule
                endmodule
