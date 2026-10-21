                module Circles
                module DrawPendingObjectExplosions
; -----------------------------------------
; рисование ожидающих взрывов восьми объектов
; исходный диапазон #8F0D..#8F73
; смысловое имя DrawPendingObjectExplosions
; In: CombatState.ObjectsPresent — наличие объектов, массив от Memory.Station с шагом 39
; Out: для отмеченных объектов выведены расширяющиеся круги и снят флаг запроса уничтожения
; Corrupt: HL, DE, BC, AF, HL', DE', BC', AF', IX
; Общий признак наличия объектов допускает обход, затем проверяются флаги каждого слота
; Обрабатываются объекты со всеми битами OBJ_DEATH_MASK в FSpaceObject.Flags, центр, знаки и радиус берутся из ExplodeX, ExplodeY, SignPhase и Radius
; Перед циклом рендер перенаправляется на экран с пределами #40..#4F
; Один взрыв рисуется четырьмя кругами, радиус увеличивается на 3, счётчик цвета уменьшается на 4
; После всех восьми слотов выполнение проваливается в Game.Circles.SelectCircleBackBuffer.Entry и восстанавливает буферный режим
; -----------------------------------------
                ; смещения описывают исходные данные, память не выделяется
ExplodeX:       EQU FSpaceObject.Acceleration                                   ; экранный X взрыва вместо ускорения, записывает StartObjectExplosion
ExplodeY:       EQU FSpaceObject.Roll                                           ; экранный Y взрыва вместо крена
SignPhase:      EQU FSpaceObject.Pitch                                          ; знаки центра и фаза вместо команды тангажа
Radius:         EQU FSpaceObject.Payload                                        ; радиус взрыва вместо обычной нагрузки объекта

                ; проверка исходного начала фрагмента
                ASSERT $ == #8F0D
                ; проверка наличия объектов перед обходом их запросов взрыва
Entry:          LD A, (CombatState.ObjectsPresent)
                AND A
                RET Z                                                           ; выход, если в объектном кадре не было ни одного непустого слота

                ; перенаправление рисования с буфера на реальный экран
                LD A, #40
                LD (CircleRaster.FillTop), A
                LD A, #4F
                LD (CircleRaster.TargetBottom), A
                LD A, #3F
                LD (CircleRaster.TargetTop), A
                LD HL, #0000
                LD A, #50
                CALL Game.Circles.PatchCircleScreenTarget.Entry
                ; поиск ожидающих взрывов среди восьми 39-байтовых слотов
                LD IX, Memory.Station
                LD B, #08
                ; проверка совместных флагов Destroy и Exploding
CheckObject:    PUSH BC
                LD A, (IX + FSpaceObject.Flags)
                LD C, A
                AND OBJ_DEATH_MASK
                CP OBJ_DEATH_MASK
                JR NZ, NextObject                                               ; переход, если оба бита запроса и состояния взрыва не установлены одновременно

                ; подготовка цвета и параметров круга из состояния взрыва
                LD L, #0A
                CALL Game.Extensions.AttributeVectorAndEnergyBomb.Entry
                LD H, (IX + ExplodeX)
                LD L, (IX + ExplodeY)
                LD (CircleState.OffsetY), HL
                LD L, (IX + SignPhase)
                LD H, (IX + Radius)
                LD (CircleState.Flags), HL
                LD C, #0F
                ; рисование очередного круга и увеличение радиуса на 3
DrawRing:       PUSH BC
                CALL Game.Extensions.DrawCircleAndProtectScratchStack.Entry
                POP BC
                ADD A, #03
                LD (CircleState.Radius), A
                LD A, C
                SUB #04
                LD C, A
                JR NC, DrawRing                                                 ; переход, если счётчик эффекта ещё не пересёк 0 после вычитания 4, нарисовать следующий круг

                ; восстановление атрибутов и сброс флага Destroy
                LD L, #0F
                CALL Game.Extensions.AttributeVectorAndEnergyBomb.Entry
                RES OBJ_DESTROY_BIT, (IX + FSpaceObject.Flags)
                ; переход к следующему 39-байтовому слоту
NextObject:     LD DE, #0027
                ADD IX, DE
                POP BC
                DJNZ CheckObject                                                ; далее Game.Circles.SelectCircleBackBuffer.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #8F74
                endmodule
                endmodule
