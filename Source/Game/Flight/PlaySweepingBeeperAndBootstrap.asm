                module Flight
                module PlaySweepingBeeperAndBootstrap
; -----------------------------------------
; Тональный сигнал с меняющейся задержкой и вход начальной подготовки
; исходный диапазон #7344..#736F
; In:
;   основной вход без параметров,7366 получает текущий SP
; Out:
;   24 полных импульса на порту FE, шесть HALT, отдельно 7366 сохраняет SP в 7578
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Шесть групп по четыре периода, перед каждым периодом E=(2*E+5) mod256, два DJNZ задают высокий и
;   низкий полупериоды
;   7366 вызывает 94F4 и 8042, затем линейно продолжается в 7370, это отдельный вход из 70E0
;   Первые периоды имеют E=5,15,35,75,155,59,123,251, далее последовательность сходится к 251,
;   прерывания разрешены для HALT
; -----------------------------------------
                ASSERT $ == #7344
                ; шесть групп по четыре периода, HALT выполняется перед каждой группой
Entry:          LD B, #06
                LD E, #00
SweepGroup:     PUSH BC
                HALT
                LD C, #04
                ; расчёт периода по формуле E=(2*E+5) mod256
NextPeriod:     LD A, E
                ADD A, A
                ADD A, #05
                LD E, A
                LD B, A
                ; высокая фаза бипера с задержкой B
                LD A, #30
                OUT (#FE), A
HighDelay:      DJNZ HighDelay

                ; низкая фаза бипера с той же задержкой
                LD A, E
                LD B, A
                XOR A
                OUT (#FE), A
LowDelay:       DJNZ LowDelay

                DEC C
                JR NZ, NextPeriod                                               ; переход, если не все четыре периода группы проиграны, продолжить развёртку периода

                POP BC
                DJNZ SweepGroup

                RET

                ; отдельный стартовый вход сохраняет SP и подготавливает кабину
Bootstrap:      LD (Game.Flight.MainGameLoop.SavedSP), SP
                CALL Game.Flight.ResetFlightControls.Entry
                CALL Game.Screen.RestoreCockpitIfNeeded.Entry
                ASSERT $ == #7370
                endmodule
                endmodule
