                module Trade
                module OptionalBeep
; -----------------------------------------
; Звуковой сигнал по разрешению настройки
; исходный диапазон #E1E8..#E1F6
; In:
;   Бит 7 InputState.Config разрешает звук
; Out:
;   При разрешении передаёт HL=128, DE=96 в ROM Rom.Beeper
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   При сброшенном бите возвращается сразу, длительность задаёт ROM BEEPER
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E1E8
                ; проверка бита разрешения звука до выбора параметров ROM BEEPER
Entry:          LD A, (InputState.Config)
                BIT INPUT_SND_BIT, A
                RET Z                                                           ; выход, если звук отключён в настройках, вызов ROM BEEPER не нужен

                ; для сигнала задаются период HL=128 и число циклов DE=96
                LD HL, #0080
                LD DE, #0060
                JP Rom.Beeper

                ; проверка исходного конца фрагмента
                ASSERT $ == #E1F7
                endmodule
                endmodule
