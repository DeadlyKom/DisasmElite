                module Universe
                module SelectSpecialCargoText
; -----------------------------------------
; выбор варианта текста специального груза
; исходный диапазон #7A27..#7A58
; In:
;   память State.Invasion, состояние
;   память State.RankState, старший байт рейтинга
; Out:
;   AF, A равен #0C при State.Invasion<2 или State.RankState<#84, иначе #BC
; Corrupt:
;   нет дополнительных регистров
; Note:
; Используется списком груза Game.Extensions.PrintCargoAndMessageBanks.Entry. Блок StarPoints после RET хранит 16 звёзд по два байта.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #7A27
                ; проверка условий расширенного названия груза
                ; миссии 1, 7+1, 7+3, военное состояние выбирает текст беженцев либо десанта
                ; описание в Docs/Manual.md, раздел mission-1, mission-7-1, mission-7-3
Entry:          LD A, (State.Invasion)
                CP INV_ACTIVE_MIN
                JR C, SelectToken                                               ; переход, если состояние State.Invasion меньше 2

                LD A, (State.RankState)
                CP RANK_CAPT_CODE
SelectToken:    LD A, #0C
                RET C                                                           ; выход, если состояние либо старший рейтинг ниже соответствующего порога

                LD A, #BC
                RET

                ; данные шестнадцати звёзд, знако-модульные пары координат
StarPoints      DB #00, #00, #00, #00, #00, #00, #00, #00                       ; 16 пар знако-модульных координат звёзд
                DB #00, #00, #00, #00, #00, #00, #00, #00
                DB #00, #00, #00, #00, #00, #00, #00, #00
                DB #00, #00, #00, #00, #00, #00, #00, #00
                ; проверка исходного конца фрагмента
                ASSERT $ == #7A59
                endmodule
                endmodule
