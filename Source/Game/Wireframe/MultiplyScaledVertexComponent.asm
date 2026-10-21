                module Wireframe
                module MultiplyScaledVertexComponent
; -----------------------------------------
; умножение масштабированной компоненты вершины на элемент матрицы
; исходный диапазон #AB1E..#AB33
; In:
;   BC, B содержит модуль компоненты вершины
;   IY, адрес элемента строки матрицы
;   память ProjectionState.Scale, ненулевое число предварительных сдвигов
; Out:
;   HL, модуль произведения, H равен нулю
;   DE, исходное значение
; Corrupt:
;   BC, AF
; Note:
; B предварительно сдвигается влево ProjectionState.Scale раз с восьмибитным усечением.
; модуль элемента матрицы извлекается из FSignWord.SignHigh слова по IY, знак учитывает вызывающая процедура
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #AB1E
                ; расчёт увеличенного модуля компоненты для точной ближней проекции
Entry:          LD A, (ProjectionState.Scale)
ScaleComponent: SLA B
                DEC A
                JR NZ, ScaleComponent                                           ; переход, если ещё не выполнены все предварительные сдвиги компоненты

                LD C, (IY + FSignWord.SignHigh)
                RES 7, C
                PUSH DE
                CALL Game.Wireframe.MultiplyHighByteApprox.Entry
                LD L, A
                LD H, #00
                POP DE
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #AB34
                endmodule
                endmodule
