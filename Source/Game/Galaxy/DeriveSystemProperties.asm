                module Galaxy
                module DeriveSystemProperties
; -----------------------------------------
; Расчёт экономики, правительства, технологии, населения и производительности
; исходный диапазон #E08C..#E106
; In:
;   GalaxyState.WorkingSeed = семя планеты
; Out:
;   GalaxyState.TargetSeed копия семени, TargetX/TargetY координаты, поля GalaxyState.Economy, Government, Technology, Population и Productivity характеристики
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   e=GalaxyState.WorkingSeed + FSystemSeed.Y&7, g=(GalaxyState.WorkingSeed + FSystemSeed.GovBits>>3)&7, при g<2 устанавливается e bit1, t=(GalaxyState.WorkingSeed + FSystemSeed.X&3)+(e XOR7)+ceil(g/2),
;   p=4*t+e+g+1, продуктивность=((e XOR7)+3)*(g+4)*p*8 по модулю 65536
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E08C
                ; вычисление экономики и правительства из полей рабочего семени
Entry:          LD HL, (GalaxyState.WorkingSeed)
                LD (GalaxyState.TargetSeed), HL
                LD A, H
                LD (TargetY), A
                AND SEED_ECON_MASK
                LD (GalaxyState.Economy), A
                LD HL, (GalaxyState.WorkingSeed + FSystemSeed.GovBits)
                LD (GalaxyState.TargetSeed + FSystemSeed.GovBits), HL
                LD A, H
                LD (TargetX), A
                LD A, L
                SRL A
                SRL A
                SRL A
                AND SEED_GOV_MASK
                LD (GalaxyState.Government), A
                SRL A
                JR NZ, Technology                                               ; переход, если номер правительства не меньше 2, экономику дополнительно не корректировать

                LD A, (GalaxyState.Economy)
                OR #02
                LD (GalaxyState.Economy), A
                ; технология зависит от экономики, двух битов семени и половины правительства
Technology:     LD A, (GalaxyState.Economy)
                XOR #07
                AND A
                LD B, A
                LD A, H
                AND SEED_TECH_MASK
                ADD A, B
                LD B, A
                LD A, (GalaxyState.Government)
                SRL A
                ADC A, B
                LD (GalaxyState.Technology), A
                ADD A, A
                ADD A, A
                LD B, A
                LD A, (GalaxyState.Government)
                LD C, A
                LD A, (GalaxyState.Economy)
                ADC A, B
                ADC A, C
                ADC A, #01
                LD (GalaxyState.Population), A
                LD A, (GalaxyState.Economy)
                XOR #07
                ADC A, #03
                LD D, A
                LD A, (GalaxyState.Government)
                ADC A, #04
                CALL Game.Galaxy.MultiplyBytes.Entry
                LD A, (GalaxyState.Population)
                LD D, L
                CALL Game.Galaxy.MultiplyBytes.Entry
                ADD HL, HL
                ADD HL, HL
                ADD HL, HL
                LD (GalaxyState.Productivity), HL
                LD HL, (GalaxyState.WorkingSeed + FSystemSeed.MixLow)
                LD (GalaxyState.TargetSeed + FSystemSeed.MixLow), HL
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #E107
                endmodule
                endmodule
