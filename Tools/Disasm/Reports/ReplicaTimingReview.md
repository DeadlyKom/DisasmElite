# План проверки периодических процессов реплики Elite

Материал для нового проекта, 2026-10-21. Прочитаны инструкции текущей версии и существующие отчёты. Новые тесты, сборки и измерения не запускались. Исходники не изменялись. Это каталог будущих проверок, а не заявление о совпадении работающей реплики.

## Границы доказательства

- **static** — поведение установлено чтением инструкций. Счёт относится к вызовам, итерациям или операциям вывода, а не автоматически к секундам.
- **existing executed report** — существующий отчёт описывает исполнение исходных байтов в ограниченной среде. Здесь применим к выбору повреждений MECH-03.
- **measurements missing** — ещё нужен захват оригинала с аппаратными прерываниями, ROM, портами, длительностями и внешним вводом. Все паспорта требуют этого дополнения для утверждений о темпе реального полёта.

Аппаратный период прерывания, принятый вход IM2, вызов логической процедуры и готовое изображение — четыре разных события. Их нельзя заранее считать одним тиком. Быстрый рендер способен изменить число принятых прерываний между логическими вызовами, управление, звук и темп механик.

Структуры снимков: [FCommander](../../../Includes/Structs/Commander.inc), [FInputState](../../../Includes/Structs/InputState.inc), [FGauge/FGaugeState](../../../Includes/Structs/Gauge.inc), [FCoordinate/FSpaceObject](../../../Includes/Structs/SpaceObject.inc), [FSystemSeed/FGalaxyState/FFlightMessage/FFlightEvent/FSoundState/FInputMotion](../../../Includes/Structs/GameWorkspace.inc). `FlightState` и `CombatState` — пространства имён разнесённых полей, не существующие физические F-типы. Включать в снимки и рабочие байты операндов изменяемых инструкций.

## Контрольные точки

### TIME-01 — Порядок основного цикла и различия экранов

- **Граница:** `Game.Flight.MainGameLoop.Entry`, ветка `FlightFrame`, затем `CheckDeath` и следующий вход. [MainGameLoop.asm](../../../Source/Game/Flight/MainGameLoop.asm).
- **Состояние:** `FlightState.View/FlightStatus/SpaceMode/ControlsLocked/PlayerDead`, `CombatState.SpawnCounter`, InputMotion, FlightMessage, JumpCountdown, объекты и приборы. Сохранять последовательность достигнутых входов, а не только окончательные байты.
- **Ожидание:** активный проход содержит один UpdateObjectsAndWeapons. При View<4 порядок включает звёзды → сообщения → объекты/оружие → туннель → взрывы/экран/сканер → приборы → маскировку → боевое управление/урон → близость светил. При View>=4 сначала объекты/оружие, затем урон, расширение новы, сообщения и **8 HALT** с обработкой карты. ProcessLaserAndEcm здесь возвращается до лазера и ECM. При FlightStatus=0 обычный полётный проход не выполняется.
- **Сценарии:** виды 0/3/4, полёт/станция, обычное/особое пространство, смена вида при удержании огня и активном ECM, событие/прыжок на границе прохода, гибель.
- **Статус доказательства:** static; measurements missing. Постоянная частота логического прохода из этих инструкций не следует.

### TIME-02 — Принятый IM2 и запрет прерываний

- **Граница:** `Game.Input.InterruptGateAndAcceleration.Entry` → `Game.Input.KeyboardControlInterrupt.Entry` → возврат. [InterruptGateAndAcceleration.asm](../../../Source/Game/Input/InterruptGateAndAcceleration.asm), [KeyboardControlInterrupt.asm](../../../Source/Game/Input/KeyboardControlInterrupt.asm), [EnableInterruptMode2.asm](../../../Source/Game/Input/EnableInterruptMode2.asm).
- **Состояние:** I/IFF/SP, InputStack, InterruptGate, KeyboardCall, InputState, InputMotion, SoundState, SoundRequests. Рабочий стек обработчика начинается с Memory.Screen+#0020.
- **Ожидание:** один полный обработчик вызывает сканирование, интегратор управления и диспетчер звука **по одному разу**, в этом порядке. Сохраняются HL, DE, BC, AF, IX, IY. DI действует до EI/RET. Установка IM2 задаёт I=#FD, но не частоту аппаратного источника. [ProjectSafely](../../../Source/Game/Extensions/PrintCargoAndMessageBanks.asm) делает DI, ставит RET в InterruptGate, меняет SP, затем восстанавливает JR и делает EI.
- **Сценарии:** обычный вход, запрос во время DI, проекция на временном стеке, подмена KeyboardCall демонстрацией, звук выключен/включён и длинный пакет.
- **Статус доказательства:** static; measurements missing. В стенде раздельно считать аппаратные запросы, принятые IRQ и полные вызовы подсистем.

### TIME-03 — Пауза и блокирующие переходные циклы

- **Граница:** блокирующие `HandlePauseMenu.Entry`, `LaunchOrDockShip.Entry`, `AnimateTransitionTunnel.Entry`, `MainGameLoop.DeathFrame/DeathDelay`. [HandlePauseMenu.asm](../../../Source/Game/Flight/HandlePauseMenu.asm), [LaunchOrDockShip.asm](../../../Source/Game/Flight/LaunchOrDockShip.asm), [AnimateTransitionTunnel.asm](../../../Source/Game/Flight/AnimateTransitionTunnel.asm), [MainGameLoop.asm](../../../Source/Game/Flight/MainGameLoop.asm).
- **Состояние:** InputState.Config/LastKey, InputMotion, ViewKeyLock, JumpMode, TunnelFrames/Depths/Rings/Limit/Finish, ControlsLocked, SoundState.
- **Ожидание:** пауза ждёт отпускания/новых клавиш через HALT, не обновляет обычный мир. При сохранённом View<4 IM2 продолжает интегрировать управление и звук. Стыковка: первоначальный вызов туннеля плюс **47** итераций DockFrame. Старт: первоначальный туннель плюс **36** LaunchFrame и **11** FinalFrame. Гибель: **30** DeathFrame, затем **50 HALT**. Эти циклы различаются составом действий. TunnelFrames=#42 при гиперпереходе не доказывает 66 одинаковых экранных кадров: действуют изменяемые переходы и пределы.
- **Сценарии:** пауза с удерживаемым поворотом/тормозом и звуком, выход из паузы, старт/стыковка со звуком и без, гиперпереход/межзвёздный выход, гибель с эффектами.
- **Статус доказательства:** static; measurements missing. Общая длительность и число опубликованных кадров гипертуннеля требуют трассы входов и операндов.

