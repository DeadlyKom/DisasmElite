                module Motion
                module ProcessObjectEnergyAndTactics
; -----------------------------------------
; восстановление энергии и выбор тактического действия объекта
; исходный диапазон #A2C0..#A402
; In:
;   IX, объект
;   IY, описание модели
; Out:
;   IX, исходный объект
;   IY, исходная модель
;   энергия, команды и боевые флаги обновлены
; Corrupt:
;   HL, DE, BC, AF
; Note:
; Энергия восстанавливается на 1, у моделей с максимумом не ниже #F0 на 4, затем ограничивается максимумом.
; Для второй миссии MissionPhase регулирует переходы фаз при энергиях #34/#50 и дополнительный расход энергии.
; ниже половины максимальной энергии возможен запуск при ненулевом остатке FSpaceObject.Flags по OBJ_LAUNCH_MASK, ниже восьмой части выбирается спасение
; успех создания потомка проверяется по Z, выпуск капсулы сбрасывает OBJ_ESCAPE_BIT и OBJ_ACTIVE_BIT в FSpaceObject.Flags родителя
; ветвь с FModel.Flags=#04 ищет живой ведущий объект с FSpaceObject.Hostility=#0C, отсутствие ведущего переводит текущий объект в подбираемое состояние
; TARGET_ECM_BIT в FSpaceObject.Target разрешает ответный ECM при обнаруженной ракетной угрозе
; обычные корабли продолжают в Game.Motion.CheckObjectBoxAndChooseCourse.ChooseCourse, OBJ_SPECIAL_BIT в FSpaceObject.Flags2 допускает порождение через Game.Motion.CallObjectActionPreservingPointers.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #A2C0
                ; расчёт восстановления энергии с ограничением максимумом модели
Entry:          LD A, (IY + FModel.MaxEnergy)
                LD C, (IX + FSpaceObject.Energy)
                INC C
                CP #F0
                JR C, ClampEnergy                                               ; переход, если максимальная энергия модели меньше #F0 и восстановление остаётся единичным

                INC C
                INC C
                INC C
ClampEnergy:    CP C
                JR C, CheckMission                                              ; переход, если восстановленная энергия превысила максимум модели

                LD A, C
                ; миссия 2 CLOAKING DEVICE, фазы особой встречи переключаются при энергетических порогах
                ; описание в Docs/Manual.md, раздел mission-2
CheckMission:   LD B, A
                ; проверка фазы второй миссии и её энергетических порогов
                LD A, (CloakActive)
                AND A
                NOP
                LD HL, MissionPhase
                LD A, B
                CP #50
                LD A, (HL)
                JR C, CheckPhaseOne                                             ; переход, если энергия ещё ниже порога #50 для смены фазы миссии

                CP #02
                JR NZ, CheckPhaseOne                                            ; переход, если миссия не находится во второй фазе

                DEC (HL)
CheckPhaseOne:  CP #01
                JR NZ, StoreEnergy                                              ; переход, если миссия не находится в первой фазе

                LD A, B
                CP #34
                JR NC, DrainEnergy                                              ; переход, если энергия не ниже #34 и можно продолжать расход в первой фазе

                LD A, #02
                LD (HL), A
                JR StoreEnergy

DrainEnergy:    SUB #02
                LD B, A
                ; обновление энергии и проверка необходимости аварийной реакции
StoreEnergy:    LD A, B
                LD (IX + FSpaceObject.Energy), A
                LD B, (IY + FModel.MaxEnergy)
                ADD A, A
                JR C, CheckLeader                                               ; переход, если удвоение энергии переполнилось и объект не нуждается в аварийной реакции

                CP B
                JR NC, CheckLeader                                              ; переход, если энергия не ниже половины максимальной

                ADD A, A
                JR C, TryLaunch                                                 ; переход, если четырёхкратная энергия переполнилась и объект ещё не в критическом состоянии

                ADD A, A
                JR C, TryLaunch                                                 ; переход, если восьмикратная энергия переполнилась и объект ещё не в критическом состоянии

                CP B
                JR C, TryEscape                                                 ; переход, если энергия меньше восьмой части максимальной

                ; проверка остатка запускаемых средств и вероятности запуска
TryLaunch:      LD A, (IX + FSpaceObject.Flags)
                AND OBJ_LAUNCH_MASK
                JR Z, CheckLeader                                               ; переход, если у объекта не осталось запускаемых средств

                CALL Game.Combat.NextRandomByte.Entry
                CP #80
                JR NC, CheckLeader                                              ; переход, если случайная проверка не разрешила запуск

                LD A, (CombatState.EcmTimer)
                AND A
                JR NZ, CheckLeader                                              ; переход, если ECM уже активен и запуск откладывается

                ; выбор типа запускаемого средства по описанию модели
                LD A, (IY + FModel.LaunchMask)
                AND MODEL_SHOT_MASK
                JR NZ, SelectPayload                                            ; переход, если модель явно задаёт тип запускаемого средства в старшей тетраде

                OR #06
SelectPayload:  XOR #04
                LD B, A
                PUSH BC
                CALL Game.Motion.CallObjectActionPreservingPointers.Entry
                POP BC
                JR NZ, CheckLeader                                              ; переход, если диспетчер не смог создать запускаемый объект

                DEC (IX + FSpaceObject.Flags)
                LD A, B
                CP #02
                JR NZ, CheckLeader                                              ; переход, если запущенное средство не относится к действию #02

                LD HL, FlightEvents + FFlightEvent                              ; вторая пара очереди, запрос сообщения о выпущенной ракете
                SET EVENT_WAIT_BIT, (HL)
                JR CheckLeader

                ; выбор спасения при критической энергии
