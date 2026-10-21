                module Wireframe
                module AdvanceObjectMetadata
; -----------------------------------------
; переход к следующей расширенной записи объекта
; исходный диапазон #A8EC..#A9C8
; In:
;   память ObjectEffects.Current, текущая запись
; Out:
;   HL, следующая запись
;   DE, число 39 для шага основного слота
; Corrupt:
;   AF
; Note:
; Метаданные имеют шаг 10, основной объект шаг 39.
; После RET лежит рабочая область геометрии, её исходные содержимые сохранены.
; ProjectedVerts содержит 46 экранных вершин по три байта, FaceVisibility содержит 16 признаков граней
; ObjectMatrix содержит девять слов матрицы, VertexProducts содержит девять кэшированных произведений
; ProjectionState.Depth хранит глубину, ProjectionState.VertexOffset смещение вершины, поля ProjectionState.X/Y/Z повёрнутые координаты
; ProjectionState.ScreenX, ScreenY и Flags хранят проекцию, поля SignX, SignY и SignZ хранят знаки пространственных координат
; ProjectionState.Scale, число сдвигов ближней проекции. ProjectionState.NoCache, запрет использования кэша.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #A8EC
                ; обновление указателя метаданных и подготовка шага основного объекта
Entry:          LD HL, (ObjectEffects.Current)
                LD DE, #000A
                ADD HL, DE
                LD (ObjectEffects.Current), HL
                LD E, #27
                RET

                ; рабочие данные проекций, граней, матрицы и промежуточных вычислений
