                module Charts
                module XorMapCrosshair
; -----------------------------------------
; Рисование горизонтальной и вертикальной частей перекрестия
; исходный диапазон #E52E..#E610
; In:
;   D051/D052 = центр, E52B = ширина, E52C/E52D = вертикальные границы
; Out:
;   Пиксели перекрестия инвертированы XOR
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Горизонталь разбивается на неполные крайние байты и целые FF, переходы обрабатывают
;   обрезание слева/справа, крайние биты рамки защищаются масками 7F/FE, хвост E647 строит
;   вертикальную часть с ограничением Y
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E52E
                ; горизонталь перекрестия обрезается слева и справа перед формированием краевых масок
Entry:          LD A, (MapViewport.CrosshairSize)
                SRL A
                LD B, A
                LD A, (MapCircleX)
                SUB B
                JR C, ClipLeft                                                  ; переход, если левая половина перекрестия выходит за нулевую координату X, обрезать её

                JR Z, ClipLeft                                                  ; переход, если левая граница перекрестия совпала с нулём, применить граничный путь

                LD D, A
                LD A, (MapCircleY)
                LD C, A
                LD A, D
                CALL Game.Charts.PixelAddressAndVerticalCrosshair.Entry
                LD A, (MapCircleX)
                ADD A, B
                JR C, ClipRight                                                 ; переход, если правая граница перекрестия вышла за 255, обрезать её

                AND #07
                JR NZ, FullSpan                                                 ; переход, если правая граница не выровнена по восьми пикселям, сохранить частичную маску

                LD A, #08
                ; вычисление маски неполного левого байта и числа полностью заполненных байтов
FullSpan:       LD E, A
                LD A, (MapViewport.CrosshairSize)
                SUB E
                LD C, A
                AND #07
                JR NZ, FirstMask                                                ; переход, если длина первого участка не кратна восьми, построить маску края

                LD D, #08
                LD A, C
                SUB D
                JR CountFullBytes

FirstMask:      LD D, A
                LD A, C
CountFullBytes: AND #F8
                JR Z, EdgePair                                                  ; переход, если между краями нет целых восьмипиксельных байтов, выводить только края

                RRA
                RRA
                RRA
                AND #1F
                JP DrawFullSpan

ClipLeft:       LD A, (MapCircleY)
                LD C, A
                XOR A
                CALL Game.Charts.PixelAddressAndVerticalCrosshair.Entry
                LD A, (MapCircleX)
                ADD A, B
                LD C, A
                AND #07
                JR NZ, LeftMask                                                 ; переход, если обрезанная ширина не кратна восьми, построить маску правого края

                LD E, #08
                LD A, C
                SUB E
                JR LeftFullBytes

LeftMask:       LD E, A
                LD A, C
LeftFullBytes:  AND #F8
                JR Z, LeftEdgeOnly                                              ; переход, если после левого обрезания нет полных байтов, выводить только край

                RRA
                RRA
                RRA
                AND #1F
                JP DrawLeftClip

ClipRight:      LD A, (MapCircleX)
                LD C, A
                XOR A
                SUB C
                ADD A, B
                LD C, A
                AND #07
                JR NZ, RightMask                                                ; переход, если ширина справа не кратна восьми, построить маску левого края

                LD D, #08
                LD A, C
                SUB D
                JR RightFullBytes

RightMask:      LD D, A
                LD A, C
RightFullBytes: AND #F8
                JR Z, RightEdgeOnly                                             ; переход, если после правого обрезания нет полных байтов, выводить только край

                RRA
                RRA
                RRA
                AND #1F
                JP DrawRightClip

EdgePair:       CALL Game.Charts.BuildHighBitRun.Entry
                CALL Game.Charts.BuildLowBitRun.Entry
                LD A, (HL)
                XOR D
                LD (HL), A
                INC HL
                JR LastEdge

LeftEdgeOnly:   CALL Game.Charts.BuildHighBitRun.Entry
                RES 7, E
                JR LastEdge

RightEdgeOnly:  CALL Game.Charts.BuildLowBitRun.Entry
                RES 0, D
                JP @Game.Charts.PixelAddressAndVerticalCrosshair.XorLowMask

DrawFullSpan:   LD B, A
                ; инверсия краёв и полных внутренних байтов сохраняет фон при повторном вызове
                CALL Game.Charts.BuildHighBitRun.Entry
                CALL Game.Charts.BuildLowBitRun.Entry
                LD A, (HL)
                XOR D
                LD (HL), A
                INC HL
FullByte:       LD A, (HL)
                XOR #FF
                LD (HL), A
                INC HL
                DJNZ FullByte

LastEdge:       JP @Game.Charts.PixelAddressAndVerticalCrosshair.XorHighMask

DrawLeftClip:   LD B, A
                CALL Game.Charts.BuildHighBitRun.Entry
                LD A, (HL)
                XOR #7F
                LD (HL), A
                INC HL
                DEC B
                JR Z, LastEdge                                                  ; переход, если счётчик полного байта обнулился, перейти к последнему краю линии

LeftClipByte:   LD A, (HL)
                XOR #FF
                LD (HL), A
                INC HL
                DJNZ LeftClipByte

                JR LastEdge

DrawRightClip:  LD B, A
                CALL Game.Charts.BuildLowBitRun.Entry
                LD A, (HL)
                XOR D
                LD (HL), A
                INC HL
                DEC B
                JR Z, RightBoundary                                             ; переход, если полные байты линии закончились, вывести конечную маску

RightClipByte:  LD A, (HL)
                XOR #FF
                LD (HL), A
                INC HL
                DJNZ RightClipByte

RightBoundary:  LD A, (HL)
                XOR #FE
                LD (HL), A
                JR @Game.Charts.PixelAddressAndVerticalCrosshair.DrawVertical
                ; проверка исходного конца фрагмента
                ASSERT $ == #E611
                endmodule
                endmodule
