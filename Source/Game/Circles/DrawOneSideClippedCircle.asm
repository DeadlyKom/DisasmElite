                module Circles
                module DrawOneSideClippedCircle
; -----------------------------------------
; две половины круга с единственным боковым отсечением
; исходный диапазон #888E..#88B7
; смысловое имя DrawOneSideClippedCircle
; In: BC — положение центра после классификации, D — радиус
; Out: обе видимые половины выведены через один из боковых построителей
; Corrupt: HL, DE, BC, AF, HL', DE', BC', AF'
; Вход #8898 использует уже нормализованный центр
; AF' сохраняет предел движения, бит 0 E выбирает пару левых или правых обработчиков
; Маски пересчитываются перед каждой половиной
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #888E
                ; подготовка смещения и ограничителя для обеих половин отсечённого круга
Entry:          LD A, B
                ADD A, #78
                LD (CircleState.ClipX), A
                LD B, A
                XOR A
                JR ChooseSide

                ; выбор стороны по биту 0 признаков проекции
SideLimit:      LD A, B
                SUB #77
ChooseSide:     EX AF, AF'
                BIT CIRC_RIGHT_BIT, E
                JR Z, ClipLeft                                                  ; переход, если признак правого положения центра сброшен, отсечь левый край

                ; подготовка и вывод двух половин с правым отсечением
                CALL Game.Circles.PrepareRightClippedCircle.Entry
                CALL Game.Screen.RightArcDown.Entry
                CALL Game.Circles.PrepareRightClippedCircle.Entry
                JP Game.Screen.RightArcUp.Entry

                ; подготовка и вывод двух половин с левым отсечением
ClipLeft:       CALL Game.Circles.PrepareLeftClippedCircle.Entry
                CALL Game.Screen.LeftArcDown.Entry
                CALL Game.Circles.PrepareLeftClippedCircle.Entry
                JP Game.Screen.LeftArcUp.Entry
                ; проверка исходного конца фрагмента
                ASSERT $ == #88B8
                endmodule
                endmodule
