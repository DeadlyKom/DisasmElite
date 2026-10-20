                module Circles
                module PrintShipAndContinueRightFill
; -----------------------------------------
; печать названия улучшенного корабля и продолжение правой заливки
; исходный диапазон #8D38..#8DED
; смысловое имя PrintUpgradedShipNameAndContinueRightFill
; In: для #8D38 поле #D08E, для #8D4C состояние правой отсечённой дуги
; Out: при улучшении печатается токен#F9, курсор переводится на строку 4
; Corrupt: HL, DE, BC, AF, построитель также HL', DE', BC', AF'
; Токен #F9 через основной банк обозначает Cobra Mk4
; Независимый #8D4C продолжает заливку с фиксированным правым краем
; #8DC8 — изменяемый переход в шестнадцать PUSH AF, #8DC9 — смещение
; После серии записей #8DDA восстанавливает SP и выбирает следующую экранную строку
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #8D38
                ; подготовка курсора и проверка установленного улучшения
Entry:          LD HL, #0306
                LD (TextColumn), HL
                LD A, (State.ShipUpgrade)
                AND A
                LD A, #F9
                CALL NZ, Game.Text.PrintMainToken.Entry                         ; вызов, если улучшение#D08E установлено, напечатать название Cobra Mk4
                LD A, #04
                JP Game.Trade.SetTextRow.Entry

                ; продолжение правой отсечённой заливки, шаг по строке
NextRightRow:   JR NZ, RightRowDown                                             ; переход, если направление вниз, перейти на следующую строку

                CALL Game.Circles.StepCircleRowUp.Entry
                JR AddRightYError

RightRowDown:   CALL Game.Circles.StepCircleRowDown.Entry
                ; расчёт ошибки после увеличения Y
AddRightYError: EXX
                ADD HL, DE
                INC E
                ADD HL, DE
                BIT 7, H
                EXX
                JR NZ, TestRightError                                           ; переход, если ошибка окружности отрицательна, проверить шаг по X

                ; сужение левой подвижной маски
                SRL B
                JR NC, CrossLeftByte                                            ; переход, если левая маска исчерпала байт, увеличить левый адрес

                ; расчёт шага X с проверкой ограничителя A'
AddRightXError: EXX
                ADD HL, BC
                INC C
                EX AF, AF'
                CP C
                JR Z, JoinBothArc                                               ; переход, если C' достиг ограничителя A', перейти к общему двухкраевому циклу

                EX AF, AF'
                ADD HL, BC
                BIT 7, H
                EXX
TestRightError: JP NZ, Game.Circles.SelectJumpAndContinueLeftFill.FillToRight   ; переход, если ошибка после шага X отрицательна, залить очередную строку

                JR SweepRightFill

                ; увеличение левого адреса после исчерпания маски
CrossLeftByte:  INC E
                LD A, L
                SUB E
                JR Z, FinishRight                                               ; переход, если левый и фиксированный правый адреса совпали, завершить половину

                LD B, #7F
                JR AddRightXError

                ; снятие бокового отсечения для общего двухкраевого цикла
JoinBothArc:    EX AF, AF'
                JP Game.Circles.SetCabinHeatAndContinueFilledCircle.FinishXError

JoinBothSweep:  EX AF, AF'
                JP Game.Circles.SetCabinHeatAndContinueFilledCircle.EndSweepError

                ; выход с восстановлением SP и сохранённого AF
FinishRight:    LD SP, (CircleState.SavedSP)
                POP AF
                RET

                ; переход левого края в следующий байт
SweepLeftByte:  INC E
                LD A, L
                SUB E
                JR Z, FinishRight                                               ; переход, если левый и фиксированный правый адреса совпали, завершить половину

                LD B, #7F
                JR RightSweepErr

                ; горизонтальный проход правой отсечённой заливки
SweepRightFill: SRL B
                JR NC, SweepLeftByte                                            ; переход, если левая маска перешла границу байта

RightSweepErr:  EXX
                ADD HL, BC
                INC C
                JR Z, FinishRight                                               ; переход, если C' обернулся в 0, половина закончилась

                EX AF, AF'
                CP C
                JR Z, JoinBothSweep                                             ; переход, если C' достиг ограничителя A', перейти в общий горизонтальный цикл

                EX AF, AF'
                ADD HL, BC
                BIT 7, H
                EXX
                JR Z, SweepRightFill                                            ; переход, если ошибка неотрицательна, продолжить сужение в этой строке

                ; расчёт ошибки следующей строки и наложение левой маски
                EXX
                ADD HL, DE
                INC E
                ADD HL, DE
                EXX
                LD D, L
                LD L, E
                LD A, (HL)
                OR B
                LD (HL), A
                LD A, D
                SUB E
                DEC A
                SRL A
                JR NC, SetFillPairs                                             ; переход, если число внутренних байтов чётное, отдельный байт не требуется

                INC L
                LD (HL), #FF
                ; расчёт числа пар и смещения входа в серию PUSH AF
SetFillPairs:   LD L, D
                SUB #11
                CPL
                LD (CircleRaster.RightPairJump), A
                LD SP, CircleFillWord
                POP AF
                LD SP, HL
                ; изменяемый переход в шестнадцать парных записей
PairJump        EQU $ + 1                                                       ; смещение JR, число пар внутренних байтов при правом отсечении
FillPairsJump:  JR FillPairsJump

                ; парные записи через временный экранный SP
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
                ; восстановление реального SP и переход к следующей строке
                LD A, (CircleState.DirectionDown)
                AND A
                LD SP, (CircleState.SavedSP)
                JR NZ, StepFillDown                                             ; переход, если направление вниз после быстрого заполнения

                CALL Game.Circles.StepCircleRowUp.Entry
                JR SweepRightFill

StepFillDown:   CALL Game.Circles.StepCircleRowDown.Entry
                JR SweepRightFill
                ; проверка исходного конца фрагмента
                ASSERT $ == #8DEE
                endmodule
                endmodule
