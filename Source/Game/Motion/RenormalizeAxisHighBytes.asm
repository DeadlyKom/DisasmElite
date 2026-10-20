                module Motion
                module RenormalizeAxisHighBytes
; -----------------------------------------
; коррекция длины оси по старшим байтам её компонент
; исходный диапазон #9F41..#9F67
; In:
;   IX, адрес трёх слов оси
; Out:
;   IX, адрес за вектором, старшие байты компонент обновлены
; Corrupt:
;   HL, DE, BC, AF
; Note:
; Обрабатываются байты IX+1,+3,+5, младшие байты не меняются.
; Коэффициент коррекции строится из суммы табличных квадратов удвоенных модулей.
; Это приближённое устранение накопленной ошибки вращения.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9F41
                ; расчёт суммы квадратов старших байтов компонент
Entry:          LD H, #BF
                LD L, (IX + FAxis.X + FSignWord.SignHigh)
                SLA L
                LD A, (HL)
                LD L, (IX + FAxis.Y + FSignWord.SignHigh)
                SLA L
                ADD A, (HL)
                LD L, (IX + FAxis.Z + FSignWord.SignHigh)
                SLA L
                ADD A, (HL)
                SRA A
                SRA A
                ; расчёт коэффициента коррекции для трёх компонент
                NEG
                XOR #80
                LD B, A
                CALL Game.Motion.ScaleAxisHighByte.Entry
                CALL Game.Motion.ScaleAxisHighByte.Entry
                CALL Game.Motion.ScaleAxisHighByte.Entry
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #9F68
                endmodule
                endmodule
