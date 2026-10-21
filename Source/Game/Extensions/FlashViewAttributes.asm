                module Extensions
                module FlashViewAttributes
; -----------------------------------------
; двухфазная смена атрибутов области обзора
; исходный диапазон #70A9..#70AF
; смысловое имя FlashViewAttributes
; In: параметры атрибутного заполнения для Game.Flight.FillViewAttributesAndFlightState.Entry
; Out: первая фаза с L=#28 завершена, вторая начинается с L=#0F по Game.Flight.SetViewAttributesWithCloaking.Entry
; Corrupt: HL, DE, BC, AF по контракту Game.Flight.FillViewAttributesAndFlightState.Entry
; После последней LD L,#0F нет RET, выполнение продолжается в следующем файле
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #70A9
                ; вывод первой фазы и подготовка цвета второй фазы
Entry:          LD L, #28
                CALL Game.Flight.FillViewAttributesAndFlightState.Entry
                LD L, #0F                                                       ; далее Game.Flight.SetViewAttributesWithCloaking.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #70B0
                endmodule
                endmodule
