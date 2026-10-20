                module Extensions
                module DrawCompressedEdges
; -----------------------------------------
; вывод упакованных рёбер дополнительной модели
; исходный диапазон #6F41..#6FF1
; смысловое имя DrawCompressedEdges
; In: IX — объект, IY — 23-байтовый заголовок, (#A9B8) — уровень детализации
; Out: видимые линии добавлены в экранный буфер, IX восстановлен
; Corrupt: HL, DE, BC, AF, #AA0F, #AA1E, счётчик в операнде #6F42
; IY+0E/0F задаёт смещение блока рёбер, IY+04 — количество обрабатываемых записей
; Первые два слова блока задают указатели потока порогов и упакованных пар вершин
; Бит 5 потока различает новую группу повторов, младшие пять бит задают порог видимости
; #AA10 проверяет грань, #AE50 получает две проекции, #B044 выполняет отсечение и вывод
; На специальных кадрах #AA1E временно получает XOR B (#A8), на выходе возвращается OR B (#B0)
; EX (SP),IX меняет объект на заголовок модели, ADD IX,DE выбирает блок рёбер
; До цикла IX+0..3 читаются как два указателя, в цикле IX продвигается по потоку граней
; IX+4 задаёт текущие грани, IX+5 проверяет следующий байт, FF удерживает указатель
; POP IX восстанавливает основной объект
; -----------------------------------------
                ; смещения описывают исходные данные, память не выделяется
ThresholdPtr:   EQU 0                                                           ; первое слово блока, адрес потока порогов, читается до продвижения IX
VertexPtr:      EQU 2                                                           ; второе слово блока, адрес упакованных пар вершин, читается до продвижения IX
FaceStream:     EQU 4                                                           ; поток граней после двух слов, в цикле IX уже содержит смещение текущей записи

                ; проверка исходного начала фрагмента
                ASSERT $ == #6F41
                ; расчёт следующего кадра и временной логической операции проверки граней
FrameCounter    EQU $ + 1                                                       ; операнд счётчика, оборачивается через 256 вызовов
Entry:          LD A, #FF
                INC A
                LD (FrameCounter), A
                JR Z, ReadEdgeBlock                                             ; переход, если счётчик кадров обернулся в ноль, сохранить обычную проверку граней

                LD A, (ProjectionState.Depth)
                CP #08
                JR C, ReadEdgeBlock                                             ; переход, если детализация меньше 8, сохранить обычную проверку граней

                LD A, (IX+FSpaceObject.Flags2)
                AND A
                JR NZ, ReadEdgeBlock                                            ; переход, если дополнительные флаги Flags2 ненулевые, сохранить обычную проверку граней

                LD A, #A8
                LD (VertexRaster.FaceCombine), A
                ; получение относительного блока рёбер из заголовка модели
ReadEdgeBlock:  LD E, (IY+FModel.Edges)
                LD D, (IY+FModel.Edges+1)
                LD B, (IY+FModel.EdgeCount)
                LD C, #01
                PUSH IY
                EX (SP), IX
                ADD IX, DE
                LD L, (IX+ThresholdPtr)
                LD H, (IX+ThresholdPtr+1)
                LD E, (IX+VertexPtr)
                LD D, (IX+VertexPtr+1)
                ; проверка маркера новой группы и счётчика повторов порога
ReadEdgeGroup:  LD A, (HL)
                BIT EDGE_DIRECT_BIT, A
                JR NZ, UseThreshold                                             ; переход, если бит 5 записи установлен, использовать текущую группу

                LD C, A
                INC HL
                LD A, (HL)
UseThreshold:   LD (VertexFlags.Current), A
                AND EDGE_LOD_MASK
                DEC C
                JR NZ, TestEdge                                                 ; переход, если в группе остались рёбра, не сдвигать поток порогов

                INC C
                INC HL
                ; сохранение текущих потоков перед проверками ребра
TestEdge:       PUSH BC
                PUSH DE
                PUSH HL
                CP EDGE_LOD_MASK
                JR Z, TestFace                                                  ; переход, если порог равен 31, проверка расстояния не нужна

                ; проверка порога детализации, значение 31 означает отсутствие ограничения
                LD B, A
                LD A, (ProjectionState.Depth)
                CP B
                JR NC, NextEdge                                                 ; переход, если детализация не меньше порога ребра, пропустить ребро

                ; проверка видимости грани перед вычислением двух концов
TestFace:       LD A, (IX+FaceStream)
                CALL Game.Wireframe.AnyPackedFaceVisible.Entry
                JR Z, NextEdge                                                  ; переход, если грань невидима, пропустить ребро

                ; извлечение пятибитного номера первой вершины из упакованной пары
                LD HL, VertexFlags.Current
                RL (HL)
                LD A, (DE)
                RRA
                RL (HL)
                LD (HL), A
                LD A, (DE)
                JR NC, LowVertex                                                ; переход, если добавочный бит номера вершины нулевой, использовать младшую тетраду

                AND #0F
                ADD A, #10
                JR ProjectFirst

LowVertex:      AND #0F
                ; получение первой экранной вершины и проверка её допустимости
ProjectFirst:   CALL Game.Wireframe.ReadProjectedVertex.Entry
                JR NZ, NextEdge                                                 ; переход, если первая вершина не имеет допустимой проекции, пропустить ребро

                LD C, A
                ; извлечение и проекция второй вершины
                PUSH DE
                LD A, (VertexFlags.Current)
                RRCA
                RRCA
                RRCA
                AND #1F
                CALL Game.Wireframe.ReadProjectedVertex.Entry
                EX DE, HL
                POP DE
                JR NZ, NextEdge                                                 ; переход, если вторая вершина не имеет допустимой проекции, пропустить ребро

                ; упаковка признаков концов для общего отсекателя линий
                RRCA
                RRA
                RL C
                RLA
                RL C
                CALL Game.Wireframe.DrawClippedLine.Entry
                ; восстановление потоков и переход к следующему ребру
NextEdge:       POP HL
                POP DE
                POP BC
                INC DE
                LD A, (IX+FaceStream+1)
                INC A
                JR Z, CountEdge                                                 ; переход, если байт признака равен #FF, не сдвигать указатель признаков

                INC IX
CountEdge:      DJNZ ReadEdgeGroup

                POP IX
                ; восстановление указателя объекта и штатной операции OR B
                LD A, #B0
                LD (VertexRaster.FaceCombine), A
                RET
FlagsStream     DW #023C                                                        ; текущий указатель потока признаков граней и вершин
                ; сохранённое дополнение после указателя, обращений к этим пяти байтам не найдено
                DB #00, #00, #00, #00, #00                                      ; исходные байты #6FED..#6FF1
                ; проверка исходного конца фрагмента
                ASSERT $ == #6FF2
                endmodule
                endmodule
