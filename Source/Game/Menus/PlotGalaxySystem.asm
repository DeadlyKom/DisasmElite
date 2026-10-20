                module Menus
                module PlotGalaxySystem
; -----------------------------------------
; Вывод одной точки на общей карте галактики
; исходный диапазон #EC14..#EC3A
; In:
;   DEC1 = Y семени, DEC3 = X семени
; Out:
;   Соответствующий пиксель инвертирован
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Координаты передаются ROM22AA как B=24+(127-(DEC1>>1)), C=DEC3, результат A задаёт номер
;   бита в самомодифицируемой инструкции SET по EC36, запись выполняет XOR
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #EC14
                ; координаты системы переводятся в одну точку общей карты с XOR-наложением
Entry:          LD A, (GalaxyState.WorkingSeed + FSystemSeed.Y)
                SRL A
                XOR #7F
                ADD A, #18
                LD B, A
                LD A, (GalaxyState.WorkingSeed + FSystemSeed.X)
                LD C, A
                CALL Rom.PlotAddress
                XOR #07
                SLA A
                SLA A
                SLA A
                OR #C0
                LD DE, GalaxyDotMask
                LD (DE), A
                LD B, #00
PixelMask       EQU $ + 1                                                       ; второй байт SET n,B, номер пиксельного бита задаётся результатом ROM
                SET 1, B
                LD A, (HL)
                XOR B
                LD (HL), A
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #EC3B
                endmodule
                endmodule
