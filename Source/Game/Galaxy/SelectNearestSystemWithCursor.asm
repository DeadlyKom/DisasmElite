                module Galaxy
                module SelectNearestSystemWithCursor
; -----------------------------------------
; Выбор ближайшей системы с удалением и возвратом XOR-курсора
; исходный диапазон #DF60..#DF73
; In:
;   70E3 = экран, D0BB/D0BC = точка поиска
; Out:
;   Выбранная планета и её расстояние обновлены
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Для экранов 7/8 обрамляет DF74 двумя вызовами XOR-рисования курсора, для остальных переходит
;   непосредственно DF74
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DF60
                ; в режимах карт прежнее перекрестие стирается XOR перед выбором новой цели
Entry:          LD A, (FlightState.View)
                CP #07
                JR C, Game.Galaxy.FindNearestSystem.Entry                       ; переход, если номер экрана меньше 7, курсор карты стирать не требуется

                CP #09
                JR NC, Game.Galaxy.FindNearestSystem.Entry                      ; переход, если номер экрана не меньше 9, курсор карты стирать не требуется

                CALL Game.Charts.MapCursorTransformAndKeys.Entry
                CALL Game.Galaxy.FindNearestSystem.Entry
                JP Game.Charts.MapCursorTransformAndKeys.Entry
                ; проверка исходного конца фрагмента
                ASSERT $ == #DF74
                endmodule
                endmodule
