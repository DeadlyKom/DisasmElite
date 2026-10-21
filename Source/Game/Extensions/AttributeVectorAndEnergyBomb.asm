                module Extensions
                module AttributeVectorAndEnergyBomb
; -----------------------------------------
; вектор атрибутов, подтверждение меню и энергетическая бомба
; исходный диапазон #6FF8..#70A8
; смысловое имя AttributeVectorAndEnergyBomb
; In: для Game.Extensions.AttributeVectorAndEnergyBomb.ConfirmUpgrade A — ответ, HL — изменяемое поле пилота, для Game.Extensions.AttributeVectorAndEnergyBomb.UseEnergyBomb — состояние клавиш
; Out: Game.Extensions.AttributeVectorAndEnergyBomb.UseEnergyBomb увеличивает EnergyBomb=State.EnergyBomb, ставит CombatState.DestroyAll=1 и бит 0 FlightState.SoundRequests, выполняет 24 вспышки
; Corrupt: HL, DE, BC, AF по контракту атрибутных процедур
; Game.Extensions.AttributeVectorAndEnergyBomb.ConfirmUpgrade при Y обнуляет MineralLife=State.MineralLife и записывает #FF в (HL), затем выбирает продолжение меню
; Game.Extensions.AttributeVectorAndEnergyBomb.ReadCargoByte — помощник чтения строки товара, его байт Game.Extensions.AttributeVectorAndEnergyBomb.ColonyGate заменяется NOP/RET в Game.Extensions.HandleSpecialMessageToken.Entry
; MarketTable.Base содержит 17 записей рынка по четыре байта, EquipmentTable.Base содержит 14 цен по три байта
; Game.Extensions.AttributeVectorAndEnergyBomb.UseEnergyBomb проверяет команду InputState.DeviceKeys.5 и наличие энергетической бомбы, #FF увеличивается в 0 и расходует её
; Боевой цикл Game.Combat.UpdateAllSpaceObjects.CheckMassKill проверяет CombatState.DestroyAll, у допустимых объектов устанавливается OBJ_DESTROY_BIT в FSpaceObject.Flags
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #6FF8
Entry:          JP Game.Flight.SetViewAttributesWithCloaking.Entry

                ; проверка подтверждения Y перед изменением состояния пилота
                ; миссия 4 MINERAL LIFE, путь установки трюма сбрасывает колонию только при входном A = #59
                ; описание в Docs/Manual.md, раздел mission-4
ConfirmUpgrade: CP #59
                JR NZ, SelectMenu                                               ; переход, если ответ отличается от Y, пропустить изменения состояния

                XOR A
                LD (State.MineralLife), A
                DEC A
                LD (HL), A
                ; проверка наличия улучшения перед выбором ветви меню
SelectMenu:     LD L, #8E
                INC A
                CP (HL)
                JP Z, Game.Trade.EquipmentAlreadyOwned.PrintItemError           ; переход, если поле State.ShipUpgrade равно нулю, перейти к Game.Trade.EquipmentAlreadyOwned.PrintItemError

                JP Game.Trade.InstallPurchasedEquipment.AddCargoSpace

                ; чтение текущего байта строки товара через сохранённый указатель
                ; миссия 4 MINERAL LIFE, изменяемый ColonyGate задаёт ограничение продажи живых минералов
                ; описание в Docs/Manual.md, раздел mission-4
ReadCargoByte:  LD HL, (MarketWork.CargoCursor)
                LD A, (HL)
                ; изменяемая точка допуска, Game.Extensions.HandleSpecialMessageToken.Entry записывает сюда NOP либо RET
ColonyGate:     NOP
                ; проверка минимального количества продажи B перед чтением запаса
                LD A, B
                CP #03
                DEC A
                RET C                                                           ; выход, если количество продажи B меньше 3, вернуть B-1 для отказа последующего SUB B

                LD A, (HL)
                RET

                ; товар 0, продовольствие, цена / коэффициент и знак экономики / запас / случайная маска
