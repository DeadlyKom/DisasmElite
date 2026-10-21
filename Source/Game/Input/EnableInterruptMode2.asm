                module Input
                module EnableInterruptMode2
; -----------------------------------------
; выбор режима IM2 со старшим байтом адреса таблицы #FD
; исходный диапазон #FF4C..#FF52
; смысловое имя EnableInterruptMode2
; In: нет
; Out: I=#FD, процессор в IM2, A=#FD
; Corrupt: AF — A изменяется, флаги сохраняются, I
; Разрешение прерываний IFF не меняется, EI здесь отсутствует
; при байте шины #FF два последних байта после Game.Input.ScanKeyboardMatrix.GalaxyFormat образуют адрес InterruptGate
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #FF4C
                ; установка страницы векторов и режима IM2 без изменения IFF
Entry:          LD A, #FD
                LD I, A
                IM 2
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #FF53
                endmodule
                endmodule
