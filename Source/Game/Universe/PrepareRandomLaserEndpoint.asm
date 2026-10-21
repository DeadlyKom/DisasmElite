                module Universe
                module PrepareRandomLaserEndpoint
; -----------------------------------------
; подготовка метаданных и случайной конечной точки луча
; исходный диапазон #7B37..#7B49
; In:
;   память ObjectEffects.Current, запись объекта
;   память ObjectEffects.Flags, общие признаки взаимодействия
; Out:
;   HL, метаданные+1
;   AF, A содержит случайный байт
; Corrupt:
;   BC
; Note:
; Бит 2 первой записи при необходимости устанавливается согласно инверсной проверке ObjectEffects.Flags.
; Первый экранный конец помечается FF, затем хвостовой переход возвращает случайный байт генератора.
; Используется для свободного окончания лазерного луча.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #7B37
                ; обновление признака взаимодействия и сброс первого экранного конца
Entry:          LD HL, (ObjectEffects.Current)
                LD A, (HL)
                PUSH HL
                LD HL, ObjectEffects.Flags
                CALL Game.Wireframe.MergeInverseHostilityFlag.Entry
                POP HL
                LD (HL), A
                INC HL
                LD (HL), #FF
                JP Game.Combat.NextRandomByte.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #7B4A
                endmodule
                endmodule
