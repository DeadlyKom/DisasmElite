                module Missions
                module SpecialMessageAndScoopReward
; -----------------------------------------
; оформление окна специального сообщения, Game.Missions.SpecialMessageAndScoopReward.Entry
; исходный диапазон #D162..#D1C6
; In:
;   HL, H содержит строку, L содержит столбец печати
;   DE, D содержит токен второй таблицы, E содержит атрибут окна
; Out:
;   окно очищено, токен #5C оформляет сообщение, затем печатается входной токен D
;   480 байтов от Memory.Attributes + #0020 заполнены атрибутом E, текстовый курсор обновлён
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   входные HL и DE сохраняются только на время очистки и печати #5C
;   счётчики C=#E0 и B=2 дают 224+256=480 записей, а не 736
;   входы подбора и правового статуса ниже имеют собственные контракты
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D162
                ; сохранение координат и цвета вокруг очистки окна сообщения
Entry:          PUSH HL
                PUSH DE
                CALL Game.Text.ClearViewAndFrame.Entry
                LD A, #5C
                CALL Game.Text.PrintDescriptionToken.Entry
                POP DE
                POP HL
                LD (TextColumn), HL
                LD HL, Memory.Attributes + #0020                                ; атрибуты со второй символьной строки
                ; заполнение 480 атрибутов, первый проход содержит 224 байта, второй 256
                LD BC, #02E0
FillAttrs:      LD (HL), E
                INC HL
                DEC C
                JR NZ, FillAttrs                                                ; переход, если ещё не заполнены все атрибуты текущей группы

                DEC B
                JR NZ, FillAttrs                                                ; переход, если осталась следующая группа атрибутов сообщения

                LD A, D
                JP Game.Text.PrintDescriptionToken.Entry

                ; миссия 5 ALIEN COMPUTER, проверка признака специального контейнера
                ; описание в Docs/Manual.md, раздел mission-5
                ; разделение специального контейнера ALIEN COMPUTER и обычного груза
; -----------------------------------------
; разделение контейнера ALIEN COMPUTER и обычного товара, Game.Missions.SpecialMessageAndScoopReward.ClassifyScoop
; In:
;   HL, State.FreeCargo
;   AF, A содержит обычный индекс товара 0..16
;   IX, подобранный объект
; Out:
;   при Flags2.7 увеличен State.AlienComputer и поставлено уведомление #F3
;   иначе выполнен AddCargo, DE, BC, IX, IY сохранены
; Corrupt:
;   HL, AF
; Note:
;   для специального контейнера FreeCargo не уменьшается, проверка этого места сделана ранее
;   штатный вход расположен по ScoopItem, прямой вход требует H=#D0
; -----------------------------------------
                ; миссия 5 ALIEN COMPUTER, специальный контейнер увеличивает код компьютера и выводит его название
                ; описание в Docs/Manual.md, раздел mission-5
ClassifyScoop:  BIT OBJ_ALIEN_BIT, (IX+FSpaceObject.Flags2)
                JR Z, AddCargo                                                  ; переход, если бит 7 типа подобранного объекта сброшен, обработать обычный груз

                LD L, #86
                INC (HL)
                LD A, #F3
                JR QueuePickup

                ; миссия 2 CLOAKING DEVICE, получение устройства при подборе предмета FF
                ; описание в Docs/Manual.md, раздел mission-2
                ; дополнительный вход подбора, код FF означает специальный миссионный предмет
; -----------------------------------------
; учёт подобранного предмета после проверки столкновения, Game.Missions.SpecialMessageAndScoopReward.ScoopItem
; In:
;   AF, A содержит товар 0..16 либо #FF
;   IX, подобранный объект, Flags2.7 отличает контейнер ALIEN COMPUTER
;   для обычного товара State.FreeCargo > 0
; Out:
;   при A=#FF установлен MissionFlags.6 и поставлено уведомление #7D
;   иначе выполнен ClassifyScoop, DE, BC, IX, IY сохранены
; Corrupt:
;   HL, AF
; Note:
;   сам вход не проверяет свободный тоннаж, тип ковша и геометрию захвата
;   специальный предмет #FF не меняет обычные слоты груза и FreeCargo
; -----------------------------------------
                ; миссия 2 CLOAKING DEVICE, код предмета FF выдаёт CLOAKING DEVICE
                ; описание в Docs/Manual.md, раздел mission-2
