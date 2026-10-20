                module Circles
                module SkipRowsDownAndDrawCircleContours
; -----------------------------------------
; пропуск строк вниз и три контурных построителя
; исходный диапазон #9032..#928B
; смысловое имя SkipRowsDownAndDrawCircleContours
; In: #9032 получает B число строк и A координату Y, прочие входы получают регистры дуги
; Out: строки пропущены либо построен контур без заполнения середины
; Corrupt: #9032 меняет HL, AF/BC сохраняет, контуры меняют HL, DE, BC, AF и альтернативные регистры
; #9060 — контур с фиксированным правым краем, #90FB — два движущихся края, #91F4 — фиксированный левый край
; Каждый построитель хранит реальный SP в#8623 и снимает AF внешней обёртки при завершении
; Одиночные маски B/C вращаются, перенос означает переход пикселя через границу байта
; HL' хранит ошибку окружности, E' растёт по Y, C' растёт от отрицательного X к нулю
; При смене знака ошибки переключаются шаги по строкам и пикселям
; AF' задаёт ограничитель отсечения, достижение переводит боковую дугу в общий двухкраевой цикл
; #91AC/#91C0/#91D1 закрывают конечные участки, используя уже поставленные биты экрана
; Байт#928B — исходный резерв после безусловного перехода, не выполняется
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9032
                ; преобразование начальной строки перед пропуском вниз
Entry:          PUSH AF
                PUSH BC
                LD B, A
                LD C, #F7
                CALL Rom.PixelFromA
                SET 7, H
                POP BC
                PUSH BC
                ; проверка числа пропускаемых строк
                DEC B
                INC B
                JR Z, EndSkipRows                                               ; переход, если число пропускаемых строк равно нулю

                ; переход на строку ниже
StepDown:       INC H
                LD A, H
                AND #07
                JR Z, CrossSkipRow                                              ; переход, если переход вниз пересёк восьмистрочный блок

CountSkipRow:   DJNZ StepDown

EndSkipRows:    POP BC
                POP AF
                RET

                ; коррекция адреса при пересечении восьмистрочного блока вниз
CrossSkipRow:   LD A, L
                ADD A, #20
                LD L, A
                JR C, CheckSkipLimit                                            ; переход, если прибавление 32 дало перенос, проверить нижнюю треть экрана

                LD A, H
                SUB #08
                LD H, A
                JR CountSkipRow

                ; проверка нижнего предела буфера
CheckSkipLimit: LD A, H
                CP #D0
                JR C, CountSkipRow                                              ; переход, если H меньше#D0, продолжить пропуск строк

                JR EndSkipRows

                ; вход контура с отсечённым правым краем, проверка области
RightCutArc:    LD A, E
                AND #1F
                CP #20
                JR NC, EmptyRightArc                                            ; переход, если индекс столбца не меньше 32, при штатной маске#1F условие недостижимо

                LD A, (CircleState.DirectionDown)
                AND A
                JR NZ, RightCutBottom                                           ; переход, если направление вниз, проверить нижний предел

                LD A, #BF
                CP H
                JR C, SaveRightStack                                            ; переход, если H выше#BF, строка допустима

                JR EmptyRightArc

RightCutBottom: LD A, #CF
                CP H
                JR NC, SaveRightStack                                           ; переход, если H не больше#CF, строка допустима

EmptyRightArc:  POP AF
                RET

                ; сохранение реального SP перед контурным проходом
SaveRightStack: LD (CircleState.SavedSP), SP
                ; наложение левого контурного пикселя на текущую строку
DrawLeftPixel:  LD D, L
                LD L, E
                LD A, (HL)
                OR B
                LD (HL), A
                LD L, D
                ; выбор вертикального направления движения
                LD A, (CircleState.DirectionDown)
                AND A
                JR NZ, RightArcDown                                             ; переход, если направление вниз, перейти на следующую строку

                CALL Game.Circles.StepCircleRowUp.Entry
                JR RightYError

