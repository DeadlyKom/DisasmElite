                module Universe
                module UpdateAndDrawStarField
; -----------------------------------------
; пересчёт и вывод звёздного поля по углам, скорости и направлению вида
; исходный диапазон #78B1..#79F8
; In:
;   память 70E3..70E6, вид, углы и скорость
;   FlightState.SpaceMode, обычная система либо особое пространство
;   память 7A39..7A58,16 пар звёзд
; Out:
;   координаты звёзд и пиксели буфера обновлены
; Corrupt:
;   HL, DE, BC, AF, AF'
; Note:
; Операнд сравнения 78B5 хранит предыдущий вид, его изменение помечает все 16 пар FF.
; По направлению камеры выбираются знаки вращения, продольное расширение и боковой перенос.
; В обычной системе обрабатываются 16 звёзд, в особом пространстве 4.
; Каждая пара сначала поворачивается малыми произведениями 9924, затем расширяется по скорости и переносится.
; Координаты знако-модульные, операции сложения выполняет 7A59. Байт R добавляет мелкое случайное дрожание.
; Вышедшие за диапазон пары заменяются случайными значениями, старший бит задаёт сторону от центра.
; Первая координата при выводе превращается в строку (63-значение) либо (63+значение+перенос) AND7F.
; Вторая даёт столбец от базы 119 с финальным OR80, перенос при отрицательном знаке сохраняется.
; Пиксели выводятся XOR-помощником A83C. Внутри нет выделения новой памяти.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #78B1
                ; проверка смены вида и сброс звёзд при изменении камеры
Entry:          LD A, (FlightState.View)
PreviousView    EQU $ + 1                                                       ; предыдущий номер вида в операнде CP, смена вида очищает звёзды
                CP #01
                LD (StarView), A
                JR Z, ViewMotion                                                ; переход, если текущий вид совпал с сохранённым и поле не нужно сбрасывать

                LD B, #20
                LD HL, StarPoints
ClearStars:     LD (HL), #FF
                INC HL
                DJNZ ClearStars

                ; расчёт коэффициентов скорости и поворота для выбранного вида
ViewMotion:     LD B, #00
                CP #02
                JR NC, SelectTurn                                               ; переход, если выбран боковой вид без продольного расширения

                PUSH AF
                RRCA
                LD B, A
                LD A, (FlightState.Speed)
                SRL A
                INC A
                OR B
                LD B, A
                POP AF
SelectTurn:     LD HL, FlightState.Roll
                JR C, ReadTurn                                                  ; переход, если выбран передний либо задний вид и используется угол LR

                INC HL
ReadTurn:       PUSH AF
                LD A, (HL)
                JR C, StoreTurn                                                 ; переход, если выбран передний либо задний вид и угол не делится пополам

                AND #80
                LD C, A
                LD A, (HL)
                RRCA
                AND #3F
                OR C
StoreTurn:      LD C, A
                POP AF
                ; расчёт знаков бокового переноса и сопряжённого вращения
                PUSH AF
                RRCA
                AND #80
                PUSH AF
                XOR C
                LD C, A
                LD A, #01
                XOR L
                LD L, A
                POP DE
                PUSH DE
                RRCA
                CPL
                AND #80
                XOR D
                XOR (HL)
                LD D, A
                POP AF
                LD L, #E6
                XOR (HL)
                LD E, A
                INC E
                POP AF
                CP #02
                JR NC, SelectCount                                              ; переход, если выбран боковой вид и боковой перенос сохраняется

                LD E, #00
                ; выбор количества звёзд по режиму пространства
SelectCount:    LD A, (FlightState.SpaceMode)
                AND A
                LD A, #10
                JR Z, StartStars                                                ; переход, если игрок находится в обычной системе, обработать 16 звёзд

                LD A, #04
StartStars:     PUSH AF
                LD HL, StarPoints
                ; начало пересчёта очередной знако-модульной пары
