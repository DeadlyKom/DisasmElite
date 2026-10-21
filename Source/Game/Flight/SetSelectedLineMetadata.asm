                module Flight
                module SetSelectedLineMetadata
; -----------------------------------------
; Изменение выбранной десятибайтовой записи линий
; исходный диапазон #9391..#93AB
; In:
;   BC, C номер записи, ObjectEffects.Flags текущий общий режим
; Out:
;   адрес ObjectEffects.Scratch-10*C передан Game.Wireframe.MergeInverseHostilityFlag.Entry, ObjectEffects.Flags обновлён, хвост Game.Objects.InitializeAtPlayer.Entry с A=1
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   При C=0 DJNZ выполнит 256 шагов, вызывающий обязан передать ненулевой индекс для обычного
;   результата
;   LaserThreshold bit7 предварительно помечает общий пересчёт линии
; -----------------------------------------
                ASSERT $ == #9391
                ; поиск записи с шагом минус 10 от ObjectEffects.Scratch
Entry:          CALL Game.Flight.RaiseLaserThreshold.Entry
                LD HL, ObjectEffects.Scratch
                LD DE, -FEffectRecord10
                LD B, C
FindLine:       ADD HL, DE
                DJNZ FindLine

                ; изменение записи через Game.Wireframe.MergeInverseHostilityFlag.Entry и выбор первого рабочего объекта
                LD A, (ObjectEffects.Flags)
                CALL Game.Wireframe.MergeInverseHostilityFlag.Entry
                LD (ObjectEffects.Flags), A
                LD A, #01
                JP Game.Objects.InitializeAtPlayer.Entry

                ASSERT $ == #93AC
                endmodule
                endmodule
