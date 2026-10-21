                module Interface
                module DispatchDiskAndCommanderState
; -----------------------------------------
; Вектор дискового меню и область состояния пилота
; исходный диапазон #D04E..#D0D9
; In:
;   Нет параметров для вектора
; Out:
;   Переход в Game.Disk.LoadDiskMenuOverlay.Entry
; Corrupt:
;   По контракту дискового меню
; Note:
;   MapCircleX/MapCircleY координаты курсора, MapRadius радиус топливного круга, State сериализуемый блок
;   102 байта, FlightEvents содержит десять пар сообщений, LetterCase, WordStart, CapitalNext и TextMode задают режимы текста, ShowBoarding
;   отдельный JP Game.Missions.ShowBoardingMessage.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D04E
Entry:          JP Game.Disk.LoadDiskMenuOverlay.Entry

                ; экранный X центра перекрестия
CircleX         DB #61                                                          ; координата X окружности карты
                ; экранный Y центра перекрестия
CircleY         DB #60                                                          ; координата Y окружности карты
                ; радиус отображаемого топливного круга
CircleRadius    DB #46                                                          ; радиус окружности дальности на карте
                ; исходная сериализуемая запись пилота, описание полей и флагов в FCommander
Commander       FCommander {
                    {                                                           ; FCommander.Name, имя командира, поле из 11 байтов
                        #56, #00, #4D, #45, #53, #4F,
                        #4E, #20, #20, #20, #00
                    },
                    #01,                                                        ; FCommander.LegalStatus, степень преследования, 0 законопослушный, от 50 разыскиваемый
                    #7BB8,                                                      ; FCommander.Rating, младшие 16 бит боевого рейтинга
                    #04,                                                        ; FCommander.RankState, старший рейтинг и военное состояние, схема FCommander.RankState
                    #1D,                                                        ; FCommander.JumpCount, младший байт счётчика переходов
                    #00,                                                        ; FCommander.JumpFlags, старшие разряды счётчика и флаг допуска миссий
                    #03,                                                        ; FCommander.Galaxy, номер галактики, 0..7
                    #0147,                                                      ; FCommander.CashHigh, старшая часть денег, тысячи кредитов
                    #268C,                                                      ; FCommander.CashLow, младшая часть денег, десятые доли кредита
                    #E5,                                                        ; FCommander.MarketRandom, случайный параметр воспроизводимого рынка
                    {                                                           ; FCommander.Cargo, количества товаров в трюме, структура FGoods
                        #00,                                                    ; FGoods.Food, продовольствие, т
                        #00,                                                    ; FGoods.Textiles, текстиль, т
                        #00,                                                    ; FGoods.Radioactives, радиоактивные материалы, т
                        #00,                                                    ; FGoods.Slaves, рабы, т
                        #00,                                                    ; FGoods.Liquor, алкоголь, т
                        #00,                                                    ; FGoods.Luxuries, предметы роскоши, т
                        #00,                                                    ; FGoods.Narcotics, наркотики, т
                        #00,                                                    ; FGoods.Computers, компьютеры, т
                        #00,                                                    ; FGoods.Machinery, промышленное оборудование, т
                        #00,                                                    ; FGoods.Alloys, сплавы, т
                        #00,                                                    ; FGoods.Firearms, огнестрельное оружие, т
                        #00,                                                    ; FGoods.Furs, меха, т
                        #03,                                                    ; FGoods.Minerals, минералы, т
                        #00,                                                    ; FGoods.Gold, золото, кг
                        #00,                                                    ; FGoods.Platinum, платина, кг
                        #5C,                                                    ; FGoods.Gemstones, драгоценные камни, г
                        #07                                                     ; FGoods.AlienItems, инопланетные предметы, т
                    },
                    #19,                                                        ; FCommander.FreeCargo, свободное место в трюме, тонны
                    #42,                                                        ; FCommander.FrontLaser, тип переднего лазера
                    #42,                                                        ; FCommander.RearLaser, тип заднего лазера
                    #01,                                                        ; FCommander.LeftLaser, тип левого лазера
                    #01,                                                        ; FCommander.RightLaser, тип правого лазера
                    #00,                                                        ; FCommander.Mission1, состояние первой миссии
                    #46,                                                        ; FCommander.Fuel, топливо в десятых долях светового года, максимум 70
                    #04,                                                        ; FCommander.Missiles, количество ракет
                    #FF,                                                        ; FCommander.LargeCargo, состояние расширенного трюма
                    #7F,                                                        ; FCommander.ECM, наличие и состояние системы ECM
                    #7F,                                                        ; FCommander.AlienComputer, состояние инопланетного компьютера и счётчик его событий
                    #06,                                                        ; FCommander.MineralLife, состояние живой колонии минералов
                    #FF,                                                        ; FCommander.FuelScoops, наличие и состояние топливного ковша
                    #00,                                                        ; FCommander.EscapePod, наличие спасательной капсулы
                    #FF,                                                        ; FCommander.EnergyBomb, наличие и состояние энергетической бомбы
                    #FF,                                                        ; FCommander.EnergyUnit, наличие и состояние энергетического блока
                    #FF,                                                        ; FCommander.DockComputer, наличие и состояние стыковочного компьютера
                    #FF,                                                        ; FCommander.GalacticDrive, наличие и состояние галактического гиперпривода
                    #00,                                                        ; FCommander.ShipUpgrade, код установленного улучшения корабля
                    #00,                                                        ; FCommander.Invasion, фаза и размер области вторжения
                    {                                                           ; FCommander.GalaxySeed, шесть байтов семени галактики
                        #52,                                                    ; FSystemSeed.NameBits, бит 6 выбирает четыре слога вместо трёх
                        #D2,                                                    ; FSystemSeed.Y, координата Y, биты 2..0 дают исходную экономику
                        #42,                                                    ; FSystemSeed.GovBits, биты 5..3 задают правительство
                        #10,                                                    ; FSystemSeed.X, координата X, биты 1..0 участвуют в технологии
                        #9A,                                                    ; FSystemSeed.MixLow, младший байт третьего слова при шаге генератора
                        #BD                                                     ; FSystemSeed.Syllable, биты 4..0 задают индекс слога имени
                    },
                    {                                                           ; FCommander.SystemSeed, шесть байтов семени текущей системы
                        #7A,                                                    ; FSystemSeed.NameBits, бит 6 выбирает четыре слога вместо трёх
                        #3A,                                                    ; FSystemSeed.Y, координата Y, биты 2..0 дают исходную экономику
                        #22,                                                    ; FSystemSeed.GovBits, биты 5..3 задают правительство
                        #3B,                                                    ; FSystemSeed.X, координата X, биты 1..0 участвуют в технологии
                        #6A,                                                    ; FSystemSeed.MixLow, младший байт третьего слова при шаге генератора
                        #47                                                     ; FSystemSeed.Syllable, биты 4..0 задают индекс слога имени
                    },
                    #0A,                                                        ; FCommander.Technology, технологический уровень системы, счёт с нуля
                    #04,                                                        ; FCommander.Government, тип правительства системы, 0..7
                    {                                                           ; FCommander.MarketStock, остатки товаров станции, структура FGoods
                        #0B,                                                    ; FGoods.Food, продовольствие, т
                        #0D,                                                    ; FGoods.Textiles, текстиль, т
                        #0D,                                                    ; FGoods.Radioactives, радиоактивные материалы, т
                        #00,                                                    ; FGoods.Slaves, рабы, т
                        #0A,                                                    ; FGoods.Liquor, алкоголь, т
                        #26,                                                    ; FGoods.Luxuries, предметы роскоши, т
                        #2D,                                                    ; FGoods.Narcotics, наркотики, т
                        #1C,                                                    ; FGoods.Computers, компьютеры, т
                        #20,                                                    ; FGoods.Machinery, промышленное оборудование, т
                        #13,                                                    ; FGoods.Alloys, сплавы, т
                        #21,                                                    ; FGoods.Firearms, огнестрельное оружие, т
                        #13,                                                    ; FGoods.Furs, меха, т
                        #00,                                                    ; FGoods.Minerals, минералы, т
                        #09,                                                    ; FGoods.Gold, золото, кг
                        #00,                                                    ; FGoods.Platinum, платина, кг
                        #00,                                                    ; FGoods.Gemstones, драгоценные камни, г
                        #00                                                     ; FGoods.AlienItems, инопланетные предметы, т
                    },
                    #00,                                                        ; FCommander.Mission3, этап миссии 3 и служебное состояние войны
                    #43,                                                        ; FCommander.MissionFlags, награды, особое оборудование и занятость трюма миссией
                    {                                                           ; FCommander.SunPosition, три трёхбайтовые координаты солнца
                        {#F0, #52, #05},                                        ; FSpacePosition.X, FCoordinate {Fraction, Low, SignHigh}
                        {#33, #98, #07},                                        ; FSpacePosition.Y, FCoordinate {Fraction, Low, SignHigh}
                        {#B6, #FA, #8B}                                         ; FSpacePosition.Z, FCoordinate {Fraction, Low, SignHigh}
                    }
                }
                ASSERT $ - Commander == FCommander
                ; флаг повторного миссионного предупреждения
MissionNotice   DB #00                                                          ; флаг, повторное миссионное предупреждение уже подготовлено
                ; галактическая координата X выбранной цели
TargetX         DB #14                                                          ; галактическая координата X выбранной цели
                ; галактическая координата Y выбранной цели
TargetY         DB #AD                                                          ; галактическая координата Y выбранной цели
                ; десять пар очереди событий, поля двух пар также используются при печати чисел
FlightEvents    FFlightEvent {
                    #08,                                                        ; FFlightEvent.ColumnFlags, бит ожидания и столбец сообщения
                    #C9                                                         ; FFlightEvent.Token, номер сообщения основной таблицы
                }
                ; уведомление после запуска вражеской ракеты
IncomingEvent   FFlightEvent {
                    #07,                                                        ; FFlightEvent.ColumnFlags, бит ожидания и столбец сообщения
                    #78                                                         ; FFlightEvent.Token, номер сообщения основной таблицы
                }
                FFlightEvent {
                    #09,                                                        ; FFlightEvent.ColumnFlags, бит ожидания и столбец сообщения
                    #C8                                                         ; FFlightEvent.Token, номер сообщения основной таблицы
                }
                FFlightEvent {
                    #02,                                                        ; FFlightEvent.ColumnFlags, бит ожидания и столбец сообщения
                    #FD                                                         ; FFlightEvent.Token, номер сообщения основной таблицы
                }
                FFlightEvent {
                    #0C,                                                        ; FFlightEvent.ColumnFlags, бит ожидания и столбец сообщения
                    #E2                                                         ; FFlightEvent.Token, номер сообщения основной таблицы
                }
                ; событие подбора груза, также предложение улучшения корабля
CargoEvent      FFlightEvent {
                    #0B,                                                        ; FFlightEvent.ColumnFlags, бит ожидания и столбец сообщения
                    #00                                                         ; FFlightEvent.Token, номер сообщения основной таблицы
                }
                ; специальное событие, используется в состоянии войны
                FFlightEvent {
                    #06,                                                        ; FFlightEvent.ColumnFlags, бит ожидания и столбец сообщения
                    #65                                                         ; FFlightEvent.Token, номер сообщения основной таблицы
                }
                ; Token используется также как признак подавления ведущих нулей
ZeroEvent       FFlightEvent {
                    #00,                                                        ; FFlightEvent.ColumnFlags, бит ожидания и столбец сообщения
                    #01                                                         ; FFlightEvent.Token, номер сообщения основной таблицы
                }
                ; Token используется также как минимальная ширина числа
WidthEvent      FFlightEvent {
                    #00,                                                        ; FFlightEvent.ColumnFlags, бит ожидания и столбец сообщения
                    #00                                                         ; FFlightEvent.Token, номер сообщения основной таблицы
                }
                FFlightEvent {
                    #0A,                                                        ; FFlightEvent.ColumnFlags, бит ожидания и столбец сообщения
                    #1F                                                         ; FFlightEvent.Token, номер сообщения основной таблицы
                }
                ASSERT $ - FlightEvents == 10 * FFlightEvent
ZeroSuppress    EQU ZeroEvent.Token                                             ; подавление ведущих нулей, токен восьмой пары
NumberWidth     EQU WidthEvent.Token                                            ; минимальная ширина числа, токен девятой пары
                ; режим регистра букв, 1 заглавные, 2 строчные
LetterCase      DB #00                                                          ; регистр букв, 1 заглавные, 2 строчные
                ; состояние начала слова для преобразования регистра
WordStart       DB #01                                                          ; флаг, следующий символ начинает слово
                ; одноразовый признак заглавной буквы
CapitalNext     DB #00                                                          ; флаг, следующая буква должна стать заглавной
                ; сохранённый режим текста, проверка в Game.Text.ApplyTextCase.EmitCharacter нейтрализована NOP
TextMode        DB #00                                                          ; сохранённый режим текста, его проверка нейтрализована NOP
                ; сохранённый указатель на LD HL, Memory.Screen в Game.Text.DrawCharacter8x8.Entry
TextBasePatch   DW Game.Text.DrawCharacter8x8.ScreenHigh - 2                    ; сохранённый адрес команды загрузки экранной базы текста
ShowBoarding:   JP Game.Missions.ShowBoardingMessage.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #D0DA
                endmodule
                endmodule
