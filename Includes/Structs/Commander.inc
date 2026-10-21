                ifndef _STRUCT_COMMANDER_
                define _STRUCT_COMMANDER_

; -----------------------------------------
; сериализуемое состояние командира, рабочий экземпляр State
; DiskUtility.Menu.LoadCommander копирует FCommander байтов из DiskBuffer.Work в State
; DiskUtility.Menu.BackupPilot обновляет резервный экземпляр
; резерв расположен в Game.Missions.RatingBountyDamageAndNewCommander.NewCommander
; DiskUtility.Menu.OverwriteSave записывает сектор начиная с State
; логическая длина файла равна FCommander, остальные байты сектора принадлежат хвосту
; денежная сумма в кредитах равна (CashHigh * 10000 + CashLow) / 10
; числовые поля расположены младшим байтом вперёд
; -----------------------------------------
                struct FCommander                                               ; состояние пилота, ровно 102 байта
Name            TEXT 11, {#00}                                                  ; +00..0A, имя с нулём, ввод изменяет первые восемь байтов
LegalStatus     DB #00                                                          ; +0B, 0 законопослушный, 1..49 нарушитель, от 50 разыскивается
Rating          DW #0000                                                        ; +0C..0D, младшие 16 бит боевого рейтинга
; -----------------------------------------
; FCommander.RankState, старший байт рейтинга и код военного состояния
;      7    6    5    4    3    2    1    0
;   +----+----+----+----+----+----+----+----+
;   | WA | RS | RC | RC | RN | RN | RN | NX |
;   +----+----+----+----+----+----+----+----+
;
;   вне войны весь байт является старшим разрядом числового рейтинга
;   военный формат применяется при ненулевом State.Invasion
;   WA      [7]     - флаг, разрешён вывод воинского звания
;   RS      [6]     - флаг, отставка IN RESERVE, запрещает поиск секретной базы
;   RN      [3..1]  - номер воинского звания, извлекается маской RANK_NUM_MASK
;   NX      [0]     - флаг, разрешена проверка следующего предложения задания
;   RC      [5..4]  - разряды числового рейтинга, в номер воинского звания не входят
;   INC/DEC изменяют весь байт, NX и номер звания не являются независимыми счётчиками
;   начало вторжения устанавливает RANK_START_CODE, ответ Y увеличивает код на 1
;   RANK_RSV_BIT проверяется маской #40, это бит 6 при нумерации от нуля
; -----------------------------------------
RankState       DB #00                                                          ; +0E, старший разряд рейтинга и военное состояние, схема выше
JumpCount       DB #00                                                          ; +0F, младший байт счётчика, 16-битные обращения начинаются здесь
; -----------------------------------------
; FCommander.JumpFlags, старшая часть счётчика переходов и разрешение миссии
;      7    6    5    4    3    2    1    0
;   +----+----+----+----+----+----+----+----+
;   | MS | CT | CT | CT | CT | CT | CT | CT |
;   +----+----+----+----+----+----+----+----+
;
;   MS      [7]     - флаг, при следующем прибытии проверить выдачу старых миссий
;   CT      [6..0]  - старшие разряды числового счётчика переходов
;   Game.Travel.LaserTypeAndArrivalEvents.CheckGrant проверяет и сбрасывает JUMP_MSN_BIT
;   затем передаёт управление в Game.Travel.GetSalePriceAndMissionFlags.GrantMission
;   Game.Extensions.UpdateInvasionOnRatingOverflow.MarkJumpCount устанавливает JUMP_MSN_BIT
;   этот вход используется при отказе запуска вторжения
;   перенос из State.JumpCount увеличивает весь State.JumpFlags
;   допуск войны проверяется по общим битам State.JumpFlags и State.RankState
; -----------------------------------------
JumpFlags       DB #00                                                          ; +10, старшая часть счётчика и разрешение выдачи миссии
Galaxy          DB #00                                                          ; +11, индекс галактики 0..7
CashHigh        DW #0000                                                        ; +12..13, целые тысячи кредитов
CashLow         DW #0000                                                        ; +14..15, остаток в десятых кредита, штатно меньше 10000
MarketRandom    DB #00                                                          ; +16, случайный параметр воспроизводимого рынка
Cargo           FGoods                                                          ; +17..27, количества товаров в трюме, структура FGoods
FreeCargo       DB #00                                                          ; +28, оставшееся место в трюме в тоннах
FrontLaser      DB #00                                                          ; +29, тип переднего лазера
RearLaser       DB #00                                                          ; +2A, тип заднего лазера
LeftLaser       DB #00                                                          ; +2B, тип левого лазера
RightLaser      DB #00                                                          ; +2C, тип правого лазера
; Game.Travel.GetSalePriceAndMissionFlags.GrantMission устанавливает State.Mission1 при выдаче задания
Mission1        DB #00                                                          ; +2D, активность первой миссии
Fuel            DB #00                                                          ; +2E, топливо в десятых светового года, максимум 70
Missiles        DB #00                                                          ; +2F, число ракет, покупка ограничена четырьмя
; Game.Trade.InstallPurchasedEquipment.CheckCargoBay устанавливает расширенный трюм
; Game.Menus.PrintStatusFieldAndCargoScreen.CargoScreen проверяет поле перед показом вместимости
LargeCargo      DB #00                                                          ; +30, расширенный трюм, признак увеличенной вместимости
; -----------------------------------------
; FCommander.ECM, код устройства и текущая активность
;      7    6    5    4    3    2    1    0
;   +----+----+----+----+----+----+----+----+
;   | ON | LV | LV | LV | LV | LV | LV | LV |
;   +----+----+----+----+----+----+----+----+
;
;   ON      [7]     - флаг, ECM включена до окончания CombatState.EcmTimer
;   LV      [6..0]  - числовая часть кода оборудования, не отдельные флаги
;   Game.Objects.ActivateEnemyECM.Entry сохраняет C с установленным ECM_ON_BIT
;   Game.Combat.ProcessLaserAndEcm.ReadEcm снимает ECM_ON_BIT при истечении таймера
;   Game.Flight.LaunchOrDockShip.Entry также снимает этот бит при стыковке
;   Game.Missions.RatingBountyDamageAndNewCommander.DamageItem повреждает устройство
;   обработчик устанавливает старший бит перед увеличением кода на единицу
;   наличие устройства проверяется по всему байту, а не только ECM_ON_BIT
; -----------------------------------------
ECM             DB #00                                                          ; +31, установленная ECM, бит 7 также участвует в повреждении
; -----------------------------------------
; FCommander.AlienComputer, код устройства и числовой счётчик
;      7    6    5    4    3    2    1    0
;   +----+----+----+----+----+----+----+----+
;   | CT | CT | CT | CT | CT | CT | CT | AC |
;   +----+----+----+----+----+----+----+----+
;
;   AC      [0]     - флаг, установлен ALIEN COMPUTER, ALIEN_OWN_BIT
;   Game.Menus.PrintCombatRankAndEquipment.Entry проверяет его перед выводом названия
;   Game.Extensions.CreateMissileOrMissionCraft.SpendMissile проверяет его при замене ракеты грузом
;   CT      [7..1]  - числовой счётчик обработок удаляемой модели, не отдельные флаги
;   Game.Circles.UpdateThargoidAndBodyCoords.Entry сравнивает младший байт FSpaceObject.Blueprint
;   с LOW Blueprint.Thargoid и при совпадении прибавляет 2 ко всему State.AlienComputer
;   Game.Combat.ReleaseMissileTargets.CheckTarget вызывает обработчик для непустых слотов обычного обхода
;   IX остаётся удаляемым объектом, поэтому одно удаление может дать несколько прибавлений
;   этот счётчик не равен числу уничтоженных кораблей
;   при создании контейнера Game.Objects.InitializeObject.Entry изменяет BC, DE и IY
;   вызывающий цикл их не восстанавливает, этот путь меняет параметры дальнейшего обхода
;   прибавление 2 сохраняет ALIEN_OWN_BIT, только результат всего байта 0 создаёт контейнер
;   Game.Missions.SpecialMessageAndScoopReward.ClassifyScoop увеличивает весь байт при подборе
;   Game.Extensions.UpdateInvasionOnRatingOverflow.Entry проверяет OR двух полных байтов
;   ненулевой State.AlienComputer либо State.MineralLife разрешает дальнейшую проверку войны
;   счётчик без ALIEN_OWN_BIT и состояние погибшей колонии тоже проходят эту проверку
; -----------------------------------------
AlienComputer   DB #00                                                          ; +32, ALIEN COMPUTER, бит 0 означает наличие, остальные биты содержат счётчик событий
; -----------------------------------------
; FCommander.MineralLife, состояние колонии MINERAL LIFE
;      7    6    5    4    3    2    1    0
;   +----+----+----+----+----+----+----+----+
;   | BL | SZ | SZ | SZ | SZ | SZ | SZ | SZ |
;   +----+----+----+----+----+----+----+----+
;
;   BL      [7]     - флаг, проверка жизнеспособности немедленно отклоняет колонию, MIN_BLOCK_BIT
;   Game.Text.CheckMineralLifeColony.Entry выносит этот бит в перенос и возвращается при C=1
;   SZ      [6..0]  - младшие разряды состояния колонии, не независимые флаги
;   Game.Flight.TryColonizeMinerals.Entry записывает количество минералов до подбора новой тонны
;   поле State.Cargo + FGoods.Minerals должно содержать не меньше двух тонн до подбора
;   значение всего State.MineralLife, равное 0, допускает создание колонии
;   Game.Text.CheckMineralLifeColony.Entry требует не меньше трёх тонн после подбора
;   при нехватке минералов записывает весь State.MineralLife = #FF, запрещая повторное создание
;   Game.Extensions.UpdateSpecialCargoStatus.Entry вычитает количество минералов из запаса камней
;   используются State.Cargo + FGoods.Gemstones и State.Cargo + FGoods.Minerals
;   отрицательная разность записывается по модулю 256 во весь State.MineralLife
;   эта запись не является независимым изменением SZ либо MIN_BLOCK_BIT
;   Game.Extensions.AttributeVectorAndEnergyBomb.ConfirmUpgrade сбрасывает состояние колонии
;   Game.Trade.PromptCargoQuantityAndRefugees.UnloadRefugees также обнуляет State.MineralLife
; -----------------------------------------
MineralLife     DB #00                                                          ; +33, MINERAL LIFE, 0 до колонизации, бит 7 запрещает живую колонию
FuelScoops      DB #00                                                          ; +34, топливный ковш, проверяет Game.Travel.UpdateAmbientFlightMessage.CheckScooping
EscapePod       DB #00                                                          ; +35, спасательная капсула
EnergyBomb      DB #00                                                          ; +36, энергетическая бомба
EnergyUnit      DB #00                                                          ; +37, энергетический блок
DockComputer    DB #00                                                          ; +38, стыковочный компьютер
GalacticDrive   DB #00                                                          ; +39, галактический гиперпривод, проверяет Game.Travel.ClearFlightEventsAndHandleJump.CheckJumpKeys
ShipUpgrade     DB #00                                                          ; +3A, Cobra Mk4, #FD после покупки, влияет на уровни оборудования
; -----------------------------------------
; FCommander.Invasion, фаза и величина области вторжения
;      7    6    5    4    3    2    1    0
;   +----+----+----+----+----+----+----+----+
;   | AT | SZ | SZ | SZ | SZ | SZ | SZ | SZ |
;   +----+----+----+----+----+----+----+----+
;
;   AT      [7]     - флаг, код наступления таргонов
;   SZ      [6..0]  - величина фронта, числовое поле, не отдельные флаги
;   0 означает отсутствие вторжения, 1 завершённое состояние, от 2 область активна
;   #81..#FF кодируют наступление, #7F..#02 используются после снятия AT
;   таймер прибавляет NOT State.Invasion, геометрия использует удвоение всего байта
;   десант сбрасывает AT и уменьшает величину до освобождения текущей системы
; -----------------------------------------
Invasion        DB #00                                                          ; +3B, фаза и размер вторжения, #81..FF наступление, #7F..01 отступление
GalaxySeed      FSystemSeed                                                     ; +3C..41, три слова исходного семени галактики
SystemSeed      FSystemSeed                                                     ; +42..47, семя текущей системы, поля FSystemSeed
Technology      DB #00                                                          ; +48, технологический уровень текущей системы, счёт с нуля
Government      DB #00                                                          ; +49, правительство текущей системы, 0..7
MarketStock     FGoods                                                          ; +4A..5A, остатки товаров станции, последний слот обычно нулевой
; -----------------------------------------
; FCommander.Mission3, этап третьей миссии и состояние особой системы с отметкой попадания
;      7    6    5    4    3    2    1    0
;   +----+----+----+----+----+----+----+----+
;   | .. | .. | .. | .. | HI | ST | ST | ST |
;   +----+----+----+----+----+----+----+----+
;
;   HI      [3]     - флаг, обработчик попадания отметил специальную цель
;   ST      [2..0]  - числовой этап миссии, штатные значения 0..6
;   бит 2 кода ST проверяется после установки HI, это проверка части этапа
;   при ST.2=0 обработчик сбрасывает State.Mission3 и назначает State.LegalStatus = #FF
;   при ST.2=1 отметка HI сохраняется, затем проверяется MS_ACCEPT_BIT в State.MissionFlags
;   Game.Text.HandleSpecialObjectMission.Entry изменяет отметку попадания и законность
;   Game.Missions.OfferThirdMission.Entry и Game.Travel.LaserTypeAndArrivalEvents.ArrivalEvents
;   обслуживают последовательность третьей миссии
;   Game.Text.OfferRegionDependentMission.OccupiedSystem устанавливает состояние 4 для войны
;   Game.Universe.CheckSpecialSystemOrRandom.Entry устанавливает 4 при Z от проверки особой системы
; -----------------------------------------
Mission3        DB #00                                                          ; +5B, этап третьей миссии и особое состояние системы, см. схему и обработчики выше
; -----------------------------------------
; FCommander.MissionFlags, общие отметки миссий, оборудования и военных заданий
;      7    6    5    4    3    2    1    0
;   +----+----+----+----+----+----+----+----+
;   | M3 | CL | CG | R5 | R4 | R3 | R2 | R1 |
;   +----+----+----+----+----+----+----+----+
;
;   M3      [7]     - флаг, принято предложение третьей миссии, MS_ACCEPT_BIT
;   Game.Missions.OfferThirdMission.AcceptMission устанавливает его при ответе Y
;   Game.Missions.CompleteThirdMission.Entry не снимает этот флаг при выдаче награды
;   при State.Mission3 = 4 блокируется обработка ECM в двух входах
;   Game.Combat.ProcessLaserAndEcm.CheckEcmLock проверяет ECM игрока
;   Game.Motion.ProcessObjectEnergyAndTactics.CheckEcm проверяет ответный ECM объекта
;   Game.Menus.PrintCombatRankAndEquipment.NextEquipment использует M3 для подписи State.ECM
;   подпись выводится входом Game.Menus.PrintCombatRankAndEquipment.SpecialName вместо обычного имени
;   CL      [6]     - флаг, получено устройство маскировки, MS_CLOAK_BIT
;   Game.Missions.SpecialMessageAndScoopReward.ScoopItem ставит его при коде предмета #FF
;   Game.Flight.ToggleCloakingDevice.Entry проверяет разрешение клавиши Y
;   Game.Menus.PrintCombatRankAndEquipment.Entry выводит устройство после перебора лазеров
;   Game.Universe.InitializeExtendedObjectMetadata.StoreFlags учитывает CL при выборе FX_ENERGY_BIT
;   Game.Objects.GenerateSpaceTraffic.Entry требует CL=0 вместе с R2=1 для особой встречи
;   CG      [5]     - флаг, трюм занят беженцами либо десантом, MS_CARGO_BIT
;   Game.Trade.MissionRegionMetric.BoardRefugees ставит его после Y и очищает трюм с State.FreeCargo
;   Game.Charts.NextScreenCharacterRowAndRefugees.OfferRefugees запрещает повторное предложение
;   Game.Text.OfferRegionDependentMission.OfferVolunteer также проверяет занятость трюма
;   Game.Extensions.PrintCargoAndMessageBanks.Entry выводит особый груз
;   Game.Universe.SelectSpecialCargoText.Entry выбирает подпись беженцев либо десанта
;   Game.Trade.PromptCargoQuantityAndRefugees.UnloadRefugees снимает CG при высадке
;   Game.Combat.HandleEscapeCapsule.ClearCargo снимает CG при запуске спасательной капсулы
;   Game.Extensions.CreateMissileOrMissionCraft.Entry снимает CG при выпуске десанта
;   R5      [4]     - флаг, пятая отметка общей последовательности заданий, MS_MARK5_BIT
;   отдельной команды установки этого бита в разобранном игровом коде не найдено
;   смысл конкретного выполненного задания по одному чтению не определяется
;   R4      [3]     - флаг, награда за третью миссию выдана, MS_MARK4_BIT
;   Game.Missions.CompleteThirdMission.Entry устанавливает эту отметку
;   R3      [2]     - флаг, третья миссия выдана либо система освобождена десантом, MS_MARK3_BIT
;   Game.Travel.GetSalePriceAndMissionFlags.ThirdMission ставит R3 вместе с State.Mission3 = 1
;   Game.Text.HandleSpecialObjectMission.DestroyStation ставит R3 при освобождении занятой системы
;   R2      [1]     - флаг, вторая отметка общей последовательности заданий, MS_MARK2_BIT
;   Game.Travel.GetSalePriceAndMissionFlags.SecondMission устанавливает её при выдаче события
;   Game.Text.NextDescriptionRandom.CheckWarSupply ставит R2 после военной поставки еды либо оружия
;   Game.Objects.GenerateSpaceTraffic.Entry читает комбинацию R2=1 и CL=0
;   R1      [0]     - флаг, первая отметка общей последовательности заданий, MS_MARK1_BIT
;   Game.Travel.GetSalePriceAndMissionFlags.GrantMission ставит её вместе с State.Mission1 = 1
;   Game.Universe.ApplyEnhancedFlightControl.CheckRefugees проверяет допуск высадки беженцев
;   при активном вторжении допустимая высадка доходит до Game.Universe.ApplyEnhancedFlightControl.MarkResult
;   этот вход устанавливает R1, при State.Invasion < 2 отметка не меняется
;   Game.Text.OfferRegionDependentMission.FindRewardBit проверяет отметку по номеру военного этапа
;   число вращений допускает чтение битов 0..6, включая общие отметки и флаги CG/CL
;   Game.Travel.GetSalePriceAndMissionFlags.GrantMission проверяет входное A AND State.MissionFlags
;   Game.Extensions.UpdateInvasionOnRatingOverflow.Entry применяет MS_START_MASK при начале войны
;   маска сохраняет M3, CL и R5, очищает CG и R1..R4
;   R1..R3 имеют общие применения в обычных миссиях и военных заданиях
; -----------------------------------------
MissionFlags    DB #00                                                          ; +5C, флаги наград, особого оборудования и занятого миссией трюма
SunPosition     FSpacePosition                                                  ; +5D..65, координаты светила, копируются в FlightState.Sun
                ends


                ; проверка размера и критических границ сериализации
                ASSERT FCommander == #66
                ASSERT FCommander.LegalStatus == #0B
                ASSERT FCommander.Rating == #0C
                ASSERT FCommander.RankState == #0E
                ASSERT FCommander.JumpCount == #0F
                ASSERT FCommander.JumpFlags == #10
                ASSERT FCommander.CashHigh == #12
                ASSERT FCommander.Cargo == #17
                ASSERT FCommander.Cargo + FGoods == FCommander.FreeCargo
                ASSERT FCommander.GalaxySeed == #3C
                ASSERT FCommander.SystemSeed == #42
                ASSERT FCommander.MarketStock == #4A
                ASSERT FCommander.MarketStock + FGoods == FCommander.Mission3
                ASSERT FCommander.SunPosition == #5D

                endif
