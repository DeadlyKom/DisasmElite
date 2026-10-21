                ifndef _VARIABLES_FLIGHT_
                define _VARIABLES_FLIGHT_

CloakDivider    EQU Game.Flight.HandleMapCursorKeys.CloakDivider                ; делитель проверки маскировки, после срабатывания загружается 2
JoystickMode    EQU Game.Flight.ReportBoardingAndReturnToTitle.JoystickMode     ; выбранный режим управления джойстиком
FastTravel      EQU Game.Universe.GetObjectMetadataAddress.FastTravel           ; флаг, выполнен ускоренный перенос звёздного поля
StarView        EQU Game.Universe.UpdateAndDrawStarField.PreviousView           ; предыдущий номер вида в операнде CP, смена вида очищает звёзды
FastSpawnPhase  EQU Game.Universe.HandleFastTravelStep.SpawnPhase               ; чередующаяся маска #55/#AA в операнде LD A
TunnelRings     EQU Game.Flight.DivideByteFractionForTunnel.RingCount           ; число колец туннеля, 8 либо 16
TunnelLeft      EQU Game.Flight.DivideByteFractionForTunnel.RingsLeft           ; число ещё не обработанных колец кадра
TunnelFrames    EQU Game.Flight.DivideByteFractionForTunnel.PhaseFrames         ; число кадров до смены фазы туннеля
HyperDepths     EQU Game.Flight.DivideByteFractionForTunnel.HyperDepths         ; шестнадцать глубин колец гиперперехода
DockDepths      EQU Game.Flight.DivideByteFractionForTunnel.DockDepths          ; восемь глубин колец стыковки и старта
TunnelDepths    EQU Game.Flight.AnimateTransitionTunnel.DepthTable              ; адрес текущей таблицы глубин в операнде LD HL
TunnelPhase     EQU Game.Flight.AnimateTransitionTunnel.PhaseJump               ; смещение JR Z, выбор этапа изменения туннеля
TunnelLimit     EQU Game.Flight.AnimateTransitionTunnel.DepthLimit              ; изменяемая глубина завершения в операнде CP
TunnelFinish    EQU Game.Flight.AnimateTransitionTunnel.FinishJump              ; смещение JR C, выбор завершения старта либо гипертуннеля
JumpCountdown   EQU Game.Travel.ClearFlightEventsAndHandleJump.JumpCountdown    ; остаток отсчёта гиперперехода, ноль означает отсутствие отсчёта
JumpMode        EQU Game.Interface.DispatchFlightMessage.JumpMode               ; режим перехода, 0 нет, 1 обычный, 2 галактический
ViewKeyLock     EQU Game.Interface.DispatchFlightMessage.ViewKeyLock            ; флаг, блокировка повторной обработки клавиши смены вида
CloakActive     EQU Game.Interface.DispatchFlightMessage.CloakActive            ; флаг, включена маскировка корабля
MissionNotice   EQU Game.Interface.DispatchDiskAndCommanderState.MissionNotice  ; флаг, повторное миссионное предупреждение уже подготовлено
FlightEvents    EQU Game.Interface.DispatchDiskAndCommanderState.FlightEvents   ; десять пар очереди, координата с битом ожидания и токен
FlightMessage   EQU Game.Disk.DrawScreenStripsAndPrivateStack.MessageData       ; адрес структуры FFlightMessage
.RepeatTimer    EQU FlightMessage + FFlightMessage.RepeatTimer                  ; таймер повторного предупреждения
.Frames         EQU FlightMessage + FFlightMessage.Frames                       ; оставшееся время показа сообщения
.QueuePhase     EQU FlightMessage + FFlightMessage.QueuePhase                   ; фаза чередования очереди и фоновых сообщений
.Column         EQU FlightMessage + FFlightMessage.Column                       ; столбец текущего сообщения
.Token          EQU FlightMessage + FFlightMessage.Token                        ; токен текущего сообщения
.Reward         EQU FlightMessage + FFlightMessage.Reward                       ; денежная награда для сообщения о премии
.DamagedItem    EQU FlightMessage + FFlightMessage.DamagedItem                  ; код повреждённого оборудования
LaunchPending   EQU Game.Data.LaunchCounter.Pending                             ; флаг, при следующем вылете увеличить счётчик
LaunchCount     EQU Game.Data.LaunchCounter.Count                               ; число вылетов после отмеченного перехода в систему

DemoModel       EQU Game.Flight.Fill240Attributes.DemoModel                     ; номер демонстрационной модели, младшая тетрада с пропуском 12..15
StarPoints      EQU Game.Universe.SelectSpecialCargoText.StarPoints             ; 16 пар знако-модульных координат звёзд

CargoEvent      EQU FlightEvents + 5 * FFlightEvent                             ; шестая пара очереди, признак ожидания, столбец и токен

ArrivalGate     EQU Game.Travel.LaserTypeAndArrivalEvents.ArrivalGate           ; изменяемый JR Z событий прибытия, временный RET подавляет этот хвост
DistantSigns    EQU Game.Flight.TryColonizeMinerals.DistantSigns                ; шесть старших знако-модульных байтов координат двух дальних светил
IncomingEvent   EQU Game.Interface.DispatchDiskAndCommanderState.IncomingEvent  ; вторая пара очереди, сообщение после запуска вражеской ракеты

                endif                                                           ; ~_VARIABLES_FLIGHT_
