# Руководство Elite 3 и соответствие исходному коду

Это руководство из файла `ELITE3HL.B` данного образа `ELITE3HL.TRD`.
[Распакованный текст](../Tools/Disasm/Research/ManualReadable.txt) получен из
[исходного ресурса](../Source/Manual/Resources/PackedText.bin), который подключается
в [Source/Manual/Include.inc](../Source/Manual/Include.inc).
Названия миссий ниже взяты из этого руководства. Другие версии Elite для сопоставления не используются.

Первая часть документа — навигация по фактическим обработчикам игры. Вторая часть —
полный текст руководства в исходном порядке, с сохранением переносов, рисунков и опечаток.
Пояснения к реализации находятся вне блоков `text` и не являются текстом автора игры.
Ссылки ведут на файлы, точный вход указан рядом его именем, поэтому добавление пустых строк не нарушает навигацию.

## Содержание

- [Общая выдача старых миссий](#mission-dispatch)
- [Общие поля и сброс состояния](#mission-shared-state)
- [Миссия 1, беженцы](#mission-1)
- [Миссия 2, CLOAKING DEVICE](#mission-2)
- [Миссия 3, принятие и этапы задания](#mission-3)
- [Миссия 4, MINERAL LIFE](#mission-4)
- [Миссия 5, ALIEN COMPUTER](#mission-5)
- [Миссия 6, Cobra Mk4](#mission-6)
- [Миссия 7, INVASION](#mission-7-invasion)
- [7+1, эвакуация беженцев](#mission-7-1)
- [7+2, военные поставки](#mission-7-2)
- [7+3, высадка десанта](#mission-7-3)
- [7+4, секретная командная база](#mission-7-4)
- [Исходное руководство](#original-manual): [введение](#manual-chapter-1), [копирование](#manual-chapter-2), [отличия Elite 3](#manual-chapter-3), [управление](#manual-chapter-4), [ответы](#manual-chapter-5), [объявления](#manual-chapter-6)

<a id="mission-dispatch"></a>
## Выдача старых миссий

Руководство связывает повторную выдачу старых миссий с сообщением `RIGHT ON COMMANDER!` в [разделе «Ответы»](#manual-chapter-5). В обработчике прибытия флаг `JUMP_MSN_BIT` сначала проверяется и сбрасывается. Затем `GrantMission` проверяет пересечение входной маски с `State.MissionFlags` и выбирает очередной этап. Эти отметки одновременно используются военными заданиями, поэтому они не образуют независимого постоянного списка завершённых миссий.

| Проверка или действие | Исходник и вход |
|---|---|
| входная маска и общие отметки выбирают очередную старую миссию | [GetSalePriceAndMissionFlags.asm](../Source/Game/Travel/GetSalePriceAndMissionFlags.asm), `GrantMission` |
| старший счётчик переходов разрешает выдачу события по маске рейтинга | [LaserTypeAndArrivalEvents.asm](../Source/Game/Travel/LaserTypeAndArrivalEvents.asm), `CheckGrant` |

<a id="mission-shared-state"></a>
## Общие поля и сброс состояния

[FCommander](../Includes/Structs/Commander.inc) описывает сериализуемые поля, их смещения и схемы битов. [Константы командира](../Includes/Const/Commander.inc) задают номера битов и маски, [GameState.inc](../Includes/Variables/GameState.inc) — адреса существующих полей.

`State.RankState` объединяет старший байт числового рейтинга и военный код. Чтение этого поля в обычном прицеливании не является проверкой задания. `State.Mission3` хранит этап третьей миссии, но значение 4 также устанавливается для оккупированной и особой системы. `MissionFlags` объединяет награды, наличие маскировки и занятость трюма. `MissionPhase` — отдельная рабочая фаза встречи второй миссии, а `CloakActive` — включённое состояние уже полученного устройства.

`ResetCommander` восстанавливает поля заданий из изменяемого резерва `NewCommander`. Резерв может быть перезаписан дисковой процедурой сохранения, поэтому его нельзя считать неизменным исходным пилотом. Использование адреса `State.Mission1` как базы индекса оборудования также не означает чтение или изменение самой миссии.

[MissionAnnotations.json](../Tools/Disasm/Reports/MissionAnnotations.json) содержит соответствия обработчиков, полей и разделов руководства. Реестр прямых обращений дополняется вручную проверенными косвенными путями. Автоматическая проверка имён и ссылок сама по себе не доказывает смысл алгоритма.

| Проверка или действие | Исходник и вход |
|---|---|
| обычный боевой рейтинг использует тот же старший байт, что и военное состояние | [PrintCombatRankAndEquipment.asm](../Source/Game/Menus/PrintCombatRankAndEquipment.asm), `Entry` |
| восстановление полей заданий из изменяемого резерва NewCommander | [RatingBountyDamageAndNewCommander.asm](../Source/Game/Missions/RatingBountyDamageAndNewCommander.asm), `ResetCommander` |
| нулевой старший байт рейтинга уменьшает вероятность лазера, номер миссии здесь не проверяется | [SteerObjectAndTryLaser.asm](../Source/Game/Motion/SteerObjectAndTryLaser.asm), `CheckLaser` |
| адрес State.Mission1 служит базой индекса оборудования, состояние миссии не читается | [GetEquipmentStateAddress.asm](../Source/Game/Trade/GetEquipmentStateAddress.asm), `Entry` |

<a id="mission-1"></a>
## Миссия 1, беженцы

Руководство называет спасение `REFUGEES` миссией 1 в описании [MINERAL LIFE](#manual-mission-4), а в [задании 7+1](#manual-mission-7-1) сравнивает с ним военную эвакуацию.

`State.Mission1` влияет на допуск перевозки, предупреждения и цвет полётного вида. Ответ Y очищает 17 товаров и свободный тоннаж, после чего `MS_CARGO_BIT` отмечает особый груз. Высадка отдельно проверяет разрешение, снимает этот бит, записывает 100 единиц Gemstones и обнуляет состояние колонии. Спасательная капсула снимает признак груза без выдачи этой награды.

Пути с `Mission1 != 0` и галактический переход могут попасть в общий `ClearMissions`, где обнуляются `Mission3`, активная `Mission1` и её предупреждение. Это фактический общий сброс, его нельзя описывать как завершение задания с наградой.

| Проверка или действие | Исходник и вход |
|---|---|
| предложение перевозки только при свободном миссионном трюме | [NextScreenCharacterRowAndRefugees.asm](../Source/Game/Charts/NextScreenCharacterRowAndRefugees.asm), `OfferRefugees` |
| спасательная капсула снимает признак особого груза после очистки тоннажных товаров | [HandleEscapeCapsule.asm](../Source/Game/Combat/HandleEscapeCapsule.asm), `ClearCargo` |
| признак занятого миссией трюма включает отдельную подпись беженцев либо десанта | [PrintCargoAndMessageBanks.asm](../Source/Game/Extensions/PrintCargoAndMessageBanks.asm), `Entry` |
| активная первая миссия выбирает особую окраску вида | [ApplyMissionViewColour.asm](../Source/Game/Flight/ApplyMissionViewColour.asm), `Entry` |
| после туннеля обычный цвет возвращается только вне первой миссии | [DivideByteFractionForTunnel.asm](../Source/Game/Flight/DivideByteFractionForTunnel.asm), `FinishTunnel` |
| первая миссия ограничивает атрибут вида маской перед заливкой | [FillViewAttributesAndFlightState.asm](../Source/Game/Flight/FillViewAttributesAndFlightState.asm), `Entry` |
| после вылета отмечается уже показанное предупреждение первой миссии | [MarkMissionViewInitialized.asm](../Source/Game/Flight/MarkMissionViewInitialized.asm), `Entry` |
| общий выбор атрибута учитывает маскировку и далее состояние первой миссии | [SetViewAttributesWithCloaking.asm](../Source/Game/Flight/SetViewAttributesWithCloaking.asm), `Entry` |
| посадка вызывает предложения заданий, вылет применяет предупреждение первой миссии | [LaunchOrDockShip.asm](../Source/Game/Flight/LaunchOrDockShip.asm), `Entry` |
| допуск к перевозке и выбор текста беженцев либо десанта | [ToggleSecondaryCoordinateObject.asm](../Source/Game/Input/ToggleSecondaryCoordinateObject.asm), `CheckPilot` |
| разрешённая высадка снимает особый груз, выдаёт Gemstones и сбрасывает колонию | [PromptCargoQuantityAndRefugees.asm](../Source/Game/Trade/PromptCargoQuantityAndRefugees.asm), `UnloadRefugees` |
| ответ Y очищает товары и свободный тоннаж, затем занимает трюм | [MissionRegionMetric.asm](../Source/Game/Trade/MissionRegionMetric.asm), `BoardRefugees` |
| активная первая миссия направляет переход в общий сброс заданий | [CommitJumpFuelAndMishap.asm](../Source/Game/Travel/CommitJumpFuelAndMishap.asm), `Entry` |
| общий переход очищает активные старые миссии и предупреждение | [TickJumpCountdown.asm](../Source/Game/Travel/TickJumpCountdown.asm), `ClearMissions` |
| полётные сообщения учитывают задания, низкая энергия снимает маскировку | [UpdateAmbientFlightMessage.asm](../Source/Game/Travel/UpdateAmbientFlightMessage.asm), `Entry` |
| проверка разрешения высадки, военный путь ставит первую отметку | [ApplyEnhancedFlightControl.asm](../Source/Game/Universe/ApplyEnhancedFlightControl.asm), `CheckRefugees` |
| военное состояние выбирает текст беженцев либо десанта | [SelectSpecialCargoText.asm](../Source/Game/Universe/SelectSpecialCargoText.asm), `Entry` |
| перекрывающийся вход прекращает предложение покупки при занятом миссионном трюме | [ResetCloakingAndSeedFlightRandom.asm](../Source/Game/Trade/ResetCloakingAndSeedFlightRandom.asm), `BusyCargo` |

<a id="mission-2"></a>
## Миссия 2, CLOAKING DEVICE

В [разделе «Ответы»](#manual-chapter-5) получение маскировки названо стандартной миссией. Начальная встреча требует второй отметки `MissionFlags`, отсутствия `MS_CLOAK_BIT`, нулевой `MissionPhase` и успешной случайной проверки.

Рабочая `MissionPhase` связывает генерацию кораблей, энергетические фазы, скрытие каркаса и появление специального контейнера. При подходящем подборе в фазе 3 обычный индекс груза заменяется кодом `#FF`. Только затем `ScoopItem` ставит `MS_CLOAK_BIT`. Повреждение или удаление объектов и быстрое перемещение могут сбросить фазу встречи.

Наличие устройства и его включение различаются: `MS_CLOAK_BIT` хранится у командира, а `CloakActive` управляет цветом вида, расходом энергии и дополнительной случайной проверкой лазера противника. Энергетическая проверка выключает активную маскировку, не отнимая устройство.

| Проверка или действие | Исходник и вход |
|---|---|
| уничтожение миссионного корабля либо контейнера сбрасывает фазу встречи | [UpdateAllSpaceObjects.asm](../Source/Game/Combat/UpdateAllSpaceObjects.asm), `ClearMission` |
| фаза 3 превращает подходящий подобранный контейнер в предмет CLOAKING DEVICE | [HandleObjectCollision.asm](../Source/Game/Combat/HandleObjectCollision.asm), `MissionCargo` |
| столкновение с миссионным объектом сбрасывает фазу встречи | [HandleObjectCollision.asm](../Source/Game/Combat/HandleObjectCollision.asm), `DestroyImpact` |
| включённая маскировка добавляет единицу к расходу энергии | [ApplyPlayerDamage.asm](../Source/Game/Combat/ApplyPlayerDamage.asm), `RecoverEnergy` |
| включённая маскировка добавляет случайную проверку допуска лазера противника | [ScheduleLinkedObjectLaser.asm](../Source/Game/Extensions/ScheduleLinkedObjectLaser.asm), `PermitLaser` |
| наличие CLOAKING DEVICE разрешает переключение маскировки клавишей Y | [ToggleCloakingDevice.asm](../Source/Game/Flight/ToggleCloakingDevice.asm), `Entry` |
| активная маскировка восстанавливает свой цвет полётного вида | [ApplyCloakingViewColour.asm](../Source/Game/Flight/ApplyCloakingViewColour.asm), `Entry` |
| общий выбор атрибута учитывает маскировку и далее состояние первой миссии | [SetViewAttributesWithCloaking.asm](../Source/Game/Flight/SetViewAttributesWithCloaking.asm), `Entry` |
| после лазеров отдельно выводятся ALIEN COMPUTER и CLOAKING DEVICE | [PrintCombatRankAndEquipment.asm](../Source/Game/Menus/PrintCombatRankAndEquipment.asm), `NextLaser` |
| код предмета FF выдаёт CLOAKING DEVICE | [SpecialMessageAndScoopReward.asm](../Source/Game/Missions/SpecialMessageAndScoopReward.asm), `ScoopItem` |
| общий вектор подбора разделяет маскировку, компьютер и обычные минералы | [DispatchMissionEvents.asm](../Source/Game/Missions/DispatchMissionEvents.asm), `ScoopItem` |
| фазы особой встречи переключаются при энергетических порогах | [ProcessObjectEnergyAndTactics.asm](../Source/Game/Motion/ProcessObjectEnergyAndTactics.asm), `CheckMission` |
| первая фаза скрывает каркас корабля с миссионным признаком | [ProjectObjectAndSelectDetail.asm](../Source/Game/Motion/ProjectObjectAndSelectDetail.asm), `CheckMission` |
| сочетание второй отметки и отсутствия маскировки допускает особую встречу | [GenerateSpaceTraffic.asm](../Source/Game/Objects/GenerateSpaceTraffic.asm), `Entry` |
| полётные сообщения учитывают задания, низкая энергия снимает маскировку | [UpdateAmbientFlightMessage.asm](../Source/Game/Travel/UpdateAmbientFlightMessage.asm), `Entry` |
| наличие маскировки участвует в случайном допуске энергетического эффекта объекта | [InitializeExtendedObjectMetadata.asm](../Source/Game/Universe/InitializeExtendedObjectMetadata.asm), `StoreFlags` |
| уничтожение миссионного корабля переводит встречу в фазу специального контейнера | [SpawnDestructionContentsAndEffects.asm](../Source/Game/Universe/SpawnDestructionContentsAndEffects.asm), `Entry` |
| подготовка полёта записывает переданное состояние маскировки | [ResetCloakingAndSeedFlightRandom.asm](../Source/Game/Trade/ResetCloakingAndSeedFlightRandom.asm), `Entry` |
| быстрое перемещение обнуляет фазу второй миссии при очистке окружения | [HandleFastTravelStep.asm](../Source/Game/Universe/HandleFastTravelStep.asm), `Entry` |
| отдельный рабочий байт хранит фазу появления и подбора миссионного предмета | [AnimateIntroAndObjectPipeline.asm](../Source/Game/Combat/AnimateIntroAndObjectPipeline.asm), `MissionPhase` |
| рабочий флаг включённой маскировки отделён от признака наличия устройства | [DispatchFlightMessage.asm](../Source/Game/Interface/DispatchFlightMessage.asm), `CloakActive` |

<a id="mission-3"></a>
## Миссия 3, принятие и этапы задания

Исходное руководство упоминает три сохранённые старые миссии, но не даёт отдельного подробного описания третьей. Ниже используются только её состояния и тексты данного образа, без сюжетного названия из другой Elite.

Ответ Y ставит `Mission3=3` и `MS_ACCEPT_BIT`; другой ответ обнуляет этап. В `ArrivalEvents` эти проверки выполняются только при `State.Galaxy != 0`. При прибытии исходный этап 1 увеличивается до 2, исходный 4 заменяется на 3, а совпадение текущего семени с базовым записывает 4. Проверка `CP #03` в `CheckStage` выполняется уже после `DEC A`, то есть проверяет исходное значение 4.

Диспетчер обрабатывает этапы 1/2 как предложение, 5 как награду и 6 как отдельное сообщение. Событие в станционном слоте имеет собственный путь к этапу 5. Награда обнуляет этап, увеличивает `RankState` и ставит `MS_MARK4_BIT`, сохраняя `MS_ACCEPT_BIT`.

Значение 4 используется также войной. Оно влияет на враждебность станции, генерацию кораблей и поведение объектов. Запрет ECM требует **одновременно** этапа 4 и `MS_ACCEPT_BIT`. Тот же флаг принятия выбирает особую подпись первого поля оборудования `State.ECM` в этой версии. Эти общие применения нельзя приписывать исключительно сюжетной третьей миссии.

| Проверка или действие | Исходник и вход |
|---|---|
| совместная проверка этапа 4 и MS_ACCEPT_BIT запрещает обработку ECM игрока | [ProcessLaserAndEcm.asm](../Source/Game/Combat/ProcessLaserAndEcm.asm), `CheckEcmLock` |
| общее состояние 4 делает станцию враждебной | [UpdateAllSpaceObjects.asm](../Source/Game/Combat/UpdateAllSpaceObjects.asm), `Entry` |
| общее состояние 4 разрешает агрессивное поведение объекта | [SetObjectAggressionFlag.asm](../Source/Game/Extensions/SetObjectAggressionFlag.asm), `Entry` |
| оккупированная область выбирает военный корабль, состояние 4 исключает обычный Viper | [UpdateStationAndSpecialShips.asm](../Source/Game/Extensions/UpdateStationAndSpecialShips.asm), `Entry` |
| после посадки сначала обрабатываются задания, затем предложение Cobra Mk4 | [OfferUpgradeAndCorrectPosition.asm](../Source/Game/Extensions/OfferUpgradeAndCorrectPosition.asm), `Entry` |
| этапы 1 и 2 выбирают предложение, 5 награду, 6 отдельное сообщение | [DispatchThirdMissionStage.asm](../Source/Game/Flight/DispatchThirdMissionStage.asm), `Entry` |
| посадка вызывает предложения заданий, вылет применяет предупреждение первой миссии | [LaunchOrDockShip.asm](../Source/Game/Flight/LaunchOrDockShip.asm), `Entry` |
| MS_ACCEPT_BIT выбирает специальное имя первого устройства, поля State.ECM | [PrintCombatRankAndEquipment.asm](../Source/Game/Menus/PrintCombatRankAndEquipment.asm), `NextEquipment` |
| ненулевое общее состояние и совпадение семени разрешают особое описание системы | [PrintSystemStatistics.asm](../Source/Game/Menus/PrintSystemStatistics.asm), `Entry` |
| ответ Y принимает третью миссию, другой ответ сбрасывает её этап | [OfferThirdMission.asm](../Source/Game/Missions/OfferThirdMission.asm), `Entry` |
| награда увеличивает старший рейтинг и ставит четвёртую отметку без снятия MS_ACCEPT_BIT | [CompleteThirdMission.asm](../Source/Game/Missions/CompleteThirdMission.asm), `Entry` |
| вектор предложения третьей миссии передаёт ответ основному обработчику | [DispatchMissionEvents.asm](../Source/Game/Missions/DispatchMissionEvents.asm), `OfferMission` |
| вектор награды за третью миссию | [DispatchRatingAndMissionEnd.asm](../Source/Game/Missions/DispatchRatingAndMissionEnd.asm), `EndMission` |
| состояние 4 выбирает курс по параметру поведения без обычной проверки станции | [CheckObjectBoxAndChooseCourse.asm](../Source/Game/Motion/CheckObjectBoxAndChooseCourse.asm), `CheckHostility` |
| попадание в особую цель передаётся общему обработчику ракеты либо десанта | [GuideMissileAndCheckImpact.asm](../Source/Game/Motion/GuideMissileAndCheckImpact.asm), `FindTarget` |
| совместная проверка этапа 4 и MS_ACCEPT_BIT запрещает ответный ECM | [ProcessObjectEnergyAndTactics.asm](../Source/Game/Motion/ProcessObjectEnergyAndTactics.asm), `CheckEcm` |
| состояние 4 меняет вероятность и код порождения объектов | [ProcessObjectEnergyAndTactics.asm](../Source/Game/Motion/ProcessObjectEnergyAndTactics.asm), `ChooseFlight` |
| общие состояния 1 и 4 принудительно выбирают модели встречи | [GenerateSpaceTraffic.asm](../Source/Game/Objects/GenerateSpaceTraffic.asm), `EncounterClass` |
| состояние 4 выбирает специальный код события | [ChooseEncounterCode.asm](../Source/Game/Screen/ChooseEncounterCode.asm), `Entry` |
| обычная ракета меняет этап попадания, Sidewinder обрабатывает высадку десанта | [HandleSpecialObjectMission.asm](../Source/Game/Text/HandleSpecialObjectMission.asm), `Entry` |
| прибытие меняет этап задания и проверяет семя целевой системы | [LaserTypeAndArrivalEvents.asm](../Source/Game/Travel/LaserTypeAndArrivalEvents.asm), `ArrivalEvents` |
| общий переход очищает активные старые миссии и предупреждение | [TickJumpCountdown.asm](../Source/Game/Travel/TickJumpCountdown.asm), `ClearMissions` |
| полётные сообщения учитывают задания, низкая энергия снимает маскировку | [UpdateAmbientFlightMessage.asm](../Source/Game/Travel/UpdateAmbientFlightMessage.asm), `Entry` |
| помеченное событие станционного слота переводит общее состояние в этап 5 | [BuildStationGeometry.asm](../Source/Game/Travel/BuildStationGeometry.asm), `MissionStage` |
| побайтовое сравнение семени определяет совпадение с целевой системой задания | [CompareSystemSeedToGalaxyBase.asm](../Source/Game/Menus/CompareSystemSeedToGalaxyBase.asm), `Entry` |

<a id="mission-4"></a>
## Миссия 4, MINERAL LIFE

[Описание в исходном руководстве](#manual-mission-4).

При подборе минерала проверка колонизации выполняется до увеличения его количества. Жизнеспособность требует не менее трёх тонн минералов и допустимого состояния `MineralLife`. Запись `#FF` при гибели запрещает повторное образование колонии, пока другой путь не очистит всё поле.

**Отличие от формулировки руководства:** оно советует удаляться от солнца, а `TryColonizeMinerals` вызывает `PlanetDistanceHint` и требует оценку удаления от планеты не меньше 56. Дополнительно проверяются полоса `-8 <= Y-X <= 7` и не менее двух тонн минералов до подбора. Значение 56 не обозначено здесь световыми годами.

Живая колония обнуляет рыночный запас минералов, включает цену 1000 Cr за тонну и минимальную партию продажи в три тонны. В `ReadCargoByte` проверяется только нижний порог `B >= 3`; отдельной проверки верхнего предела 63 из руководства в этом пути продажи нет. Общий ввод количества принимает одну или две десятичные цифры.

**Кормление отличается от обещанных трёх пропусков:** `UpdateSpecialCargoStatus` сразу вычитает Minerals из Gemstones. При нехватке восьмибитный результат записывается в `MineralLife`, отдельный счётчик трёх голодных переходов не ведётся. Например, при трёх тоннах и нуле Gemstones записывается `#FD`; следующая проверка колонии отвергает это состояние по `MIN_BLOCK_BIT`. Вызов кормления находится в [AnimateTransitionTunnel.asm](../Source/Game/Flight/AnimateTransitionTunnel.asm), вход `Entry`, после проверки `ViewKeyLock`.

Сброс поля после высадки беженцев — отдельное реальное взаимодействие заданий. В `AttributeVectorAndEnergyBomb.ConfirmUpgrade` сброс происходит только при входном `A=#59`. Его вызывающий путь покупки трюма передаёт `A=(State.LargeCargo)`; это нельзя объявлять непосредственной проверкой ответа Y с клавиатуры.

| Проверка или действие | Исходник и вход |
|---|---|
| путь установки трюма сбрасывает колонию только при входном A = #59 | [AttributeVectorAndEnergyBomb.asm](../Source/Game/Extensions/AttributeVectorAndEnergyBomb.asm), `ConfirmUpgrade` |
| изменяемый ColonyGate задаёт ограничение продажи живых минералов | [AttributeVectorAndEnergyBomb.asm](../Source/Game/Extensions/AttributeVectorAndEnergyBomb.asm), `ReadCargoByte` |
| проверка колонии выбирает название минералов и переключает ограничения продажи | [HandleSpecialMessageToken.asm](../Source/Game/Extensions/HandleSpecialMessageToken.asm), `Entry` |
| при живой колонии Gemstones расходуются по количеству Minerals | [UpdateSpecialCargoStatus.asm](../Source/Game/Extensions/UpdateSpecialCargoStatus.asm), `Entry` |
| проверка количества минералов, удаления и региона перед появлением колонии | [TryColonizeMinerals.asm](../Source/Game/Flight/TryColonizeMinerals.asm), `Entry` |
| живая колония обнуляет рыночный остаток минералов | [ApplyMissionMarketRestrictions.asm](../Source/Game/Menus/ApplyMissionMarketRestrictions.asm), `CheckMinerals` |
| колонизация проверяется до увеличения количества подобранных минералов | [SpecialMessageAndScoopReward.asm](../Source/Game/Missions/SpecialMessageAndScoopReward.asm), `AddCargo` |
| общий вектор подбора разделяет маскировку, компьютер и обычные минералы | [DispatchMissionEvents.asm](../Source/Game/Missions/DispatchMissionEvents.asm), `ScoopItem` |
| проверка признака гибели и минимального запаса минералов для живой колонии | [CheckMineralLifeColony.asm](../Source/Game/Text/CheckMineralLifeColony.asm), `Entry` |
| разрешённая высадка снимает особый груз, выдаёт Gemstones и сбрасывает колонию | [PromptCargoQuantityAndRefugees.asm](../Source/Game/Trade/PromptCargoQuantityAndRefugees.asm), `UnloadRefugees` |
| изменяемый MineralGate разрешает специальную цену живых минералов | [GetSalePriceAndMissionFlags.asm](../Source/Game/Travel/GetSalePriceAndMissionFlags.asm), `Entry` |

<a id="mission-5"></a>
## Миссия 5, ALIEN COMPUTER

[Описание в исходном руководстве](#manual-mission-5).

Бит `ALIEN_OWN_BIT` отмечает наличие компьютера, остальные разряды участвуют в счётчике. Обработка удаляемой модели Thargoid прибавляет 2 к целому байту и при нулевом результате пытается создать специальный контейнер. Этот помощник вызывается из обхода ссылок объектов, поэтому один удалённый Thargoid не обязательно соответствует одному приращению. Правило «компьютер за каждые 128 уничтожений» из этих инструкций не следует.

Подбор объекта с `OBJ_ALIEN_BIT` увеличивает весь байт и ставит сообщение `ALIEN COMPUTER`. Для специального запуска дополнительно требуются непустые `AlienItems` и клавиша D. Тогда расход ракеты компенсируется, единица `AlienItems` переносится в свободный тоннаж, а модель заменяется на Tharglet.

| Проверка или действие | Исходник и вход |
|---|---|
| счётчик обработок модели Thargoid и создание контейнера при нулевом результате | [UpdateThargoidAndBodyCoords.asm](../Source/Game/Circles/UpdateThargoidAndBodyCoords.asm), `Entry` |
| компьютер, AlienItems и клавиша D заменяют ракету специальным кораблём | [CreateMissileOrMissionCraft.asm](../Source/Game/Extensions/CreateMissileOrMissionCraft.asm), `SpendMissile` |
| после лазеров отдельно выводятся ALIEN COMPUTER и CLOAKING DEVICE | [PrintCombatRankAndEquipment.asm](../Source/Game/Menus/PrintCombatRankAndEquipment.asm), `NextLaser` |
| специальный контейнер увеличивает код компьютера и выводит его название | [SpecialMessageAndScoopReward.asm](../Source/Game/Missions/SpecialMessageAndScoopReward.asm), `ClassifyScoop` |
| общий вектор подбора разделяет маскировку, компьютер и обычные минералы | [DispatchMissionEvents.asm](../Source/Game/Missions/DispatchMissionEvents.asm), `ScoopItem` |

<a id="mission-6"></a>
## Миссия 6, Cobra Mk4

[Описание в исходном руководстве](#manual-mission-6).

Околосолнечная ветвь подготавливает особое окружение и сообщение о модернизации. После посадки обработчик проверяет деньги, состояние второго объекта и отсутствие улучшения. Ответ Y записывает `ShipUpgrade=#FD` и уменьшает старший байт `CashHigh`.

**Цена по инструкциям — 256 000 Cr.** В [кратком обзоре](#manual-chapter-3) указано 250 000 Cr, а в [подробном разделе](#manual-mission-6) — 256 000. Изменение старшего байта слова, хранящего тысячи кредитов, соответствует 256 тысячам.

Таблица ниже включает применение полученного улучшения: подпись корабля, чтение клавиш и перестановку направлений лазеров. Эти процедуры не выдают задание повторно.

| Проверка или действие | Исходник и вход |
|---|---|
| вывод названия модернизированного корабля | [PrintShipAndContinueRightFill.asm](../Source/Game/Circles/PrintShipAndContinueRightFill.asm), `Entry` |
| код модернизации выбирает путь чтения ряда клавиатуры | [ScanUpgradeKeyRow.asm](../Source/Game/Circles/ScanUpgradeKeyRow.asm), `Entry` |
| околосолнечная ветвь подготавливает особые объекты и предложение Cobra Mk4 | [UpdateStationAndSpecialShips.asm](../Source/Game/Extensions/UpdateStationAndSpecialShips.asm), `NearSun` |
| после посадки сначала обрабатываются задания, затем предложение Cobra Mk4 | [OfferUpgradeAndCorrectPosition.asm](../Source/Game/Extensions/OfferUpgradeAndCorrectPosition.asm), `Entry` |
| посадка вызывает предложения заданий, вылет применяет предупреждение первой миссии | [LaunchOrDockShip.asm](../Source/Game/Flight/LaunchOrDockShip.asm), `Entry` |
| наличие Cobra Mk4 разрешает перестановку направлений лазеров | [IndexPauseCommandAndHandlers.asm](../Source/Game/Flight/IndexPauseCommandAndHandlers.asm), `SwapLasers` |

<a id="mission-7-invasion"></a>
## Миссия 7, INVASION

[Описание в исходном руководстве](#manual-mission-7).

`State.Invasion` хранит фазу и размер области. `State.RankState` хранит старший рейтинг и военный код. Геометрия фронта действует в первой галактике при `Invasion >= 2`. Запуск проверяет старые миссии, ненулевые специальные состояния пилота, рейтинг и пересечение его битов со счётчиком переходов. Печатное звание Elite само по себе не является полным условием.

Перед новым вторжением `MS_START_MASK` сохраняет принятие третьей миссии, маскировку и пятую отметку, но очищает занятый особым грузом трюм и четыре младшие отметки. Военные задания читают те же `MissionFlags`, что и старые миссии. `FindRewardBit` выбирает отметку вращениями, допуская биты 0..6.

Военный рынок имеет конкретное отличие от поставок 7+2: обработчик обнуляет **Textiles и Firearms**, тогда как отметка поставки проверяет **Food или Firearms**. В разборе сохранены именно эти инструкции.

**Таймер войны:** при `Invasion=#FF` добавка `CPL` к накопителю равна нулю. Поэтому один этот путь не подтверждает обещание руководства об автоматическом окончании войны. Высадка десанта явно снимает старший бит и уменьшает фронт. Таблица описывает найденные условия и записи, не подменяя их сюжетным обещанием.

| Проверка или действие | Исходник и вход |
|---|---|
| проверка военной области участвует в выборе результата гиперперехода | [SelectJumpAndContinueLeftFill.asm](../Source/Game/Circles/SelectJumpAndContinueLeftFill.asm), `Entry` |
| совместная проверка этапа 4 и MS_ACCEPT_BIT запрещает обработку ECM игрока | [ProcessLaserAndEcm.asm](../Source/Game/Combat/ProcessLaserAndEcm.asm), `CheckEcmLock` |
| общее состояние 4 делает станцию враждебной | [UpdateAllSpaceObjects.asm](../Source/Game/Combat/UpdateAllSpaceObjects.asm), `Entry` |
| накопитель времени изменяет фронт и ставит сообщение MAYDAY | [UpdateClockAndRotateDistantBodies.asm](../Source/Game/Combat/UpdateClockAndRotateDistantBodies.asm), `Entry` |
| общее состояние 4 разрешает агрессивное поведение объекта | [SetObjectAggressionFlag.asm](../Source/Game/Extensions/SetObjectAggressionFlag.asm), `Entry` |
| оккупированная область выбирает военный корабль, состояние 4 исключает обычный Viper | [UpdateStationAndSpecialShips.asm](../Source/Game/Extensions/UpdateStationAndSpecialShips.asm), `Entry` |
| после посадки сначала обрабатываются задания, затем предложение Cobra Mk4 | [OfferUpgradeAndCorrectPosition.asm](../Source/Game/Extensions/OfferUpgradeAndCorrectPosition.asm), `Entry` |
| проверка старых миссий, оборудования и рейтинга перед запуском вторжения | [UpdateInvasionOnRatingOverflow.asm](../Source/Game/Extensions/UpdateInvasionOnRatingOverflow.asm), `Entry` |
| геометрия выбранной системы определяет подписи OCCUPIED и RESISTING | [PrintPlanetInvasionStatus.asm](../Source/Game/Extensions/PrintPlanetInvasionStatus.asm), `Entry` |
| посадка вызывает предложения заданий, вылет применяет предупреждение первой миссии | [LaunchOrDockShip.asm](../Source/Game/Flight/LaunchOrDockShip.asm), `Entry` |
| военная область ограничивает рынок и устанавливает общее состояние 4 либо 0 | [ApplyMissionMarketRestrictions.asm](../Source/Game/Menus/ApplyMissionMarketRestrictions.asm), `Entry` |
| ненулевое общее состояние и совпадение семени разрешают особое описание системы | [PrintSystemStatistics.asm](../Source/Game/Menus/PrintSystemStatistics.asm), `Entry` |
| две границы фронта выделяют полосу сопротивления | [CheckMissionRegionBand.asm](../Source/Game/Menus/CheckMissionRegionBand.asm), `Entry` |
| переполнение числового рейтинга передаётся проверке начала войны | [RatingBountyDamageAndNewCommander.asm](../Source/Game/Missions/RatingBountyDamageAndNewCommander.asm), `Entry` |
| состояние 4 выбирает курс по параметру поведения без обычной проверки станции | [CheckObjectBoxAndChooseCourse.asm](../Source/Game/Motion/CheckObjectBoxAndChooseCourse.asm), `CheckHostility` |
| совместная проверка этапа 4 и MS_ACCEPT_BIT запрещает ответный ECM | [ProcessObjectEnergyAndTactics.asm](../Source/Game/Motion/ProcessObjectEnergyAndTactics.asm), `CheckEcm` |
| состояние 4 меняет вероятность и код порождения объектов | [ProcessObjectEnergyAndTactics.asm](../Source/Game/Motion/ProcessObjectEnergyAndTactics.asm), `ChooseFlight` |
| общие состояния 1 и 4 принудительно выбирают модели встречи | [GenerateSpaceTraffic.asm](../Source/Game/Objects/GenerateSpaceTraffic.asm), `EncounterClass` |
| состояние 4 выбирает специальный код события | [ChooseEncounterCode.asm](../Source/Game/Screen/ChooseEncounterCode.asm), `Entry` |
| область вторжения и полоса сопротивления подменяют тип встречного корабля | [SelectTrafficType.asm](../Source/Game/Screen/SelectTrafficType.asm), `CheckSpecial` |
| геометрия фронта использует текущую систему и код вторжения | [CheckMissionRegion.asm](../Source/Game/Text/CheckMissionRegion.asm), `Entry` |
| общая геометрия фронта применяется к сохранённому семени выбранной системы | [CheckSavedSystemRegion.asm](../Source/Game/Text/CheckSavedSystemRegion.asm), `Entry` |
| место, военный код и отметки определяют выдачу задания либо отставку | [OfferRegionDependentMission.asm](../Source/Game/Text/OfferRegionDependentMission.asm), `Entry` |
| общий принтер добавляет воинское звание и отметку отставки | [PrintRankWithMissionSuffix.asm](../Source/Game/Text/PrintRankWithMissionSuffix.asm), `Entry` |
| метрика координат используется общей проверкой фронта | [MissionRegionMetric.asm](../Source/Game/Trade/MissionRegionMetric.asm), `Entry` |

<a id="mission-7-1"></a>
## 7+1, эвакуация беженцев

[Описание в исходном руководстве](#manual-mission-7-1). Используется общий путь приёма и высадки [миссии 1](#mission-1).

Военный допуск учитывает полосу сопротивления и код звания. Успех военной проверки высадки проходит через `MarkResult` и ставит `MS_MARK1_BIT`. При `Invasion < 2` разрешение возвращается раньше, без установки этой военной отметки.

| Проверка или действие | Исходник и вход |
|---|---|
| предложение перевозки только при свободном миссионном трюме | [NextScreenCharacterRowAndRefugees.asm](../Source/Game/Charts/NextScreenCharacterRowAndRefugees.asm), `OfferRefugees` |
| спасательная капсула снимает признак особого груза после очистки тоннажных товаров | [HandleEscapeCapsule.asm](../Source/Game/Combat/HandleEscapeCapsule.asm), `ClearCargo` |
| признак занятого миссией трюма включает отдельную подпись беженцев либо десанта | [PrintCargoAndMessageBanks.asm](../Source/Game/Extensions/PrintCargoAndMessageBanks.asm), `Entry` |
| допуск к перевозке и выбор текста беженцев либо десанта | [ToggleSecondaryCoordinateObject.asm](../Source/Game/Input/ToggleSecondaryCoordinateObject.asm), `CheckPilot` |
| разрешённая высадка снимает особый груз, выдаёт Gemstones и сбрасывает колонию | [PromptCargoQuantityAndRefugees.asm](../Source/Game/Trade/PromptCargoQuantityAndRefugees.asm), `UnloadRefugees` |
| ответ Y очищает товары и свободный тоннаж, затем занимает трюм | [MissionRegionMetric.asm](../Source/Game/Trade/MissionRegionMetric.asm), `BoardRefugees` |
| проверка разрешения высадки, военный путь ставит первую отметку | [ApplyEnhancedFlightControl.asm](../Source/Game/Universe/ApplyEnhancedFlightControl.asm), `CheckRefugees` |
| военное состояние выбирает текст беженцев либо десанта | [SelectSpecialCargoText.asm](../Source/Game/Universe/SelectSpecialCargoText.asm), `Entry` |
| перекрывающийся вход прекращает предложение покупки при занятом миссионном трюме | [ResetCloakingAndSeedFlightRandom.asm](../Source/Game/Trade/ResetCloakingAndSeedFlightRandom.asm), `BusyCargo` |

<a id="mission-7-2"></a>
## 7+2, военные поставки

[Описание в исходном руководстве](#manual-mission-7-2).

После продажи вызывается `CheckWarSupply`. Он допускает только Food или Firearms, проверяет полосу сопротивления и ставит `MS_MARK2_BIT`. Этот бит одновременно участвует в выдаче старой второй миссии. Нельзя описывать его как исключительную отметку одного задания.

| Проверка или действие | Исходник и вход |
|---|---|
| военная область ограничивает рынок и устанавливает общее состояние 4 либо 0 | [ApplyMissionMarketRestrictions.asm](../Source/Game/Menus/ApplyMissionMarketRestrictions.asm), `Entry` |
| продажа продовольствия либо оружия в полосе сопротивления ставит вторую отметку | [NextDescriptionRandom.asm](../Source/Game/Text/NextDescriptionRandom.asm), `CheckWarSupply` |
| продажа передаёт тип товара проверке военной поставки | [TradeTitleAndSellLoop.asm](../Source/Game/Trade/TradeTitleAndSellLoop.asm), `SellCargo` |

<a id="mission-7-3"></a>
## 7+3, высадка десанта

[Описание в исходном руководстве](#manual-mission-7-3).

Активная война, занятый специальным грузом трюм и достаточный военный код выбирают Sidewinder вместо ракеты. Путь снимает `MS_CARGO_BIT` и восстанавливает вместимость. При попадании Sidewinder в занятой системе ставится `MS_MARK3_BIT`, фронт уменьшается до освобождения системы, затем снимаются враждебность станции и специальное состояние.

В `HandleSpecialObjectMission.DestroyStation` регистр IX указывает на десантный корабль. Обнуляется энергия **самого десанта**. Название метки не доказывает уничтожение станции или секретной базы.

| Проверка или действие | Исходник и вход |
|---|---|
| спасательная капсула снимает признак особого груза после очистки тоннажных товаров | [HandleEscapeCapsule.asm](../Source/Game/Combat/HandleEscapeCapsule.asm), `ClearCargo` |
| проверка войны, занятого трюма и военного кода допускает запуск десанта | [CreateMissileOrMissionCraft.asm](../Source/Game/Extensions/CreateMissileOrMissionCraft.asm), `Entry` |
| признак занятого миссией трюма включает отдельную подпись беженцев либо десанта | [PrintCargoAndMessageBanks.asm](../Source/Game/Extensions/PrintCargoAndMessageBanks.asm), `Entry` |
| допуск к перевозке и выбор текста беженцев либо десанта | [ToggleSecondaryCoordinateObject.asm](../Source/Game/Input/ToggleSecondaryCoordinateObject.asm), `CheckPilot` |
| попадание в особую цель передаётся общему обработчику ракеты либо десанта | [GuideMissileAndCheckImpact.asm](../Source/Game/Motion/GuideMissileAndCheckImpact.asm), `FindTarget` |
| обычная ракета меняет этап попадания, Sidewinder обрабатывает высадку десанта | [HandleSpecialObjectMission.asm](../Source/Game/Text/HandleSpecialObjectMission.asm), `Entry` |
| Sidewinder отмечает высадку и сдвигает фронт до освобождения текущей системы | [HandleSpecialObjectMission.asm](../Source/Game/Text/HandleSpecialObjectMission.asm), `DestroyStation` |
| ответ Y очищает товары и свободный тоннаж, затем занимает трюм | [MissionRegionMetric.asm](../Source/Game/Trade/MissionRegionMetric.asm), `BoardRefugees` |
| военное состояние выбирает текст беженцев либо десанта | [SelectSpecialCargoText.asm](../Source/Game/Universe/SelectSpecialCargoText.asm), `Entry` |
| перекрывающийся вход прекращает предложение покупки при занятом миссионном трюме | [ResetCloakingAndSeedFlightRandom.asm](../Source/Game/Trade/ResetCloakingAndSeedFlightRandom.asm), `BusyCargo` |

<a id="mission-7-4"></a>
## 7+4, секретная командная база

[Описание в исходном руководстве](#manual-mission-7-4).

`CheckMissionSystem` проверяет отсутствие отставки, военную область и координаты. Полный путь требует `Y=#5C, X=#03`; при раннем выходе с C=0 значение Y=#FF также даёт Z без проверки X. Маска запрета `RANK_RSV_MASK=#40` соответствует биту 6.

Z от проверки разрешает особое положение станционного слота и `Mission3=4`. Ненулевой `FlightState.SpaceMode` не является условием этой процедуры. Дальше используются общие пути враждебности станции и попадания в особый объект. Они разделены с десантным Sidewinder, чей обработчик освобождения относится к 7+3.

**Путь завершения требует отдельного различения:** общий обработчик `BuildStationGeometry.MissionStage` записывает этап 5 по событию станционного слота, но вызывающая проверка в `ArrivalEvents` пропускается при `State.Galaxy=0`. Поэтому эту цепочку нельзя считать доказанным завершением секретной базы в первой галактике. Сам `CompleteThirdMission` изменяет рейтинг, этап и отметку награды, но напрямую не записывает `State.Invasion`. Обещанное сюжетное окончание войны не подставляется вместо этих инструкций.

| Проверка или действие | Исходник и вход |
|---|---|
| общее состояние 4 делает станцию враждебной | [UpdateAllSpaceObjects.asm](../Source/Game/Combat/UpdateAllSpaceObjects.asm), `Entry` |
| отставка, военная область и координаты определяют допуск особой станции | [CheckMissionSystem.asm](../Source/Game/Input/CheckMissionSystem.asm), `Entry` |
| попадание в особую цель передаётся общему обработчику ракеты либо десанта | [GuideMissileAndCheckImpact.asm](../Source/Game/Motion/GuideMissileAndCheckImpact.asm), `FindTarget` |
| обычная ракета меняет этап попадания, Sidewinder обрабатывает высадку десанта | [HandleSpecialObjectMission.asm](../Source/Game/Text/HandleSpecialObjectMission.asm), `Entry` |
| помеченное событие станционного слота переводит общее состояние в этап 5 | [BuildStationGeometry.asm](../Source/Game/Travel/BuildStationGeometry.asm), `MissionStage` |
| Z от проверки особой системы задаёт положение станции и состояние 4 | [CheckSpecialSystemOrRandom.asm](../Source/Game/Universe/CheckSpecialSystemOrRandom.asm), `Entry` |
| размещение небесных тел вызывает особую проверку станционного слота | [SystemBoundaryAndObjects.asm](../Source/Game/Data/SystemBoundaryAndObjects.asm), `PlaceBodies` |

<a id="original-manual"></a>
## Исходное руководство

Далее сохранён весь распакованный текст из файла на диске. Заголовки вне блоков добавлены для навигации.

<a id="manual-menu"></a>
### Меню руководства

```text




 1. ВВЕДЕНИЕ
 2. КОПИРОВАНИЕ ПРОГРАММЫ
 3. ОСНОВНЫЕ ОТЛИЧИЯ ELITE3 ОТ
    ELITE
 4. УПРАВЛЕНИЕ
 5. ОТВЕТЫ
 6. ОБ'ЯВЛЕНИЯ

 R. RUN "ELITE3"



```

<a id="manual-chapter-1"></a>
### 1. Введение

```text
#1
  *  *  *  *  *  *  *  *  *  *

           ВВЕДЕНИЕ

     ВЫ ПРИОБРЕЛИ ДИСКЕТУ
     С ПРОГРАММОЙ ELITE3?

  ВЫ СДЕЛАЛИ ПРАВИЛЬНЫЙ ВЫБОР!

    ПРЕЖДЕ, ЧЕМ НАЧАТЬ ИГРУ,
         ОБЯЗАТЕЛЬНО
     ВЫПОЛНИТЕ КОПИРОВАНИЕ
    НА СВОЕМ ДИСКОВОДЕ - ТАК,
 КАК ОБ ЭТОМ СКАЗАНО В ГЛАВЕ 2.

  ELITE3   НЕ   ВСЕГДА  РАБОТАЕТ
НА НЕСТАНДАРТНЫХ ПРОШИВКАХ  ПЗУ,
ПРОСЬБА ПО ЭТОМУ ПОВОДУ  ПРЕТЕН-
ЗИЙ НЕ ПРЕД'ЯВЛЯТЬ.

  НА НЕКОТОРЫХ КОМПЬЮТЕРАХ С НЕ-
СТАНДАРТНО ОРГАНИЗОВАННОЙ  ШИНОЙ
ПРОГРАММА НЕ ГРУЗИТСЯ (СБРАСЫВА-
ЕТСЯ ПОСЛЕ ИЗОБРАЖЕНИЯ КАРТИНКИ)

  *****************************
  *                           *
  *   ВЛАДЕЛЬЦЫ ПЕНТАГОНОВ!   *
  *                           *
  * ОБРАЩАЙТЕСЬ К ВАЛЕРЕ.     *
  *                           *
  * М."СТУДЕНЧЕСКАЯ, 1-Е ОБЩ.,*
  * КОМНАТА 212А.             *
  *                           *
  *****************************

  КРОМЕ ТОГО, ДОПУСКАЕТСЯ РАБОТА
ТОЛЬКО  НА 80-ДОРОЖЕЧНЫХ ДВУСТО-
РОННИХ ДИСКЕТАХ ПОД УПРАВЛЕНИЕМ
TR-DOS 5.03 И ВЫШЕ.
  (СПОСОБ ДЛЯ ПОЛУЧЕНИЯ КОПИИ НА
40-ДОРОЖЕЧНЫЙ 2-СТОРОННИЙ  - ДЛЯ
ЯРЫХ ПОКЛОННИКОВ ПОДОБНОГО ХЛАМА
- ПРИВЕДЕН ВО ВТОРОЙ ГЛАВЕ).

  КОМПЬЮТЕРЫ "PROFI",  "HOBBIT",
"SCORPION", "ATM TURBO" И ПРОЧИЕ
ДИНОЗАВРЫ, ЕСЛИ ШИНА В НИХ  НОР-
МАЛЬНАЯ, И ЕСТЬ ВОЗМОЖНОСТЬ БЛО-
КИРОВАТЬ ДОПОЛНИТЕЛЬНЫЕ ПРИЛАДЫ,
ТОЖЕ ВПОЛНЕ ПРИГОДНЫ.

  МЕЛОМАНЫ! ВЫНИМАЙТЕ СВОИ МУЗЫ-
КАЛКИ (СОВЕТ СПЕЦИАЛИСТА).  ЕСЛИ
ELITE3 ЗАВИСАЕТ  ВО ВРЕМЯ ПОЛЕТА
ЧАЩЕ, ЧЕМ РАЗ В СУТКИ, ЭТО ОЗНА-
ЧАЕТ, ЧТО ВАШЕМУ КОМПЬЮТЕРУ ПОРА
В УТИЛЬ (РЕЗЮМЕ АВТОРА).

  ЕСЛИ ВЫ УЖЕ  ХОРОШО ЗНАКОМЫ  С
ПРОГРАММОЙ  ELITE , ТО  ОСВАИВАЯ
ELITE*3 , ВЫ  ПОЛУЧИТЕ   ДВОЙНОЕ
УДОВОЛЬСТВИЕ ,  ЗАМЕЧАЯ МНОГОЧИ-
СЛЕННЫЕ РАСШИРЕНИЯ И  ДОПОЛНЕНИЯ
В  ХОДЕ  ИГРЫ.

  В ЭТОМ СЛУЧАЕ  ВЫ МОЖЕТЕ  ПРО-
ДОЛЖИТЬ СВОЮ ПИЛОТСКУЮ КАРЬЕРУ ,
ЗАПИСАВ  ПРЕДВАРИТЕЛЬНО СВОЮ ЗА-
ПИСЬ СОСТОЯНИЯ  НА ДИСК КАК ФАЙЛ
КОДОВ ДЛИНЫ 102 БАЙТА.  НО ЛУЧШЕ
ВСЕ-ТАКИ НАЧАТЬ СНАЧАЛА, НЕ ПРЕ-
НЕБРЕГАЯ НЕОБХОДИМОСТЬЮ ПЕРЕУЧИ-
ВАТЬСЯ ДЕЛАТЬ КОЕ-ЧТО ЗАНОВО.

         УСПЕХОВ !

               КЛАДОВ В.Л.,
               13 ЯНВАРЯ 1993 Г.

   НАЗВАНИЕ ELITE*2 ЗАМЕНЕНО НА
  ELITE*3 - ЧТОБЫ НЕ ПРОИСХОДИЛО
    ПУТАНИЦЫ С МНОГОЧИСЛЕННЫМИ
   ПРОФАНАЦИЯМИ  И ДИСКИЗАЦИЯМИ,
      НОСЯЩИМИ ТАКОЕ ЖЕ ИМЯ.

               3 ОКТЯБРЯ 1993 Г.





=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>=>














```

<a id="manual-chapter-2"></a>
### 2. Копирование программы

```text
#2
           *   *   *

     КОПИРОВАНИЕ ПРОГРАММЫ.
     >>>>>>>>>>>>>>>>>>>>>


  ПРОГРАММА ELITE3 ИМЕЕТ ОГРАНИ-
ЧЕНИЯ НА КОПИРОВАНИЕ ,  И ПРЕДУ-
ПРЕЖДЕНИЕ  ОБ ЭТОМ  ВЫВОДИТСЯ ВО
ВРЕМЯ ЗАГРУЗКИ В ТИТРАХ.

  КОПИЯ ПРОГРАММЫ МОЖЕТ БЫТЬ ПО-
ЛУЧЕНА С ПОМОЩЬЮ ВСТРОЕННОГО КО-
ПИРОВЩИКА В ДИСКОВОМ МЕНЮ. ДЕЛА-
ЕТСЯ ЭТО НАЖАТИЕМ  КЛАВИШИ "3" ,
КОГДА  ДИСКОВОЕ МЕНЮ  ОТОБРАЖЕНО
НА ЭКРАНЕ .  ЕСЛИ  У ВАС ИМЕЕТСЯ
ПРАВО ПОЛУЧИТЬ КОПИЮ ПРОГРАММЫ ,
ТО  НАЧИНАЕТ  РАБОТАТЬ   УТИЛИТА
COPY; В ПРОТИВНОМ СЛУЧАЕ СЛЕДУЕТ
СООБЩЕНИЕ О ТОМ , СКОЛЬКО УСПЕШ-
НЫХ ВЫЛЕТОВ ВАМ ОСТАЛОСЬ СДЕЛАТЬ
ДО ПОЛУЧЕНИЯ ПРАВА  НА ОЧЕРЕДНОЕ
КОПИРОВАНИЕ.

  ПРИ ВХОДЕ В АВТОКОПИРОВЩИК , В
ВЕРХНЕЙ   ЧАСТИ   ЭКРАНА   ВИДЕН
УНИКАЛЬНЫЙ НОМЕР ЭКЗЕМПЛЯРА ПРО-
ГРАММЫ , А ТАКЖЕ  ЧЕРЕЗ  ДЕФИС -
КОЛИЧЕСТВО СНЯТЫХ  КОПИЙ  ( ЕСЛИ
БЫЛИ ) , И ЧЕРЕЗ ДВОЕТОЧИЕ - КО-
ЛИЧЕСТВО КОПИЙ ,  КОТОРЫЕ  МОГУТ
БЫТЬ СДЕЛАНЫ (ЕСЛИ ЕСТЬ ПРАВО).

  КОПИЯ ТРЕТЬЕГО ПОКОЛЕНИЯ (ИМЕ-
ЮЩАЯ  ТРЕХСОСТАВНОЙ  НОМЕР  ВИДА
NNNNN.NNNNN.NNNNN) НЕ  МОЖЕТ ИС-
ПОЛЬЗОВАТЬСЯ ДЛЯ АВТОКОПИРОВАНИЯ
- ПРИ ВХОДЕ В COPY С ТАКОЙ  ДИС-
КЕТЫ   ВЫСВЕЧИВАЕТСЯ  ТОЛЬКО  ЕЕ
ИДЕНТИФИКАТОР.

  ЛЕГАЛЬНО  ПРИОБРЕТЕННАЯ  ПРОГ-
РАММА СРАЗУ ЖЕ  ПОЗВОЛЯЕТ ВЫПОЛ-
НИТЬ ОДНО КОПИРОВАНИЕ  НА ОТФОР-
МАТИРОВАННЫЙ И ПРОВЕРЕННЫЙ ДИСК,
СЛЕДУЮЩЕЕ КОПИРОВАНИЕ МОЖЕТ БЫТЬ
ВЫПОЛНЕНО ТОЛЬКО  ПОСЛЕ  256 УС-
ПЕШНЫХ ПЕРЕЛЕТОВ. НОМЕР ПРОДАВА-
ЕМОГО ЭКЗЕМПЛЯРА -ОДНОСОСТАВНОЙ,
ТО ЕСТЬ ПРОГРАММА - ПЕРВОГО  ПО-
КОЛЕНИЯ.

  ПРОГРАММА, СКОПИРОВАННАЯ НЕЛЕ-
ГАЛЬНО, ПРИ ПОПЫТКЕ ВХОДА В ДИС-
КОВОЕ МЕНЮ СБРАСЫВАЕТСЯ.
  ТО ЖЕ САМОЕ  МОЖЕТ ПРОИСХОДИТЬ
С ВЕРНОЙ КОПИЕЙ В СЛУЧАЕ  НЕСОВ-
МЕСТИМОСТИ ДИСКОВОДОВ.  ПОПЫТАЙ-
ТЕСЬ САМИ НАЙТИ ХОРОШИЙ ДИСКОВОД
(ХОТЯ БЫ ДЛЯ СНЯТИЯ ОДНОЙ КОПИИ)
И ВЫПОЛНИТЕ КОПИЮ С ДВУМЯ ДИСКО-
ВОДАМИ.   В  "ХОРОШИЙ"  ДИСКОВОД
ВСТАВЬТЕ ИСХОДНЫЙ ДИСК, В ВАШ -
ДИСК , КОТОРЫЙ НА НЕМ ОТФОРМАТИ-
РОВАН. ВЫПОЛНИТЕ ЗАГРУЗКУ И  ВЫ-
ЗОВИТЕ COPY , ДАЛЕЕ ПО  ЗАПРОСАМ
"INSERT OLD/NEW DISK..." ПОДКЛЮ-
ЧАЙТЕ ПО ОЧЕРЕДИ ДИСКОВОД С ТРЕ-
БУЕМОЙ ДИСКЕТОЙ.ВПОЛНЕ БЕЗОПАСНО
ЭТО МОЖНО ДЕЛАТЬ,  ЕСЛИ  ЗАРАНЕЕ
ПОДКЛЮЧИТЬ ПИТАНИЕ  К ОБОИМ ДИС-
КОВОДАМ,И ВСТАВЛЯТЬ ИНФОРМАЦИОН-
НУЮ ШИНУ  В РАЗ'ЕМ  ТРЕБУЮЩЕГОСЯ
УСТРОЙСТВА. ОБА УСТРОЙСТВА ДОЛЖ-
НЫ ОТВЕЧАТЬ НА ЗАПРОС ДИСКА "A".
  ЭТОТ ЖЕ МЕТОД ГОДИТСЯ ДЛЯ СКИ-
ДЫВАНИЯ  КОПИИ  НА 40-ДОРОЖЕЧНЫЙ
ДИСКОВОД: ВАМ ПОТРЕБУЕТСЯ  НАЙТИ
80-ДОРОЖЕЧНЫЙ ДИСКОВОД ЛИШЬ ОДИН
РАЗ, ТОЛЬКО ДЛЯ ПОЛУЧЕНИЯ ПЕРВОЙ
КОПИИ.

  СТРОГО ЗАПРЕЩАЕТСЯ  ВОССТАНАВ-
ЛИВАТЬ ДИСК  С ПОМОЩЬЮ  ПРОГРАММ
ВРОДЕ DCU, ADS, И ПРОЧИХ.
  ЕСЛИ КУПЛЕННАЯ ВАМИ ДИСКЕТА НЕ
ЧИТАЕТСЯ НА ВАШЕМ ДИСКОВОДЕ, ОНА
МОЖЕТ БЫТЬ ЗАМЕНЕНА ТОЛЬКО В ТОМ
СЛУЧАЕ , ЕСЛИ ОНА НЕ БЫЛА ИСПОР-
ЧЕНА ПО ВАШЕЙ ВИНЕ.

    ПОРЯДОК КОПИРОВАНИЯ.
    >>>>>>>>>>>>>>>>>>>
1. ЗАРАНЕЕ ПОДГОТОВИТЬ ОТФОРМА-
   ТИРОВАННЫЙ И ПРОВЕРЕННЫЙ ДИСК
   (2 СТОРОНЫ,80 ДОРОЖЕК),МАЛЕЙ-
   ШИЕ СБОИ  НА ПЕРВЫХ  8 ЦИЛИН-
   ДРАХ ЧРЕВАТЫ КРУПНЫМИ  НЕПРИ-
   ЯТНОСТЯМИ.
2. ВОЙТИ В DISK MENU (SYMB.SHFT)
3. ВЫЗВАТЬ АВТОКОПИРОВЩИК ("3").
4. ОТВЕТИТЬ Y(ES) НА ЗАПРОС
   "ARE YOU SURE (Y/N)?"
5. ПО  ЗАПРОСАМ  "INSERT OLD/NEW
   DISK ... " ВСТАВЛЯТЬ В ДИСКО-
   ВОД "A" СООТВЕТСТВЕННО ИСХОД-
   НУЮ ИЛИ НОВУЮ ДИСКЕТУ , И НА-
   ЖИМАТЬ КЛАВИШУ ENTER.
6. ПО ОКОНЧАНИИ КОПИРОВАНИЯ КОМ-
   ПЬЮТЕР СБРАСЫВАЕТСЯ И ВЫХОДИТ
   НА  АВТОМАТИЧЕСКУЮ  ЗАГРУЗКУ
   ПОЛУЧЕННОЙ КОПИИ.
     ПРИ ЭТОМ  НА ВЫХОДНОМ ДИСКЕ
   СФОРМИРОВАНЫ ДВА ФАЙЛА:
   - BOOT (BASIC)   2 СЕКТОРА;
   - ELITE3(CODE) 209 СЕКТОРОВ.
     ЭТИ ДВА ФАЙЛА НЕ МОГУТ БЫТЬ
   ПЕРЕМЕЩЕНЫ  ИЛИ СКОПИРОВАНЫ В
   ДАЛЬНЕЙШЕМ БЕЗ  ИСПОЛЬЗОВАНИЯ
   ВСТРОЕННОГО  АВТОКОПИРОВЩИКА,
   ЛЮБЫЕ ДРУГИЕ ФАЙЛЫ КОПИРУЮТСЯ
   НА ДИСК ОБЫЧНЫМИ СРЕДСТВАМИ.



  *  *  *  *  *  *  *  *  *  *














```

<a id="manual-chapter-3"></a>
### 3. Основные отличия Elite 3 от Elite

```text
#3
 |    ОТЛИЧИЯ ОТ ELITE.
 |    =================
 |
 |
О|БАЗЫ:
Т|- ПОСАДКА НА БАЗУ ВРУЧНУЮ -
Л|  ЭТО ОЧЕНЬ СЛОЖНАЯ ОПЕРАЦИЯ
И|  В ELITE3 . В ЛЮБОЙ МОМЕНТ
Ч|  ИЗ ВХОДНОГО КОЛОДЦА МОЖЕТ
И|  ВЫЛЕТЕТЬ ДРУГОЙ КОРАБЛЬ,
Я|  СТОЛКНОВЕНИЕ С КОТОРЫМ ЧАЩЕ
 |  ВСЕГО ЗАКАНЧИВАЕТСЯ КАТА-
О|  СТРОФОЙ.
Т|- ОТКРЫТИЕ ОГНЯ ПО МИРНЫМ
 |  КОРАБЛЯМ ИЛИ ПО КОРАБЛЯМ
E|  СИЛ ФЕДЕРАЦИИ ВВИДУ БАЗЫ,
L|  ИЛИ ПО САМОЙ БАЗЕ ВЫЗЫВАЕТ
I|  НЕМЕДЛЕННУЮ АТАКУ ПОЛИЦЕЙС-
T|  КИХ.
E|- АНАЛОГИЧНО, ЕСЛИ БАЗА ЗАХ-
 |  ВАЧЕНА ТАРГОНАМИ ИЛИ ПИРАТА-
 |  МИ, ВАС АТАКУЮТ СООТВЕТСТ-
 |  ВЕННО ТАРГОНЫ ИЛИ ПИРАТЫ.
О|- В ТО ЖЕ ВРЕМЯ, ВВИДУ БАЗЫ,
Т|  КОНТРОЛИРУЕМОЙ СИЛАМИ ФЕДЕ-
Л|  РАЦИИ, ВЫ МОЖЕТЕ ВЕСТИ АК-
И|  ТИВНЫЕ БОЕВЫЕ ДЕЙСТВИЯ ПРО-
Ч|  ТИВ ВРАГОВ ФЕДЕРАЦИИ, УНИЧ-
И|  ТОЖАТЬ АСТЕРОИДЫ - ЭТО ПОЙ-
Я|  ДЕТ ЛИШЬ НА ПОЛЬЗУ ВАШЕМУ
 |  СТАТУСУ.
О|- БАЗА, КАК И ЛЮБОЙ КОРАБЛЬ,
Т|  РАЗУМНО ИСПОЛЬЗУЕТ E.C.M.
 |  СИСТЕМУ ТОЛЬКО ДЛЯ УНИЧТО-
E|  ЖЕНИЯ ЗАПУЩЕННЫХ ПО НЕЙ
L|  САМОЙ РАКЕТ: ВПОЛНЕ ВОЗ-
I|  МОЖНО ИСПОЛЬЗОВАНИЕ РАКЕТ
T|  ПО ЛЮБЫМ ЦЕЛЯМ В ВИДУ БАЗЫ
E|  ( В ТОМ ЧИСЛЕ И ПО ВАШЕЙ
 |  "КОБРЕ" !)
 |- УНИЧТОЖЕНИЕ БАЗЫ, КАК И
 |  УНИЧТОЖЕНИЕ ПОЛИЦЕЙСКОГО
О|  ПРЕВРАЩАЕТ ВАС ВО ВРАГА
Т|  ФЕДЕРАЦИИ #1. В ГАЛАКТИКАХ
Л|  2-8 ТАКИХ НАРУШИТЕЛЕЙ НА
И|  ПОДЛЕТЕ К ПЛАНЕТЕ ВСТРЕЧАЕТ
Ч|  ПОЛИЦЕЙСКИЙ КОРДОН.
И|
Я|ДРУГИЕ КОРАБЛИ:
 |- ВЕДУТ ОГОНЬ НЕ ТОЛЬКО ПО ВА-
О|  ШЕМУ КОРАБЛЮ, НО И ДРУГ ПО
Т|  ДРУГУ, ИСПОЛЬЗУЯ ЛАЗЕРЫ,
 |  РАКЕТЫ И ПРОТИВОРАКЕТНУЮ
E|  СИСТЕМУ, ИНОГДА ДАЖЕ ЭНЕР-
L|  ГЕТИЧЕСКУЮ БОМБУ. ПРИ ЭТОМ
I|  ВОЗМОЖНЫ СОВМЕСТНЫЕ ДЕЙСТВИЯ
T|  ГРУПП КОРАБЛЕЙ ДРУГ ПРОТИВ
E|  ДРУГА (И ВЫ МОЖЕТЕ УЧАВСТ-
 |  ВОВАТЬ, ОПАСАЙТЕСЬ ЛИШЬ
 |  ОКАЗАТЬСЯ МЕЖДУ ДВУХ ОГНЕЙ!)
 |- ПОДБИРАЮТ ГРУЗЫ, ЕСЛИ ИМЕЮТ
О|  FUEL SCOOPS -СБОРЩИК ТОПЛИВА
Т|- УХОДЯТ В ГИПЕРПЕРЕХОД ИЛИ
Л|  ТЕЛЕПОРТИРУЮТСЯ НА БАЗУ ПРИ
И|  ПОМОЩИ DOCKING COMPUTER'А
Ч|  ИЛИ ESCAPE POD (ЕСЛИ УСПЕЮТ)
И|- НЕКОТОРЫЕ КОРАБЛИ НЕСУТ НА
Я|  БОРТУ КОРАБЛИ МЕНЬШЕГО РАЗ-
 |  МЕРА (ПИТОНЫ МОГУТ ТРАНСПОР-
О|  ТИРОВАТЬ ДО ТРЕХ ДРУГИХ КО-
Т|  РАБЛЕЙ МЕЖПЛАНЕТНОГО КЛАССА,
 |  НЕ ИМЕЮЩИХ САМОСТОЯТЕЛЬНОЙ
E|  СПОСОБНОСТИ К ГИПЕРПЕРЕХОДУ)
L|- КРОМЕ ТОГО, ВЫ ВСТРЕТИТЕ
I|  КОРАБЛИ НОВОГО ПОКОЛЕНИЯ:
T|  ТАРГОИД-6,ГЕККО И МАМБА.
E|
 |КОСМОЛОГИЯ:
 |- СТАЛИ ВОЗМОЖНЫ ПОЛЕТЫ НА
 |J-ДВИГАТЕЛЕ В МЕЖЗВЕЗДНОМ
О|ПРОСТРАНСТВЕ. ОРИЕНТИРОВАТЬСЯ
Т|ВАМ ПРИ ЭТОМ ПОМОЖЕТ ГИРОКОМ-
Л|ПАС, ПОКАЗЫВАЮЩИЙ СТОРОНЫ
И|СВЕТА ОТНОСИТЕЛЬНО ВАШЕГО ТЕ-
Ч|КУЩЕГО ПОЛОЖЕНИЯ В ПЛОСКОСТИ
И|ГАЛАКТИКИ.
Я|- НА ДОСТАТОЧНО БОЛЬШОМ УДАЛЕ-
 |НИИ ОТ СОЛНЦА В ПЛАНЕТНЫХ СИС-
О|ТЕМАХ  НАЧИНАЕТСЯ  МЕТЕОРИТНЫЙ
Т|ПОЯС, В ПРЕДЕЛАХ КОТОРОГО
 |ЛИШЬ ИЗРЕДКА ВСТРЕЧАЮТСЯ ДРУ-
E|ГИЕ ОХОТНИКИ ЗА МИНЕРАЛАМИ.
L|
I|СТАРЫЕ МИССИИ:
T|- ТРИ МИССИИ, ВСТРЕЧАВШИЕСЯ
E|  В ELITE, СОХРАНЕНЫ. НО В
 |  ELITE3 ОНИ МОГУТ ПОВТОРЯТЬСЯ
 |  НЕОДНОКРАТНО.
 |
О|НОВОЕ ВООРУЖЕНИЕ КОБРЫ-МК3:
Т|- СТАР-КОМПАС, ПОКАЗЫВАЕТ В
Л|  РЕЖИМЕ ПОПЕРЕМЕННОГО МИГА-
И|  НИЯ ОРИЕНТАЦИЮ НА СОЛНЦЕ
Ч|  И НА ПЛАНЕТУ, ВКЛЮЧАЕТСЯ
И|  ПО КОМАНДЕ CAPS+C .
Я|- СФЕРИЧЕСКИЙ ЛОКАТОР.
 |  ВКЛЮЧАЕТСЯ ПО КОМАНДЕ
О|  CAPS+L .
Т|- СУПЕР-ЛАЗЕР. МОЖЕТ БЫТЬ
 |  КУПЛЕН НА ПЛАНЕТЕ 15-ГО
E|  УРОВНЯ. СТОИМОСТЬ 33000CR.
L|
I|
T|
E|
 |
 |
 |
Н|       НОВЫЕ МИССИИ:
О|       =>=>=>=>=>=>
В|
Ы|   МИССИЯ 4.
Е|
 |   ВО ВРЕМЯ ОХОТЫ ЗА МИНЕРАЛА-
М|   МИ НАЙТИ ЖИВЫЕ КРИСТАЛЛЫ.
И|
С|
С|   МИССИЯ 5.
И|
И|   ПОДОБРАТЬ С ПОДБИТОГО
 |   ТАРГОИДА УСТРОЙСТВО
 |   ДИСТАНЦИОННОГО УПРАВЛЕНИЯ
 |   - "ALIEN COMPUTER".
Н|   ЭТО УСТРОЙСТВО ПОЗВОЛЯЕТ
О|   ЗАПУСКАТЬ ИМЕЮЩИЕСЯ НА
В|   БОРТУ ALIEN ITEMS ("D" И
Ы|   "F" ОДНОВРЕМЕННО ).
Е|
 |
М|   МИССИЯ 6.
И|
С|   КУПИТЬ КОБРУ-МК4 (250000CR)
С|
И|      ВОЗМОЖНОСТИ КОБРЫ-МК4:
И|
 |   - ПОКУПКА ДО 4-Х УСТРОЙСТВ,
 |   ТАКИХ КАК FUEL SCOOPS,
 |   E.C.M. SYSTEM, ENERGY BOMB
Н|   И Т.Д., ПРИЧЕМ 4 ЭНЕРГЕТИ-
О|   ЧЕСКИХ ПОДЗАРЯЖАЮЩИХ УС-
В|   ТРОЙСТВ В 5 РАЗ УВЕЛИЧИВАЕТ
Ы|   СКОРОСТЬ ПОДЗАРЯДКИ ЭНЕРГЕ-
Е|   ТИЧЕСКИХ ОТСЕКОВ, А 4 LARGE
 |   CARGO BAY'S УВЕЛИЧИВАЮТ
М|   ГРУЗОПОД'ЕМНОСТЬ ДО 80ТОНН.
И|   - МНОГОКРАТНОЕ УВЕЛИЧЕНИЕ
С|   СКОРОСТИ И МАНЕВРЕННОСТИ,
С|   ЕСЛИ ПРИ ВЫПОЛНЕНИИ МАНЕВРА
И|   УДЕРЖИВАТЬ В НАЖАТОМ СОСТО-
И|   ЯНИИ КЛАВИШУ "J".
 |   - ВОЗМОЖНОСТЬ В ЛЮБОЙ МО-
 |   МЕНТ ПОВЕРНУТЬ ПО ЧАСОВОЙ
 |   СТРЕЛКЕ СТАНИНУ С ЛАЗЕРАМИ:
Н|   CAPS+A .
О|   - ВОЗМОЖНОСТЬ ВЫПОЛНЕНИЯ
В|   ГИПЕРПЕРЕХОДА В ЛЮБУЮ ГА-
Ы|   ЛАКТИКУ, В ТОМ ЧИСЛЕ В
Е|   ЛЮБОЕ МЕСТО ТЕКУЩЕЙ ГАЛАК-
 |   ТИКИ (ВО ВРЕМЯ ПРЕДСТАРТО-
М|   ВОГО ОТСЧЕТА УДЕРЖИВАТЬ В
И|   НАЖАТОМ СОСТОЯНИИ ЦИФРОВУЮ
С|   КЛАВИШУ 1-8).
С|
И|
И|   МИССИЯ 7.
 |
 |   ПРИНЯТЬ УЧАСТИЕ В КРУПНО-
 |   МАСШТАБНОЙ ВОЙНЕ С ТАРГО-
Н|   НАМИ, И ДОБИТЬСЯ ПРИ ЭТОМ
О|   КАК МОЖНО БОЛЕЕ ВЫСОКОГО
В|   ЗВАНИЯ.
Ы|7+1. ЭВАКУАЦИЯ ПЕРСОНАЛА
Е|   СТАНЦИЙ ТИПА "КОРИОЛИС",
||   ОКАЗАВШИХСЯ В ЗОНЕ АКТИВ-
М|   НЫХ БОЕВЫХ ДЕЙСТВИЙ.
И|7+2. ДОСТАВКА ПРОДОВОЛЬСТВИЯ
С|   И ОРУЖИЯ НА СРАЖАЮЩИЕСЯ
С|   ПЛАНЕТЫ.
И|7+3. ВЫСАДКА ДЕСАНТА НА ОК-
И|   КУПИРОВАННЫЕ СТАНЦИИ.
 |7+4. УНИЧТОЖЕНИЕ СЕКРЕТНОЙ
 |   КОМАНДНОЙ БАЗЫ ТАРГОНОВ,
 |   РАСПОЛОЖЕННОЙ В МЕЖЗВЕЗДНОМ
 |   ПРОСТРАНСТВЕ, ВДАЛИ ОТ
 |   ПЛАНЕТНЫХ СИСТЕМ.
 |
* * * * * * * * * * * * * * * *















```

<a id="manual-chapter-4"></a>
### 4. Управление

```text
#4
          * * *

       УПРАВЛЕНИЕ.

          * * *



  ELITE3  НЕ ОБРАЩАЕТСЯ К  ПОРТУ
ДЖОЙСТИКА, И ИСПОЛЬЗУЕТ УПРАВЛЕ-
НИЕ ТОЛЬКО ОТ КЛАВИАТУРЫ.

  УПРАВЛЕНИЕ ВО ВРЕМЯ ИГРЫ:
  =>=>=>=>=>=>=>=>=>=>=>=>
  1 - ПЕРЕДНИЙ ОБЗОР
  2 - ЗАДНИЙ   ОБЗОР
  3 - ЛЕВЫЙ    ОБЗОР
  4 - ПРАВЫЙ   ОБЗОР
  A - ОГОНЬ ИЗ ЛАЗЕРА
  S - ВНИЗ     N - ВЛЕВО
  X - ВВЕРХ    M - ВПРАВО
  CAPS.SHFT - СБАВИТЬ СКОРОСТЬ
  SYMB.SHFT - УВЕЛИЧИТЬ СКОРОСТЬ
  T - НАЦЕЛИВАНИЕ РАКЕТЫ
  U - СНЯТИЕ РАКЕТЫ С ЦЕЛИ
  F - ЗАПУСК РАКЕТЫ ПО ЦЕЛИ
D И F - ЗАПУСК ALIEN ITEMS
  E - ВКЛЮЧЕНИЕ ПРОТИВОРАКЕТНОЙ
      СИСТЕМЫ
  W - ВЗРЫВ ЭНЕРГЕТИЧЕСКОЙ БОМБЫ
  Q - КАТАПУЛЬТИРОВАНИЕ
  Y - ВКЛ./ВЫКЛ. УСТРОЙСТВА
      НЕВИДИМОСТИ
  C - АКТИВИЗАЦИЯ УСТРОЙСТВА
    АВТОМАТИЧЕСКОГО ПРИЧАЛИВАНИЯ
  H - ГИПЕРПЕРЕХОД
G И H - ГИПЕРПЕРЕХОД В ДРУГУЮ
      ГАЛАКТИКУ
  J - ПОЛЕТ НА J-ДВИГАТЕЛЕ С
      ОКОЛОСВЕТОВОЙ СКОРОСТЬЮ

  I - КАРТА ГАЛАКТИКИ {
  O - ПОДРОБНАЯ КАРТА |
  P - ИНФОРМАЦИЯ ПО   |
      ПЛАНЕТЕ         |НА БАЗЕ И
  K - ПРЕЙСКУРАНТ ЦЕН |ВО ВРЕМЯ
      И ТОВАРОВ НА ТЕ-< ПОЛЕТА
      КУЩЕЙ ПЛАНЕТЕ   |ДЕЙСТВУЮТ
  L - СОСТОЯНИЕ ИГРЫ  |ОДИНАКОВО
  ENTER - ПЕРЕЧЕНЬ    |
      ГРУЗОВ НА БОРТУ |
  CAPS.SHFT - ПАУЗА   }

  УПРАВЛЕНИЕ В КАРТЕ (I,O):
  =>=>=>=>=>=>=>=>=>=>=>=>
  S - ВВЕРХ  N - ВЛЕВО
  X - ВНИЗ   M - ВПРАВО
  D - КУРСОР НА БЛИЖАЙШУЮ ЗВЕЗДУ
  P - ИНФОРМАЦИЯ ПО БЛИЖАЙШЕЙ
      ПЛАНЕТНОЙ СИСТЕМЕ
  B - ВОЗВРАТ КУРСОРА В ПОЗИЦИЮ
      ТЕКУЩЕЙ ПЛАНЕТНОЙ СИСТЕМЫ

  УПРАВЛЕНИЕ НА БАЗЕ:
  =>=>=>=>=>=>=>=>=>
  1 - ВЫХОД ИЗ БАЗЫ
  2 - ПОКУПКА ТОВАРОВ
  3 - ПРОДАЖА ТОВАРОВ
  4 - ПОКУПКА ОБОРУДОВАНИЯ
  SYMB.SHFT - ВХОД В ДИСКОВОЕ
              МЕНЮ

  УПРАВЛЕНИЕ В РЕЖИМЕ "ПАУЗА":
  =>=>=>=>=>=>=>=>=>=>=>=>=>=

  BREAK - ВЫХОД ИЗ ПАУЗЫ
  Q - СБРОС ИГРЫ, ВОССТАНОВЛЕ-
      НИЕ ПРЕДЫДУЩЕГО СОСТОЯНИЯ
  A - ПОВОРОТ СТАНИНЫ С ЛАЗЕРАМИ
      ПО ЧАСОВОЙ СТРЕЛКЕ (ТОЛЬКО
      ДЛЯ КОБРЫ-МК4 !)
  C - ПЕРЕКЛЮЧЕНИЕ КОМПАСА В
      РЕЖИМ СТАР-КОМПАСА И
      ОБРАТНО
  L - ПЕРЕКЛЮЧЕНИЕ ЛОКАТОРА В
      РЕЖИМ СФЕРИЧЕСКОГО ЛОКА-
      ТОРА И ОБРАТНО
  S - ВКЛЮЧЕНИЕ/ВЫКЛЮЧЕНИЕ ЗВУКА
  F - ВКЛЮЧЕНИЕ/ВЫКЛЮЧЕНИЕ
      РЕЖИМА ПОИСКА ТАРГОНОВ В
      МЕЖЗВЕЗДНОМ ПРОСТРАНСТВЕ
      ПРИ ГИПЕРПЕРЕХОДЕ
  B - ПЕРЕКЛЮЧЕНИЕ ВСЕХ КЛАВИШ
      УПРАВЛЕНИЯ ПОВОРОТАМИ В
      ПРОТИВОПОЛОЖНОЕ НАПРАВЛЕ-
      НИЕ (ЭФФЕКТ - НОРМАЛЬНОЕ
      УПРАВЛЕНИЕ ДЛЯ ЗАДНЕГО
      ЭКРАНА)
  Y - ПЕРЕКЛЮЧЕНИЕ КЛАВИШ
      УПРАВЛЕНИЯ ВВЕРХ/ВНИЗ
      ВО ВЗАИМНО-ПРОТИВОПОЛОЖ-
      НЫЕ ЗНАЧЕНИЯ
  K - ВМЕСТО КЛАВИШ S-X-N-M
      БУДУТ ИСПОЛЬЗОВАТЬСЯ
      КЛАВИШИ КУРСОРА 5-6-7-8,
      ОГОНЬ ЛАЗЕРАМИ ВОЗМОЖНО
      БУДЕТ ВЕСТИ 0 ИЛИ A;
      ОДНАКО, ЧТОБЫ ЭТА КЛАВИША
      РАБОТАЛА, НЕОБХОДИМО В
      ОТВЕТ НА ЗАПРОС
      "PRESS SPACE, COMMANDER"
      НАЖАТЬ КУРСОР ВЛЕВО (5).
  D - УПРАВЛЕНИЕ В ДИНАМИКЕ,
      КОГДА ДОСТИГНУТАЯ СКОРОСТЬ
      ПОВОРОТА СОХРАНЯЕТСЯ
  R - РЕАКТИВНОСТЬ УПРАВЛЕНИЯ

  УПРАВЛЕНИЕ В ДИСКОВОМ МЕНЮ:
  =>=>=>=>=>=>=>=>=>=>=>=>=>
  S - ВВЕРХ  {
  X - ВНИЗ   < ПЕРЕМЕЩЕНИЕ
  N - ВЛЕВО  | КУРСОРА ПО
  M - ВПРАВО } КАТАЛОГУ
  1 - ЗАГРУЗКА ФАЙЛА
  2 - ВЫГРУЗКА - ЗАПРАШИВАЕТСЯ
      ДОПОЛНИТЕЛЬНО ИМЯ, ПОСЛЕ
      ЧЕГО ВОЗМОЖНО:
    - ВВЕСТИ ИМЯ И ПОСЛЕ ENTER
      БУДЕТ ЛИБО СОЗДАН НОВЫЙ
      ФАЙЛ, ЛИБО ВЫПОЛНИТСЯ
      ЗАПИСЬ В СТАРЫЙ ФАЙЛ, ЕСЛИ
      ТАКОЙ ФАЙЛ УЖЕ СУЩЕСТВУЕТ;
    - ПРОСТО НАЖАТЬ ENTER, И
      ВЫПОЛНИТСЯ ЗАПИСЬ В ФАЙЛ,
      ОТМЕЧЕННЫЙ КУРСОРОМ;
    - НАЖАТЬ BREAK И УДЕРЖИВАТЬ
      ДО ВЫХОДА ИЗ DISK MENU:
      СОСТОЯНИЕ ЗАПОМИНАЕТСЯ В
      ПАМЯТИ КОМПЬЮТЕРА.
  3 - ОБРАЩЕНИЕ К ВНУТРЕННЕМУ
      КОПИРОВЩИКУ ELITE*3.
      ЕСЛИ ПРАВО КОПИРОВАНИЯ ЕЩЕ
      НЕ ПОЛУЧЕНО , БУДЕТ НАПЕ-
      ЧАТАНО, СКОЛЬКО ОСТАЛОСЬ
      СДЕЛАТЬ УСПЕШНЫХ ПЕРЕЛЕТОВ
      ДО РАЗРЕШЕНИЯ НА ОЧЕРЕДНОЕ
      КОПИРОВАНИЕ.
  4 - ВЫЗОВ ДЕМОНСТРАЦИОННОГО
      РЕЖИМА.














```

<a id="manual-chapter-5"></a>
### 5. Ответы, общие сведения

```text
#5
       ЭТА  ГЛАВА СОДЕРЖИТ

       ОТВЕТЫ  НА ВОПРОСЫ,

       НА  КОТОРЫЕ  ОБЫЧНО

       ОТВЕЧАТЬ НЕ СЛЕДУЕТ





   ЕСЛИ ВЫ ЛЮБИТЕ ДОКАПЫВАТЬСЯ

   ДО  ВСЕГО  САМОСТОЯТЕЛЬНО ,

      НЕ ЧИТАЙТЕ ДАЛЬШЕ:

   НАЖМИТЕ СКОРЕЕ BREAK !!!





















  СТАРЫЕ МИССИИ ВЫДАЮТСЯ ТЕПЕРЬ
ПОСЛЕ КАЖДОГО ОЧЕРЕДНОГО СООБЩЕ-
НИЯ "RIGHT ON COMMANDER!"

  О МИССИЯХ 4-6, КАК И О СТАН-
ДАРТНОЙ МИССИИ CLOAKING DEVICE,
НИКАКИХ СПЕЦИАЛЬНЫХ СООБЩЕНИЙ В
ХОДЕ ИГРЫ НЕ ВЫДАЕТСЯ. БОЛЕЕ
ТОГО ,ЭТИ МИССИИ ВООБЩЕ ЯВЛЯЮТСЯ
НЕ ИМПЕРАТИВОМ, ОБЯЗАТЕЛЬНЫМ К
ИСПОЛНЕНИЮ, А В НЕКОТОРОМ РОДЕ
ДОПОЛНИТЕЛЬНЫМИ ВОЗМОЖНОСТЯМИ,
КОТОРЫЕ НАДО ОТКРЫТЬ И УМЕЛО
ИСПОЛЬЗОВАТЬ В СВОИХ ИНТЕРЕСАХ.
НО ЕСЛИ ВЫ ИЗ ТЕХ, КТО ЛЮБИТ
СМОТРЕТЬ ДЕТЕКТИВЫ, НАПЕРЕД ЗНАЯ
ФИНАЛ, ТО ЧИТАЙТЕ ДАЛЬШЕ.




```

<a id="manual-mission-4"></a>
### 5. Ответы, миссия 4 MINERAL LIFE

```text
  МИССИЯ 4. MINERAL LIFE.
  ========


  НАДО НАЙТИ ЗВЕЗДНУЮ СИСТЕМУ НА
ГЛАВНОЙ ДИАГОНАЛИ ЛЮБОЙ ГАЛАКТИ-
КИ.
 +++++++++++++++ ГЛАВНАЯ  ДИАГО-
 +.            + НАЛЬ  СОЕДИНЯЕТ
 +  .          + ВЕРХНИЙ ЛЕВЫЙ И
 +    .        + И НИЖНИЙ ПРАВЫЙ
 +      .      + УГОЛ ГАЛАКТИКИ.
 +        .    +
 +          .  +
 +            .+
 +++++++++++++++

  В ТАКОЙ ПЛАНЕТНОЙ СИСТЕМЕ НАДО
ЛЕТЕТЬ ОТ СОЛНЦА ДО ТЕХ ПОР,ПОКА
ОНО НЕ  УМЕНЬШИТСЯ  ДО  РАЗМЕРОВ
МАЛЕНЬКОЙ ЗВЕЗДОЧКИ,И ТАМ ЛОВИТЬ
МИНЕРАЛЫ.

  КАК ТОЛЬКО В СПИСКЕ ГРУЗОВ  НА
БОРТУ ВМЕСТО  ОБЫЧНЫХ  МИНЕРАЛОВ
ВЫ УВИДИТЕ НАДПИСЬ MINERAL LIFE,
ТО СЧИТАЙТЕ СЕБЯ БОГАЧОМ : ТОННА
ТАКОГО ГРУЗА СТОИТ 1000CR.

  ДАЛЕЕ КАЖДАЯ ПОЙМАННАЯ ИЛИ КУ-
ПЛЕННАЯ ТОННА ОБЫЧНЫХ  МИНЕРАЛОВ
КОЛОНИЗИРУЕТСЯ ВАШИМИ ГОСТЯМИ, И
ТОЖЕ СТАНОВИТСЯ ДРАГОЦЕННОЙ.

  ОДНАКО ЖИВЫЕ КРИСТАЛЛЫ -  ПРИ-
ВИРЕДЛИВЫ И СВАРЛИВЫ: КАК ТОЛЬКО
ИХ СТАНЕТ МЕНЬШЕ ТРЕХ ТОНН , ОНИ
ПРЕВРАТЯТСЯ В ОБЫЧНЫЕ КАМНИ.  ПО
ЭТОЙ ПРИЧИНЕ НИКТО У ВАС  НЕ КУ-
ПИТ МЕНЬШЕ ТРЕХ ТОНН ЗА РАЗ.ЕСТЬ
И ВЕРХНИЙ ПРЕДЕЛ - 63 ТОННЫ (ДЛЯ
ЖАДНЫХ ВЛАДЕЛЬЦЕВ КОБРЫ МК4).

  ЕСЛИ ЖЕ ВЫ ХОТИТЕ СОХРАНИТЬ  И
РАЗМНОЖИТЬ MINERAL LIFE, ПРЕВРА-
ТИВ СВОЙ КОРАБЛЬ  В СВОЕОБРАЗНУЮ
КОСМИЧЕСКУЮ ФЕРМУ , ТО ЗАПОМНИТЕ
СЛЕДУЮЩЕЕ: ЧТОБЫ ЖИТЬ , ИМ НУЖНО
ПИТАТЬСЯ.  КОРМЯТСЯ  ОНИ  ВАШИМИ
ДРАГОЦЕННОСТЯМИ В МОМЕНТ  ГИПЕР-
ПЕРЕХОДА ,  ИЗДАВАЯ  ХАРАКТЕРНЫЙ
ХРУМКАЮЩИЙ ЗВУК И  ПОГЛОЩАЯ  ПРИ
ЭТОМ 1 ГРАММ GEM STONES  НА ОДНУ
ТОННУ СВОЕГО ЖИВОГО ВЕСА. И ЕСЛИ
ВЫ ЗАБУДЕТЕ ПОКОРМИТЬ ИХ ТРИ РА-
ЗА ПОДРЯД, ТО - ПРОЩАЙ, КОЛХОЗ!

  ЕСЛИ ПО КАКОЙ-ЛИБО ПРИЧИНЕ ВА-
ШИ ПИТОМЦЫ ОКОЛЕЛИ,ТО В ГРУЗОВЫХ
ОТСЕКАХ ВАШЕЙ КОБРЫ  ПОСЕЛЯЮТСЯ
ОСТАТОЧНЫЕ КРИСТАЛЛОИДЫ, КОТОРЫЕ
РАЗЛАГАЮТ ЛЮБОЙ ПОПАВШИЙ НА БОРТ
НАСТОЯЩИЙ ЖИВОЙ МИНЕРАЛ, И БОЛЬ-
ШЕ ВАМ РАЗВЕСТИ MINERAL LIFE НЕ
УДАСТСЯ, ПОКА ОТСЕКИ НЕ БУДУТ
ЗАМЕМЕНЫ ПОСЛЕ СПАСЕНИЯ REFUGEES
(МИССИЯ-1).







```

<a id="manual-mission-5"></a>
### 5. Ответы, миссия 5 ALIEN COMPUTER

```text
  МИССИЯ 5. ALIEN COMPUTER.
  =>=>=>=>


  НЕОБХОДИМО БИТЬСЯ С ТАРГОНАМИ,
ПОКА ИЗ ПОДБИТОГО ТАРГОНА ( СТА-
РОЙ КОНСТРУКЦИИ )  НЕ  ВЫВАЛИТСЯ
КОНТЕЙНЕР ,  ПО ВИДУ ПОХОЖИЙ  НА
ОБЫЧНЫЙ КОНТЕЙНЕР С ГРУЗОМ.   ОН
ВОЗНИКАЕТ В ПРОСТРАНСТВЕ  ДОСТА-
ТОЧНО ДАЛЕКО ОТ МЕСТА ГИБЕЛИ ВА-
ШЕЙ ЖЕРТВЫ,И СНАБЖЕН ДВИГАТЕЛЕМ,
ЧТО САМО ПО СЕБЕ  ОСЛОЖНЯЕТ  ЕГО
ПОИМКУ. К ТОМУ ЖЕ, ЕСЛИ ПОБЛИЗО-
СТИ ИМЕЮТСЯ ДРУГИЕ  ТАРГОНЫ , ТО
ОНИ ПОСТАРАЮТСЯ ДОБРАТЬСЯ ДО НЕ-
ГО РАНЬШЕ ВАС, А СКОРОСТЬ У НИХ,
САМИ ПОНИМАЕТЕ, КАКАЯ.

  ЕСЛИ ВЫ УПУСТИЛИ ЭТОТ ТРОФЕЙ ,
ТО ЭТО ЕЩЕ НЕ ОЗНАЧАЕТ, ЧТО ВОЗ-
МОЖНОСТЬ ПОЙМАТЬ ЕГО УПУЩЕНА НА-
ВСЕГДА: МОЖНО ПРОДОЛЖИТЬ ОХОТУ ,
И ТОТ, КТО ИЩЕТ, ТОТ ВСЕГДА НАЙ-
ДЕТ!

  ПОЛУЧИВ ALIEN COMPUTER, ВЫ МО-
ЖЕТЕ , ИСПОЛЬЗУЯ СИСТЕМУ НАЦЕЛИ-
ВАНИЯ РАКЕТ, ЗАПУСКАТЬ ИМЕЮЩИЕСЯ
НА БОРТУ ALIEN ITEMS (НАЖАТЬ "D"
И НЕ ОТПУСКАЯ - "F").  УНИЧТОЖИВ
ЦЕЛЬ ЛАЗЕРОМ ИЛИ  ТАРАНОМ ,  ВАШ
ALIEN ITEM БУМЕРАНГОМ  ВОЗВРАЩА-
ЕТСЯ НАЗАД. НАДО ТОЛЬКО ПРАВИЛЬ-
НО РАЗВЕРНУТЬСЯ, ЧТОБЫ НЕ СТОЛК-
НУТЬСЯ С НИМ (ВАМ-ТО ПОЧТИ НИЧЕ-
ГО НЕ БУДЕТ, НО БУМЕРАНГУ НЕ ПО-
ЗДОРОВИТСЯ).

  ALIEN ITEMS ЭФФЕКТИВНЫ ТОЛЬКО
ДЛЯ БОРЬБЫ С ТАРГОНАМИ ( И УНИЧ-
ТОЖЕНИЯ ОРБИТАЛЬНЫХ СТАНЦИЙ ),
ПРОЧИЕ КОРАБЛИ ОЧЕНЬ ЛЕГКО СБИ-
ВАЮТ ИХ ЛАЗЕРАМИ.






```

<a id="manual-mission-6"></a>
### 5. Ответы, миссия 6 Cobra Mk4

```text
  МИССИЯ 6. ПОКУПКА КОБРЫ-МК4.
  =>=>=>=>


  ВЫПОЛНЯЕТСЯ В ПЛАНЕТНЫХ СИСТЕ-
МАХ НА ГЛАВНОЙ ДИАГОНАЛИ (ТЕХ ЖЕ
САМЫХ, ЧТО И В МИССИИ 4 - ПОИСКА
MINERAL LIFE).

  ЛЕТЕТЬ ТЕПЕРЬ НУЖНО В  НАПРАВ-
ЛЕНИИ СОЛНЦА.ЕСЛИ УДАЕТСЯ КАКИМ-
-ЛИБО СПОСОБОМ ПЕРЕСЕЧЬ  ОПАСНУЮ
ЗОНУ, В КОТОРОЙ ИДУТ НЕПРЕРЫВНЫЕ
СРАЖЕНИЯ, ТО ВЫ ДОСТИГАЕТЕ НАХО-
ДЯЩИХСЯ ВБЛИЗИ ЗВЕЗДЫ ДВУХ СТАН-
ЦИЙ ТИПА "КОРИОЛИС" , НА ОДНУ ИЗ
КОТОРЫХ НАДО СОВЕРШИТЬ  ПОСАДКУ.
  ДЕЛАТЬ ЭТО, СКОРЕЕ ВСЕГО, ПРИ-
ДЕТСЯ ВРУЧНУЮ , ТАК ЧТО ПОТРЕНИ-
РУЙТЕСЬ ЗАРАНЕЕ.
  И , ЕСЛИ ВЫ  НЕ ЗАБЫЛИ С СОБОЙ
256000 КРЕДИТОК, МК-4 - ВАША.

  ВПРОЧЕМ , ВЫ МОЖЕТЕ ОСТАВАТЬСЯ
КОНСЕРВАТОРОМ И ЛЕТАТЬ ДАЛЬШЕ НА
СЛЕГКА МОДЕРНИЗИРОВАННОЙ КОСЕРВ-
НОЙ БАНКЕ ТИПА МК-3, НО УЧТИТЕ,
ЧТО В ЭТОМ СЛУЧАЕ ЗВАНИЯ ПОЛКОВ-
НИК  ВАМ  НЕ  ВИДАТЬ  КАК  СВОИХ
УШЕЙ : БЕЗ КОБРЫ МК-4 ВЫСАДИТЬ
ДЕСАНТ НА ОККУПИРОВАННОЙ ПЛАНЕТЕ
ПРАКТИЧЕСКИ НЕВОЗМОЖНО.






```

<a id="manual-mission-7"></a>
### 5. Ответы, миссия 7 INVASION

```text
  МИССИЯ 7. INVASION
  =>=>=>=>


  НА НЕКОТОРОМ ЭТАПЕ ИГРЫ, КОГДА
ВЫ УЖЕ ДОСТИГНЕТЕ КЛАССА ELITE И
НАЧНЕТЕ НЕМНОГО СКУЧАТЬ, НАЧИНА-
ЕТСЯ КРУПНОМАСШТАБНОЕ  ВТОРЖЕНИЕ
АРМАДЫ ТАРГОНОВ В ГАЛАКТИКУ-1.

  ВЫ ПОЛУЧИТЕ ОБ ЭТОМ СООБЩЕНИЕ
В БОЕБОМ ЭКРАНЕ:
  MAYDAY! GALACTIC 1 INVADED!

  МОЖЕТЕ НЕ СПЕШИТЬ -  ВРЕМЕНИ У
ВАС БУДЕТ ДОСТАТОЧНО.  ПО ПРИБЫ-
ТИИ В ГАЛАКТИКУ-1 ВЫ ОБНАРУЖИТЕ,
ЧТО НЕКОТОРЫЕ ПЛАНЕТНЫЕ СИСТЕМЫ
НАХОДЯТСЯ В СОСТОЯНИИ АКТИВНЫХ
БОЕВЫХ ДЕЙСТВИЙ (RESISTING), А
НЕКОТОРЫЕ, ВОЗМОЖНО, УЖЕ ЗАХВА-
ЧЕНЫ (OCCUPIED) ПРОКЛЯТЫМИ НАСЕ-
КОМЫМИ. (СМОТРИТЕ ИНФОРМАЦИЮ ПО
ПЛАНЕТАМ, ЦЕНТР ВТОРЖЕНИЕ НАХО-
ДИТСЯ В ЗАПАДНОЙ ЧАСТИ ГАЛАКТИ-
КИ, ВБЛИЗИ ПЛАНЕТЫ TIBEDIED).

  СОВЕРШАТЬ РЕЙСЫ ВБЛИЗИ ФРОНТО-
ВОЙ ЗОНЫ СТАНОВИТСЯ ОПАСНЫМ ДЕ-
ЛОМ: ТО И ДЕЛО ВАС ПЕРЕХВАТЫВАЮТ
В МЕЖЗВЕЗДНОМ ПРОСТРАНСТВЕ ГРУП-
ПЫ ТАРГОНОВ ( ИНОГДА ВШЕСТЕРОМ,
ЧАСТО МНОГИЕ ИЗ НИХ - НЕВИДИМКИ)
ПОСЕЩЕНИЕ ОККУПИРОВАННЫХ ПЛАНЕТ
ПРАКТИЧЕСКИ САМОУБИЙСТВЕННО. ПО-
ПРОБУЙТЕ, И УБЕДИТЕСЬ.

  ОБЩИЙ СЦЕНАРИЙ ВОЙНЫ ВЫГЛЯДИТ
СЛЕДУЮЩИМ ОБРАЗОМ. СНАЧАЛА ТАР-
ГОНЫ СТРЕМИТЕЛЬНО НАСТУПАЮТ,ПРИ
ЭТОМ С КАЖДЫМ ПРОДВИЖЕНИЕМ ИХ
АРМАДЫ ВПЕРЕД ВЫ ПОЛУЧАЕТЕ СО-
ОБЩЕНИЕ "MAYDAY...". ПОСТЕПЕННО
ГАЛАКТИКА ПОЛУЧАЕТ ВСЕ БОЛЬШЕ
ПОДКРЕПЛЕНИЙ, ПРОСТЫЕ ТОРГОВЦЫ
ВРОДЕ ВАС ВСТУПАЮТ В РЯДЫ ЕЕ ДО-
БРОВОЛЬНЫХ ЗАЩИТНИКОВ (ХОТЯ НА-
ХОДИТСЯ И ДОСТАТОЧНОЕ ЧИСЛО МА-
РОДЕРОВ И ПРЕДАТЕЛЕЙ), И СТОЛЕ-
ТИЯМИ ПЛАНИРОВАВШИЙСЯ БЛИЦКРИГ
ТЕРПИТ ФИАСКО. ПРАВДА, ДО НАС-
ТУПЛЕНИЯ ПЕРЕЛОМА В ХОДЕ ВОЙНЫ
ТАРГОНЫ МОГУТ УСПЕТЬ ОККУПИРО-
ВАТЬ БОЛЬШУЮ ЧАСТЬ ПЕРВОЙ ГАЛАК-
ТИКИ, НО ИХ ПЛАНЫ ВСЕ РАВНО ОБ-
РЕЧЕНЫ. ПОСЛЕ ТОГО, КАК ФЕДЕРА-
ЦИЯ НАЧИНАЕТ ПОБЕЖДАТЬ, СООБЩЕ-
НИЯ С.О.С. ПЕРЕСТАЮТ ПОСТУПАТЬ,
И НАЧИНАЕТСЯ ВСЕ БОЛЕЕ БЫСТРОЕ
ОСВОБОЖДЕНИЕ.

  ВЫ МОЖЕТЕ И НЕ ПРИНИМАТЬ УЧАС-
ТИЯ ,  И  ПРОДОЛЖАТЬ  ЗАНИМАТЬСЯ
СВОИМ БИЗНЕСОМ. ВОЙНА НАЧНЕТСЯ И
ЗАКОНЧИТСЯ  БЛАГОПОЛУЧНО  И  БЕЗ
ВАШЕЙ  ПОМОЩИ.  НО  ВОЗМОЖНО   И
ВСТУПИТЬ  В  СИЛЫ  ФЕДЕРАЦИИ , И
ПОПЫТАТЬСЯ СДЕЛАТЬ ВОЕННУЮ КАРЬ-
ЕРУ, А В СЛУЧАЕ  ОЧЕНЬ УСПЕШНОГО
ВЫПОЛНЕНИЯ МИССИЙ ДАЖЕ  УСКОРИТЬ
ПОБЕДУ "НАШИХ".

  ВСТУПИТЬ В ГАЛАКТИЧЕСКИЕ  ДОБ-
РОВОЛЬЧЕСКИЕ СИЛЫ МОЖНО НА ЛЮБОЙ
ВОЮЮЩЕЙ ПЛАНЕТЕ (RESISTING).
ДОСТАТОЧНО ОТВЕТИТЬ YES НА  ВОП-
РОС, КОТОРЫЙ ВАМ ТАМ ЗАДАДУТ.

```

<a id="manual-mission-7-1"></a>
### 5. Ответы, 7+1 эвакуация

```text
  ВАМ СРАЗУ ПРИСВАИВАЮТ ЗВАНИЕ
ЛЕЙТЕНАНТ, И ДАЮТ ЗАДАНИЕ
1. ЭВАКУАЦИЯ БЕЖЕНЦЕВ С ВОЮЮЩИХ
   (RESISTING) ПЛАНЕТ.
   ВСЕ ПОЧТИ ТО ЖЕ САМОЕ, ЧТО И
   В СТАНДАРТНОЙ МИССИИ 1, НО
   ЭТО ЗАДАНИЕ - НЕ НА ОДИН РАЗ.
   ВЫ ДОЛЖНЫ СОВЕРШАТЬ ЧЕЛНОЧНЫЕ
   РЕЙСЫ С ВОЮЮЩИХ ПЛАНЕТ НА ТЕ,
   КОТОРЫХ ВОЙНА ЕЩЕ НЕ КОСНУ-
   ЛАСЬ, И ВЫВОЗИТЬ БЕЖЕНЦЕВ ДО
   ТЕХ ПОР, ПОКА КОМАНДОВАНИЕ НЕ
   РЕШИТ, ЧТО ВАС ПОРА ПОВЫСИТЬ
   В ЗВАНИИ. ПОСЛЕ ОЧЕРЕДНОГО
   УСПЕШНОГО РЕЙСА, КОГДА ВЫ
   ПРИБУДЕТЕ ЗА ОЧЕРЕДНОЙ ПОР-
   ЦИЕЙ ЖИВОГО ГРУЗА,ВАМ ОБ'ЯВЯТ
   О ПРИСВОЕНИИ ЗВАНИЯ
КАПИТАН, И ВАШЕ НОВОЕ ЗАДАНИЕ
```

<a id="manual-mission-7-2"></a>
### 5. Ответы, 7+2 поставки

```text
2. ДОСТАВКА ОРУЖИЯ (FIREARMS), И
   ПРОДОВОЛЬСТВИЯ (FOOD) НА ВОЮ-
   ЮЩИЕ ПЛАНЕТЫ. КАК И ВСЕ ДОБ-
   РОВОЛЬЦЫ, ВЫ ПО-ПРЕЖНЕМУ ВОЮ-
   ЕТЕ ЗА СВОЙ СЧЕТ: ВАМ НУЖНО
   БУДЕТ ПОКУПАТЬ УКАЗАННЫЕ ТО-
   ВАРЫ НА НЕВОЮЮЩИХ ПЛАНЕТАХ И
   ПЕРЕВОЗИТЬ И ПРОДАВАТЬ ИХ НА
   СТАНЦИИ, НАХОДЯЩИЕСЯ В ЗОНЕ
   АКТИВНЫХ БОЕВЫХ ДЕЙСТВИЙ.
   ВПРОЧЕМ, ЕСЛИ ДЕЙСТВОВАТЬ С
   ГОЛОВОЙ, ИЗ ЭТИХ ОЕРАЦИЙ ТОЖЕ
   МОЖНО ИЗВЛЕЧЬ НЕКОТОРУЮ ПРИ-
   БЫЛЬ.

```

<a id="manual-mission-7-3"></a>
### 5. Ответы, 7+3 десант

```text
   СЛЕДУЮЩЕЕ ЗВАНИЕ -
МАЙОР, И НОВОЕ ЗАДАНИЕ - НАМНОГО
СЛОЖНЕЕ (И ИНТЕРЕСНЕЕ) ПРЕДЫДУ-
ЩИХ ДВУХ.
3. ВЫСАДКА ДЕСАНТА НА ОККУПИРО-
   ВАННУЮ ТАРГОНАМИ СТАНЦИЮ.
   ДЕСАНТ НЕОБХОДИМО БРАТЬ НА
   СРАЖАЮЩЕЙСЯ СТАНЦИИ (КЛАВИ-
   ШЕЙ 2 - ПОКУПКА, КАК И ДЛЯ
   ПРИЕМА НА БОРТ REFUGEES В
   МИССИЯХ 1 И 7+1). С ЭТОГО
   МОМЕНТА У ВАС НА БОРТУ НА-
   ХОДИТСЯ МАЛОГАБАРИТНЫЙ КО-
   РАБЛЬ ТИПА SIDEWINDER, ПЕРЕ-
   ОБОРУДОВАННЫЙ СПЕЦИАЛЬНО ДЛЯ
   ДОСТАВКИ ДЕСАНТА. С НЕГО СНЯ-
   ТО ВСЕ ВООРУЖЕНИЕ, И БОЛЬШАЯ
   ЧАСТЬ ОБОРУДОВАНИЯ, КРОМЕ
   СИСТЕМЫ САМОНАВЕДЕНИЯ, ТАКОЙ
   ЖЕ, КАК У РАКЕТ. ВМЕСТО ЗА-
   ПУСКА ПЕРВОЙ ЖЕ РАКЕТЫ ПРО-
   ИЗОЙДЕТ РАССТЫКОВКА, И ДЕСАН-
   ТНЫЙ КОРАБЛЬ НАПРАВИТСЯ К
   УКАЗАННОЙ ВАМИ ЦЕЛИ. ТАКОЙ
   ЦЕЛЬЮ ДОЛЖНА БЫТЬ СТАНЦИЯ
   НА ЛЮБОЙ ОККУПИРОВАННОЙ ПЛА-
   НЕТЕ. ПРОБЛЕМА - В ДОСТИЖЕ-
   НИИ ЭТОЙ СТАНЦИИ: В ОККУПИ-
   РОВАННОЙ ТАРГОНАМИ ПЛАНЕТНОЙ
   СИСТЕМЕ ПРИ ПОДЛЕТЕ К ПЛАНЕТЕ
   НЕПРОШЕННЫХ ГОСТЕЙ ВСТРЕЧАЕТ
   АРМАДА ТАРГОНОВ-ПЕРЕХВАТЧИКОВ
   НАПОДОБИЕ АРМАДЫ ПОЛИЦЕЙСКИХ
   В ГАЛАКТИКАХ 2-8, АНАЛОГИЧ-
   НЫМ ОБРАЗОМ ПРИВЕТСТВУЮЩИХ
   SUPER-FUGITIVНЫХ ПИЛОТОВ.
   И ЕЩЕ: ЧТОБЫ ВАШ ДЕСАНТ НЕ
   БЫЛ УНИЧТОЖЕН КАКИМ-ЛИБО ТАР-
   ГОНОМ, ВЫПУСКАЙТЕ ДЕСАНТ КАК
   МОЖНО БЛИЖЕ К СТАНЦИИ. ОСОБО
   СТОЛКНОВЕНИЯ ОПАСАТЬСЯ НЕ
   СТОИТ: СРАЗУ ПОСЛЕ ПРОНИКНО-
   ВЕНИЯ ДЕСАНТНОГО КОРАБЛЯ В
   СТАНЦИЮ И ПОЛУЧЕНИЯ СООБЩЕНИЯ
   RIGHT ON COMMANDER МОЖНО
   ВКЛЮЧАТЬ DOCKING COMPUTER.

```

<a id="manual-mission-7-4"></a>
### 5. Ответы, 7+4 командная база

```text
СЛЕДУЮЩЕЕ ЗВАНИЕ - ПОДПОЛКОВНИК
(LIEUTENANT-COLONEL), И СЛЕДУЮ-
ЩЕЕ (И ПОСЛЕДНЕЕ) ЗАДАНИЕ:
4. НАЙТИ И УНИЧТОЖИТЬ КОМАНДНУЮ
   БАЗУ ТАРГОНОВ, В КАЧЕСТВЕ
   КОТОРОЙ ОНИ ИСПОЛЬЗУЮТ ВОРО-
   ВАННУЮ СТАНЦИЮ ТИПА КОРИОЛИС.
   ОНИ ОТБУКСИРОВАЛИ ЕЕ В НЕИЗ-
   ВЕСТНЫЙ СЕКТОР ГАЛАКТИКИ(КО-
   МАНДОВАНИЮ ИЗВЕСТНО ТОЛЬКО,
   ЧТО ЭТО ГДЕ-ТО ПОБЛИЗОСТИ ОТ
   TIBEDIED'А), И ДЛЯ ЕЕ ПОИСКА
   НЕОБХОДИМО ИСПОЛЬЗОВАТЬ ВСЕ
   ИМЕЮЩИЕСЯ В ВАШЕМ РАСПОРЯЖЕ-
   НИИ СРЕДСТВА ПЕРЕДВИЖЕНИЯ В
   МЕЖЗВЕЗДНОМ ПРОСТРАНСТВЕ.
   ( УТОЧНЕНИЕ ДЛЯ НЕПОНЯТЛИВЫХ:
    ЭТО ТАМ, ГДЕ НЕТ НИ ЗВЕЗД,
    НИ ПЛАНЕТ ).
   ВПРОЧЕМ, ДАЖЕ ЕСЛИ ВЫ НЕ СМО-
   ЖЕТЕ ВЫПОЛНИТЬ ЭТУ МИССИЮ, ПО
   ОКОНЧАНИИ ВОЙНЫ ВЫ ВСЕ РАВНО
   ПОЛУЧИТЕ ЗВАНИЕ ПОЛКОВНИК
   (ТАК КАК ЗВАНИЕ ПОДПОЛКОВНИК
   В ОТСТАВКЕ НЕ ВЛЕЗАЕТ ВО
   ВСЮ ШИРИНУ ЭКРАНА).



              * * *








```

<a id="manual-chapter-6"></a>
### 6. Объявления

```text
#6





         ВНИМАНИЕ !

   В 1994 ГОДУ ОЖИДАЕТСЯ
   ПОЯВЛЕНИЕ ELITE4 -  С
   НОВЫМИ УРОВНЯМИ, ПОД-
   ГРУЖАЕМЫМИ С ДИСКА, С
   УЛУЧШЕННОЙ  ГРАФИКОЙ,
   ИСПОЛЬЗОВАНИЕМ  МУЗЫ-
   КАЛЬНОГО СОПРОЦЕССОРА
   И ПРОЧИМИ ПРЕЛЕСТЯМИ.
   РАЗУМЕЕТСЯ, БУДУТ НО-
   ВЫЕ  МИССИИ  И  НОВЫЕ
   ПРИКЛЮЧЕНИЯ И ГОЛОВО-
   ЛОМКИ. ТЕ, КТО СМОГУТ
   ПРЕДСТАВИТЬ ЭКЗЕМПЛЯР
   ELITE3 ПЕРВОГО  ПОКО-
   ЛЕНИЯ ,  ПРИ  ПОКУПКЕ
   ELITE4 ПОЛУЧАТ ЗНАЧИ-
   ТЕЛЬНУЮ СКИДКУ.

         КЛАДОВ ВЛАДИМИР


         БИЗНЕСМЕНЫ !

         ЗА ПОЛ-ЦЕНЫ
  ПРЕДЛАГАЮТСЯ ДИСКЕТЫ С ELITE*3
  НУЛЕВОГО ПОКОЛЕНИЯ С ПРАВОМ НА
  255 (МОЖНО МЕНЬШЕ) КОПИЙ  ПЕР-
  ВОГО ПОКОЛЕНИЯ (ПОЛУЧАЮТСЯ ЭК-
  ЗЕМПЛЯРЫ С ПРАВОМ ОДНОЙ КОПИИ)

  ОБРАЩАТЬСЯ К KЛАДОВУ BЛАДИМИРУ
  (УЛ.ШАМШУРИНА 20,КВ.48,ВТОРНИК
  ИЛИ ВОСКРЕСЕНЬЕ,  ДО 14:00 ИЛИ
  ПОСЛЕ 18:00).


#7

```
