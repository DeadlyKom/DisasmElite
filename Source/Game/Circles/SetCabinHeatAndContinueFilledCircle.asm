                module Circles
                module SetCabinHeatAndContinueFilledCircle
; -----------------------------------------
; сохранение нагрева и продолжения заливки круга
; исходный диапазон #8B3F..#8C28
; смысловое имя SetCabinHeatAndContinueFilledCircle
; In: для #8B3F H — рассчитанный нагрев, #7103 — специальный режим, для #8B4B — состояние дуги
; Out: #70EE=H либо 0, независимые входы рисуют заполненные строки
; Corrupt: первый вход AF, построители HL, DE, BC, AF, HL', DE', BC', AF'
; #8B4B продолжает круг без бокового отсечения, #8BF8 начинает левый отсечённый вариант
; Накопитель ошибки HL' увеличивается на 2*y+1 при изменении E' и на 2*x+1 при изменении C'
; Знак ошибки выбирает шаг по Y либо сужение горизонтальных краёв
; #8BD2 — изменяемый JR внутрь шестнадцати PUSH AF, AF=#FFFF, SP указывает в строку экрана
; После заполнения настоящий SP восстанавливается до вызова помощника перехода строки
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #8B3F
                ; проверка специального режима перед сохранением температуры
Entry:          LD A, (FlightState.SpaceMode)
                AND A
                LD A, H
                JR Z, StoreHeat                                                 ; переход, если специальный режим#7103 выключен, сохранить рассчитанный нагрев

                XOR A
StoreHeat:      LD (GaugeState + FGaugeState.CabinHeat.Current), A
                RET

                ; переход на следующую строку выбранного направления
NextArcRow:     JR NZ, StepArcDown                                              ; переход, если направление вниз, перейти к следующей строке

                CALL Game.Circles.StepCircleRowUp.Entry
                JR AddYError

StepArcDown:    CALL Game.Circles.StepCircleRowDown.Entry
                ; расчёт нового отклонения окружности, error += y+(y+1)
AddYError:      EXX
                ADD HL, DE
                INC E
                ADD HL, DE
                BIT 7, H
                EXX
                JR NZ, TestRowError                                             ; переход, если ошибка окружности отрицательна, проверить необходимость шага по X

                ; сужение левой и правой масок при переходе по X
                SRL B
                JR NC, CrossLeftByte                                            ; переход, если левая маска исчерпала байт, увеличить левый адрес

MoveRightMask:  SLA C
                JR NC, CrossRightByte                                           ; переход, если правая маска исчерпала байт, уменьшить правый адрес

                ; расчёт поправки error += x+(x+1) в альтернативных регистрах
AddXError:      EXX
                ADD HL, BC
                INC C
FinishXError:   ADD HL, BC
                BIT 7, H
                EXX
TestRowError:   JP NZ, Game.Circles.BeginFilledUnclippedHalf.FillEdgeRow        ; переход, если ошибка после шага X отрицательна, залить очередную строку

                JR SweepEdges

                ; переход левой маски в следующий байт строки
CrossLeftByte:  INC E
                LD A, L
                SUB E
                JR Z, FinishHalf                                                ; переход, если левый и правый адреса совпали, завершить половину

                LD B, #7F
                JR MoveRightMask

                ; переход правой маски в предыдущий байт строки
CrossRightByte: DEC L
                LD A, L
                SUB E
                JR Z, FinishHalf                                                ; переход, если правый и левый адреса совпали, завершить половину

                LD C, #FE
                JR AddXError

                ; восстановление реального SP и сохранённого AF
FinishHalf:     LD SP, (CircleState.SavedSP)
                POP AF
                RET

                ; переход левого края во время горизонтального прохода
SweepLeftByte:  INC E
                LD A, L
                SUB E
                JR Z, FinishHalf                                                ; переход, если края сошлись при горизонтальном проходе, завершить половину

                LD B, #7F
                JR SweepRightMask

                ; переход правого края во время горизонтального прохода
SweepRightByte: DEC L
                LD A, L
                SUB E
                JR Z, FinishHalf                                                ; переход, если края сошлись при горизонтальном проходе, завершить половину

                LD C, #FE
                JR SweepXError

                ; сужение контура без перехода на другую строку
