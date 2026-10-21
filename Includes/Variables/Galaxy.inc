                ifndef _VARIABLES_GALAXY_
                define _VARIABLES_GALAXY_

GalaxyState     EQU Game.Travel.SetFuelAndGauge.SystemData                      ; адрес структуры FGalaxyState
.TargetSeed     EQU GalaxyState + FGalaxyState.TargetSeed                       ; шестибайтовое семя выбранной цели
.WorkingSeed    EQU GalaxyState + FGalaxyState.WorkingSeed                      ; рабочее семя перебора и генерации имени
.SavedSeed      EQU GalaxyState + FGalaxyState.SavedSeed                        ; копия рабочего семени на время вложенного перебора
.TextSeed       EQU GalaxyState + FGalaxyState.TextSeed                         ; четыре байта генератора описаний
.InputBuffer    EQU GalaxyState + FGalaxyState.InputBuffer                      ; десять вводимых символов и завершающий ноль
.GeneratedName  EQU GalaxyState + FGalaxyState.GeneratedName                    ; восемь букв имени и завершающий ноль
.CurrentName    EQU GalaxyState + FGalaxyState.CurrentName                      ; сохранённое имя текущей системы
.TargetName     EQU GalaxyState + FGalaxyState.TargetName                       ; сохранённое имя выбранной цели
.Distance       EQU GalaxyState + FGalaxyState.Distance                         ; расстояние до цели в десятых светового года
.Economy        EQU GalaxyState + FGalaxyState.Economy                          ; экономика выбранной системы, индекс 0..7
.Government     EQU GalaxyState + FGalaxyState.Government                       ; правительство выбранной системы, индекс 0..7
.Technology     EQU GalaxyState + FGalaxyState.Technology                       ; технологический уровень, счёт с нуля
.Population     EQU GalaxyState + FGalaxyState.Population                       ; население в десятых миллиарда
.Productivity   EQU GalaxyState + FGalaxyState.Productivity                     ; производительность системы
.Reserved       EQU GalaxyState + FGalaxyState.Reserved                         ; сохранённые байты образа, обращений к полю не найдено
.ScanIndex      EQU GalaxyState + FGalaxyState.ScanIndex                        ; индекс перебора, переполнение завершает 256 систем
.NameCursor     EQU GalaxyState + FGalaxyState.NameCursor                       ; адрес следующего символа в GeneratedName
NearestMetric   EQU Game.Galaxy.FindSystemByExactName.NearestMetric             ; наименьшая квадратичная метрика до курсора
TargetX         EQU Game.Interface.DispatchDiskAndCommanderState.TargetX        ; галактическая координата X выбранной цели
TargetY         EQU Game.Interface.DispatchDiskAndCommanderState.TargetY        ; галактическая координата Y выбранной цели

NameSyllables   EQU Game.Input.ScanKeyboardMatrix.NameSyllables                 ; 32 пары символов для генератора имён и текстовых токенов
GalaxyFormat    EQU Game.Input.ScanKeyboardMatrix.GalaxyFormat                  ; параметры атрибутов строки сравнения семени галактики

TextSyllables   EQU Game.Input.ScanKeyboardMatrix.TextSyllables                 ; двухсимвольные слоги описаний, начало перед общей таблицей имён

                endif                                                           ; ~_VARIABLES_GALAXY_
