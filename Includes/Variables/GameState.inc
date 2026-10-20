                ifndef _GAME_STATE_
                define _GAME_STATE_

; -----------------------------------------
; имена исходных адресов, определения не выделяют память
; размещение взято из инструкций и сериализуемого блока данной версии
; смещения полей связаны со структурой, размер которой проверяется ASSERT
; -----------------------------------------
State           EQU Game.Interface.DispatchDiskAndCommanderState.Commander      ; адрес структуры FCommander, состояние пилота
.Commander      EQU State                                                       ; начало сериализуемой записи FCommander
.Name           EQU State + FCommander.Name                                     ; имя командира, поле из 11 байтов
.LegalStatus    EQU State + FCommander.LegalStatus                              ; степень преследования, 0 законопослушный, от 50 разыскиваемый
.Rating         EQU State + FCommander.Rating                                   ; младшие 16 бит боевого рейтинга
.RankState      EQU State + FCommander.RankState                                ; старший рейтинг и военное состояние, схема FCommander.RankState
.JumpCount      EQU State + FCommander.JumpCount                                ; младший байт счётчика переходов
.JumpFlags      EQU State + FCommander.JumpFlags                                ; старшие разряды счётчика и флаг допуска миссий
.Galaxy         EQU State + FCommander.Galaxy                                   ; номер галактики, 0..7
.CashHigh       EQU State + FCommander.CashHigh                                 ; старшая часть денег, тысячи кредитов
.CashLow        EQU State + FCommander.CashLow                                  ; младшая часть денег, десятые доли кредита
.MarketRandom   EQU State + FCommander.MarketRandom                             ; случайный параметр воспроизводимого рынка
.Cargo          EQU State + FCommander.Cargo                                    ; адрес структуры FGoods, количества товаров в трюме
.FreeCargo      EQU State + FCommander.FreeCargo                                ; свободное место в трюме, тонны
.FrontLaser     EQU State + FCommander.FrontLaser                               ; тип переднего лазера
.RearLaser      EQU State + FCommander.RearLaser                                ; тип заднего лазера
.LeftLaser      EQU State + FCommander.LeftLaser                                ; тип левого лазера
.RightLaser     EQU State + FCommander.RightLaser                               ; тип правого лазера
.Mission1       EQU State + FCommander.Mission1                                 ; состояние первой миссии
.Fuel           EQU State + FCommander.Fuel                                     ; топливо в десятых долях светового года, максимум 70
.Missiles       EQU State + FCommander.Missiles                                 ; количество ракет
.LargeCargo     EQU State + FCommander.LargeCargo                               ; состояние расширенного трюма
.ECM            EQU State + FCommander.ECM                                      ; наличие и состояние системы ECM
.AlienComputer  EQU State + FCommander.AlienComputer                            ; состояние инопланетного компьютера и счётчик его событий
.MineralLife    EQU State + FCommander.MineralLife                              ; состояние живой колонии минералов
.FuelScoops     EQU State + FCommander.FuelScoops                               ; наличие и состояние топливного ковша
.EscapePod      EQU State + FCommander.EscapePod                                ; наличие спасательной капсулы
.EnergyBomb     EQU State + FCommander.EnergyBomb                               ; наличие и состояние энергетической бомбы
.EnergyUnit     EQU State + FCommander.EnergyUnit                               ; наличие и состояние энергетического блока
.DockComputer   EQU State + FCommander.DockComputer                             ; наличие и состояние стыковочного компьютера
.GalacticDrive  EQU State + FCommander.GalacticDrive                            ; наличие и состояние галактического гиперпривода
.ShipUpgrade    EQU State + FCommander.ShipUpgrade                              ; код установленного улучшения корабля
.Invasion       EQU State + FCommander.Invasion                                 ; фаза и размер области вторжения
.GalaxySeed     EQU State + FCommander.GalaxySeed                               ; шесть байтов семени галактики
.SystemSeed     EQU State + FCommander.SystemSeed                               ; шесть байтов семени текущей системы
.Technology     EQU State + FCommander.Technology                               ; технологический уровень системы, счёт с нуля
.Government     EQU State + FCommander.Government                               ; тип правительства системы, 0..7
.MarketStock    EQU State + FCommander.MarketStock                              ; адрес структуры FGoods, остатки товаров станции
.Mission3       EQU State + FCommander.Mission3                                 ; этап третьей миссии и отметка попадания
.MissionFlags   EQU State + FCommander.MissionFlags                             ; награды, особое оборудование и занятость трюма миссией
.SunPosition    EQU State + FCommander.SunPosition                              ; три трёхбайтовые координаты солнца

