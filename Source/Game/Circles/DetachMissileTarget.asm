                module Circles
                module DetachMissileTarget
; -----------------------------------------
; снятие цели ракеты после исчезновения объекта
; исходный диапазон #8C29..#8C3B
; смысловое имя DetachMissileTarget
; In: IY — зависимая ракета/объект, AF — A содержит новое значение цели
; Out: при нечётном младшем байте FSpaceObject.Blueprint устанавливается OBJ_DESTROY_BIT в FSpaceObject.Flags объекта IY
; Corrupt: только флаги AF
; Для чётного адреса модели FSpaceObject.Flags2 получает OBJ_LOST_FL, FSpaceObject.Target получает A
; Это самостоятельный обработчик из Game.Combat.ReleaseMissileTargets.Entry, геометрический построитель сюда не проваливается
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #8C29
                ; проверка модели ракеты перед снятием исчезнувшей цели
Entry:          BIT 0, (IY + FSpaceObject.Blueprint)
                JR Z, DetachTarget                                              ; переход, если младший байт адреса модели чётный, очистить цель без уничтожения

                SET OBJ_DESTROY_BIT, (IY + FSpaceObject.Flags)
                RET

                ; перевод ракеты на отдельный режим без прямого запроса уничтожения
DetachTarget:   LD (IY + FSpaceObject.Flags2), OBJ_LOST_FL
                LD (IY + FSpaceObject.Target), A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #8C3C
                endmodule
                endmodule
