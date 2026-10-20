                module Circles
                module SelectJumpAndContinueLeftFill
; -----------------------------------------
; выбор условия гиперперехода и продолжение левой заливки
; исходный диапазон #8C3C..#8D2A
; смысловое имя ChooseHyperjumpConditionAndContinueLeftFill
; In: для #8C3C состояние задания, для #8C4A — регистры итератора левой дуги
; Out: первый вход возвращает #7105 либо#F9 по переносу, остальные входы рисуют круг
; Corrupt: HL, DE, BC, AF по проверке, построитель также альтернативные регистры
; При активном вторжении #D67A поглощает байт#78 как порог, при раннем отказе тот же байт выполняется как LD A,B без изменения C
; #8C4A продолжает заливку с фиксированным левым краем, #8CF8 начинает правый отсечённый вариант
; AF' хранит ограничитель C' для перехода к общему неотсечённому построителю
; #8CD2 выбирает начало серии PUSH AF, #8CD3 хранит число пропускаемых команд
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #8C3C
                ; проверка задания с встроенным параметром#78 после CALL
Entry:          CALL Game.Text.CheckMissionRegion.Entry
                LD A, B
                CALL C, Game.Combat.NextRandomByte.Entry                        ; вызов, если проверка задания разрешила случайный вариант
                ; выбор штатного либо специального байта гиперперехода
                LD A, (FlightState.RandomByte)
                RET NC                                                          ; выход, если проверки не оставили C=1, вернуть штатный байт#7105

                LD A, #F9
                RET

                ; продолжение левой отсечённой заливки, шаг по строке
NextLeftRow:    JR NZ, LeftRowDown                                              ; переход, если направление вниз, перейти на следующую строку

                CALL Game.Circles.StepCircleRowUp.Entry
                JR AddLeftYError

LeftRowDown:    CALL Game.Circles.StepCircleRowDown.Entry
                ; расчёт ошибки после увеличения Y
AddLeftYError:  EXX
                ADD HL, DE
                INC E
                ADD HL, DE
                BIT 7, H
                EXX
                JR NZ, TestLeftError                                            ; переход, если ошибка окружности отрицательна, проверить шаг по X

                ; сужение правой подвижной маски
                SLA C
                JR NC, CrossRightByte                                           ; переход, если правая маска исчерпала байт, уменьшить правый адрес

                ; расчёт шага X и проверка ограничителя отсечения в A'
AddLeftXError:  EXX
                ADD HL, BC
                INC C
                EX AF, AF'
                CP C
                JR Z, JoinBothArc                                               ; переход, если C' достиг ограничителя A', перейти к двухкраевой дуге

                EX AF, AF'
                ADD HL, BC
                BIT 7, H
                EXX
TestLeftError:  JP NZ, Game.Circles.SetCabinHeatAndContinueFilledCircle.FillLeft ; переход, если ошибка после шага X отрицательна, залить очередную строку

                JR SweepLeftFill

                ; уменьшение правого адреса после исчерпания маски
CrossRightByte: DEC L
                LD A, L
                SUB E
                INC A
                JR Z, FinishLeft                                                ; переход, если правый адрес перешёл за фиксированный левый, завершить половину

                LD C, #FE
                JR AddLeftXError

                ; переход из отсечённого участка к двухкраевому построению
JoinBothArc:    EX AF, AF'
                EXX
                LD A, L
                SUB E
                EXX
                JR Z, FinishLeft                                                ; переход, если края совпали при снятии отсечения, завершить половину

                JP Game.Circles.SetCabinHeatAndContinueFilledCircle.FinishXError

                ; снятие отсечения при горизонтальном проходе
JoinBothSweep:  EX AF, AF'
                EXX
                LD A, L
                SUB E
                EXX
                JR Z, FinishLeft                                                ; переход, если края совпали при снятии отсечения, завершить половину

                JP Game.Circles.SetCabinHeatAndContinueFilledCircle.EndSweepError

                ; общий выход левой заливки с восстановлением стека
FinishLeft:     LD SP, (CircleState.SavedSP)
                POP AF
                RET

                ; переход правой маски в предыдущий байт
SweepRightByte: DEC L
                LD A, L
                SUB E
                INC A
                JR Z, FinishLeft                                                ; переход, если правый адрес перешёл за фиксированный левый, завершить половину

                LD C, #FE
                JR LeftSweepError

                ; горизонтальный проход левой отсечённой заливки