RightArcDown:   CALL Game.Circles.StepCircleRowDown.Entry
                ; расчёт ошибки после шага Y
RightYError:    EXX
                ADD HL, DE
                INC E
                ADD HL, DE
                BIT 7, H
                EXX
                JR NZ, DrawLeftPixel                                            ; переход, если ошибка после шага Y отрицательна, вывести левый пиксель новой строки

                ; вращение одиночной левой маски
                RRC B
                JR C, RightCrossLeft                                            ; переход, если одиночная левая маска пересекла границу байта

                ; расчёт шага X с проверкой ограничителя A'
RightXError:    EXX
                ADD HL, BC
                INC C
                EX AF, AF'
                CP C
                JR Z, JoinArcRight                                              ; переход, если C' достиг ограничителя A', перейти к общей дуге

                EX AF, AF'
                ADD HL, BC
                BIT 7, H
                EXX
                JR NZ, DrawLeftPixel                                            ; переход, если ошибка после шага X отрицательна, вывести левый пиксель новой строки

                JR SweepLeftPixel

                ; увеличение левого адреса после переноса пиксельной маски
RightCrossLeft: INC E
                LD A, L
                SUB E
                JR C, FinishRightArc                                            ; переход, если левый край перешёл правую границу, завершить половину

                JR RightXError

                ; переход к общей дуге после достижения ограничителя
JoinArcRight:   EX AF, AF'
                JP EndBothXError

JoinSweepRight: EX AF, AF'
                JP EndBothSweep

                ; выход из правого отсечённого контура с восстановлением стека
FinishRightArc: LD SP, (CircleState.SavedSP)
                POP AF
                RET

                ; переход левого адреса во время горизонтального прохода
RightSweepByte: INC E
                LD A, L
                SUB E
                JR C, FinishRightArc                                            ; переход, если левый край перешёл правую границу, завершить половину

                JR RightSweepErr

                ; наложение очередного пикселя в горизонтальном проходе
SweepLeftPixel: LD D, L
                LD L, E
                LD A, (HL)
                OR B
                LD (HL), A
                LD L, D
                RRC B
                JR C, RightSweepByte                                            ; переход, если левая маска пересекла границу байта, увеличить E

                ; расчёт ошибки после шага X и проверка окончания половины
RightSweepErr:  EXX
                ADD HL, BC
                INC C
                JR Z, FinishRightArc                                            ; переход, если C' обернулся в 0, половина закончилась

                EX AF, AF'
                CP C
                JR Z, JoinSweepRight                                            ; переход, если C' достиг ограничителя A', перейти к общему горизонтальному проходу

                EX AF, AF'
                ADD HL, BC
                BIT 7, H
                EXX
                JR Z, SweepLeftPixel                                            ; переход, если ошибка неотрицательна, продолжить пиксели в той же строке

                ; расчёт ошибки следующей строки и выбор направления
                EXX
                ADD HL, DE
                INC E
                ADD HL, DE
                EXX
                LD A, (CircleState.DirectionDown)
                AND A
                JR NZ, RightSweepDown                                           ; переход, если направление вниз, перейти на следующую строку

                CALL Game.Circles.StepCircleRowUp.Entry
                JR SweepLeftPixel

RightSweepDown: CALL Game.Circles.StepCircleRowDown.Entry
                JR SweepLeftPixel

                ; вход контура с двумя подвижными краями
BothArc:        LD A, E
                SUB L
                JR NC, EmptyBothArc                                             ; переход, если левый адрес не меньше правого, контурная половина пуста

                LD A, (CircleState.DirectionDown)
                AND A
                JR NZ, BothArcBottom                                            ; переход, если направление вниз, проверить нижнюю границу

                LD A, #BF
                CP H
                JR C, SaveBothStack                                             ; переход, если H выше#BF, строка допустима

                JR EmptyBothArc

BothArcBottom:  LD A, #CF
                CP H
                JR NC, SaveBothStack                                            ; переход, если H не больше#CF, строка допустима