### TIME-04 — Генераторы, перенос и зависимость от R

- **Граница:** `Game.Math.NextRandom`, `Game.Combat.NextRandomByte.Entry`, два чтения R в `Game.Universe.UpdateAndDrawStarField.AddJitter`, `RespawnStar`. [NextRandom.asm](../../../Source/Game/Math/NextRandom.asm), [NextRandomByte.asm](../../../Source/Game/Combat/NextRandomByte.asm), [UpdateAndDrawStarField.asm](../../../Source/Game/Universe/UpdateAndDrawStarField.asm).
- **Состояние:** GalaxyState.WorkingSeed/Memory.RandomSeed — три слова, RandomState — два байта, входной/выходной CY, R, StarPoints, StarView, отдельный TextSeed, FlightState.RandomByte как сохранённый параметр рынка.
- **Ожидание:** трёхсловный генератор: `(x,y,z) → (y,z,x+y+z mod 65536)`. Байтовый: `B=(2H+CY) mod 256`, новый H=`(B+L+перенос удвоения) mod 256`, новый L=B. Пересоздание звезды делает **2 вызова** байтового генератора. В достигнутом AddJitter **2 LD A,R**, результат меняет координаты. Одних seed и списка клавиш недостаточно для полного детерминизма.
- **Сценарии:** один seed при CY=0/1, смена вида, звезда на границе диапазона, обычное/особое пространство, быстрый полёт, разная нагрузка рендера при том же вводе.
- **Статус доказательства:** static; measurements missing. Рекомендация: эталон записывает порядок RNG-вызовов, CY и R либо воспроизводит полную последовательность Z80. Разделение визуального генератора и механик — последующее явное решение, не допустимая молчаливая подмена.

### INPUT-01 — Сканирование клавиатуры и событийные биты

- **Граница:** `Game.Input.ScanKeyboardMatrix.Entry` → `FinishKeyboardRowAndSelectJoystick.Entry` → нормализация. [ScanKeyboardMatrix.asm](../../../Source/Game/Input/ScanKeyboardMatrix.asm), [FinishKeyboardRowAndSelectJoystick.asm](../../../Source/Game/Input/FinishKeyboardRowAndSelectJoystick.asm), [ResetDemoAndNormalizeControls.asm](../../../Source/Game/Input/ResetDemoAndNormalizeControls.asm).
- **Состояние:** FInputState целиком, RowPort, KeyReadTail, KeyboardCall, значения портов в порядке чтения.
- **Ожидание:** штатный обход **8 строк по 5 битов**. На входе обнуляется NumberKeys, LastKey=#FF, остальные байты нельзя считать полностью очищенными. Режим управления, инверсия и конфликты применяются после сканирования; потребители позднее снимают события.
- **Сценарии:** нет клавиш, отдельная клавиша каждой строки, комбинации/конфликты, режимы управления, удержание, импульс между логическими проходами, демонстрационный перехват.
- **Статус доказательства:** static; measurements missing. Дополнительно записывать прямые чтения порта в [CreateMissileOrMissionCraft](../../../Source/Game/Extensions/CreateMissileOrMissionCraft.asm), [ScanUpgradeKeyRow](../../../Source/Game/Circles/ScanUpgradeKeyRow.asm), [ApplyEnhancedFlightControl](../../../Source/Game/Universe/ApplyEnhancedFlightControl.asm), которые обходят обычный снимок клавиатуры.

### INPUT-02 — Интеграция крена, тангажа и скорости

- **Граница:** `Game.Input.IntegrateFlightControls.Entry` → `ClampAndStoreFlightSpeed.StoreSpeed`. [IntegrateFlightControls.asm](../../../Source/Game/Input/IntegrateFlightControls.asm), [InterruptGateAndAcceleration.asm](../../../Source/Game/Input/InterruptGateAndAcceleration.asm), [ClampAndStoreFlightSpeed.asm](../../../Source/Game/Input/ClampAndStoreFlightSpeed.asm).
- **Состояние:** InputMotion.Roll/Pitch/Speed, InputState.FlightKeys/Config, View. Углы — знак/модуль, не signed int16.
- **Ожидание:** View>=4 сразу возвращает. За допущенный вызов шаг крена #00FF, тангажа #0066, скорости #00A0. Автоторможение свободных осей при разрешении — #003C/#0024. Противоположные одновременные команды сохраняют величину. Реверс при INPUT_STOP_BIT обнуляет ось, иначе вычитает полный шаг. Рост углов отменяется при бите 4 H, скорости — бите 5 H. Отрицательный результат торможения ограничивается нулём. Штатный выход обнуляет FlightKeys.
- **Сценарии:** знак/нулевой модуль, оба направления, предел до/после шага, INPUT_STOP_BIT/INPUT_BRAKE_BIT, View=3/4, скорость около нуля/предела.
- **Статус доказательства:** static; measurements missing. Сравнивать слова целиком, не только старшие байты.

### INPUT-03 — Передача управления в полётное состояние

