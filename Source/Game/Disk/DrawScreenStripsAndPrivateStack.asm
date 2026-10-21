                module Disk
                module DrawScreenStripsAndPrivateStack
; -----------------------------------------
; Копирование полос экрана и альтернативный стек сортировки
; исходный диапазон #DA2F..#DA79
; In:
;   Параметры для входа Game.Disk.DrawScreenStripsAndPrivateStack.Entry не требуются
; Out:
;   Две полосы скопированы, байт Game.Screen.SwapAndSkipRow.NextRowCall восстановлен в CD
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Временно меняет CALL на JP в Game.Screen.SwapAndSkipRow.NextRowCall, копирует 6 строк Memory.Screen + #0140→Memory.Screen + #0520 и 4 строки Memory.Screen + #10E0→Memory.Screen + #0340
;   DrawStrips отдельно вызывает Game.Objects.SelectObjectAction.Entry на SP=Memory.Screen + #0020 с DI/EI
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DA2F
                ; копирование полос обзорного экрана и возврат прежнего указателя стека
Entry:          LD HL, Game.Screen.SwapAndSkipRow.NextRowCall
                LD (HL), #C3
                PUSH HL
                LD HL, Memory.Screen + #0140                                    ; начало исходной полосы из шести строк
                LD DE, Memory.Screen + #0520                                    ; начало назначения первой полосы
                LD B, #06
                CALL Game.Screen.CopyAlternateRows.Entry
                LD HL, Memory.Screen + #10E0                                    ; начало исходной полосы из четырёх строк
                LD DE, Memory.Screen + #0340                                    ; начало назначения второй полосы
                LD B, #04
                CALL Game.Screen.CopyAlternateRows.Entry
                POP HL
                LD (HL), #CD
                JP Game.Flight.DispatchDangerIndicator.Entry

DrawStrips:     LD C, A
                SRL C
                LD (ScreenStack), SP
                DI
                LD SP, Memory.Screen + #0020                                    ; временный стек в начале экранной памяти, исходный SP сохранён
                CALL Game.Objects.SelectObjectAction.Entry
SavedSP         EQU $ + 1                                                       ; сохранённый SP в операнде восстановления стека после вывода
                LD SP, #0000
                EI
                RET

                ; сохранённая рабочая область между стековым обработчиком и состоянием сообщений
                DB #00, #00, #00, #00, #00, #00, #00, #00                       ; #DA64..#DA6B
                DB #00, #00                                                     ; #DA6C..#DA6D
                ; четыре исходных байта FF, область состояния сообщений
                DB #FF, #FF                                                     ; продолжение данных #DA6E..#DA6F
SaveSelection   DB #FF                                                          ; индекс выбранного командира в дисковом меню
SavePageStart   DB #FF                                                          ; индекс первого командира отображаемой страницы
                ; состояние показа текущего полётного сообщения
MessageData     FFlightMessage {
                    #00,                                                        ; FFlightMessage.RepeatTimer, таймер повторного предупреждения
                    #00,                                                        ; FFlightMessage.Frames, оставшееся время показа сообщения
                    #00,                                                        ; FFlightMessage.QueuePhase, фаза чередования очереди и фоновых сообщений
                    #00,                                                        ; FFlightMessage.Column, столбец текущего сообщения
                    #00,                                                        ; FFlightMessage.Token, токен текущего сообщения
                    #0000,                                                      ; FFlightMessage.Reward, денежная награда для сообщения о премии
                    #F5                                                         ; FFlightMessage.DamagedItem, код повреждённого оборудования
                }
                ASSERT $ - MessageData == FFlightMessage

                ; прежние имена указывают на поля экземпляра MessageData
RepeatTimer     EQU MessageData.RepeatTimer                                     ; поле FFlightMessage.RepeatTimer
Frames          EQU MessageData.Frames                                          ; поле FFlightMessage.Frames
QueuePhase      EQU MessageData.QueuePhase                                      ; поле FFlightMessage.QueuePhase
Column          EQU MessageData.Column                                          ; поле FFlightMessage.Column
Token           EQU MessageData.Token                                           ; поле FFlightMessage.Token
Reward          EQU MessageData.Reward                                          ; поле FFlightMessage.Reward
DamagedItem     EQU MessageData.DamagedItem                                     ; поле FFlightMessage.DamagedItem
                ; проверка исходного конца фрагмента
                ASSERT $ == #DA7A
                endmodule
                endmodule
