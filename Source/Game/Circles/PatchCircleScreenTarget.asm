                module Circles
                module PatchCircleScreenTarget
; -----------------------------------------
; применение режима прямого экрана или буфера
; исходный диапазон #8F88..#8FB7
; смысловое имя PatchCircleScreenTarget
; In: HL — пара NOP/NOP либо SET7,H, AF — A содержит нижнюю границу
; Out: точки преобразования адресов и предельные сравнения обновлены
; Corrupt: AF
; Патчатся #89DA/#89FB/#8A6E, нижние пределы #8A61/#8E18 и верхние/нижние проверки дуг
; Операнды LD A,#4F/#3F в этом коде меняет #8F74 на#CF/#BF
; #8FB4..#8FB5 — сохранённый резерв, #8FB6/#8FB7=#FFFF — образец быстрого заполнения
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #8F88
                ; обновление трёх команд выбора буфера и пределов вертикального прохода
Entry:          LD (CircleRaster.LeftBuffer), HL
                LD (CircleRaster.RightBuffer), HL
                LD (CircleRaster.FillBuffer), HL
                NOP
                NOP
                NOP
                LD (CircleRaster.FillBottom), A
                LD (CircleRaster.NextRow), A
LowerLimit      EQU $ + 1                                                       ; нижний предел, который патчер распространяет на три обработчика
                LD A, #4F
                LD (CircleRaster.RightBottom), A
                LD (CircleRaster.BothBottom), A
                LD (CircleRaster.LeftBottom), A
UpperLimit      EQU $ + 1                                                       ; верхний предел, который патчер распространяет на четыре обработчика
                LD A, #3F
                LD (CircleRaster.RightTop), A
                LD (CircleRaster.BothTop), A
                LD (CircleRaster.LeftTop), A
                LD (CircleRaster.PreviousRow), A
                RET
                ; два исходных резервных байта без установленного потребителя, сохраняются
CircleFillData  EQU $                                                           ; начало сохранённых рабочих данных, исходное размещение
.Reserved       DW #0000                                                        ; исходные байты без установленного потребителя
.Word           DW #FFFF                                                        ; образец #FFFF для заполнения двух экранных байтов через PUSH AF
                ; проверка исходного конца фрагмента
                ASSERT $ == #8FB8
                endmodule
                endmodule