SweepLeftFill:  SLA C
                JR NC, SweepRightByte                                           ; переход, если правая маска перешла границу байта

LeftSweepError: EXX
                ADD HL, BC
                INC C
                JR Z, FinishLeft                                                ; переход, если C' обернулся в 0, половина закончилась

                EX AF, AF'
                CP C
                JR Z, JoinBothSweep                                             ; переход, если C' достиг ограничителя A', перейти в общий горизонтальный цикл

                EX AF, AF'
                ADD HL, BC
                BIT 7, H
                EXX
                JR Z, SweepLeftFill                                             ; переход, если ошибка неотрицательна, продолжить сужение в той же строке

                ; расчёт ошибки следующей строки и наложение правой маски
                EXX
                ADD HL, DE
                INC E
                ADD HL, DE
                EXX
                LD A, (HL)
                OR C
                LD (HL), A
                LD D, L
                LD L, E
                LD A, D
                SUB E
                SRL A
                JR NC, SetFillPairs                                             ; переход, если число внутренних байтов чётное, отдельный байт не требуется

                LD (HL), #FF
                ; расчёт числа пар#FF для быстрого заполнения
SetFillPairs:   LD L, D
                SUB #11
                CPL
                LD (CircleRaster.LeftPairJump), A
                LD SP, CircleFillWord
                POP AF
                LD SP, HL
                ; изменяемый переход в серию записи через стек
PairJump        EQU $ + 1                                                       ; смещение JR, число пар внутренних байтов при левом отсечении
FillPairsJump:  JR FillPairsJump

                ; шестнадцать парных записей PUSH AF в экранную строку
                PUSH AF
                PUSH AF
                PUSH AF
                PUSH AF
                PUSH AF
                PUSH AF
                PUSH AF
                PUSH AF
                PUSH AF
                PUSH AF
                PUSH AF
                PUSH AF
                PUSH AF
                PUSH AF
                PUSH AF
                PUSH AF
                ; восстановление реального SP и вертикального направления
                LD A, (CircleState.DirectionDown)
                AND A
                LD SP, (CircleState.SavedSP)
                JR NZ, StepFillDown                                             ; переход, если направление вниз после быстрого заполнения

                CALL Game.Circles.StepCircleRowUp.Entry
                JR SweepLeftFill

StepFillDown:   CALL Game.Circles.StepCircleRowDown.Entry
                JR SweepLeftFill

                ; вход заливки с фиксированным правым краем
RightFixedFill: LD A, E
                AND #1F
                CP #20
                JR NC, EmptyRightFill                                           ; переход, если индекс столбца не меньше 32, при штатной маске#1F условие недостижимо

                LD A, (CircleState.DirectionDown)
                AND A
                JR NZ, RightBottom                                              ; переход, если направление вниз, проверить нижний предел
UpperLimit      EQU $ + 1                                                       ; верхний предел заполнения круга с правым отсечением
                LD A, #BF
                CP H
                JR C, RightFillStack                                            ; переход, если H выше#BF, строка допустима

                JR EmptyRightFill
LowerLimit      EQU $ + 1                                                       ; нижний предел заполнения круга с правым отсечением
RightBottom:    LD A, #CF
                CP H
                JR NC, RightFillStack                                           ; переход, если H не больше#CF, строка допустима

                ; возврат с удалением сохранённого AF
EmptyRightFill: POP AF
                RET

                ; сохранение реального SP для правой отсечённой заливки
RightFillStack: LD (CircleState.SavedSP), SP
                ; наложение левой маски и расчёт внутренней ширины
FillToRight:    LD D, L
                LD L, E
                LD A, (HL)
                OR B
                LD (HL), A
                LD A, D
                SUB E
                DEC A
                SRL A
                JR NC, FillRightCore                                            ; переход, если число внутренних байтов чётное, отдельный байт не требуется

                INC L
                LD (HL), #FF
                ; заполнение середины и переход к правой дуге
FillRightCore:  CALL Game.Extensions.FillBackwardAndCountDemo.Entry
                JR Game.Circles.PrintShipAndContinueRightFill.NextRightRow
                ; проверка исходного конца фрагмента
                ASSERT $ == #8D2B
                endmodule
                endmodule
