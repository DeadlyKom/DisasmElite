                module Wireframe
                module LocateFaceNormalData
; -----------------------------------------
; подготовка адреса нормалей и потока признаков граней
; исходный диапазон #AE0E..#AE1C
; In:
;   DE, D содержит старший байт смещения
;   IX, начало модели
;   IY, начало модели
; Out:
;   DE, E содержит число нормалей FModel.NormalCount модели по IY, D равен нулю
;   IX, адрес потока признаков
;   память Game.Extensions.DrawCompressedEdges.FlagsStream, адрес потока признаков
; Corrupt:
;   нет дополнительных регистров
; Note:
; младший байт относительного адреса читается из FModel.Normals модели по IX, старший передан в D
; Общий хвост Game.Wireframe.LocateFaceNormalData.StoreStream используется также подготовкой вершин Game.Wireframe.LocateVertexCoordinateData.Entry.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #AE0E
                ; поиск нормалей по смещению модели
Entry:          LD E, (IX + FModel.Normals)
                ADD IX, DE
                LD E, (IY + FModel.NormalCount)
                ; обновление общего указателя потока признаков
StoreStream:    LD (Game.Extensions.DrawCompressedEdges.FlagsStream), IX
                LD D, #00
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #AE1D
                endmodule
                endmodule