TryEscape:      CALL Game.Combat.NextRandomByte.Entry
                CP (IX + FSpaceObject.Target)
                JR C, CheckEcm                                                  ; переход, если случайная проверка оставляет объект в бою

                BIT OBJ_ESCAPE_BIT, (IX + FSpaceObject.Flags)
                JR Z, CheckCargoPod                                             ; переход, если у объекта нет спасательной капсулы

                LD A, #07
                CALL Game.Motion.CallObjectActionPreservingPointers.Entry
                JR NZ, CheckLeader                                              ; переход, если спасательную капсулу создать не удалось

                RES OBJ_ESCAPE_BIT, (IX + FSpaceObject.Flags)
                RES OBJ_ACTIVE_BIT, (IX + FSpaceObject.Flags)
                RET

CheckCargoPod:  LD A, (IY + FModel.Cargo)
                AND A
                JR Z, CheckLeader                                               ; переход, если модель не предусматривает создание спасательного объекта

                LD A, #06
                CALL Game.Motion.CallObjectActionPreservingPointers.Entry
                ; поиск ведущего для специальной группы объектов
CheckLeader:    LD A, (IY + FModel.Flags)
                CP #04
                JR NZ, CheckEcm                                                 ; переход, если FModel.Flags отличается от #04 и поиск ведущего объекта не требуется

                PUSH IX
                LD IX, Memory.Station
                LD DE, #0027
                LD B, #06
FindLeader:     ADD IX, DE
                LD A, (IX + FSpaceObject.Energy)
                AND A
                JR Z, NextLeader                                                ; переход, если проверяемый слот пуст и поиск ведущего продолжается

                LD A, (IX + FSpaceObject.Hostility)
                SUB #0C
                JR Z, LeaderResult                                              ; переход, если найден ведущий объект с флагами #0C

NextLeader:     DJNZ FindLeader

                INC A
                ; Z остаётся от найденного ведущего, либо от INC A при последней разности #FF
LeaderResult:   POP IX
                JP Z, Game.Motion.CheckObjectBoxAndChooseCourse.ChooseCourse    ; переход, если поиск оставил Z, продолжить управляемый полёт

                RES OBJ_ACTIVE_BIT, (IX + FSpaceObject.Flags)
                SET OBJ_SCOOP_BIT, (IX + FSpaceObject.Flags2)
                SRL (IX + FSpaceObject.Speed)
                RET

                ; проверка возможности ответного применения ECM
                ; миссии 3, 7 INVASION, совместная проверка этапа 4 и MS_ACCEPT_BIT запрещает ответный ECM
                ; описание в Docs/Manual.md, раздел mission-3, mission-7-invasion
CheckEcm:       BIT TARGET_ECM_BIT, (IX + FSpaceObject.Target)
                JR Z, ChooseFlight                                              ; переход, если объект не оборудован ECM

                LD A, (State.Mission3)
                CP #04
                JR NZ, CheckEcmTimer                                            ; переход, если режим State.Mission3 отличается от 4 и специальное ограничение не действует

                LD A, (State.MissionFlags)
                BIT MS_ACCEPT_BIT, A
                JR NZ, ChooseFlight                                             ; переход, если в режиме 4 установлен запрет ECM State.MissionFlags.7

CheckEcmTimer:  LD A, (CombatState.EcmTimer)
                AND A
                JR NZ, ChooseFlight                                             ; переход, если ECM уже работает

                PUSH IX
                CALL Game.Extensions.FindLiveTrackedObject.Entry
                LD A, (IX + FSpaceObject.Blueprint)
                POP IX
                JR NC, EcmPadding                                               ; переход, если поиск не обнаружил ракетную угрозу

                CP #E3
                JR NZ, EcmPadding                                               ; переход, если обнаруженная модель не имеет младшего адреса #E3

                LD A, #08
                LD (CombatState.EcmTimer), A
EcmPadding:     NOP
                NOP
                ; выбор обычного полёта либо порождения особым объектом
                ; миссии 3, 7 INVASION, состояние 4 меняет вероятность и код порождения объектов
                ; описание в Docs/Manual.md, раздел mission-3, mission-7-invasion
ChooseFlight:   BIT OBJ_SPECIAL_BIT, (IX + FSpaceObject.Flags2)
                JR Z, Game.Motion.CheckObjectBoxAndChooseCourse.ChooseCourse    ; переход, если объект обычный и должен перейти к выбору курса

                LD A, (ActiveShips)
                CP #04
                RET NC                                                          ; выход, если счётчик ActiveShips уже достиг ограничения 4

                CALL Game.Combat.NextRandomByte.Entry
                BIT OBJ_HOSTILE_BIT, (IX + FSpaceObject.Hostility)
                JR Z, PeacefulSpawn                                             ; переход, если объект не враждебен и используется редкая вероятность порождения

                CP #24
                RET NC                                                          ; выход, если случайное число не меньше #24 и враждебное порождение пропускается

                LD A, (State.Mission3)
                CP #04
                LD A, #14
                JR NZ, Game.Motion.CallObjectActionPreservingPointers.Entry     ; переход, если режим отличается от 4 и выполняется действие #14

                CALL Game.Combat.NextRandomByte.Entry
                CP #88
                RET NC                                                          ; выход, если дополнительная случайная проверка не разрешила действие #44

                LD A, #44
                JR Game.Motion.CallObjectActionPreservingPointers.Entry

PeacefulSpawn:  CP #02
                RET NC                                                          ; выход, если случайное число не меньше 2 и мирное порождение пропускается

                LD A, #24                                                       ; далее Game.Motion.CallObjectActionPreservingPointers.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #A403
                endmodule
                endmodule
