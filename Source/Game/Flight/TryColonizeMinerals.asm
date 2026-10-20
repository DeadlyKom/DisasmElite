                module Flight
                module TryColonizeMinerals
; -----------------------------------------
; Попытка появления живых минералов при подборе груза
; исходный диапазон #7370..#7393
; In:
;   State.MineralLife = состояние колонии, для заселения требуется 0
;   State.Cargo + FGoods.Minerals = количество минералов до подбора
;   State.SystemSeed = координаты текущей системы для проверки диагональной полосы
; Out:
;   при допуске State.MineralLife получает количество минералов до подбора, не меньше 2
; Corrupt:
;   AF, HL сохранён
; Note:
;   Game.Screen.PlanetDistanceHint.Entry оценивает удаление от планеты
;   для заселения требуется A >= 56 при C = 0
;   Game.Circles.CheckSystemCoordinateBand.Entry допускает полосу -8 <= Y-X <= 7
;   Game.Missions.SpecialMessageAndScoopReward.AddCargo вызывает проверку до увеличения
;   количества в State.Cargo + FGoods.Minerals, порог 2 требует двух тонн до добавления подобранной тонны
;   ненулевой State.MineralLife запрещает повторную колонизацию, в том числе после гибели колонии
; -----------------------------------------
                ASSERT $ == #7370
                ; миссия 4 MINERAL LIFE, проверка условий появления живой колонии
                ; описание в Docs/Manual.md, раздел mission-4
                ; проверка отсутствия существующей либо погибшей колонии минералов
Entry:          LD A, (State.MineralLife)
                AND A
                RET NZ                                                          ; выход, если состояние живых минералов уже задано

                ; оценка удаления от планеты с сохранением указателя текущего груза
                PUSH HL
                CALL Game.Screen.PlanetDistanceHint.Entry
                POP HL
                RET C                                                           ; выход, если оценка расстояния до планеты переполнилась

                ; проверка минимальной оценки удаления 56
                CP #38
                RET C                                                           ; выход, если оценка расстояния до планеты меньше 56

                ; проверка диагональной полосы системы, -8<=Y-X<=7
                PUSH HL
                CALL Game.Circles.CheckSystemCoordinateBand.Entry
                POP HL
                RET NZ                                                          ; выход, если система находится вне разрешённой диагональной полосы

                ; проверка количества до подбора тонны и фиксация размера колонии
                LD A, (State.Cargo + FGoods.Minerals)
                CP #02
                RET C                                                           ; выход, если до добавления новой тонны имеется меньше двух тонн минералов

                LD (State.MineralLife), A
                RET
                ; Game.Text.InitializeSixTriples.Entry разворачивает DistantSigns в шесть координат
                ; начиная с DistantBodies.First.X, каждая получает байты 00, 00, старший байт из таблицы
DistantSigns    DB #03, #00, #03, #83, #00, #03                                 ; шесть старших знако-модульных байтов координат двух дальних светил
                ASSERT $ == #7394
                endmodule
                endmodule