- **Граница:** `Game.Flight.UpdateFlightControlGauges.Entry` из начала MainGameLoop при ControlsLocked=0. [UpdateFlightControlGauges.asm](../../../Source/Game/Flight/UpdateFlightControlGauges.asm).
- **Состояние:** InputMotion, FlightState.Roll/Pitch/Speed, соответствующие GaugeState, ControlsLocked.
- **Ожидание:** мир получает старшие байты InputMotion. Приборы крена/тангажа откладывают модуль от 21 по знаку, скорость — `5*Speed+5` с байтовой арифметикой. Между копированиями возможно несколько IM2. ControlsLocked блокирует копирование, но не проверяется интегратором IM2.
- **Сценарии:** 0/1/несколько интеграций между копиями, блокировка/разблокирование, пауза с накоплением управления, границы младших байтов.
- **Статус доказательства:** static; measurements missing. Это отдельная граница передачи управления в мир.

### MECH-01 — Восстановление банков энергии и щитов

- **Граница:** `Game.Combat.RecoverPlayerEnergy.Entry`, отдельный `RecoverOneEnergyUnit.Entry`. [RecoverPlayerEnergy.asm](../../../Source/Game/Combat/RecoverPlayerEnergy.asm), [RepeatEnergyRecovery.asm](../../../Source/Game/Screen/RepeatEnergyRecovery.asm), [RecoverOneEnergyUnit.asm](../../../Source/Game/Combat/RecoverOneEnergyUnit.asm), [RecoverShieldUnit.asm](../../../Source/Game/Combat/RecoverShieldUnit.asm).
- **Состояние:** State.EnergyUnit, GaugeState + FGaugeState.Energy4.Current … Energy1.Current, FrontShield.Current, RearShield.Current.
- **Ожидание:** EnergyUnit=0 даёт **1** единичный проход. Ненулевой u даёт **257-u**, включая последний провал после возврата: #FF→2, #FE→3, #FD→4. Единичный проход ищет первый банк, не равный #A0, от Energy4 к Energy1 и увеличивает его на 1. Только когда все четыре уже #A0, увеличиваются оба щита, каждый до #A0. В ApplyPlayerDamage восстановление предшествует урону.
- **Сценарии:** каждый первый неполный банк, последний недостающий пункт банка, все банки полны и один/два неполных щита, коды блока 0/#FF/#FE/#FD/1, нештатный банк выше #A0 для фиксации проверки на равенство.
- **Статус доказательства:** static; measurements missing. Скорость в единицах за секунду не измерена.

### MECH-02 — Урон щитам и расход банков энергии

- **Граница:** `Game.Combat.ApplyPlayerDamage.Entry`, отдельные DamageShieldAndEnergy/DrainEnergyBanks. [ApplyPlayerDamage.asm](../../../Source/Game/Combat/ApplyPlayerDamage.asm), [DamageShieldAndEnergy.asm](../../../Source/Game/Combat/DamageShieldAndEnergy.asm), [DrainEnergyBanks.asm](../../../Source/Game/Combat/DrainEnergyBanks.asm), [UpdateAllSpaceObjects.asm](../../../Source/Game/Combat/UpdateAllSpaceObjects.asm).
- **Состояние:** FrontDamage, RearDamage, EnergyDrain, ShieldHits, CloakActive, банки/щиты, FlightStatus, PlayerDead.
- **Ожидание:** при FlightStatus=0 ранний выход. Начало объектного прохода обнуляет накопленные урон/расход. Затем восстановление → передний щит → задний щит → общий расход. Урон щиту — до **4 вычитаний C**. При заёме щит обнуляется, одно повторение расходуется на пробитие, оставшиеся B переходят на банки. DrainEnergyBanks начинает с Energy1, при нехватке обнуляет банк и пробует **полный C** на следующем, не арифметический остаток. B уменьшается только после успешного вычитания. Общий расход имеет B=4, ненулевой CloakActive добавляет к C единицу. Нулевой урон одному щиту уменьшает ненулевой ShieldHits на 1, при двух нулевых возможны два уменьшения.
- **Сценарии:** C=0, щит C-1/C/4C, пробитие на каждом повторении, пустые промежуточные банки, точное обнуление последнего банка и следующий расход, CloakActive 0/1/#FF, EnergyDrain=#FF с переполнением добавки.
- **Статус доказательства:** static; measurements missing. Проверять алгоритм перехода между банками, а не только суммарную энергию.

### MECH-03 — Выбор повреждённого оборудования и груза

- **Граница:** `Game.Missions.DispatchEquipmentDamage.Entry` → `Game.Missions.RatingBountyDamageAndNewCommander.DamageItem`. [DamageShieldAndEnergy.asm](../../../Source/Game/Combat/DamageShieldAndEnergy.asm), [DispatchEquipmentDamage.asm](../../../Source/Game/Missions/DispatchEquipmentDamage.asm), [RatingBountyDamageAndNewCommander.asm](../../../Source/Game/Missions/RatingBountyDamageAndNewCommander.asm).
- **Состояние:** ShieldHits, FlightState.RandomByte, FlightMessage.Token/DamagedItem, Fuel, оборудование, Cargo/FreeCargo, четвёртая запись FlightEvents.
- **Ожидание:** прямой вызов при уроне >=#46. После пробития с оставшимися повторениями ShieldHits+=5, значение >=#0D вызывает дополнительную проверку. Token=#FD подавляет новое повреждение. Индекс `RandomByte >> 2`, нового RNG нет: 0 — топливо; 1..6 — ECM/FuelScoops/EscapePod/EnergyBomb/EnergyUnit/DockComputer; 7..16 — грузовые индексы 2..11; >=17 — ничего. Ненулевое устройство получает `((v OR #80)+1) mod 256`, ненулевой груз уменьшается на 1 и освобождает тонну.
- **Сценарии:** все 256 RandomByte, Token=#FD/другой, пустые/непустые поля, оборудование #7F/#FF/#FE, ShieldHits около 13, повторные попадания и затухание накопителя.
- **Статус доказательства:** static + existing executed report [MissionRewardsValidation.json](MissionRewardsValidation.json), **256 damage_selector** случаев на исходных байтах SkoolKit 10.1 без ROM/прерываний. Measurements missing для частоты и последовательности повреждений в полном полёте.

### MECH-04 — Охлаждение, темп и урон лазера