ScoopItem:      LD HL, State.FreeCargo
                CP #FF
                JR NZ, ClassifyScoop                                            ; переход, если код предмета не равен FF, проверить контейнер и обычный груз

                LD L, #B0
                SET MS_CLOAK_BIT, (HL)
                LD A, #7D
                JR QueuePickup

                ; для минералов проверяется возможность колонизации до увеличения их количества
; -----------------------------------------
; добавление одной единицы обычного груза, Game.Missions.SpecialMessageAndScoopReward.AddCargo
; In:
;   HL, State.FreeCargo, положительное значение
;   AF, A содержит индекс товара 0..16
; Out:
;   выбранный Cargo[A] увеличен на 1 по модулю 256, FreeCargo уменьшен на 1
;   уведомление содержит токен #D0+A, для товаров 3 и 6 повышен legal status
;   DE, BC, IX, IY сохранены
; Corrupt:
;   HL, AF
; Note:
;   для минералов сначала вызывается TryColonizeMinerals с прежним количеством
;   проверки переполнения отдельного слота нет
; -----------------------------------------
                ; миссия 4 MINERAL LIFE, колонизация проверяется до увеличения количества подобранных минералов
                ; описание в Docs/Manual.md, раздел mission-4
AddCargo:       CP #0C
                PUSH AF
                CALL Z, Game.Flight.TryColonizeMinerals.Entry                   ; вызов, если подобраны минералы, проверить возможность появления MINERAL LIFE
                POP AF
                DEC (HL)
                ADD A, #6B
                LD L, A
                INC (HL)
                ADD A, #65
                ; формирование события подбора с текстовым кодом в очереди CargoEvent/CargoEvent + FFlightEvent.Token
; -----------------------------------------
; уведомление о подборе и проверка запрещённого товара, Game.Missions.SpecialMessageAndScoopReward.QueuePickup
; In:
;   HL, H=#D0, младшая половина не используется
;   AF, A содержит готовый токен уведомления
; Out:
;   CargoEvent=#8B, CargoEvent + FFlightEvent.Token=входное A
;   после вычитания #D0 выполняется CheckIllegal, DE, BC, IX, IY сохранены
; Corrupt:
;   HL, AF
; Note:
;   этот вход не увеличивает груз, изменение обычного слота выполнено в AddCargo
; -----------------------------------------
QueuePickup:    LD L, #C7
                LD (HL), #8B
                INC HL
                LD (HL), A
                SUB #D0
                ; проверка запрещённых товаров 3 и 6 с насыщением правового статуса до 255
; -----------------------------------------
; повышение правового статуса за запрещённый товар, Game.Missions.SpecialMessageAndScoopReward.CheckIllegal
; In:
;   AF, A содержит индекс товара
; Out:
;   только для товаров 3 и 6 LegalStatus увеличен на 2 с насыщением 255
;   DE, BC, IX, IY сохранены
; Corrupt:
;   HL, AF
; Note:
;   общий вход для покупки и подбора, количество единиц товара на размер штрафа не влияет
; -----------------------------------------
CheckIllegal:   CP #03
                JR Z, RaiseLegal                                                ; переход, если товар имеет индекс 3, увеличить правовой риск

                CP #06
                RET NZ                                                          ; выход, если товар не имеет индекса 6 и ранее не был индексом 3, риск не изменяется

RaiseLegal:     LD HL, State.LegalStatus
                LD A, (HL)
                ADD A, #02
                JR NC, StoreLegal                                               ; переход, если прибавление 2 к правовому статусу не переполнило байт

                SBC A, A
StoreLegal:     LD (HL), A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #D1C7
                endmodule
                endmodule
