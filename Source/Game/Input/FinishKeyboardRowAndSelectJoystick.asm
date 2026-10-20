                module Input
                module FinishKeyboardRowAndSelectJoystick
; -----------------------------------------
; переход к следующему ряду клавиатуры и выбор схемы направлений
; исходный диапазон #FC10..#FC24
; смысловое имя FinishKeyboardRowAndSelectJoystick
; In: DE — D содержит число оставшихся рядов, BC — текущий порт
; Out: до окончания восьми рядов продолжает #FD76, затем выбирает клавиатуру или #FC3D
; Corrupt: DE, AF
; D получает младшую тетраду #FC09, E — настройки #FC0E
; При режиме 0 направления уже готовы, при 1..3 используются биты цифровых клавиш #FC0F
; Обработчик порта Kempston в этой версии отсутствует
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #FC10
                ; проверка завершения всех восьми клавиатурных рядов
Entry:          DEC D
                JP NZ, @Game.Input.ScanKeyboardMatrix.ScanRow                   ; переход, если остались неопросенные ряды клавиатуры

                ; выбор источника направлений из младших двух битов настроек
                LD A, (InputState.FlightKeys)
                AND #0F
                LD D, A
                LD A, (InputState.Config)
                LD E, A
                AND INPUT_MODE_MASK
                JR Z, @Game.Input.ResetDemoAndNormalizeControls.SwapAxisPairs   ; переход, если выбран режим клавиатуры, перейти сразу к настройкам осей

                DEC A
                JR @Game.Input.ResetDemoAndNormalizeControls.DigitalAxes
                ; проверка исходного конца фрагмента
                ASSERT $ == #FC25
                endmodule
                endmodule