- **Граница:** `Game.Combat.ProcessLaserAndEcm.Entry` → `FirePlayerLaser.Entry` → обновление цели/луча. [ProcessLaserAndEcm.asm](../../../Source/Game/Combat/ProcessLaserAndEcm.asm), [FirePlayerLaser.asm](../../../Source/Game/Combat/FirePlayerLaser.asm).
- **Состояние:** LaserRaster.TriggerHeld, DeviceKeys, GaugeState.LaserHeat.Current, лазеры четырёх видов, SpawnCounter, EnergyDrain, CrosshairTarget, FSpaceObject.Energy/Flags/Flags2/Target, SoundRequests.
- **Ожидание:** достигнутый FirePlayerLaser охлаждает на **2**, минимум 0. Обёртка не вызывает его при View>=4, гибели или отсутствии лазера выбранного вида. После охлаждения температура >=#90 запрещает огонь. Новый спуск стреляет сразу, удержание типа 1 требует `(SpawnCounter AND 1)=0`, типа 4 — `(SpawnCounter AND 7)=0`, остальных — маска 0. SpawnCounter уменьшается раз на объектный проход. Выстрел добавляет EnergyDrain на 1, нагрев на 8 у типов 1/4 либо 10 у остальных, максимум #A0. Урон: 15 для типов <3, 23 для 3, 50 для остальных допустимых типов.
- **Сценарии:** новый/удерживаемый/отпущенный спуск, все фазы маски, температура перед вызовом #91/#92, охлаждение 0/1/2, смена вида на направление без лазера, пустая/специальная/взрывающаяся/неуязвимая цель, точное исчерпание энергии.
- **Статус доказательства:** static; measurements missing. FPS не заменяет SpawnCounter и условия вызова.

### MECH-05 — Включение, длительность и расход ECM

- **Граница:** `Game.Combat.ProcessLaserAndEcm.ReadEcm`, `Game.Objects.ActivateEnemyECM.Entry`. [ProcessLaserAndEcm.asm](../../../Source/Game/Combat/ProcessLaserAndEcm.asm), [ActivateEnemyECM.asm](../../../Source/Game/Objects/ActivateEnemyECM.asm).
- **Состояние:** EcmTimer, State.ECM, DeviceKeys, EnergyDrain, SoundRequests, MissionFlags/Mission3.
- **Ожидание:** допустимый запрос при таймере 0 и ненулевом оборудовании ставит ECM_ON и таймер **10**, без начисления расхода в самом входе включения. Каждый следующий допущенный вызов уменьшает таймер, ставит звуковой запрос и при ненулевом коде оборудования добавляет 1 расхода. Переход 1→0 снимает ECM_ON_BIT. View>=4, гибель и MS_ACCEPT_BIT совместно с Mission3=4 пропускают участок. Команда снимается при достижении ReadEcm.
- **Сценарии:** без оборудования, повторное нажатие, таймер 10/1/0, карта и обратно, запрет миссии до/во время ECM, изменение оборудования при активном таймере, реакция ракет на тот же таймер.
- **Статус доказательства:** static; measurements missing. Длительность — 10 последующих допущенных уменьшений, не секунды и не обязательно 10 аппаратных кадров.

### MECH-06 — Захват цели и пуск ракеты

- **Граница:** `Game.Combat.HandleMissileControls.Entry`, DispatchObjectAction, FinishLaunch. [HandleMissileControls.asm](../../../Source/Game/Combat/HandleMissileControls.asm).
- **Состояние:** State.Missiles, AimState, MissileTarget, CrosshairTarget, DeviceKeys, FlightEvents, SoundRequests, занятость слотов.
- **Ожидание:** AimState 0/1/2 — снят/поиск/захват. При поиске и пустом MissileTarget ненулевая цель прицела записывается до команд, состояние становится 2, вызывается Rom.Beeper с HL=#0070, DE=#0060. Приоритет команд: взвод → пуск → снятие. Пуск только при состоянии 2, передаёт `(MissileTarget << 4) OR 2`. Успех сбрасывает AimState и ставит SND_MISSILE_BIT, отказ ставит первое событие очереди.
- **Сценарии:** нет ракет, смена/потеря цели, одновременные команды, захват и пуск в одном вызове, нет свободного слота, повторный пуск, общая настройка звука выключена — Rom.Beeper здесь вызывается без её проверки.
- **Статус доказательства:** static; measurements missing. Расход ракеты и параметры нового объекта сравнивать вместе с диспетчером объектов.

### MECH-07 — Периодическая проверка маскировки

- **Граница:** `Game.Flight.ToggleCloakingDevice.Entry`, ApplyPlayerDamage и UpdateAmbientFlightMessage.DropCloak. [ToggleCloakingDevice.asm](../../../Source/Game/Flight/ToggleCloakingDevice.asm), [UpdateAmbientFlightMessage.asm](../../../Source/Game/Travel/UpdateAmbientFlightMessage.asm).
- **Состояние:** CloakDivider/CloakActive, SystemKeys, MissionFlags, Energy3.Current/Energy4.Current, враждебность станции, Danger.
- **Ожидание:** после срабатывания делитель 2, штатно проверка через **2 вызова**, первоначально 1. Y снимается перед возвратом/ожиданием, срабатывающий путь имеет **1 HALT** для нового опроса. Наличие устройства обязательно. DEC переводит 1→0 в выключение, а 0→#FF до проверки Energy3>=40. При отказе #FF остаётся и затем считается ненулевой маскировкой для расхода. Фоновая проверка Energy4<159 снимает CloakActive.
- **Сценарии:** короткое/долгое Y, отсутствие устройства, Energy3=39/40, состояние 0/1/#FF, низкая Energy4 при занятой/свободной строке сообщения, карта/кабина, HALT обновления атрибутов.
- **Статус доказательства:** static; measurements missing. Не исправлять молча промежуточное #FF в совместимом режиме.

### MECH-08 — Близость светил и нагрев кабины