MarketParams    FMarketEntry {                                                  ; запись 0, FMarketEntry
                    #13,                                                        ; FMarketEntry.Price, базовая цена, GenerateMarket масштабирует результат в четыре раза
                    #82,                                                        ; FMarketEntry.Economy, знак и модуль коэффициента экономики
                    #06,                                                        ; FMarketEntry.Stock, базовый запас до случайной и экономической поправок
                    #01                                                         ; FMarketEntry.RandomMask, маска случайного параметра системы
                }

                FMarketEntry {                                                  ; запись 1, FMarketEntry
                    #14,                                                        ; FMarketEntry.Price, базовая цена, GenerateMarket масштабирует результат в четыре раза
                    #81,                                                        ; FMarketEntry.Economy, знак и модуль коэффициента экономики
                    #0A,                                                        ; FMarketEntry.Stock, базовый запас до случайной и экономической поправок
                    #03                                                         ; FMarketEntry.RandomMask, маска случайного параметра системы
                }

                FMarketEntry {                                                  ; запись 2, FMarketEntry
                    #41,                                                        ; FMarketEntry.Price, базовая цена, GenerateMarket масштабирует результат в четыре раза
                    #83,                                                        ; FMarketEntry.Economy, знак и модуль коэффициента экономики
                    #02,                                                        ; FMarketEntry.Stock, базовый запас до случайной и экономической поправок
                    #07                                                         ; FMarketEntry.RandomMask, маска случайного параметра системы
                }

                FMarketEntry {                                                  ; запись 3, FMarketEntry
                    #28,                                                        ; FMarketEntry.Price, базовая цена, GenerateMarket масштабирует результат в четыре раза
                    #85,                                                        ; FMarketEntry.Economy, знак и модуль коэффициента экономики
                    #E2,                                                        ; FMarketEntry.Stock, базовый запас до случайной и экономической поправок
                    #1F                                                         ; FMarketEntry.RandomMask, маска случайного параметра системы
                }

                FMarketEntry {                                                  ; запись 4, FMarketEntry
                    #53,                                                        ; FMarketEntry.Price, базовая цена, GenerateMarket масштабирует результат в четыре раза
                    #85,                                                        ; FMarketEntry.Economy, знак и модуль коэффициента экономики
                    #FB,                                                        ; FMarketEntry.Stock, базовый запас до случайной и экономической поправок
                    #0F                                                         ; FMarketEntry.RandomMask, маска случайного параметра системы
                }

                FMarketEntry {                                                  ; запись 5, FMarketEntry
                    #C4,                                                        ; FMarketEntry.Price, базовая цена, GenerateMarket масштабирует результат в четыре раза
                    #08,                                                        ; FMarketEntry.Economy, знак и модуль коэффициента экономики
                    #36,                                                        ; FMarketEntry.Stock, базовый запас до случайной и экономической поправок
                    #03                                                         ; FMarketEntry.RandomMask, маска случайного параметра системы
                }

                FMarketEntry {                                                  ; запись 6, FMarketEntry
                    #EB,                                                        ; FMarketEntry.Price, базовая цена, GenerateMarket масштабирует результат в четыре раза
                    #1D,                                                        ; FMarketEntry.Economy, знак и модуль коэффициента экономики
                    #08,                                                        ; FMarketEntry.Stock, базовый запас до случайной и экономической поправок
                    #78                                                         ; FMarketEntry.RandomMask, маска случайного параметра системы
                }

                FMarketEntry {                                                  ; запись 7, FMarketEntry
                    #9A,                                                        ; FMarketEntry.Price, базовая цена, GenerateMarket масштабирует результат в четыре раза
                    #0E,                                                        ; FMarketEntry.Economy, знак и модуль коэффициента экономики
                    #38,                                                        ; FMarketEntry.Stock, базовый запас до случайной и экономической поправок
                    #03                                                         ; FMarketEntry.RandomMask, маска случайного параметра системы
                }

                FMarketEntry {                                                  ; запись 8, FMarketEntry
                    #75,                                                        ; FMarketEntry.Price, базовая цена, GenerateMarket масштабирует результат в четыре раза
                    #06,                                                        ; FMarketEntry.Economy, знак и модуль коэффициента экономики
                    #28,                                                        ; FMarketEntry.Stock, базовый запас до случайной и экономической поправок
                    #07                                                         ; FMarketEntry.RandomMask, маска случайного параметра системы
                }

                FMarketEntry {                                                  ; запись 9, FMarketEntry
                    #4E,                                                        ; FMarketEntry.Price, базовая цена, GenerateMarket масштабирует результат в четыре раза
                    #01,                                                        ; FMarketEntry.Economy, знак и модуль коэффициента экономики
                    #11,                                                        ; FMarketEntry.Stock, базовый запас до случайной и экономической поправок
                    #1F                                                         ; FMarketEntry.RandomMask, маска случайного параметра системы
                }

                FMarketEntry {                                                  ; запись 10, FMarketEntry
                    #7C,                                                        ; FMarketEntry.Price, базовая цена, GenerateMarket масштабирует результат в четыре раза
                    #0D,                                                        ; FMarketEntry.Economy, знак и модуль коэффициента экономики
                    #1D,                                                        ; FMarketEntry.Stock, базовый запас до случайной и экономической поправок
                    #07                                                         ; FMarketEntry.RandomMask, маска случайного параметра системы
                }

                FMarketEntry {                                                  ; запись 11, FMarketEntry
                    #B0,                                                        ; FMarketEntry.Price, базовая цена, GenerateMarket масштабирует результат в четыре раза
                    #89,                                                        ; FMarketEntry.Economy, знак и модуль коэффициента экономики
                    #DC,                                                        ; FMarketEntry.Stock, базовый запас до случайной и экономической поправок
                    #3F                                                         ; FMarketEntry.RandomMask, маска случайного параметра системы
                }

                FMarketEntry {                                                  ; запись 12, FMarketEntry
                    #20,                                                        ; FMarketEntry.Price, базовая цена, GenerateMarket масштабирует результат в четыре раза
                    #81,                                                        ; FMarketEntry.Economy, знак и модуль коэффициента экономики
                    #35,                                                        ; FMarketEntry.Stock, базовый запас до случайной и экономической поправок
                    #03                                                         ; FMarketEntry.RandomMask, маска случайного параметра системы
                }

                FMarketEntry {                                                  ; запись 13, FMarketEntry
                    #61,                                                        ; FMarketEntry.Price, базовая цена, GenerateMarket масштабирует результат в четыре раза
                    #A1,                                                        ; FMarketEntry.Economy, знак и модуль коэффициента экономики
                    #42,                                                        ; FMarketEntry.Stock, базовый запас до случайной и экономической поправок
                    #07                                                         ; FMarketEntry.RandomMask, маска случайного параметра системы
                }

                FMarketEntry {                                                  ; запись 14, FMarketEntry
                    #AB,                                                        ; FMarketEntry.Price, базовая цена, GenerateMarket масштабирует результат в четыре раза
                    #A2,                                                        ; FMarketEntry.Economy, знак и модуль коэффициента экономики
                    #37,                                                        ; FMarketEntry.Stock, базовый запас до случайной и экономической поправок
                    #1F                                                         ; FMarketEntry.RandomMask, маска случайного параметра системы
                }

                FMarketEntry {                                                  ; запись 15, FMarketEntry
                    #2D,                                                        ; FMarketEntry.Price, базовая цена, GenerateMarket масштабирует результат в четыре раза
                    #C1,                                                        ; FMarketEntry.Economy, знак и модуль коэффициента экономики
                    #FA,                                                        ; FMarketEntry.Stock, базовый запас до случайной и экономической поправок
                    #0F                                                         ; FMarketEntry.RandomMask, маска случайного параметра системы
                }

                FMarketEntry {                                                  ; запись 16, FMarketEntry
                    #35,                                                        ; FMarketEntry.Price, базовая цена, GenerateMarket масштабирует результат в четыре раза
                    #0F,                                                        ; FMarketEntry.Economy, знак и модуль коэффициента экономики
                    #C0,                                                        ; FMarketEntry.Stock, базовый запас до случайной и экономической поправок
                    #07                                                         ; FMarketEntry.RandomMask, маска случайного параметра системы
                }
