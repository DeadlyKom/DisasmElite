                module Flight
                module HandleMapCursorKeys
; -----------------------------------------
; Диспетчер клавиш карты при выключенном гиперпереходе
; исходный диапазон #71F3..#7221
; In:
;   FlightState.View вид 7/8, JumpMode=0, InputState.FlightKeys/InputState.ChartKeys маски клавиш
; Out:
;   выбран первый установленный бит, вызван индекс 9..15 диспетчера Game.Screen.DispatchMenu.Entry
; Corrupt:
;   HL, DE, BC, AF, IX, IY по выбранному обработчику
; Note:
;   Младшая тетрада InputState.FlightKeys объединяется с битами 4..6 InputState.ChartKeys, приоритет у младшего установленного бита
;   После действия обе маски очищаются,CloakDivider отдельный счётчик опроса маскировки
; -----------------------------------------
                ASSERT $ == #71F3
                ; проверка экранов карты 7/8 и отсутствия туннеля
Entry:          LD A, (FlightState.View)
                CP #07
                RET C                                                           ; выход, если номер вида меньше 7, курсор карты не обслуживается

                CP #09
                RET NC                                                          ; выход, если номер вида не равен 7 или 8, курсор карты не обслуживается

                LD A, (JumpMode)
                AND A
                RET NZ                                                          ; выход, если выполняется анимация перехода

                ; объединение масок и поиск младшего установленного бита клавиш
                LD A, (InputState.FlightKeys)
                AND FLY_DIR_MASK
                LD C, A
                LD A, (InputState.ChartKeys)
                AND CHART_KEY_MASK
                OR C
                RET Z                                                           ; выход, если ни одна клавиша карты не нажата

                LD B, #08
FindKeyBit:     INC B
                SRL A
                JR NC, FindKeyBit                                               ; переход, если очередной бит маски равен нулю, искать следующую команду

                ; вызов команды 9..16 и поглощение обеих масок курсора
                LD A, B
                CALL Game.Screen.DispatchMenu.Entry
                XOR A
                LD (InputState.ChartKeys), A
                LD (InputState.FlightKeys), A
                RET

                ; делитель проверки маскировки, после срабатывания загружается 2
CloakDivider    DB #01                                                          ; делитель проверки маскировки, после срабатывания загружается 2
                ASSERT $ == #7222
                endmodule
                endmodule
