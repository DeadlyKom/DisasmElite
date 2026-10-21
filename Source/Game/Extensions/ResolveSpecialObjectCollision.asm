                module Extensions
                module ResolveSpecialObjectCollision
; -----------------------------------------
; фильтр столкновения и обнуление энергии выбранного участника
; исходный диапазон #F97E..#F9A7
; смысловое имя ResolveSpecialObjectCollision
; In: IX и IY — участники, (ObjectEffects.Current) — метаданные IX
; Out: специальный участник передаётся Game.Motion.IsSmallSignedDistance.Entry, обычный путь возвращает A=1 при поражении
; Corrupt: AF, при переходе Game.Motion.IsSmallSignedDistance.Entry также его регистры
; Обычный путь разрешён лишь при всех флагах #D0 в метаданных
; При FSpaceObject.Flags2 второго участника IY = OBJ_STATION_FL обнуляется FSpaceObject.Energy первого IX, иначе нужен OBJ_SCOOP_BIT второго и обнуляется его энергия
; HL сохраняется при чтении метаданных, остальные поля объектов не меняются
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #F97E
                ; проверка флага управляемой ракеты первого участника столкновения
Entry:          BIT OBJ_MISSILE_BIT, (IX+FSpaceObject.Flags2)
                JP NZ, Game.Motion.IsSmallSignedDistance.Entry                  ; переход, если у объекта установлен флаг управляемой ракеты, применить обработчик Game.Motion.IsSmallSignedDistance.Entry

                ; чтение флагов метаданных без изменения HL вызывающей процедуры
                PUSH HL
                LD HL, (ObjectEffects.Current)
                LD A, (HL)
                POP HL
                AND FX_SEARCH_MASK
                XOR FX_SEARCH_MASK
                RET NZ                                                          ; выход, если не все флаги #D0 установлены, столкновение отклонено

                ; выбор участника, которому будет обнулена энергия
                LD A, (IY+FSpaceObject.Flags2)
                CP OBJ_STATION_FL
                JR Z, DestroyFirst                                              ; переход, если байт Flags2 второго участника равен #0C, обнулить энергию первого

                CPL
                AND ObjectFlag2.Scoopable
                RET NZ                                                          ; выход, если флаг захвата ковшом второго участника сброшен, столкновение отклонено

                LD (IY+FSpaceObject.Energy), A
                INC A
                RET

DestroyFirst:   XOR A
                LD (IX+FSpaceObject.Energy), A
                INC A
                RET

                DB #3C, #C9                                                     ; данные #F9A6..#F9A7
                ; проверка исходного конца фрагмента
                ASSERT $ == #F9A8
                endmodule
                endmodule