.Firearms       EQU MarketParams + FGoods.Firearms * FMarketEntry               ; исходная запись параметров оружия
                ; цена оборудования 1, старшая денежная группа и младшее слово, потребитель Game.Trade.GetEquipmentPriceAddress.Entry
EquipmentPrices FEquipmentPrice {                                               ; запись 0, FEquipmentPrice
                    #00,                                                        ; FEquipmentPrice.High, целые тысячи кредитов
                    #0000                                                       ; FEquipmentPrice.Low, младшая денежная группа, 0..9999 десятых кредита
                }

                FEquipmentPrice {                                               ; запись 1, FEquipmentPrice
                    #00,                                                        ; FEquipmentPrice.High, целые тысячи кредитов
                    #012C                                                       ; FEquipmentPrice.Low, младшая денежная группа, 0..9999 десятых кредита
                }

                FEquipmentPrice {                                               ; запись 2, FEquipmentPrice
                    #00,                                                        ; FEquipmentPrice.High, целые тысячи кредитов
                    #0FA0                                                       ; FEquipmentPrice.Low, младшая денежная группа, 0..9999 десятых кредита
                }

                FEquipmentPrice {                                               ; запись 3, FEquipmentPrice
                    #00,                                                        ; FEquipmentPrice.High, целые тысячи кредитов
                    #1770                                                       ; FEquipmentPrice.Low, младшая денежная группа, 0..9999 десятых кредита
                }

                FEquipmentPrice {                                               ; запись 4, FEquipmentPrice
                    #00,                                                        ; FEquipmentPrice.High, целые тысячи кредитов
                    #0FA0                                                       ; FEquipmentPrice.Low, младшая денежная группа, 0..9999 десятых кредита
                }

                FEquipmentPrice {                                               ; запись 5, FEquipmentPrice
                    #01,                                                        ; FEquipmentPrice.High, целые тысячи кредитов
                    #0000                                                       ; FEquipmentPrice.Low, младшая денежная группа, 0..9999 десятых кредита
                }

                FEquipmentPrice {                                               ; запись 6, FEquipmentPrice
                    #00,                                                        ; FEquipmentPrice.High, целые тысячи кредитов
                    #1482                                                       ; FEquipmentPrice.Low, младшая денежная группа, 0..9999 десятых кредита
                }

                FEquipmentPrice {                                               ; запись 7, FEquipmentPrice
                    #01,                                                        ; FEquipmentPrice.High, целые тысячи кредитов
                    #0000                                                       ; FEquipmentPrice.Low, младшая денежная группа, 0..9999 десятых кредита
                }

                FEquipmentPrice {                                               ; запись 8, FEquipmentPrice
                    #00,                                                        ; FEquipmentPrice.High, целые тысячи кредитов
                    #2328                                                       ; FEquipmentPrice.Low, младшая денежная группа, 0..9999 десятых кредита
                }

                FEquipmentPrice {                                               ; запись 9, FEquipmentPrice
                    #01,                                                        ; FEquipmentPrice.High, целые тысячи кредитов
                    #1388                                                       ; FEquipmentPrice.Low, младшая денежная группа, 0..9999 десятых кредита
                }

                FEquipmentPrice {                                               ; запись 10, FEquipmentPrice
                    #01,                                                        ; FEquipmentPrice.High, целые тысячи кредитов
                    #1388                                                       ; FEquipmentPrice.Low, младшая денежная группа, 0..9999 десятых кредита
                }

                FEquipmentPrice {                                               ; запись 11, FEquipmentPrice
                    #05,                                                        ; FEquipmentPrice.High, целые тысячи кредитов
                    #0000                                                       ; FEquipmentPrice.Low, младшая денежная группа, 0..9999 десятых кредита
                }

                FEquipmentPrice {                                               ; запись 12, FEquipmentPrice
                    #06,                                                        ; FEquipmentPrice.High, целые тысячи кредитов
                    #0000                                                       ; FEquipmentPrice.Low, младшая денежная группа, 0..9999 десятых кредита
                }

                FEquipmentPrice {                                               ; запись 13, FEquipmentPrice
                    #00,                                                        ; FEquipmentPrice.High, целые тысячи кредитов
                    #1F40                                                       ; FEquipmentPrice.Low, младшая денежная группа, 0..9999 десятых кредита
                }
                ; проверка команды и наличия энергетической бомбы
UseEnergyBomb:  LD A, (InputState.DeviceKeys)
                BIT DEV_BOMB_BIT, A
                RET Z                                                           ; выход, если команда энергетической бомбы в InputState.DeviceKeys.5 не установлена

                LD HL, State.EnergyBomb
                LD A, (HL)
                AND A
                RET Z                                                           ; выход, если энергетическая бомба отсутствует

                ; расход энергетической бомбы и установка признака массового уничтожения
                INC (HL)
                XOR A
                INC A
                LD (CombatState.DestroyAll), A
                LD HL, FlightState.SoundRequests
                SET SND_BOMB_BIT, (HL)
                LD C, #18
                ; создание 24 последовательных вспышек атрибутов
FlashAgain:     CALL Game.Extensions.FlashViewAttributes.Entry
                DEC C
                JR NZ, FlashAgain                                               ; переход, если из 24 вспышек ещё остались невыполненные

                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #70A9
                endmodule
                endmodule