- **Граница:** `Game.Screen.UpdateCelestialProximity.Entry` → `Game.Circles.SetCabinHeatAndContinueFilledCircle.Entry` либо дальняя ветка. [UpdateCelestialProximity.asm](../../../Source/Game/Screen/UpdateCelestialProximity.asm), [SetCabinHeatAndContinueFilledCircle.asm](../../../Source/Game/Circles/SetCabinHeatAndContinueFilledCircle.asm).
- **Состояние:** Sun/Planet, SpaceMode, SunScooping, CompassState.SunNear/PlanetNear, CabinHeat.Current/Altitude.Current, PlayerDead.
- **Ожидание:** температура вычисляется геометрически, самостоятельного линейного охлаждения по таймеру здесь нет. После VectorLength преобразованная дистанция сравнивается с #4000 для гибели и #2000 для ковша, ScaleProximity даёт H температуры. Сохранение пишет H при SpaceMode=0, иначе 0. Дальняя ветка обходит запись температуры и SunScooping, поэтому нельзя считать их автоматически обнулёнными при удалении. В достигнутой ближней ветке SunScooping записывается 0 либо 1.
- **Сценарии:** старшие модули координат 0/ненулевые, нулевая нормированная длина, обе стороны порогов после преобразования, удаление после установленного SunScooping, особое пространство, новая система.
- **Статус доказательства:** static; measurements missing. Пороги не называются градусами или километрами без доказательства масштаба.

### MECH-09 — Периодическая заправка и прибор топлива

- **Граница:** `Game.Travel.UpdateAmbientFlightMessage.CheckScooping` → `SetFuelAndGauge.Entry`, покупка/расход/EmptyFuelWithWarning. [UpdateAmbientFlightMessage.asm](../../../Source/Game/Travel/UpdateAmbientFlightMessage.asm), [SetFuelAndGauge.asm](../../../Source/Game/Travel/SetFuelAndGauge.asm), [EmptyFuelWithWarning.asm](../../../Source/Game/Travel/EmptyFuelWithWarning.asm).
- **Состояние:** Fuel, FuelScoops, SunScooping, Energy4.Current/Fuel.Current, FlightMessage.Frames/QueuePhase.
- **Ожидание:** +**1** топлива только при достигнутой фоновой ветке, Energy4>=159, ненулевом SunScooping и наличии ковша. Активное сообщение откладывает эту ветку. SetFuelAndGauge насыщает вход >=71 до 70, прибор=`2*fuel+floor(fuel/4)`. Скорость черпания зависит от очереди и времени жизни сообщений.
- **Сценарии:** топливо 0/69/70, без ковша, Energy4=158/159, постоянный SunScooping, занятая строка, конкурирующие события, повреждение пустого/полного бака, покупка и прыжок.
- **Статус доказательства:** static; measurements missing. Измерить число вызовов очереди между двумя прибавками топлива.

### MECH-10 — Очередь сообщений и срок показа

- **Граница:** `Game.Travel.SelectQueuedFlightMessage.Entry/SetLifetime`, `SetMessageCoordinatesAndRender.TickMessage`. [SelectQueuedFlightMessage.asm](../../../Source/Game/Travel/SelectQueuedFlightMessage.asm), [SetMessageCoordinatesAndRender.asm](../../../Source/Game/Travel/SetMessageCoordinatesAndRender.asm), [UpdateAmbientFlightMessage.asm](../../../Source/Game/Travel/UpdateAmbientFlightMessage.asm).
- **Состояние:** FFlightMessage, **10** FFlightEvent, JumpCountdown, View, TextScreenHigh, XorOpcode.
- **Ожидание:** каждый вызов сначала обслуживает прыжок и опасность. При Frames>0 уменьшается Frames, нового поиска нет. Печать TickMessage только при **прежнем Frames>=4** и View<4. Новое обычное сообщение получает 14, занимает 14 последующих уменьшений, из которых 11 с прежними 14..4 допускают печать. При пустой строке QueuePhase увеличивается: нечётная фаза — фон, чётная — первое ожидающее событие из десяти. RepeatTimer загружается 70 и уменьшается только при достижении своей фоновой ветки.
- **Сценарии:** Frames=0/1/3/4/14, View=3/4, все события одновременно, постоянно возобновляемая тревога, миссионное предупреждение, #FD/#E2 с параметром, прыжок при занятой очереди.
- **Статус доказательства:** static; measurements missing. Первый RET C сейчас ошибочно прокомментирован как проверка экрана: инструкции сравнивают прежний срок, View загружается позднее.

### MECH-11 — Отсчёт и завершение гиперперехода

- **Граница:** `ClearFlightEventsAndHandleJump.CheckJumpKeys` → `TickJumpCountdown.Entry` → `CommitJumpFuelAndMishap.Entry` либо галактическая ветка, все в Game.Travel. [ClearFlightEventsAndHandleJump.asm](../../../Source/Game/Travel/ClearFlightEventsAndHandleJump.asm), [TickJumpCountdown.asm](../../../Source/Game/Travel/TickJumpCountdown.asm), [CommitJumpFuelAndMishap.asm](../../../Source/Game/Travel/CommitJumpFuelAndMishap.asm).
- **Состояние:** ViewJumpKeys, JumpCountdown/JumpMode, Frames, Fuel/GalacticDrive/LegalStatus/Mission1/Mission3, Distance/TargetSeed, SpaceMode, MissionNotice.
- **Ожидание:** команды снимаются до проверок, активный отсчёт не перезапускается. Обычный прыжок требует ненулевой Distance с H=0 и топлива, галактический — обеих клавиш и привода. Старт задаёт **21**. Каждый вызов таймера уменьшает на 1, переход 1→0 выполняет прыжок, иначе печатается прежнее значение>>1. Первое уменьшение возможно в том же основном проходе, что старт. Обычный commit списывает Distance и делит LegalStatus на 2, но Mission1!=0 ведёт в отдельный общий сброс миссий. Межзвёздный выход зависит от INPUT_MJ_BIT и SelectJumpAndContinueLeftFill: сохранённый RandomByte и условный NextRandomByte участвуют разными путями.
- **Сценарии:** расстояние 0/ровно топливо/топливо+1/H!=0, повторная команда, таймер 21/2/1/0, карта/кабина, привод отсутствует, старые миссии, принудительный/условный межзвёздный выход, пауза/блокирующий звук.
- **Статус доказательства:** static; measurements missing. 21 — число допущенных уменьшений, не секунды и не обязательно аппаратные периоды.

