                module Travel
                module SetFuelAndGauge
; -----------------------------------------
; Ограничение топлива и обновление указателя прибора
; исходный диапазон #DEA2..#DF02
; In:
;   AF, A = запас в десятых светового года
; Out:
;   State.Fuel=min(A, 70), GaugeState + FGaugeState.Fuel.Current=2*State.Fuel+floor(State.Fuel/4)
; Corrupt:
;   BC, AF
; Note:
;   Насыщает входы>=71 до 70, после RET от Game.Travel.SetFuelAndGauge.SeedPrefix начинается блок семян, имён, параметров планеты
;   и рабочих переменных до GalaxyState.NameCursor + 1
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DEA2
                ; насыщение запаса топлива до 70 и пересчёт указателя прибора
Entry:          CP #47
                JR C, StoreFuel                                                 ; переход, если запрошенное топливо меньше 71, ограничивать его не нужно

                LD A, #46
StoreFuel:      LD (State.Fuel), A
                SLA A
                LD B, A
                SRL A
                SRL A
                SRL A
                ADD A, B
                LD (GaugeState + FGaugeState.Fuel.Current), A
                RET

                ; сохранённый байт перед областью выбранной системы
SeedPrefix      DB #00                                                          ; сохранённый байт перед семенами систем
                ; шесть байтов семени выбранной цели
TargetSeed      EQU SystemData + FGalaxyState.TargetSeed                        ; сохранённое имя поля FGalaxyState.TargetSeed
WorkingSeed     EQU SystemData + FGalaxyState.WorkingSeed                       ; сохранённое имя поля FGalaxyState.WorkingSeed
SavedSeed       EQU SystemData + FGalaxyState.SavedSeed                         ; сохранённое имя поля FGalaxyState.SavedSeed
TextSeed        EQU SystemData + FGalaxyState.TextSeed                          ; сохранённое имя поля FGalaxyState.TextSeed
InputBuffer     EQU SystemData + FGalaxyState.InputBuffer                       ; сохранённое имя поля FGalaxyState.InputBuffer
GeneratedName   EQU SystemData + FGalaxyState.GeneratedName                     ; сохранённое имя поля FGalaxyState.GeneratedName
CurrentName     EQU SystemData + FGalaxyState.CurrentName                       ; сохранённое имя поля FGalaxyState.CurrentName
TargetName      EQU SystemData + FGalaxyState.TargetName                        ; сохранённое имя поля FGalaxyState.TargetName
Distance        EQU SystemData + FGalaxyState.Distance                          ; сохранённое имя поля FGalaxyState.Distance
Economy         EQU SystemData + FGalaxyState.Economy                           ; сохранённое имя поля FGalaxyState.Economy
Government      EQU SystemData + FGalaxyState.Government                        ; сохранённое имя поля FGalaxyState.Government
Technology      EQU SystemData + FGalaxyState.Technology                        ; сохранённое имя поля FGalaxyState.Technology
Population      EQU SystemData + FGalaxyState.Population                        ; сохранённое имя поля FGalaxyState.Population
Productivity    EQU SystemData + FGalaxyState.Productivity                      ; сохранённое имя поля FGalaxyState.Productivity
Reserved        EQU SystemData + FGalaxyState.Reserved                          ; сохранённое имя поля FGalaxyState.Reserved
ScanIndex       EQU SystemData + FGalaxyState.ScanIndex                         ; сохранённое имя поля FGalaxyState.ScanIndex
NameCursor      EQU SystemData + FGalaxyState.NameCursor                        ; сохранённое имя поля FGalaxyState.NameCursor