EmptyBothArc:   POP AF
                RET

                ; сохранение реального SP перед двухкраевым проходом
SaveBothStack:  LD (CircleState.SavedSP), SP
                ; наложение правого и левого контурных пикселей
DrawBothPixels: LD A, (HL)
                OR C
                LD (HL), A
                LD D, L
                LD L, E
                LD A, (HL)
                OR B
                LD (HL), A
                LD L, D
                ; выбор направления и переход на соседнюю строку
                LD A, (CircleState.DirectionDown)
                AND A
                JR NZ, BothArcDown                                              ; переход, если направление вниз, увеличить экранную строку

                LD A, H
                DEC H
                AND #07
                CALL Z, Game.Circles.CrossCircleCharacterRowUp.Entry            ; вызов, если переход вверх пересёк восьмистрочный блок, скорректировать оба края
                JR BothYError

BothArcDown:    INC H
                LD A, H
                AND #07
                CALL Z, Game.Circles.CrossCircleCharacterRowDown.Entry          ; вызов, если переход вниз пересёк восьмистрочный блок, скорректировать оба края
                ; расчёт ошибки после шага Y
BothYError:     EXX
                ADD HL, DE
                INC E
                ADD HL, DE
                BIT 7, H
                EXX
                JP NZ, DrawBothPixels                                           ; переход, если ошибка после шага Y отрицательна, поставить два пикселя новой строки

                ; вращение двух краевых масок к центру круга
                RRC B
                JR C, BothCrossLeft                                             ; переход, если левая маска пересекла границу байта

MoveRightPixel: RLC C
                JR C, BothCrossRight                                            ; переход, если правая маска пересекла границу байта

                ; расчёт ошибки после шага X
BothXError:     EXX
                ADD HL, BC
                INC C
EndBothXError:  ADD HL, BC
                BIT 7, H
                EXX
                JP NZ, DrawBothPixels                                           ; переход, если ошибка после шага X отрицательна, поставить два пикселя новой строки

                JP SweepBothBits

                ; перенос левой маски в следующий байт
BothCrossLeft:  INC E
                LD A, L
                SUB E
                JR Z, FinishBothArc                                             ; переход, если края совпали при увеличении левого адреса, половина закончилась

                JP MoveRightPixel

                ; перенос правой маски в предыдущий байт
BothCrossRight: DEC L
                LD A, L
                SUB E
                JR Z, FinishBothArc                                             ; переход, если края совпали при уменьшении правого адреса, половина закончилась

                JP BothXError

                ; общий выход контура с восстановлением SP и AF
FinishBothArc:  LD SP, (CircleState.SavedSP)
                POP AF
                RET

                ; проверка смыкания краёв после переноса левой маски
BothSweepLeft:  INC E
                LD A, L
                SUB E
                JR Z, CloseLeftEnd                                              ; переход, если края сошлись в горизонтальном проходе, закрыть левый остаток

                JP SweepRightBit

                ; проверка смыкания краёв после переноса правой маски
BothSweepRight: DEC L
                LD A, L
                SUB E
                JR Z, CloseRightEnd                                             ; переход, если края сошлись в горизонтальном проходе, закрыть правый остаток

                JP BothSweepError

                ; горизонтальный проход с двумя граничными пикселями
SweepBothBits:  LD A, (HL)
                OR C
                LD (HL), A
                LD D, L
                LD L, E
                LD A, (HL)
                OR B
                LD (HL), A
                LD L, D
                RRC B
                JR C, BothSweepLeft                                             ; переход, если левая маска пересекла границу байта

SweepRightBit:  RLC C
                JR C, BothSweepRight                                            ; переход, если правая маска пересекла границу байта

                ; расчёт ошибки горизонтального шага и проверка нулевого остатка
BothSweepError: EXX
                ADD HL, BC
                INC C
                JR Z, CloseBothEnds                                             ; переход, если C' обернулся в 0, закрыть оба конечных участка

