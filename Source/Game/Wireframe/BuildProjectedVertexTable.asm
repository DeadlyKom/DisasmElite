                module Wireframe
                module BuildProjectedVertexTable
; -----------------------------------------
; обход вершин с отбором по детализации и признакам граней
; исходный диапазон #A9C9..#AA0F
; In:
;   IX, объект
;   IY, модель
;   память ProjectionState.Depth/ProjectionState.VertexOffset, детализация и начальное смещение -3
; Out:
;   IX, исходный объект
;   IY, исходная модель
;   таблица ProjectedVerts содержит проекции обработанных вершин
; Corrupt:
;   HL, DE, BC, AF
; Note:
; Поток признаков отделён от потока модулей координат. Бит 0 признака требует новую тройку модулей.
; Младшие пять бит задают порог детализации, #1F обходит сравнение.
; SelectVertex использует Z, оставшийся от сравнения детализации либо проверки граней.
; При уровне строго больше порога выполняется проекция, при равенстве вершина пропускается.
; При уровне меньше порога или пороге #1F проверяются пары граней.
; Ненулевая первая пара сразу разрешает проекцию, иначе её определяет вторая пара.
; VertexFlags/VertexFlags.Current хранят предыдущие и текущие признаки, начальные F2/AD являются данными.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #A9C9
                ; поиск потоков признаков и модулей координат
Entry:          PUSH IY
                PUSH IY
                LD A, (IY + FModel.VertexCount)
                EX (SP), IX
                LD D, (IY + FModel.Vertices + FSignWord.SignHigh)
                CALL Game.Wireframe.LocateVertexCoordinateData.Entry
                ADD IX, DE
                LD IY, ObjectMatrix
                ; начало итерации и расчёт экранного смещения
ProjectVertex:  PUSH AF
                LD A, (ProjectionState.VertexOffset)
                ADD A, #03
                LD (ProjectionState.VertexOffset), A
                CALL Game.Wireframe.SavePreviousVertexFlags.Entry
                AND #1F
                CP #1F
                JR Z, CheckFaces                                                ; переход, если порог вершины равен #1F и сравнение дальности обходится

                LD B, A
                LD A, (ProjectionState.Depth)
                CP B
                JR NC, SelectVertex                                             ; переход, если уровень детализации достиг порога вершины

                ; проверка двух пар граней по фактическим ветвям образа
CheckFaces:     INC HL
                LD A, (HL)
                CALL Game.Wireframe.AnyPackedFaceVisible.Entry
                JR NZ, SelectVertex                                             ; переход, если первая пара граней ненулевая, передать NZ входу проекции

                INC HL
                LD A, (HL)
                CALL Game.Wireframe.AnyPackedFaceVisible.Entry
                ; выбор проекции по Z, затем запрет прежнего кэша для пропущенной вершины
SelectVertex:   JP NZ, Game.Wireframe.DivideFractionAndProjectVertex.Project    ; переход, если проверка детализации или граней оставила NZ, спроецировать вершину

                INC A
                LD (ProjectionState.NoCache), A
                POP AF
                JP Game.Wireframe.DivideFractionAndProjectVertex.NextVertex

                ; данные предыдущих и текущих признаков
VertexFlagData  EQU $                                                           ; начало сохранённых рабочих данных, исходное размещение
.Previous       DB #F2                                                          ; предыдущие признаки знаков для повторного использования произведений
; -----------------------------------------
;      7    6    5    4    3    2    1    0
;   +----+----+----+----+----+----+----+----+
;   | SX | SY | SZ | D4 | D3 | D2 | D1 | NC |
;   +----+----+----+----+----+----+----+----+
;
;   SX      [7]     - флаг, отрицательная координата X модели
;   SY      [6]     - флаг, отрицательная координата Y модели
;   SZ      [5]     - флаг, отрицательная координата Z модели
;   D4..D1 [4..1]  - старшие четыре бита порога детализации
;   NC      [0]     - флаг, поток содержит новую тройку модулей координат
;                     в возвращаемом A бит 0 принудительно равен 1
;                     исходные знаки сохраняются для кэширования произведений
; -----------------------------------------
.Current        DB #AD                                                          ; текущие признаки координат из потока вершин
                ; проверка исходного конца фрагмента
                ASSERT $ == #AA10
                endmodule
                endmodule
