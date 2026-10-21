                module Universe
                module AddSignedStarCoordinate
; -----------------------------------------
; прибавление знако-модульного смещения к координате звезды
; исходный диапазон #7A59..#7A9D
; In:
;   HL, адрес знако-модульного байта
;   AF, A содержит смещение
; Out:
;   BC, исходное значение
;   байт координаты обновлён
; Corrupt:
;   AF
; Note:
; При равных знаках складывает модули, при разных вычитает и выбирает знак большего.
; Выход суммы за 7 бит даёт модуль 0 через SBC A,A с уже сброшенным переносом от ADD, не насыщение.
; ToggleScanner содержит отдельный обработчик переключения проекции сканера
; Он меняет ScannerRaster.Mode через XOR90 и атрибут ScannerRaster.BackdropMode через XOR7, затем при виде<4 задаёт ScannerState.Redraw=1.
; Текущий основной поток после RET в этот переключатель не попадает.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #7A59
                ; проверка знаков перед обновлением координаты звезды
Entry:          PUSH BC
                LD B, A
                XOR (HL)
                RLCA
                LD A, B
                JR C, SubMagnitudes                                             ; переход, если знаки координаты и смещения различаются

                AND #7F
                LD C, A
                LD A, (HL)
                AND #7F
                ADD A, C
                BIT 7, A
                JR Z, StoreSigned                                               ; переход, если сумма модулей помещается в семь бит

                SBC A, A
StoreSigned:    LD C, A
                LD A, B
                AND #80
                OR C
                LD (HL), A
                POP BC
                RET

                ; расчёт разности модулей и выбор знака
SubMagnitudes:  AND #7F
                LD C, A
                LD A, (HL)
                AND #7F
                SUB C
                JR NC, KeepSign                                                 ; переход, если модуль координаты не меньше смещения

                NEG
                JR StoreSigned

KeepSign:       LD B, (HL)
                JR StoreSigned

                ; действующий обработчик клавиши L меню паузы

; -----------------------------------------
; переключение обычного и альтернативного режимов сканера из меню паузы
; In:
;   состояние самомодифицируемых байтов ScannerRaster.Mode и ScannerRaster.BackdropMode
; Out:
;   режим сканера переключён, при виде полёта ScannerState.Redraw=1
; Corrupt:
;   HL, AF
; Note:
;   действующий вызов Game.Flight.IndexPauseCommandAndHandlers.ToggleScanner, обработчик клавиши L второй таблицы команд после PauseKeyMap
;   XOR #90 заменяет AND A (#A7) по ScannerRaster.Mode на SCF (#37) и обратно
;   SCF разрешает переход JP C,Game.Wireframe.DivideSlopeAndDrawScanner.DrawMarker к альтернативной проекции
;   XOR #07 переключает операнд LD A,#07 по Game.Wireframe.RefreshScannerBackground.Entry между 7 и 0
;   флаг ScannerState.Redraw запрашивает обновление сканера при режиме экрана меньше 4
; -----------------------------------------
ToggleScanner:  ; переключение обычного и альтернативного режимов сканера из меню паузы
                ; переключение машинной команды проверки и режима фоновой отрисовки
                LD HL, ScannerRaster.Mode
                LD A, (HL)
                XOR #90
                LD (HL), A
                LD HL, ScannerRaster.BackdropMode
                LD A, (HL)
                XOR #07
                LD (HL), A
                ; проверка необходимости обновить приборы в текущем виде
                LD A, (FlightState.View)
                CP #04
                RET NC                                                          ; выход, если открыт информационный экран с номером от 4

                LD A, #01
                LD (Game.Sound.StartHyperjumpNoise.Redraw), A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #7A9E
                endmodule
                endmodule
