                module Text
                module XorCharacterScanlines
; -----------------------------------------
; Наложение глифа по вертикальным строкам экрана
; исходный диапазон #D546..#D54E
; In:
;   HL = адрес экрана, DE = глиф, BC, B = число строк
; Out:
;   Байты глифа объединены с экраном XOR, H и DE увеличены на исходное B
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Байт Game.Text.XorCharacterScanlines.XorOpcode содержит XOR C, подмена на NOP превращает наложение в прямую запись, B=0 означает
;   256 итераций
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D546
                ; восемь строк глифа накладываются XOR, патч Game.Text.XorCharacterScanlines.XorOpcode=NOP переключает на перезапись
Entry:          LD A, (DE)
                LD C, (HL)
XorOpcode       XOR C                                                           ; XOR C либо NOP, способ переноса глифа на экран
                LD (HL), A
                INC H
                INC DE
                DJNZ Game.Text.XorCharacterScanlines.Entry

                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #D54F
                endmodule
                endmodule
