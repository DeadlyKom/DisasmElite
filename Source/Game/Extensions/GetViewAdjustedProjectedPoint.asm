                module Extensions
                module GetViewAdjustedProjectedPoint
; -----------------------------------------
; перестановка проекционных координат с поправкой на вид
; исходный диапазон #F945..#F959
; смысловое имя GetViewAdjustedProjectedPoint
; In: (ProjectionState.ScreenX) — пара координат, (ProjectionState.Flags) — признаки, (FlightState.View) — вид
; Out: D=(ProjectionState.ScreenX), E=(ProjectionState.ScreenY), C=(ProjectionState.Flags) с условно инвертированным битом 1
; Corrupt: DE, BC — только C, AF
; Для нечётного номера вида инвертируется бит 1, порядок байтов координат меняется
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #F945
                ; перестановка координат проекции и проверка чётности вида
Entry:          LD DE, (ProjectionState.ScreenX)
                LD A, D
                LD D, E
                LD E, A
                LD A, (FlightState.View)
                BIT 0, A
                LD A, (ProjectionState.Flags)
                JR Z, ReturnFlags                                               ; переход, если номер вида чётный, признаки проекции не инвертируются

                XOR PROJ_NEGX_MASK
ReturnFlags:    LD C, A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #F95A
                endmodule
                endmodule