LeadingByte     DB #7B                                                          ; исходный байт перед таблицей экранных вершин
GeometryData    EQU $                                                           ; начало сохранённых рабочих данных, исходное размещение
.Vertices       FProjectedVertex {                                              ; запись 0, FProjectedVertex
                    #2A,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #53,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #00                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 1, FProjectedVertex
                    #0A,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #1F,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #02                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 2, FProjectedVertex
                    #08,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #04,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #00                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 3, FProjectedVertex
                    #0B,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #0F,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #03                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 4, FProjectedVertex
                    #1C,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #02,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #03                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 5, FProjectedVertex
                    #25,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #2D,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #03                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 6, FProjectedVertex
                    #1C,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #34,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #03                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 7, FProjectedVertex
                    #16,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #31,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #03                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 8, FProjectedVertex
                    #1E,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #08,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #00                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 9, FProjectedVertex
                    #0E,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #19,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #01                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 10, FProjectedVertex
                    #0E,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #38,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #03                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 11, FProjectedVertex
                    #08,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #08,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #03                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 12, FProjectedVertex
                    #16,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #0F,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #01                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 13, FProjectedVertex
                    #09,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #12,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #01                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 14, FProjectedVertex
                    #01,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #13,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #01                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 15, FProjectedVertex
                    #0C,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #14,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #03                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 16, FProjectedVertex
                    #0B,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #0D,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #03                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 17, FProjectedVertex
                    #02,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #0A,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #01                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 18, FProjectedVertex
                    #0B,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #08,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #01                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 19, FProjectedVertex
                    #18,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #08,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #01                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 20, FProjectedVertex
                    #0A,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #18,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #02                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 21, FProjectedVertex
                    #0B,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #1C,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #02                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 22, FProjectedVertex
                    #2C,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #07,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #01                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 23, FProjectedVertex
                    #2B,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #0B,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #01                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 24, FProjectedVertex
                    #2F,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #08,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #01                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 25, FProjectedVertex
                    #22,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #16,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #03                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 26, FProjectedVertex
                    #26,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #15,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #03                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 27, FProjectedVertex
                    #23,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #12,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #03                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 28, FProjectedVertex
                    #00,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #00,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #00                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 29, FProjectedVertex
                    #00,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #00,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #00                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 30, FProjectedVertex
                    #00,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #00,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #00                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 31, FProjectedVertex
                    #00,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #00,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #00                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 32, FProjectedVertex
                    #00,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #00,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #00                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 33, FProjectedVertex
                    #00,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #00,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #00                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 34, FProjectedVertex
                    #00,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #00,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #00                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 35, FProjectedVertex
                    #00,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #00,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #00                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 36, FProjectedVertex
                    #00,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #00,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #00                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 37, FProjectedVertex
                    #00,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #00,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #00                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 38, FProjectedVertex
                    #00,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #00,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #00                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 39, FProjectedVertex
                    #00,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #00,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #00                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 40, FProjectedVertex
                    #00,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #00,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #00                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 41, FProjectedVertex
                    #00,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #00,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #00                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 42, FProjectedVertex
                    #00,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #00,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #00                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 43, FProjectedVertex
                    #00,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #00,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #00                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 44, FProjectedVertex
                    #00,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #00,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #00                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }

                FProjectedVertex {                                              ; запись 45, FProjectedVertex
                    #00,                                                        ; FProjectedVertex.X, +00, модуль горизонтального смещения
                    #00,                                                        ; FProjectedVertex.Y, +01, модуль вертикального смещения
                    #00                                                         ; FProjectedVertex.Flags, +02, знаки экранного смещения либо маркер скрытия
                }
.Faces          DB #00, #01, #00, #01, #00, #01, #00, #01                       ; 16 байтов видимости граней
                DB #00, #01, #01, #00, #01, #01, #01, #01                       ; продолжение сохранённых байтов
.Matrix         FMatrix3 {                                                      ; явные исходные значения полей
                    {                                                           ; FMatrix3.X, первая строка, преобразование компоненты X
                        #1B7E,                                                  ; FAxis.X, компонента X
                        #EF81,                                                  ; FAxis.Y, компонента Y
                        #37F3                                                   ; FAxis.Z, компонента Z
                    },
                    {                                                           ; FMatrix3.Y, вторая строка, преобразование компоненты Y
                        #1D81,                                                  ; FAxis.X, компонента X
                        #3C7E,                                                  ; FAxis.Y, компонента Y
                        #6DF3                                                   ; FAxis.Z, компонента Z
                    },
                    {                                                           ; FMatrix3.Z, третья строка, преобразование компоненты Z
                        #F8F2,                                                  ; FAxis.X, компонента X
                        #8BF2,                                                  ; FAxis.Y, компонента Y
                        #27F3                                                   ; FAxis.Z, компонента Z
                    }
                }
.Products       DW #0000, #0015, #8030, #0000, #800B, #805F, #8000, #0002       ; девять кэшированных произведений модулей вершины и матрицы
                DW #8022                                                        ; продолжение сохранённых байтов
.Depth          EQU .Projection + FProjectionState.Depth                        ; сохранённое имя поля FProjectionState.Depth
.VertexOffset   EQU .Projection + FProjectionState.VertexOffset                 ; сохранённое имя поля FProjectionState.VertexOffset
.X              EQU .Projection + FProjectionState.X                            ; сохранённое имя поля FProjectionState.X
.Y              EQU .Projection + FProjectionState.Y                            ; сохранённое имя поля FProjectionState.Y
.Z              EQU .Projection + FProjectionState.Z                            ; сохранённое имя поля FProjectionState.Z
.ScreenX        EQU .Projection + FProjectionState.ScreenX                      ; сохранённое имя поля FProjectionState.ScreenX
.ScreenY        EQU .Projection + FProjectionState.ScreenY                      ; сохранённое имя поля FProjectionState.ScreenY
.Flags          EQU .Projection + FProjectionState.Flags                        ; сохранённое имя поля FProjectionState.Flags
.SignX          EQU .Projection + FProjectionState.SignX                        ; сохранённое имя поля FProjectionState.SignX
.SignY          EQU .Projection + FProjectionState.SignY                        ; сохранённое имя поля FProjectionState.SignY
.SignZ          EQU .Projection + FProjectionState.SignZ                        ; сохранённое имя поля FProjectionState.SignZ
.Scale          EQU .Projection + FProjectionState.Scale                        ; сохранённое имя поля FProjectionState.Scale
.NoCache        EQU .Projection + FProjectionState.NoCache                      ; сохранённое имя поля FProjectionState.NoCache

.Projection     FProjectionState {                                              ; явные исходные значения полей
                    #0202,                                                      ; FProjectionState.Depth, глубина объекта, младший байт затем переиспользуется как уровень детализации
                    #1E,                                                        ; FProjectionState.VertexOffset, смещение трёхбайтовой записи в таблице экранных вершин
                    #001B,                                                      ; FProjectionState.X, повёрнутая X-компонента, затем X с добавленным положением объекта
                    #006A,                                                      ; FProjectionState.Y, повёрнутая Y-компонента, затем Y с добавленным положением объекта
                    #01DF,                                                      ; FProjectionState.Z, повёрнутая Z-компонента, затем Z с добавленным положением объекта
                    #0E,                                                        ; FProjectionState.ScreenX, модуль горизонтальной проекции центра или вершины
                    #38,                                                        ; FProjectionState.ScreenY, модуль вертикальной проекции центра или вершины
                    #03,                                                        ; FProjectionState.Flags, бит 1 знак X, бит 0 знак Y, схема в FProjectionState
                    #80,                                                        ; FProjectionState.SignX, знаковый старший байт пространственной координаты X
                    #80,                                                        ; FProjectionState.SignY, знаковый старший байт пространственной координаты Y
                    #00,                                                        ; FProjectionState.SignZ, знаковый старший байт пространственной координаты Z
                    #01,                                                        ; FProjectionState.Scale, число левых сдвигов для повышенной точности ближней вершины
                    #00                                                         ; FProjectionState.NoCache, флаг, произведения предыдущей вершины нельзя использовать
                }
                ; проверка исходного конца фрагмента
                ASSERT $ == #A9C9
                endmodule
                endmodule
