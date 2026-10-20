                module Text
                module PrintRankWithMissionSuffix
; -----------------------------------------
; Печать боевого звания и дополнительных миссионных отметок
; исходный диапазон #D755..#D7A9
; In:
;   AF, A = токен рейтинга, D062 и D08F = состояние
; Out:
;   Строка звания завершена, при условиях добавлены токены F1/A0..A6/A5
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Дополнительный текст выводится при D08F!=0, старшем бите D062 и ненулевых битах 1..3,
;   D788..D7A9 содержит остаточные машинные фрагменты, они не исполняются после JP E2A9
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D755
                ; миссия 7 INVASION, вывод воинского звания и отметки отставки
                ; описание в Docs/Manual.md, раздел mission-7-invasion
                ; после боевого рейтинга условно печатаются воинское звание и отметка отставки
Entry:          CALL Game.Trade.PrintTokenNewline.Entry
                LD A, (State.Invasion)
                AND A
                JR Z, FinishLine                                                ; переход, если состояние вторжения нулевое, дополнительных военных званий нет

                LD A, (State.RankState)
                BIT RANK_WAR_BIT, A
                JR Z, FinishLine                                                ; переход, если старший бит кода военного статуса сброшен, воинское звание не выводится

                AND RANK_NUM_MASK
                JR Z, FinishLine                                                ; переход, если биты номера военного звания равны нулю, подпись звания отсутствует

                PUSH AF
                CALL Game.Text.PrintInlineToken.Entry
                DB #F1                                                          ; аргумент вызываемой процедуры из потока команд
                POP AF
                ; номер воинского звания переводится в токены второй таблицы A0..A6
                RRCA
                ADD A, #9F
                CALL Game.Text.PrintDescriptionToken.Entry
                LD A, (State.RankState)
                AND RANK_CODE_MASK
                CP RANK_COL_RSV
                JR Z, FinishLine                                                ; переход, если военный код без младшего бита равен C8, подпись отставки не нужна

                BIT RANK_RSV_BIT, A
                LD A, #A5
                CALL NZ, Game.Text.PrintDescriptionToken.Entry                  ; вызов, если установлен бит 6 военного статуса, допечатать отметку отставки
FinishLine:     JP Game.Trade.Newline.Entry
                ; остаточный машинный хвост после JP E2A9, последний LD усечён новым входом D7AA
                DB #28, #04, #DD, #21, #33, #D6, #AF, #32                       ; #D788..#D78F
                DB #1C, #71, #C9, #C0, #48, #C9, #48, #C9                       ; #D790..#D797
                DB #00, #C9, #2A, #29, #AA, #7E, #32, #28                       ; #D798..#D79F
                DB #AA, #F6, #01, #C9, #2A, #29, #AA, #23                       ; #D7A0..#D7A7
                DB #22, #29                                                     ; #D7A8..#D7A9
                ; проверка исходного конца фрагмента
                ASSERT $ == #D7AA
                endmodule
                endmodule
