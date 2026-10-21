                module Combat
                module RecoverOneEnergyUnit
; -----------------------------------------
; восстановление единицы энергии либо двух щитов
; исходный диапазон #9AE2..#9AFA
; In:
;   банки GaugeState + FGaugeState.Energy4.Current/GaugeState + FGaugeState.Energy3.Current/GaugeState + FGaugeState.Energy2.Current/GaugeState + FGaugeState.Energy1.Current и щиты GaugeState + FGaugeState.FrontShield.Current/GaugeState + FGaugeState.RearShield.Current
; Out:
;   первый неполный банк увеличен на 1 либо щиты увеличены до A0
; Corrupt:
;   HL, BC, AF
; Note:
; Банки просматриваются от верхнего к нижнему. После первого увеличения немедленный RET.
; Только когда все четыре полны, увеличиваются оба щита. Второй щит обрабатывает общий хвост Game.Combat.RecoverShieldUnit.Entry.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9AE2
                ; поиск первого неполного банка от верхнего к нижнему
Entry:          LD HL, GaugeState + FGaugeState.Energy4.Current
                LD B, #04
CheckBank:      LD A, (HL)
                CP #A0
                JR Z, NextBank                                                  ; переход, если текущий банк полностью заряжен и нужно проверить следующий

                INC (HL)
                RET

NextBank:       DEC HL
                DEC HL
                DJNZ CheckBank

                ; восстановление щитов после заполнения всех банков
                LD HL, GaugeState + FGaugeState.FrontShield.Current
                CALL Game.Combat.RecoverShieldUnit.Entry
                LD HL, GaugeState + FGaugeState.RearShield.Current              ; далее Game.Combat.RecoverShieldUnit.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #9AFB
                endmodule
                endmodule
