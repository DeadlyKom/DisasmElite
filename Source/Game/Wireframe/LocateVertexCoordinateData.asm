                module Wireframe
                module LocateVertexCoordinateData
; -----------------------------------------
; подготовка адреса координат вершин и потока их признаков
; исходный диапазон #AE01..#AE0D
; In:
;   DE, D содержит старший байт относительного адреса FModel.Vertices модели по IY
;   AF, A содержит число вершин
;   IX, начало описания модели
;   IY, начало описания модели
; Out:
;   DE, число байтов координат, 3*A
;   AF, A сохраняется
;   IX, адрес потока признаков
;   память Game.Extensions.DrawCompressedEdges.FlagsStream, адрес потока признаков
; Corrupt:
;   нет дополнительных регистров
; Note:
; IX увеличивается на относительный адрес FModel.Vertices модели по IY, младший байт читается здесь, старший уже передан в D
; DE=3*A затем добавляется вызывающим кодом, чтобы перейти к тройкам модулей координат.
; Завершение общим хвостом Game.Wireframe.LocateFaceNormalData.StoreStream.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #AE01
                ; поиск потока признаков и расчёт размера трёхбайтовых записей вершин
Entry:          LD E, (IY + FModel.Vertices)
                ADD IX, DE
                LD E, A
                PUSH AF
                ADD A, A
                ADD A, E
                LD E, A
                POP AF
                JR Game.Wireframe.LocateFaceNormalData.StoreStream

                ; проверка исходного конца фрагмента
                ASSERT $ == #AE0E
                endmodule
                endmodule