EndBothSweep:   ADD HL, BC
                BIT 7, H
                EXX
                JR Z, SweepBothBits                                             ; переход, если ошибка неотрицательна, продолжить пиксели в этой строке

                ; расчёт ошибки следующей строки
                EXX
                ADD HL, DE
                INC E
                ADD HL, DE
                EXX
                ; выбор направления перехода строки
                LD A, (CircleState.DirectionDown)
                AND A
                JR NZ, BothSweepDown                                            ; переход, если направление вниз, перейти на следующую строку

                CALL Game.Circles.StepCircleRowUp.Entry
                JR SweepBothBits

BothSweepDown:  CALL Game.Circles.StepCircleRowDown.Entry
                JR SweepBothBits

                ; закрытие левого конечного участка по уже нарисованному байту
CloseLeftEnd:   LD L, E
                LD A, (HL)
                LD B, #FF
                AND A
                JR Z, StoreEndMask                                              ; переход, если байт левого края пока пуст, записать сплошной остаток

                LD B, A
                LD A, #FF
                ; поиск установленного бита для расширения конечной маски
FindLeftBit:    SRL B
                JR C, StoreLeftEnd                                              ; переход, если найден младший установленный бит левого края, завершить расширение маски

                ADD A, A
                JR FindLeftBit

StoreLeftEnd:   LD (HL), A
                JR LeaveClosedArc

                ; закрытие правого конечного участка по уже нарисованному байту
CloseRightEnd:  LD A, (HL)
                LD B, #FF
                AND A
                JR Z, StoreEndMask                                              ; переход, если байт правого края пуст, записать сплошной остаток

                ; поиск старшего установленного бита правой конечной маски
FindRightBit:   ADD A, A
                JR C, StoreEndMask                                              ; переход, если найден старший установленный бит правого края, завершить расширение маски

                SRL B
                JR FindRightBit

StoreEndMask:   LD (HL), B
LeaveClosedArc: JP FinishBothArc

                ; закрытие двух конечных участков при исчерпании радиуса
CloseBothEnds:  EXX
                LD A, (HL)
                AND A
                JR Z, FillFirstEnd                                              ; переход, если байт правого края пуст, начать с#FF

                LD B, A
                LD A, #FF
                ; поиск границы первого конечного участка
FindFirstBit:   SRL B
                JR C, StoreFirstEnd                                             ; переход, если найден установленный бит первого конечного участка

                ADD A, A
                JR FindFirstBit

FillFirstEnd:   LD A, #FF
                ; запись первого конечного участка и чтение второго
StoreFirstEnd:  LD (HL), A
                LD L, E
                LD A, (HL)
                LD B, #FF
                AND A
                JR Z, StoreSecondEnd                                            ; переход, если байт второго конечного участка пуст, записать#FF

                ; поиск границы второго конечного участка
FindSecondBit:  ADD A, A
                JR C, StoreSecondEnd                                            ; переход, если найден старший установленный бит второго конечного участка

                SRL B
                JR FindSecondBit

StoreSecondEnd: LD (HL), B
                JR LeaveClosedArc

                ; вход контура с фиксированным левым краем
LeftCutArc:     LD A, L
                AND #1F
                CP #20
                JR NC, EmptyLeftArc                                             ; переход, если индекс столбца не меньше 32, при штатной маске#1F условие недостижимо

                LD A, (CircleState.DirectionDown)
                AND A
                JR NZ, LeftCutBottom                                            ; переход, если направление вниз, проверить нижний предел

                LD A, #BF
                CP H
                JR C, SaveLeftStack                                             ; переход, если H выше#BF, строка допустима

                JR EmptyLeftArc

LeftCutBottom:  LD A, #CF
                CP H
                JR NC, SaveLeftStack                                            ; переход, если H не больше#CF, строка допустима

EmptyLeftArc:   POP AF
                RET

                ; сохранение реального SP для левого отсечённого контура
