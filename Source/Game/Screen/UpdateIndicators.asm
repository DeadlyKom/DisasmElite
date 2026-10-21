                module Screen
                module UpdateIndicators
; -----------------------------------------
; перерисовка только изменившихся полос приборной панели
; In:
;   пары прежнего и нового значений от GaugeState + FGaugeState.FrontShield, таблица адресов GaugeAddresses
; Out:
;   13 индикаторов синхронизированы, сохранённые прежние значения обновлены
; Corrupt:
;   HL, DE, BC, AF, BC'
; Note:
;   11 обычных величин делятся на четыре перед выводом
;   затем 2 величины выводятся в отдельном режиме с IndicatorDraw=1
;   DE перебирает двухбайтные экранные адреса, HL пары прежнего и текущего значений
;   при совпадении значений рисование пропускается
;   IndicatorDraw.MarkerMode содержит режим, GaugeAddresses содержит таблицу экранных адресов
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #84D9
                ; обновление одиннадцати обычных полос по изменению значения
Entry:          LD DE, GaugeAddresses
                EXX
                LD C, #0B
                EXX
                LD HL, GaugeState + FGaugeState.FrontShield.Current
OrdinaryGauge:  LD A, (HL)
                DEC HL
                CP (HL)
                JR Z, NextOrdinary                                              ; переход, если значение обычного индикатора не изменилось

                LD (HL), A
                SRL A
                SRL A
                PUSH HL
                PUSH DE
                CALL Game.Screen.DrawIndicatorBar.Entry
                POP DE
                POP HL
NextOrdinary:   INC DE
                INC DE
                INC HL
                INC HL
                INC HL
                EXX
                DEC C
                EXX
                JR NZ, OrdinaryGauge                                            ; переход, если остались обычные индикаторы

                ; переключение к двум индикаторам второго режима
                LD A, #01
                LD (IndicatorDraw.MarkerMode), A
                EXX
                LD C, #02
                EXX
SpecialGauge:   LD A, (HL)
                DEC HL
                CP (HL)
                JR Z, NextSpecial                                               ; переход, если значение индикатора второго режима не изменилось

                LD (HL), A
                PUSH HL
                PUSH DE
                CALL Game.Screen.DrawIndicatorMarker.Entry
                POP DE
                POP HL
NextSpecial:    INC DE
                INC DE
                INC HL
                INC HL
                INC HL
                EXX
                DEC C
                EXX
                JR NZ, SpecialGauge                                             ; переход, если остался второй индикатор

                ; сброс режима после окончания обновления
                XOR A
                LD (IndicatorDraw.MarkerMode), A
                RET

IndicatorData   EQU $                                                           ; начало сохранённых рабочих данных, исходное размещение
.MarkerMode     DB #00                                                          ; режим прибора, 0 полоса, 1 подвижный маркер
.Addresses      DW #5123, #5143, #5163, #5183, #51A3, #51C3, #5138, #5198       ; экранные адреса шкал, UpdateIndicators использует первые 13 слов
                DW #51B8, #51D8, #51F8, #5158, #5178, #51E3                     ; продолжение сохранённых байтов
                ASSERT $ == #8540
                endmodule
                endmodule