; -----------------------------------------
; состояние текущего полёта, отдельные байты разделены сохранёнными векторами JP
; UpdateFlightControlGauges переносит управление, MainGameLoop читает режимы кадра
; SunScooping не очищается каждым расчётом расстояния, это сохранённое состояние
; определения описывают исходную память и не выделяют новые байты
; -----------------------------------------
                module FlightState
InvasionClock:  EQU Game.Flight.FillViewAttributesAndFlightState.InvasionClock  ; накопитель вторжения, UpdateClockAndRotateDistantBodies прибавляет NOT State.Invasion
View:           EQU Game.Flight.FillViewAttributesAndFlightState.View           ; номер экрана, четыре вида кабины имеют коды 0..3
Roll:           EQU Game.Flight.FillViewAttributesAndFlightState.Roll           ; крен игрока в формате знак и модуль, переносится из управления FF09
Pitch:          EQU Game.Flight.FillViewAttributesAndFlightState.Pitch          ; тангаж игрока в формате знак и модуль, переносится из управления FF0B
Speed:          EQU Game.Flight.FillViewAttributesAndFlightState.Speed          ; скорость игрока, задаёт перенос объектов и длину полосы скорости
SpaceMode:      EQU Game.Flight.FillViewAttributesAndFlightState.SpaceMode      ; нуль в обычной системе, ненулевое значение в особом пространстве
FlightStatus:   EQU Game.Flight.FillViewAttributesAndFlightState.FlightStatus   ; 0 на станции, 4 норма, 6 станционная зона, 2 опасность, #63 мигание
RandomByte:     EQU Game.Flight.FillViewAttributesAndFlightState.RandomByte     ; полётный параметр, при инициализации копируется из State.MarketRandom
Sun:            EQU Game.Flight.FillViewAttributesAndFlightState.Sun            ; три координаты солнца, каждая занимает FCoordinate байтов
Planet:         EQU Game.Flight.FillViewAttributesAndFlightState.Planet         ; три координаты планеты, каждая занимает FCoordinate байтов
StationZone:    EQU Game.Flight.DispatchChartCircle.StationZone                 ; ближняя станционная зона, разрешает стыковку и запрещает появление кораблей
StationFar:     EQU Game.Flight.DispatchChartCircle.StationFar                  ; #FF для дальних координат станции, 0 для ближних
SunScooping:    EQU Game.Flight.DispatchChartCircle.SunScooping                 ; признак зоны черпаков, сбрасывается при входе в систему и на заставке
PlayerDead:     EQU Game.Flight.DispatchChartCircle.PlayerDead                  ; флаг, главный цикл должен показать гибель игрока
XorObjects:     EQU Game.Flight.DispatchChartCircle.XorObjects                  ; нуль выбирает OR, ненулевое значение выбирает XOR при выводе объектов
ControlsLocked: EQU Game.Flight.DispatchDangerIndicator.ControlsLocked          ; флаг, главный цикл пропускает ручное обновление крена, тангажа и скорости
SoundRequests:  EQU Game.Flight.DispatchSoundEffect.Requests                    ; восемь запросов звука, диспетчер выбирает младший установленный бит
AutoDock:       EQU Game.Flight.DispatchSoundEffect.AutoDock                    ; флаг, выполняется автоматическая стыковка
                endmodule

; -----------------------------------------
; тринадцать пар приборов, Previous хранит уже нарисованное значение
; Current содержит новое значение, UpdateIndicators сравнивает и обновляет пару
; первые одиннадцать полос делятся на четыре, крен и тангаж выводятся отдельно
; банки энергии нумеруются снизу вверх, расход начинается с Energy1
; восстановление начинается с Energy4, после заполнения всех банков растут щиты
; -----------------------------------------
                ; адрес структуры FGaugeState, порядок пар задан в Includes/Structs/Gauge.inc
GaugeState      EQU Game.Flight.FillViewAttributesAndFlightState.FrontShieldPrev

; -----------------------------------------
; рабочие поля объектного кадра, UpdateAllSpaceObjects очищает накопители
; ObjectsPresent устанавливается по энергии непустого слота и не означает взрыв
; #9C98 сохранён без выдуманного имени, подтверждённых потребителей не найдено
; -----------------------------------------
                module CombatState
