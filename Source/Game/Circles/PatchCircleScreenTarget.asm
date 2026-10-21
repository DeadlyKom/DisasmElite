                module Circles
                module PatchCircleScreenTarget
; -----------------------------------------
; применение режима прямого экрана или буфера
; исходный диапазон #8F88..#8FB7
; смысловое имя PatchCircleScreenTarget
; In: HL — пара NOP/NOP либо SET7,H, AF — A содержит нижнюю границу
; Out: точки преобразования адресов и предельные сравнения обновлены
; Corrupt: AF
; Патчатся CircleRaster/CircleRaster.RightBuffer/CircleRaster.FillBuffer, нижние пределы CircleRaster.FillBottom/CircleRaster.NextRow и верхние/нижние проверки дуг
; Операнды LD A,#4F/#3F в этом коде меняет Game.Circles.SelectCircleBackBuffer.Entry на #CF/#BF
; CircleFillData.Reserved содержит два сохранённых байта, слово CircleFillWord=#FFFF служит образцом быстрого заполнения
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
