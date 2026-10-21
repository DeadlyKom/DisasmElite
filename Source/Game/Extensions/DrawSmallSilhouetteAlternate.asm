                module Extensions
                module DrawSmallSilhouetteAlternate
; -----------------------------------------
; перекрывающийся вход выбора альтернативного профиля
; исходный диапазон #FB31..#FB31
; смысловое имя DrawSmallSilhouetteAlternate
; In: CircleState.OffsetY, OffsetX, Flags и Radius задают силуэт
; Out: A=#AF перед общей частью Game.Extensions.DrawSmallSilhouette.Entry после XOR A
; Corrupt: по контракту общего рендера Game.Extensions.DrawSmallSilhouette.Entry
; Байт #3E вместе с первым байтом следующего файла #AF образует LD A,#AF
; Вход Game.Extensions.DrawSmallSilhouette.Entry трактует тот же #AF как XOR A, поэтому объединять или выравнивать входы нельзя
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #FB31
                ; первый байт перекрывающейся инструкции LD A,#AF
                ; префикс LD A,n, операнд #AF находится в следующем файле
Entry:          DB #3E                                                          ; данные #FB31..#FB31
                ; проверка исходного конца фрагмента
                ASSERT $ == #FB32
                endmodule
                endmodule