SweepEdges:     SRL B
                JR NC, SweepLeftByte                                            ; переход, если левая маска перешла границу байта

SweepRightMask: SLA C
                JR NC, SweepRightByte                                           ; переход, если правая маска перешла границу байта

SweepXError:    EXX
                ADD HL, BC
                INC C
                JR Z, FinishHalf                                                ; переход, если C' обернулся в 0, горизонтальный радиус исчерпан

EndSweepError:  ADD HL, BC
                BIT 7, H
                EXX
                JR Z, SweepEdges                                                ; переход, если ошибка после шага X неотрицательна, продолжить сужение в этой строке

                EXX
                ADD HL, DE
                INC E
                ADD HL, DE
                EXX
                LD A, (HL)
                OR C
                LD (HL), A
                ; наложение граничных масок перед ускоренным заполнением середины
                LD D, L
                LD L, E
                LD A, (HL)
                OR B
                LD (HL), A
                LD A, D
                SUB E
                DEC A
                SRL A
                JR NC, SetFillPairs                                             ; переход, если число внутренних байтов чётное, нечётный байт не добавлять

                INC L
                LD (HL), #FF
                ; расчёт смещения JR по числу пар внутренних байтов
SetFillPairs:   LD L, D
                SUB #11
                CPL
                LD (CircleRaster.BothPairJump), A
                ; загрузка образца AF=#FFFF и переключение SP на строку
                LD SP, CircleFillWord
                POP AF
                LD SP, HL
                ; изменяемый переход, #8BD3 выбирает нужное число PUSH AF
PairJump        EQU $ + 1                                                       ; смещение JR, выбор числа пар байтов для заполнения через PUSH AF
FillPairsJump:  JR FillPairsJump

                ; шестнадцать команд PUSH AF, каждая записывает два байта#FF в строку
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
                ; восстановление реального SP перед продолжением дуги
                LD A, (CircleState.DirectionDown)
                AND A
                LD SP, (CircleState.SavedSP)
                JR NZ, StepFillDown                                             ; переход, если направление вниз после быстрого заполнения

                CALL Game.Circles.StepCircleRowUp.Entry
                JR SweepEdges

StepFillDown:   CALL Game.Circles.StepCircleRowDown.Entry
                JR SweepEdges

                ; вход заливки с фиксированным левым краем
LeftFixedFill:  LD A, L
                AND #1F
                CP #20
                JR NC, EmptyLeftFill                                            ; переход, если индекс столбца не меньше 32, ранний отказ, при штатной маске#1F условие недостижимо

                LD A, (CircleState.DirectionDown)
                AND A
                JR NZ, LeftFillBottom                                           ; переход, если направление вниз, проверить нижний предел
UpperLimit      EQU $ + 1                                                       ; верхний предел заполнения круга с левым отсечением
                LD A, #BF
                CP H
                JR C, LeftFillStack                                             ; переход, если H выше#BF, строка допустима

                JR EmptyLeftFill
LowerLimit      EQU $ + 1                                                       ; нижний предел заполнения круга с левым отсечением
LeftFillBottom: LD A, #CF
                CP H
                JR NC, LeftFillStack                                            ; переход, если H не больше#CF, строка допустима

                ; возврат с удалением сохранённого AF
EmptyLeftFill:  POP AF
                RET

                ; сохранение SP и наложение правой краевой маски
LeftFillStack:  LD (CircleState.SavedSP), SP
                ; расчёт длины заливки до фиксированного левого края
FillLeft:       LD A, (HL)
                OR C
                LD (HL), A
                LD D, L
                LD L, E
                LD A, D
                SUB E
                SRL A
                JR NC, FillLeftMiddle                                           ; переход, если число заполняемых байтов чётное, отдельный байт не требуется

                LD (HL), #FF
                ; заполнение внутренних байтов и переход к левой дуге
FillLeftMiddle: CALL Game.Extensions.FillBackwardAndCountDemo.Entry
                JR Game.Circles.SelectJumpAndContinueLeftFill.NextLeftRow
                ; проверка исходного конца фрагмента
                ASSERT $ == #8C29
                endmodule
                endmodule
