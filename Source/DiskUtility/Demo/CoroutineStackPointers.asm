; -----------------------------------------
; Сохранённые указатели двух стеков
; исходный диапазон #E6DC..#E6DF
; In:
;   записи StartCoroutine,ResumeDemo,YieldToGame
; Out:
;   E6DC стек игры, E6DE стек корутины
; Corrupt:
;   нет, четыре байта данных
; Note:
;   Два little-endian слова изначально нулевые, до ResumeDemo их задают StartCoroutine и YieldToGame
; -----------------------------------------
SavedStacks     DW #0000                                                        ; SP игрового обработчика прерывания
DemoStack       DW #0000                                                        ; SP сохранённых регистров корутины
