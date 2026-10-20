                module Flight
                module DrawTitleCaption
; -----------------------------------------
; Печать подписи начального экрана в буфере вида
; исходный диапазон #7430..#7446
; In:
;   D0D5 адрес инструкции загрузки экранной базы
; Out:
;   подпись второй таблицы 7 выведена по X=4,Y=13
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Сначала 7447 печатает общий заголовок, bit7 в старшем байте адреса направляет символы в C000,
;   общий 7459 возвращает базу 4000
; -----------------------------------------
                ASSERT $ == #7430
                ; общий заголовок перед подписью вторичным токеном 7
Entry:          CALL Game.Flight.DrawDemoHeading.Entry
                LD HL, #0D04
                LD A, #07
                ; позиция подписи и временный выбор экранного буфера C000
PrintCaption:   LD (TextColumn), HL
                LD HL, (TextBasePatch)
                INC HL
                INC HL
                SET 7, (HL)
                CALL Game.Interface.DispatchDescriptionToken.Entry
                JR @Game.Flight.DrawDemoHeading.RestoreScreen
                ASSERT $ == #7447
                endmodule
                endmodule
