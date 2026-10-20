                ifndef _STRUCTS_GAUGE_
                define _STRUCTS_GAUGE_

                struct FGauge                                                   ; пара значений одного индикатора [2 байта]
Previous        DB #00                                                          ; предыдущее значение индикатора
Current         DB #00                                                          ; новое значение для сравнения и вывода
                ends

                ASSERT FGauge == 2

                struct FGaugeState                                              ; значения тринадцати индикаторов кабины [26 байт]
FrontShield     FGauge                                                          ; передний щит
RearShield      FGauge                                                          ; задний щит
Fuel            FGauge                                                          ; полоса топлива, 2*fuel+floor(fuel/4)
CabinHeat       FGauge                                                          ; нагрев кабины
LaserHeat       FGauge                                                          ; нагрев лазера
Altitude        FGauge                                                          ; высота над планетой
Speed           FGauge                                                          ; полоса скорости, 5*speed+5
Energy1         FGauge                                                          ; нижний банк энергии
Energy2         FGauge                                                          ; второй банк энергии
Energy3         FGauge                                                          ; третий банк энергии
Energy4         FGauge                                                          ; верхний банк энергии
Roll            FGauge                                                          ; позиция крена относительно центра 21
Pitch           FGauge                                                          ; позиция тангажа относительно центра 21
                ends

                ASSERT FGaugeState == 26

                endif                                                           ; ~_STRUCTS_GAUGE_
