                module Charts
                module PixelAddressAndVerticalCrosshair
; -----------------------------------------
; Пиксельный адрес Spectrum и вертикальная часть перекрестия
; исходный диапазон #E621..#E6A2
; In:
;   BC, C = Y, AF, A = X для Game.Charts.PixelAddressAndVerticalCrosshair.Entry
; Out:
;   HL=Memory.Screen+((Y&192)<<5)+((Y&7)<<8)+((Y&56)<<2)+(X>>3)
; Corrupt:
;   HL, AF
; Note:
;   Сдвиги X завершаются AND31, Game.Charts.PixelAddressAndVerticalCrosshair.XorHighMask/Game.Charts.PixelAddressAndVerticalCrosshair.XorLowMask применяют крайние маски горизонтали, Game.Charts.PixelAddressAndVerticalCrosshair.DrawVertical обрезает
;   вертикаль по MapViewport.Top/MapViewport.Bottom и инвертирует один бит каждой строки, переход к следующей строке
;   использует Game.Charts.NextScreenCharacterRowAndRefugees.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E621
                ; адрес Spectrum собирается из трёх переставленных групп битов Y и X/8
Entry:          RRA
                RRA
                RRA
                AND #1F
                LD L, A
                LD A, C
                AND #38
                ADD A, A
                ADD A, A
                OR L
                LD L, A
                LD A, C
                AND #07
                OR #40
                LD H, A
                LD A, C
                AND #C0
                RRA
                RRA
                RRA
                AND #1F
                OR H
                LD H, A
                RET

XorHighMask:    LD A, (HL)
                XOR E
                LD (HL), A
                JR DrawVertical

XorLowMask:     LD A, (HL)
                XOR D
                LD (HL), A
                ; вертикаль обрезается по верхней и нижней границам текущего окна карты
DrawVertical:   LD A, (MapViewport.CrosshairSize)
                SRL A
                LD B, A
                LD A, (MapViewport.Top)
                LD C, A
                LD A, (MapCircleY)
                SUB B
                JR C, ClipTop                                                   ; переход, если верхняя часть вертикального перекрестия вышла за начало, обрезать её

                CP C
                JR C, ClipTop                                                   ; переход, если верхняя граница ниже допустимой границы окна, обрезать линию

                LD C, A
                LD A, (MapCircleX)
                CALL Game.Charts.PixelAddressAndVerticalCrosshair.Entry
                LD A, (MapViewport.Bottom)
                LD C, A
                LD A, (MapCircleY)
                ADD A, B
                SUB C
                LD C, A
                LD A, (MapViewport.CrosshairSize)
                JR C, VerticalCount                                             ; переход, если рассчитанный нижний край меньше допустимой границы, полная длина помещается

                SUB C
VerticalCount:  LD B, A
                JR PixelMask

ClipTop:        LD D, A
                LD A, C
                SUB D
                LD D, A
                LD A, (MapViewport.CrosshairSize)
                SUB D
                LD B, A
                LD A, (MapCircleX)
                CALL Game.Charts.PixelAddressAndVerticalCrosshair.Entry
                ; из X mod8 получается одиночная битовая маска для всех строк вертикали
PixelMask:      LD A, (MapCircleX)
                AND #07
                INC A
                LD C, A
                XOR A
                SCF
                RRA
                DEC C
                JR Z, MaskReady                                                 ; переход, если число сдвигов маски пикселя обнулилось, маска готова

ShiftMask:      SRL A
                DEC C
                JR NZ, ShiftMask                                                ; переход, если остались сдвиги до нужного бита пикселя, продолжить построение маски

MaskReady:      LD E, A
                ; XOR выбранного бита и переход к следующей растровой строке повторяются B раз
RasterRow:      LD A, (HL)
                XOR E
                LD (HL), A
                INC H
                LD A, H
                AND #07
                CALL Z, Game.Charts.NextScreenCharacterRowAndRefugees.Entry     ; вызов, если пересечена граница восьми строк растра, пересчитать символьную строку
                DJNZ RasterRow

                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #E6A3
                endmodule
                endmodule