SaveLeftStack:  LD (CircleState.SavedSP), SP
                ; наложение правого контурного пикселя
DrawRightPixel: LD A, (HL)
                OR C
                LD (HL), A
                ; выбор направления и переход к соседней строке
                LD A, (CircleState.DirectionDown)
                AND A
                JR NZ, LeftArcDown                                              ; переход, если направление вниз, перейти на следующую строку

                CALL Game.Circles.StepCircleRowUp.Entry
                JR LeftYError

LeftArcDown:    CALL Game.Circles.StepCircleRowDown.Entry
                ; расчёт ошибки после шага Y
LeftYError:     EXX
                ADD HL, DE
                INC E
                ADD HL, DE
                BIT 7, H
                EXX
                JR NZ, DrawRightPixel                                           ; переход, если ошибка после шага Y отрицательна, вывести правый пиксель

                ; вращение одиночной правой маски к центру
                RLC C
                JR C, LeftCrossRight                                            ; переход, если одиночная правая маска пересекла границу байта

                ; расчёт шага X и проверка ограничителя отсечения
LeftXError:     EXX
                ADD HL, BC
                INC C
                EX AF, AF'
                CP C
                JR Z, JoinArcLeft                                               ; переход, если C' достиг ограничителя A', перейти к общей дуге

                EX AF, AF'
                ADD HL, BC
                BIT 7, H
                EXX
                JR NZ, DrawRightPixel                                           ; переход, если ошибка после шага X отрицательна, вывести правый пиксель

                JR DrawRightSweep

                ; перенос правой маски в предыдущий байт
LeftCrossRight: DEC L
                LD A, L
                SUB E
                INC A
                JR Z, FinishLeftArc                                             ; переход, если правый край перешёл фиксированный левый, завершить половину

                JR LeftXError

                ; снятие отсечения после достижения ограничителя
JoinArcLeft:    EX AF, AF'
                JP EndBothXError

JoinSweepLeft:  EX AF, AF'
                JP EndBothSweep

                ; выход левого отсечённого контура с восстановлением стека
FinishLeftArc:  LD SP, (CircleState.SavedSP)
                POP AF
                RET

                ; проверка смыкания краёв при горизонтальном проходе
LeftSweepByte:  DEC L
                LD A, L
                SUB E
                INC A
                JR Z, FinishLeftArc                                             ; переход, если правый край перешёл фиксированный левый, завершить половину

                JR LeftSweepError

                ; горизонтальный проход с одним подвижным пикселем
DrawRightSweep: LD A, (HL)
                OR C
                LD (HL), A
                RLC C
                JR C, LeftSweepByte                                             ; переход, если правая маска пересекла границу байта

                ; расчёт ошибки горизонтального шага
LeftSweepError: EXX
                ADD HL, BC
                INC C
                JR Z, FinishLeftArc                                             ; переход, если C' обернулся в 0, половина закончилась

                EX AF, AF'
                CP C
                JR Z, JoinSweepLeft                                             ; переход, если C' достиг ограничителя A', перейти к общему горизонтальному проходу

                EX AF, AF'
                ADD HL, BC
                BIT 7, H
                EXX
                JR Z, DrawRightSweep                                            ; переход, если ошибка неотрицательна, продолжить пиксели в той же строке

                ; расчёт ошибки следующей строки и выбор направления
                EXX
                ADD HL, DE
                INC E
                ADD HL, DE
                EXX
                LD A, (CircleState.DirectionDown)
                AND A
                JR NZ, LeftSweepDown                                            ; переход, если направление вниз, перейти на следующую строку

                CALL Game.Circles.StepCircleRowUp.Entry
                JR DrawRightSweep

LeftSweepDown:  CALL Game.Circles.StepCircleRowDown.Entry
                JR DrawRightSweep
                ; исходный резерв после безусловного перехода, сохраняется
                DB #00                                                          ; данные #928B..#928B
                ; проверка исходного конца фрагмента
                ASSERT $ == #928C
                endmodule
                endmodule