### MECH-12 — Накопитель времени вторжения

- **Граница:** `Game.Combat.UpdateClockAndRotateDistantBodies.Entry` из `Game.Extensions.UpdateStationAndSpecialShips.Entry`. [UpdateClockAndRotateDistantBodies.asm](../../../Source/Game/Combat/UpdateClockAndRotateDistantBodies.asm), [UpdateStationAndSpecialShips.asm](../../../Source/Game/Extensions/UpdateStationAndSpecialShips.asm), [UpdateStationCoordinates.asm](../../../Source/Game/Universe/UpdateStationCoordinates.asm).
- **Состояние:** InvasionClock (16 бит), State.Invasion, CargoEvent, StationFar, энергия станции, SpaceMode.
- **Ожидание:** вызов добавляет `255-Invasion` к 16-битному накопителю. Только полное переполнение меняет Invasion. 0/1 сохраняются, 2..#7F уменьшаются, #80..#FE увеличиваются и ставят событие #82/#F0. Ветка переполнения #FF записала бы #7F, но при неизменном #FF добавка нулевая, самостоятельно она недостижима. Для фиксированного u<255 от c до ближайшего переполнения нужно `ceil((65536-c)/(255-u))` вызовов; после изменения u формула пересчитывается. Особое пространство пропускает станционный путь, UpdateStationCoordinates также выходит при StationFar=0 и ненулевой энергии станции.
- **Сценарии:** u=0/1/2/#7F/#80/#FE/#FF, c около #FFFF, карта/кабина, особое пространство, далёкая/активная станция, уже ожидающее событие.
- **Статус доказательства:** static; measurements missing. Темп войны привязан к допущенным станционным обновлениям, не просто общему времени процесса.

### MECH-13 — Рост новы и гибель игрока

- **Граница:** `Game.Universe.ExpandNovaRadius.Entry` из DrawSunAndPlanet либо информационной ветки MainGameLoop. [ExpandNovaRadius.asm](../../../Source/Game/Universe/ExpandNovaRadius.asm), [DrawSunAndPlanet.asm](../../../Source/Game/Universe/DrawSunAndPlanet.asm).
- **Состояние:** MissionNotice, Game.Flight.MainGameLoop.NovaRadius, CircleState.Radius, PlayerDead, SpaceMode, View.
- **Ожидание:** при MissionNotice=0 ничего. Иначе нулевой NovaRadius заменяется исходным CircleState.Radius, затем прибавляется **2**. Ноль результата или перенос ставит PlayerDead=1 и нулевой радиус. В DrawSunAndPlanet обновление предшествует проверке видимости проекции. На информационном экране вызывается отдельно.
- **Сценарии:** MissionNotice=0/ненулевой, начальный Radius при NovaRadius=0, #FD/#FE/#FF, невидимое солнце, карта/кабина, особое пространство, дополнительные рисования светил переходной последовательности.
- **Статус доказательства:** static; measurements missing. При отделении рендера этот побочный эффект миссии требуется перенести с прежним порядком.

### MECH-14 — Энергетическая бомба и эвакуация

