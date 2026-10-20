                ifndef _VARIABLES_INTERFACE_
                define _VARIABLES_INTERFACE_

TextColumn      EQU Game.Interface.DispatchJumpKey.TextColumn                   ; столбец печати текста
TextRow         EQU Game.Interface.DispatchJumpKey.TextRow                      ; строка печати текста
GlyphPatch      EQU Game.Interface.DispatchTextToken.GlyphPatch                 ; сохранённый адрес изменяемой команды рисования глифа
ZeroSuppress    EQU Game.Interface.DispatchDiskAndCommanderState.ZeroSuppress   ; подавление ведущих нулей, одновременно токен восьмой пары очереди
NumberWidth     EQU Game.Interface.DispatchDiskAndCommanderState.NumberWidth    ; минимальная ширина числа, одновременно токен девятой пары очереди
LetterCase      EQU Game.Interface.DispatchDiskAndCommanderState.LetterCase     ; регистр букв, 1 заглавные, 2 строчные
WordStart       EQU Game.Interface.DispatchDiskAndCommanderState.WordStart      ; флаг, следующий символ начинает слово
CapitalNext     EQU Game.Interface.DispatchDiskAndCommanderState.CapitalNext    ; флаг, следующая буква должна стать заглавной
TextMode        EQU Game.Interface.DispatchDiskAndCommanderState.TextMode       ; сохранённый режим текста, его проверка нейтрализована NOP
TextBasePatch   EQU Game.Interface.DispatchDiskAndCommanderState.TextBasePatch  ; сохранённый адрес команды загрузки экранной базы текста
DecimalRest     EQU Game.Missions.RatingBountyDamageAndNewCommander.DecimalRest ; остаток десятичного преобразования числа
TextPosition    EQU TextColumn                                                  ; слово позиции печати, младший байт столбец, старший строка

RankLowLimits   EQU Game.Menus.PrintStatusFieldAndCargoScreen.RankLowLimits     ; пороги младшего байта боевого рейтинга
RankHighLimits  EQU Game.Menus.PrintStatusFieldAndCargoScreen.RankHighLimits    ; пороги старшего байта боевого рейтинга
StatusFormat    EQU Game.Input.ScanKeyboardMatrix.StatusFormat                  ; параметры атрибутов экрана командира
CargoFormat     EQU Game.Input.ScanKeyboardMatrix.CargoFormat                   ; параметры атрибутов дополнительного экрана
CaptionFormat   EQU Game.Input.ScanKeyboardMatrix.CaptionFormat                 ; параметры атрибутов строки подписи

TextDecodeMode  EQU Game.Economy.SubtractCashLow.TextDecodeMode                 ; режим декодирования текста, 0 основная таблица, 1 описания

DeviceFields    EQU Game.Menus.PrintDirectionalLaser.DeviceFields               ; шесть младших адресных байтов полей оборудования командира

                endif                                                           ; ~_VARIABLES_INTERFACE_