MoveStar:       PUSH AF
                LD A, (HL)
                INC HL
                AND (HL)
                INC A
                JP Z, NextStar                                                  ; переход, если пара помечена FF и её пересчёт пропускается

                PUSH DE
                DEC HL
                LD D, (HL)
                INC HL
                LD E, (HL)
                PUSH HL
                LD A, D
                ADD A, A
                LD L, A
                LD A, C
                ; расчёт малых поворотов двух координат
                CALL Game.Scanner.ScaleValueAndFinishBackground.Entry
                LD D, A
                LD A, E
                ADD A, A
                LD L, A
                LD A, C
                CALL Game.Scanner.ScaleValueAndFinishBackground.Entry
                LD E, A
                POP HL
                LD A, (HL)
                CPL
                XOR C
                AND #80
                OR E
                EX AF, AF'
                DEC HL
                LD A, (HL)
                EX AF, AF'
                CALL Game.Universe.AddSignedStarCoordinate.Entry
                INC HL
                EX AF, AF'
                XOR C
                AND #80
                OR D
                CALL Game.Universe.AddSignedStarCoordinate.Entry
                LD A, B
                AND A
                JR Z, ApplyShift                                                ; переход, если коэффициент продольного расширения нулевой

                DEC HL
                LD A, (HL)
                ADD A, A
                PUSH HL
                LD L, A
                LD A, B
                CALL Game.Scanner.ScaleValueAndFinishBackground.Entry
                INC A
                LD D, A
                POP HL
                LD A, (HL)
                XOR B
                AND #80
                OR D
                CALL Game.Universe.AddSignedStarCoordinate.Entry
                INC HL
                LD A, (HL)
                PUSH HL
                ADD A, A
                LD L, A
                LD A, B
                CALL Game.Scanner.ScaleValueAndFinishBackground.Entry
                INC A
                POP HL
                LD E, A
                LD A, (HL)
                XOR B
                AND #80
                OR E
                CALL Game.Universe.AddSignedStarCoordinate.Entry
                ; применение бокового переноса и проверка центральной области
ApplyShift:     POP DE
                LD A, E
                CALL Game.Universe.AddSignedStarCoordinate.Entry
                DEC HL
                LD A, D
                CALL Game.Universe.AddSignedStarCoordinate.Entry
                LD A, B
                RLCA
                LD A, (HL)
                INC HL
                JR NC, AddJitter                                                ; переход, если знак расширения не требует проверки центрального исчезновения

                OR (HL)
                AND #70
                JR NZ, AddJitter                                                ; переход, если звезда ещё не попала в центральную область

                LD (HL), #FF
                ; добавление дрожания по регистру R
AddJitter:      LD A, R
                RRCA
                AND #81
                CALL Game.Universe.AddSignedStarCoordinate.Entry
                DEC HL
                LD A, R
                RRCA
                AND #81
                CALL Game.Universe.AddSignedStarCoordinate.Entry
                INC HL
NextStar:       INC HL
                POP AF
                DEC A
                JP NZ, MoveStar                                                 ; переход, если остались звёзды для пересчёта

                POP AF
                PUSH AF
                ; проверка диапазона и пересоздание выбывших звёзд
CheckStar:      PUSH AF
                DEC HL
                LD A, (HL)
                DEC HL
                OR #80
                INC A
                JR Z, RespawnStar                                               ; переход, если пара содержит признак недействительной координаты

                LD A, (HL)
                ADD A, A
                ADD A, A
                JR NC, NextCheck                                                ; переход, если координата остаётся в рабочем диапазоне и пересоздание не требуется

RespawnStar:    INC HL
                CALL Game.Combat.NextRandomByte.Entry
                RRCA
                LD (HL), A
                CALL Game.Combat.NextRandomByte.Entry
                RRCA
                AND #BF
                DEC HL
                LD (HL), A
NextCheck:      POP AF
                DEC A
                JR NZ, CheckStar                                                ; переход, если остались пары для проверки и пересоздания

                POP BC
                ; расчёт экранных координат и вывод пикселей
DrawStar:       PUSH BC
                LD A, (HL)
                BIT 6, A
                INC HL
                JR NZ, NextPixel                                                ; переход, если первая координата имеет установленный бит 6 и пиксель пропускается

                DEC HL
                ADD A, A
                LD A, #3F
                JR C, PositiveX                                                 ; переход, если первая координата отрицательна и используется прибавление к центру

                SUB (HL)
                JR ScreenX

PositiveX:      ADC A, (HL)
ScreenX:        AND #7F
                LD B, A
                INC HL
                LD A, (HL)
                ADD A, A
                LD A, #77
                JR C, PositiveY                                                 ; переход, если вторая координата отрицательна и используется прибавление к базе

                SUB (HL)
                JR DrawPixel

PositiveY:      ADC A, (HL)
                OR #80
DrawPixel:      LD C, A
                PUSH HL
                CALL Game.Motion.XorFarObjectPixel.Entry
                POP HL
NextPixel:      INC HL
                POP BC
                DJNZ DrawStar

                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #79F9
                endmodule
                endmodule
