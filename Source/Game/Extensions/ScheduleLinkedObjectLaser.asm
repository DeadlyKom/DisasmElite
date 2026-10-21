                module Extensions
                module ScheduleLinkedObjectLaser
; -----------------------------------------
; разрешение лазерного луча и обновление случайного порога связанного объекта
; исходный диапазон #FA84..#FAC9
; смысловое имя ScheduleLinkedObjectLaser
; In: IX — объект, (ObjectEffects.Current) — метаданные, (CloakActive) — текущий режим
; Out: при разрешении установлен OBJ_LASER_BIT в FSpaceObject.Flags объекта IX и обновлён байт LaserThreshold
; Corrupt: HL, AF, IY сохраняется
; Сначала проверяются флаги записи, общий бит 2 ObjectEffects.Flags и наличие ссылок +8/+9
; При нулевых ссылках действие разрешено без проверки таймера, иначе его бит 1 блокирует действие
; LaserThreshold одновременно является операндом CP и сдвигаемым накопителем состояния
; При CloakActive=0 случайная проверка пропускается, иначе порог берётся из изменяемого операнда
; После предварительного допуска видимый луч включается при любом случайном результате
; Возвращаемый C сохраняет результат сравнения, SteerObjectAndTryLaser проверяет его перед попаданием
; SRL и SET 5 меняют последующий порог, PUSH/POP AF сохраняют результат сравнения
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #FA84
                ; проверка допуска действия по флагам метаданных
Entry:          PUSH IY
                LD IY, (ObjectEffects.Current)
                LD A, (IY+FEffectRecord10.TypeFlags)
                AND FX_GROUP_MASK
                JR NZ, CheckLinks                                               ; переход, если младшие два флага метаданных ненулевые, проверить связи

                LD A, (ObjectEffects.Flags)
                BIT FX_ALLOW_BIT, A
                JR Z, RestoreTarget                                             ; переход, если общий бит 2 сброшен, действие не разрешено

                ; проверка наличия цели и блокировки действия
CheckLinks:     LD A, (IY+FEffectRecord10.Fallback)
                AND FX_LINK_MASK
                OR (IY+FEffectRecord10.Links)
                JR Z, PermitLaser                                               ; переход, если обе ссылки нулевые, разрешить луч без проверки таймера

                BIT FX_LASER_TICK, (IY+FEffectRecord10.Timer)
                JR NZ, RestoreTarget                                            ; переход, если бит 1 метаданных +7 установлен, действие не разрешено

                ; миссия 2 CLOAKING DEVICE, включённая маскировка добавляет случайную проверку допуска лазера противника
                ; описание в Docs/Manual.md, раздел mission-2
PermitLaser:    SCF
RestoreTarget:  POP IY
                RET NC                                                          ; выход, если действие не было разрешено, объект не менять

                ; обновление самомодифицируемого вероятностного накопителя
                LD HL, LaserThreshold
                LD A, (CloakActive)
                AND A
                SCF
                JR Z, TestRandom                                                ; переход, если режим CloakActive нулевой, пропустить получение случайного числа

                CALL Game.Combat.NextRandomByte.Entry
; -----------------------------------------
; адаптивный порог CP, одновременно сдвигаемая история допусков лазерного огня
;      7    6    5    4    3    2    1    0
;   +----+----+----+----+----+----+----+----+
;   | PS | H6 | H5 | H4 | H3 | H2 | H1 | H0 |
;   +----+----+----+----+----+----+----+----+
;
;   PS      [7]     - новый допуск либо внешнее попадание, LASER_PASS_BIT
;   H6..H0  [6..0]  - числовая история, сдвигается SRL, разряды не независимые флаги
;   после SRL бит LASER_BASE_BIT устанавливается, поэтому порог не меньше 32
;   PUSH/POP AF сохраняет результат сравнения при изменении следующего порога
; -----------------------------------------
LaserThreshold  EQU $ + 1                                                       ; порог CP и одновременно сдвигаемая история случайных проверок
                CP 1 << LASER_BASE_BIT
                ; проверка переноса и условная установка старшего бита накопителя
TestRandom:     JR NC, UpdateHistory                                            ; переход, если случайный байт не меньше порога, не добавлять бит 7 накопителя

                SET LASER_PASS_BIT, (HL)
                ; сдвиг накопителя с восстановлением флагов допуска
UpdateHistory:  PUSH AF
                SRL (HL)
                SET LASER_BASE_BIT, (HL)
                POP AF
                ; установка OBJ_LASER_BIT в FSpaceObject.Flags для отрисовки лазерного луча
                SET OBJ_LASER_BIT, (IX+FSpaceObject.Flags)
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #FACA
                endmodule
                endmodule
