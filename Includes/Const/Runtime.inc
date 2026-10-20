                ifndef _CONST_RUNTIME_FLAGS_
                define _CONST_RUNTIME_FLAGS_

; FFlightEvent.ColumnFlags, ожидающее сообщение и столбец печати
EVENT_WAIT_BIT  EQU 7                                                           ; флаг, сообщение ожидает показа
EVENT_COL_MASK  EQU #7F                                                         ; числовой столбец сообщения без признака ожидания

; FlightState.SoundRequests, бит 0 обслуживается раньше старших
SND_BOMB_BIT    EQU 0                                                           ; флаг, звук энергетической бомбы
SND_MISSILE_BIT EQU 1                                                           ; флаг, звук запуска ракеты
SND_BLAST_BIT   EQU 2                                                           ; флаг, звук взрыва или столкновения
SND_LASER_BIT   EQU 3                                                           ; флаг, звук попадания лазера
SND_FALL_BIT    EQU 4                                                           ; флаг, запрос FallingTone, установщик в игре не найден
SND_ECM_BIT     EQU 5                                                           ; флаг, звук работы ECM
SND_HIT_BIT     EQU 6                                                           ; флаг, звук выстрела или полученного удара
SND_ADDED_BIT   EQU 7                                                           ; флаг, второй запрос AddedTone, установщик в игре не найден

; FSoundState.Mode, старший бит используется шумовым режимом
SND_REPEAT_BIT  EQU 7                                                           ; флаг, перейти к следующей фазе шумового эффекта
SND_MODE_MASK   EQU #7F                                                         ; код режима без признака следующей фазы

SEED_LONG_BIT   EQU 6                                                           ; флаг, четвёртый слог имени системы
SEED_ECON_MASK  EQU #07                                                         ; три младших бита Y задают исходную экономику
SEED_GOV_MASK   EQU #07                                                         ; номер правительства после сдвига GovBits на три разряда
SEED_TECH_MASK  EQU #03                                                         ; два младших бита X участвуют в расчёте технологии
SEED_SYLL_MASK  EQU #1F                                                         ; индекс слога имени из пяти младших битов семени
DEVICE_SIGN_BIT EQU 7                                                           ; старший разряд кода оборудования, устанавливается перед уменьшением уровня

                endif                                                           ; ~_CONST_RUNTIME_FLAGS_