- **Граница:** аварийные устройства `Game.Extensions.AttributeVectorAndEnergyBomb.UseEnergyBomb`, `Game.Combat.HandleEscapeCapsule.Entry`. [AttributeVectorAndEnergyBomb.asm](../../../Source/Game/Extensions/AttributeVectorAndEnergyBomb.asm), [FlashViewAttributes.asm](../../../Source/Game/Extensions/FlashViewAttributes.asm), [FillViewAttributesAndFlightState.asm](../../../Source/Game/Flight/FillViewAttributesAndFlightState.asm), [HandleEscapeCapsule.asm](../../../Source/Game/Combat/HandleEscapeCapsule.asm).
- **Состояние:** EnergyBomb/EscapePod, DeviceKeys, DestroyAll, SoundRequests, MissileCount как счётчик эвакуации, InputMotion.Speed, LegalStatus, Cargo/FreeCargo, MissionFlags, SunPosition.
- **Ожидание:** бомба увеличивает ненулевой код (#FF→0), ставит DestroyAll=1 и звук, вызывает **24** FlashViewAttributes. Каждая вспышка содержит две заливки с HALT: **48 HALT** в цикле. Уничтожение проходит следующим объектным обходом с исключениями. Капсула при наличии и SpaceMode=0 ставит MissileCount=24, InputMotion.Speed=#0010, очищает часть груза/статуса и вызывает создание действия #17. Следующие **24 достигнутых вызова** уменьшают счётчик, 1→0 ведёт в RebaseForDock.
- **Сценарии:** отсутствие/одноразовый/необычный код устройства, удержание, специальные объекты, ввод/звук во время вспышек, капсула в особом пространстве, карта во время эвакуации, нехватка слотов, точный состав очищенного груза.
- **Статус доказательства:** static; measurements missing. Основной цикл блокируется вспышками, HALT допускает IM2. Эвакуация зависит от ProcessCombatControls, отсутствующего в информационной ветке.

### MECH-15 — Ускоренное перемещение и три прохода звёзд

- **Граница:** `Game.Universe.HandleFastTravelStep.Entry`, `DrawStarsWithJumpEffect.Entry`. [HandleFastTravelStep.asm](../../../Source/Game/Universe/HandleFastTravelStep.asm), [DrawStarsWithJumpEffect.asm](../../../Source/Game/Universe/DrawStarsWithJumpEffect.asm), [Include.inc](../../../Source/Game/Include.inc).
- **Состояние:** ViewJumpKeys, SunNear/StationFar/ShipsPresent, MissionPhase, FastTravel/FastSpawnPhase, SpawnCounter, координаты Sun/Planet/Station, Speed, StarPoints, RNG.
- **Ожидание:** команда снимается до проверок. В обычном пространстве проверяется близость, во всех режимах ShipsPresent. Успех обнуляет MissionPhase, очищает ближние слоты, вращает FastSpawnPhase #55/#AA, через раз ставит SpawnCounter=1, задаёт FastTravel=1 и выполняет **3** изменения глубины на 32 — солнце, планета, станция. Звёздный эффект сбрасывает флаг через SetSceneFlagAndResetMetadata, делает проход со скоростью 30, проход со скоростью 16 и **третий проход** через непосредственное продолжение, также при 16. Обычный случай — один проход.
- **Сценарии:** близкое солнце/станция, ShipsPresent=0/1, особое пространство, две успешные команды, SpawnCounter перед выстрелом, расход RNG при пересоздании звёзд, смена вида.
- **Статус доказательства:** static; measurements missing. Это отдельное дискретное действие, не произвольный множитель FPS или обычной скорости.

### SOUND-01 — Арбитраж и объединение звуковых запросов

- **Граница:** `Game.Sound.UpdateSound.Entry` через DispatchSoundEffect из IM2, затем `StepDataTone.FinishEffect`. [UpdateSound.asm](../../../Source/Game/Sound/UpdateSound.asm), [DispatchSoundEffect.asm](../../../Source/Game/Flight/DispatchSoundEffect.asm), [StepDataTone.asm](../../../Source/Game/Sound/StepDataTone.asm), [PlayDestructionSound.asm](../../../Source/Game/Sound/PlayDestructionSound.asm).
- **Состояние:** InputState.Config.INPUT_SND_BIT, SoundState.Mode/Duration/DataCursor, SoundRequest, SoundRequests, NoiseStep/NoiseSamples/ToneShift/PitchStep.
- **Ожидание:** отключённый звук возвращает без продвижения эффекта и очистки запросов. Активный Mode продолжается, иначе выбирается младший установленный бит. Это объединяемые биты, не счётчики повторений. Биты 0..7: SlowNoise, FastNoise, ChainedNoise, ShiftedTone, FallingTone, LongTone, AddedTone, AddedTone. Инициализатор обычно сразу исполняет первый пакет. Завершение ставит Mode=0 и переключает выбранный бит XOR-маской, полагаясь на установленный запрос.
- **Сценарии:** каждый бит, несколько одновременно, повторный запрос в активном эффекте, отключение/включение посередине, внешнее изменение маски, синхронный звук.
- **Статус доказательства:** static; measurements missing. При отделении звука от IM2 сохранять арбитраж и объединение событий либо явно согласовать отличие.

### SOUND-02 — Пакеты тона и шума

- **Граница:** пакет `Game.Sound.StepNoise.NextPacket`, `StepDataTone.NextPacket`, `StepPitchSweep.NextPeriod`. [StepNoise.asm](../../../Source/Game/Sound/StepNoise.asm), [StepDataTone.asm](../../../Source/Game/Sound/StepDataTone.asm), [StepPitchSweep.asm](../../../Source/Game/Sound/StepPitchSweep.asm), [StartExplosionNoise.asm](../../../Source/Game/Sound/StartExplosionNoise.asm).
- **Состояние:** Mode, Duration (смысл D/E зависит от режима), DataCursor, NoiseSamples/NoiseStep/PitchStep/ToneShift, ROM-байты, порядок OUT (#FE).
- **Ожидание:** тон данных — **100 периодов**, по два OUT, D уменьшается на пакет. Качающийся тон — **15 периодов** на пакет, E=`(2*E+PitchStep) mod 256`, D уменьшается. FallingTone: 2 пакета, LongTone: 8. Шум даёт NoiseSamples значений, меняет D на NoiseStep, уменьшает E. Slow/FastNoise: **8×64**, начальный D=64, шаг -2/-28. ChainedNoise: **8×64**, шаг +2, затем инициализация финальных **2×160**. StartExplosionNoise не записывает NoiseStep, его старое значение входит в исходное состояние. Нулевой B в DJNZ-задержке означает 256 итераций.
- **Сценарии:** все режимы, переходы D через 0/255, ROM-байты с нулевой задержкой, конец пакета/эффекта, цепочка взрыва, NoiseStep от прежнего звука, настройка звука между пакетами.
- **Статус доказательства:** static; measurements missing. Счёты OUT известны, полные T-state интервалы и длительности не измерены. Сначала сравнивать события порта и состояние после каждого пакета.

### SOUND-03 — Синхронные звуки и блокировка IRQ

- **Граница:** `Game.Sound.PlayLaunchSound.Entry/HyperSound`, `PlayHyperjumpSound.Entry`, `PlayDestructionSound.Entry`, цикл PlayNoise до EndSound. [PlayLaunchSound.asm](../../../Source/Game/Sound/PlayLaunchSound.asm), [PlayHyperjumpSound.asm](../../../Source/Game/Sound/PlayHyperjumpSound.asm), [PlayDestructionSound.asm](../../../Source/Game/Sound/PlayDestructionSound.asm), [StartLaunchNoise.asm](../../../Source/Game/Sound/StartLaunchNoise.asm), [StartHyperjumpNoise.asm](../../../Source/Game/Sound/StartHyperjumpNoise.asm).
- **Состояние:** звук, IFF, входы IM2, SoundRequests, ROM, beeper/бордер, состояние вызывающего перехода/гибели.
- **Ожидание:** запуск — **32×80** шумовых значений, D=64, шаг +2; HyperSound — **12×192**, D=192, шаг -16; PlayHyperjumpSound — **10×192**, D=16, шаг +16. Эти инициализаторы выполняют DI и первый пакет, синхронный цикл завершает остальные, EndSound очищает все запросы и делает EI. PlayDestructionSound отличается: StartExplosionNoise только инициализирует 2×160 и сам не делает DI, поэтому взаимодействие с IRQ требует трассы. Прямой Rom.Beeper при захвате ракеты — отдельная граница.
- **Сценарии:** звук включён/выключен, IFF=0/1, накопленные запросы, IRQ в начале/конце, разрушение с активным эффектом, последовательность разрушение → запуск при гибели.
- **Статус доказательства:** static; measurements missing. Неблокирующее аудио меняет течение ввода/мира, даже при похожем звуковом результате.

## Этапы переноса и критерии приёмки

1. **Зафиксировать исходный эксперимент.** Выбрать модель Spectrum, ROM, дисковую среду и снимок после загрузчика. Сохранить версии/хеши TRD/ROM, IFF/IM/R/SP, семена, рабочие поля и изменяемые операнды. Приёмка: снимок воспроизводимо достигает одного первого TIME-01, загрузочное преобразование не повторяется ошибочно.
2. **Разделить шкалы событий будущего стенда.** Нумеровать аппаратные периоды, принятые IM2, логические проходы, публикации изображения и каждую паспортную границу. Приёмка: трасса объясняет 8 HALT карты, ожидания маскировки и пропуски обработчиков без единого выдуманного FPS.
3. **Получить исходные трассы TIME/INPUT.** Записать обычные/прямые клавиатурные чтения, IFF/IM/R, RNG с переносом. Приёмка: повтор оригинала даёт те же границы, поля, порты и генераторы; источник расхождений выяснен до переноса.
4. **Перенести представление состояния и арифметику.** Сохранить байтовые переполнения, знак/модуль, CY, фазы и значения патчей как явное состояние. Приёмка: INPUT-02/03, TIME-04, отдельные MECH-01..05 совпадают на полных полях и пограничных входах. Этот документ не назначает размещение нового проекта и адреса памяти, их определяет пользователь.
5. **Воспроизвести последовательность механик.** Соединить обработчики по TIME-01, включая карты, блокирующие участки и очереди. Приёмка: все MECH-паспорта совпадают после каждого события в длительных сценариях, включая энергию, войну, топливо и гиперпереходы.
6. **Отделить вывод изображения, сохранив побочные эффекты.** Сначала перенести обновление звёзд/новы/эффектов и расход RNG в явные шаги прежней частоты, затем разрешить дополнительным изображениям читать состояние. Приёмка: дополнительные публикации сами не меняют механические контрольные точки. Для визуального R-зависимого шума согласуется отдельный критерий.
7. **Перенести звук и его влияние на время.** Сначала SOUND-01..03 как события/состояния, затем способ передачи beeper-потока. Приёмка: арбитраж, пакеты и DI/ожидания сохранены в совместимом режиме, отличия оформлены явными настройками.
8. **Добавить согласованное изменение темпа полёта.** Отдельно выбрать: визуальная плавность, скорость перемещения мира, период механического шага, клавиатурные накопители либо комбинация. Приёмка: выбранные неизменные механики/миссии проходят паспорта при каждом разрешённом режиме скорости; намеренные расхождения перечислены.
9. **Проверить составные длительные сценарии.** Солнце с насыщенной очередью; бой с ECM/лазером/маскировкой; карта во время боя; вторжение и особое пространство; гиперпереход с сообщениями; эвакуация; смерть; звук включён/выключен. Приёмка: определяется первый расходящийся ID, вход и поле, одинаковый итоговый кадр не скрывает расхождение состояния.

## Неизмеренные временные зависимости и решения

- Аппаратная модель, частота/длительность INT, contention, ROM и дисковая среда здесь не выбраны. Нельзя автоматически подставлять 50 Гц, 3,5 МГц или обычный ROM для любой конфигурации.
- Не измерено распределение длительности полного прохода при разном числе объектов/линий/эффектов, на карте, в особом пространстве, со звуком/без. Средняя частота не заменяет моменты допущенного IM2.
- Нужны длительности DI-участков, пропущенные IRQ, влияние шумовых пакетов, временных стеков, копирования экрана и Rom.Beeper. Проверяются альтернативные регистры и реальная аппаратная модель.
- Механики зависят от вида/очереди: лазер/ECM/эвакуация пропускаются на информационном экране, заправка ждёт фоновой ветки, война — станционного пути. Решить, сохраняются ли эти особенности буквально.
- Пауза останавливает основной цикл, но не обязательно InputMotion/звук. Совместимый и улучшенный режимы паузы требуют отдельных критериев.
- LD A,R и общий NextRandomByte связывают рендер с будущей случайностью. Подмена визуального RNG — явное отличие после эталонных трасс.
- Гипертуннель имеет изменяемые пределы/переходы. #42 в инициализации нельзя выдавать за измеренное число кадров. Трассировать каждый показ и смену фазы.
- Кабинная температура не имеет самостоятельного найденного здесь периодического охлаждения. SunScooping может сохраниться после ухода в дальнюю ветку. Проверять реальное поведение, не заменять интуитивной моделью.
- Синхронные звуки задерживают мир и иногда IRQ. Неблокирующая аудиосистема должна сохранить логические ожидания либо документировать изменение темпа.
- Побайтовое совпадение собранного TRD подтверждает дисковое представление, не частоту механик и не работающую реплику. [ExtensionsInputValidation.json](Semantics/ExtensionsInputValidation.json) — статическая сверка, не исполнение IM2.

## Замечания к существующим комментариям, без правок исходников

- SetMessageCoordinatesAndRender.TickMessage: первый RET C проверяет прежний срок сообщения <4, не экран. После DEC (HL) сравнение использует прежний A, View читается позже.
- StartExplosionNoise: Out должен относить 3 к SoundState.Mode. Процедура не пишет NoiseStep и не делает DI, что важно для самостоятельного разрушения.

Оба наблюдения включены в будущие проверки. Исходники в этом этапе не исправлялись. AI, трафик, автостыковка и полный жизненный цикл объектов требуют отдельных паспортов другого блока.