SpawnCounter:   EQU Game.Combat.DivideAndCombatState.SpawnCounter               ; счётчик появления, уменьшение до нуля запускает диспетчер объектов
ShipsPresent:   EQU Game.Combat.DivideAndCombatState.ShipsPresent               ; флаг, в текущем обходе найден объект без ObjectFlag2.NotShip
DestroyAll:     EQU Game.Combat.DivideAndCombatState.DestroyAll                 ; массовый запрос уничтожения от энергетической бомбы, снимается в конце кадра
ObjectsPresent: EQU Game.Combat.DivideAndCombatState.ObjectsPresent             ; ненулевой байт последнего занятого слота, допускает сканер и обход взрывов
CrosshairTarget:EQU Game.Combat.DivideAndCombatState.CrosshairTarget            ; номер цели прицела, 0 без цели, патч проекции данной версии пишет только 0
Danger:         EQU Game.Combat.DivideAndCombatState.Danger                     ; флаг, обнаружен опасный враждебный объект, сбрасывается при пустой сцене
DockRequest:    EQU Game.Combat.DivideAndCombatState.DockRequest                ; запрос стыковки после совмещения со станцией, обходящий клавиатурные допуски
EcmTimer:       EQU Game.Combat.DivideAndCombatState.EcmTimer                   ; оставшиеся такты ECM, влияет на ракеты, индикатор и расход энергии
EnergyDrain:    EQU Game.Combat.CreateWreckAndDamageState.EnergyDrain           ; накопленный расход энергии за объектный кадр, включая лазер и ECM
FrontDamage:    EQU Game.Combat.CreateWreckAndDamageState.FrontDamage           ; накопленный урон передней защите от лазеров и столкновений
RearDamage:     EQU Game.Combat.CreateWreckAndDamageState.RearDamage            ; накопленный урон задней защите от лазеров и столкновений
                endmodule

                ; проверка границ исходных полей и соседства пар приборов
                ASSERT FlightState.Roll + 1 == FlightState.Pitch
                ASSERT FlightState.Pitch + 1 == FlightState.Speed
                ASSERT FlightState.Speed + 1 == GaugeState + FGaugeState.FrontShield.Previous
                ASSERT GaugeState + FGaugeState.Pitch.Current + 1 == #7101
                ASSERT FGaugeState.Pitch + FGauge == FGaugeState
                ASSERT FlightState.Sun + 3 * FCoordinate == FlightState.Planet
                ASSERT FlightState.Planet + 3 * FCoordinate == #7119
                ASSERT CombatState.CrosshairTarget + 1 == #9C98
                ASSERT CombatState.EcmTimer + 1 == #9C9C
                ASSERT CombatState.RearDamage + 1 == #9CA5

                module Memory
Screen:         EQU #4000                                                       ; пиксельная видеопамять и исходное изображение
Attributes:     EQU #5800                                                       ; атрибуты знакомест Spectrum
CockpitAttrs:   EQU #5B00                                                       ; сохранённые атрибуты кабины
Station:        EQU #6048                                                       ; первая из восьми 39-байтовых записей
Objects:        EQU #606F                                                       ; шесть обычных объектов и одна ракета
Missile:        EQU #6159                                                       ; восьмая запись общего массива
ModelIndex:     EQU #6180                                                       ; 23 четырёхбайтовые записи каталога моделей
Frame:          EQU #C000                                                       ; буфер полётного вида либо сохранённой кабины
RandomSeed:     EQU Game.Travel.SetFuelAndGauge.WorkingSeed                     ; три слова рекуррентного генератора
                endmodule

                module Rom
Beeper:         EQU #03B5                                                       ; тон на динамике, HL задаёт период, DE число колебаний
FindKeyPair:    EQU #16DC                                                       ; поиск C в таблице пар HL, C-флаг означает совпадение
PlotAddress:    EQU #22AA                                                       ; B отсчитывается от низа, перед расчётом A=175-B
PixelFromA:     EQU #22B0                                                       ; A=y, C=x, копирует A в B перед общим расчётом адреса
PixelAddress:   EQU #22B1                                                       ; B=y, C=x, A=B, выход HL=адрес и A=бит
TrDos:          EQU #3D13                                                       ; штатный вход функций TR-DOS
CallDosStack:   EQU #3D2F                                                       ; вход TR-DOS по адресу, переданному на стеке
                endmodule

                ; проверка исходных адресов конечных полей и размеров
                ASSERT State.SunPosition + 9 == #D0BA
                ASSERT Memory.Station + 8 * FSpaceObject == Memory.ModelIndex
                ASSERT State.Cargo + FGoods == State.FreeCargo

                endif