SystemData      FGalaxyState {                                                  ; явные исходные значения полей
                    {                                                           ; FGalaxyState.TargetSeed, шестибайтовое семя выбранной цели
                        #38,                                                    ; FSystemSeed.NameBits, бит 6 выбирает четыре слога вместо трёх
                        #AD,                                                    ; FSystemSeed.Y, координата Y, биты 2..0 дают исходную экономику
                        #9C,                                                    ; FSystemSeed.GovBits, биты 5..3 задают правительство
                        #14,                                                    ; FSystemSeed.X, координата X, биты 1..0 участвуют в технологии
                        #1D,                                                    ; FSystemSeed.MixLow, младший байт третьего слова при шаге генератора
                        #15                                                     ; FSystemSeed.Syllable, биты 4..0 задают индекс слога имени
                    },
                    {                                                           ; FGalaxyState.WorkingSeed, рабочее семя перебора и генерации имени
                        #BC,                                                    ; FSystemSeed.NameBits, бит 6 выбирает четыре слога вместо трёх
                        #57,                                                    ; FSystemSeed.Y, координата Y, биты 2..0 дают исходную экономику
                        #82,                                                    ; FSystemSeed.GovBits, биты 5..3 задают правительство
                        #0A,                                                    ; FSystemSeed.X, координата X, биты 1..0 участвуют в технологии
                        #63,                                                    ; FSystemSeed.MixLow, младший байт третьего слова при шаге генератора
                        #AD                                                     ; FSystemSeed.Syllable, биты 4..0 задают индекс слога имени
                    },
                    {                                                           ; FGalaxyState.SavedSeed, копия рабочего семени на время вложенного перебора
                        #38,                                                    ; FSystemSeed.NameBits, бит 6 выбирает четыре слога вместо трёх
                        #AD,                                                    ; FSystemSeed.Y, координата Y, биты 2..0 дают исходную экономику
                        #9C,                                                    ; FSystemSeed.GovBits, биты 5..3 задают правительство
                        #14,                                                    ; FSystemSeed.X, координата X, биты 1..0 участвуют в технологии
                        #1D,                                                    ; FSystemSeed.MixLow, младший байт третьего слова при шаге генератора
                        #15                                                     ; FSystemSeed.Syllable, биты 4..0 задают индекс слога имени
                    },
                    {                                                           ; FGalaxyState.TextSeed, четыре байта генератора описаний
                        #00, #00, #00, #00
                    },
                    {                                                           ; FGalaxyState.InputBuffer, десять вводимых символов и завершающий ноль
                        #4A, #41, #4D, #45, #53, #4F, #4E, #20,
                        #20, #20, #00
                    },
                    {                                                           ; FGalaxyState.GeneratedName, восемь букв имени и завершающий ноль
                        #4C, #41, #56, #45, #00, #00, #00, #00,
                        #00
                    },
                    {                                                           ; FGalaxyState.CurrentName, сохранённое имя текущей системы
                        #4C, #41, #56, #45, #00, #00, #00, #00,
                        #00
                    },
                    {                                                           ; FGalaxyState.TargetName, сохранённое имя выбранной цели
                        #4C, #41, #56, #45, #00, #00, #00, #00,
                        #00
                    },
                    #0000,                                                      ; FGalaxyState.Distance, расстояние до цели в десятых светового года
                    #05,                                                        ; FGalaxyState.Economy, экономика выбранной системы, индекс 0..7
                    #03,                                                        ; FGalaxyState.Government, правительство выбранной системы, индекс 0..7
                    #04,                                                        ; FGalaxyState.Technology, технологический уровень, счёт с нуля
                    #19,                                                        ; FGalaxyState.Population, население в десятых миллиарда
                    #1B58,                                                      ; FGalaxyState.Productivity, производительность системы
                    {                                                           ; FGalaxyState.Reserved, сохранённые байты образа, обращений к полю не найдено
                        #00, #00
                    },
                    #00,                                                        ; FGalaxyState.ScanIndex, индекс перебора, переполнение завершает 256 систем
                    Game.Travel.SetFuelAndGauge.GeneratedName + 4               ; FGalaxyState.NameCursor, адрес следующего символа в GeneratedName
                }
                ; проверка исходного конца фрагмента
                ASSERT $ == #DF03
                endmodule
                endmodule
