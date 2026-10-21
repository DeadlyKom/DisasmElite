                module Sound
                module StartHyperjumpNoise
; -----------------------------------------
; подготовка шумовых параметров гиперперехода
; исходный диапазон #96B7..#96C4
; In:
;   нет
; Out:
;   DE=#100A, BC=#C010 переданы общему входу Game.Sound.StartLaunchNoise.DisableIrq
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   после JR управление не возвращается в этот фрагмент
;   SoundRequest хранит номер текущего звукового запроса
;   ScannerState содержит координаты, индекс объекта и признак обновления сканера, исполнение проигрывателя до него не доходит
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #96B7
Entry:          LD BC, #C010
                LD DE, #100A
                JR @Game.Sound.StartLaunchNoise.DisableIrq

RequestIndex    DB #00                                                          ; номер выбранного звукового запроса, 0..7
ScanData        FScannerState {
                    #00,                                                        ; FScannerState.ScaledX, масштабированная X, знак в бите 7
                    #00,                                                        ; FScannerState.ScaledY, масштабированная высота Y, знак в бите 7
                    #00,                                                        ; FScannerState.ScaledZ, масштабированная глубина Z, знак в бите 7
                    #00,                                                        ; FScannerState.ObjectIndex, обратный номер обрабатываемого слота, 8..1
                    #00                                                         ; FScannerState.Redraw, флаг, фон сканера изменён и требует восстановления
                }

ScaledX         EQU ScanData.ScaledX                                            ; адрес поля FScannerState.ScaledX
ScaledY         EQU ScanData.ScaledY                                            ; адрес поля FScannerState.ScaledY
ScaledZ         EQU ScanData.ScaledZ                                            ; адрес поля FScannerState.ScaledZ
ObjectIndex     EQU ScanData.ObjectIndex                                        ; адрес поля FScannerState.ObjectIndex
Redraw          EQU ScanData.Redraw                                             ; адрес поля FScannerState.Redraw
                ; проверка исходного конца фрагмента
                ASSERT $ == #96C5
                endmodule
                endmodule
