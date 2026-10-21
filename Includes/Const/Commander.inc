                ifndef _CONST_COMMANDER_
                define _CONST_COMMANDER_

; -----------------------------------------
; поля FCommander, расположение битов описано непосредственно перед полями
; *_BIT используются в BIT/SET/RES, *_MASK в логических операциях
; -----------------------------------------
RANK_WAR_BIT    EQU 7                                                           ; флаг, вывод воинского звания в RankState
RANK_RSV_BIT    EQU 6                                                           ; флаг, отставка и запрет поиска секретной базы
RANK_NEXT_BIT   EQU 0                                                           ; флаг, разрешена проверка очередного задания
RANK_WAR_MASK   EQU 1 << RANK_WAR_BIT                                           ; маска признака воинского звания
RANK_RSV_MASK   EQU 1 << RANK_RSV_BIT                                           ; маска отставки IN RESERVE
RANK_NEXT_MASK  EQU 1 << RANK_NEXT_BIT                                          ; маска разрешения очередного задания
RANK_NUM_MASK   EQU #0E                                                         ; биты 3..1, числовой номер воинского звания
RANK_CODE_MASK  EQU #FF ^ RANK_NEXT_MASK                                        ; код состояния без признака очередного задания
RANK_TYPE_MASK  EQU RANK_WAR_MASK | RANK_NUM_MASK                               ; военный признак и номер звания без отставки и NX
RANK_ELITE_MIN  EQU #20                                                         ; минимальный старший рейтинг для попытки запуска вторжения
RANK_START_CODE EQU RANK_WAR_MASK | RANK_NEXT_MASK                              ; начальное военное состояние #81 до ответа добровольца
RANK_LT_CODE    EQU RANK_WAR_MASK | (1 << 1)                                    ; военный код #82, первый полученный чин
RANK_CAPT_CODE  EQU RANK_WAR_MASK | (2 << 1)                                    ; военный код #84, порог перевозки десанта
RANK_MAJ_CODE   EQU RANK_WAR_MASK | (3 << 1)                                    ; военный код #86, допуск предложения десанта
RANK_COL_RSV    EQU RANK_WAR_MASK | RANK_RSV_MASK | (4 << 1)                    ; код #C8, особое окончание печати воинского звания
JUMP_MSN_BIT    EQU 7                                                           ; флаг, проверка выдачи старых миссий при прибытии
JUMP_COUNT_MASK EQU #7F                                                         ; старшие числовые разряды счётчика без разрешения миссии
MS_ACCEPT_BIT   EQU 7                                                           ; флаг, принято предложение третьей миссии
MS_CLOAK_BIT    EQU 6                                                           ; флаг, получено устройство маскировки
MS_CARGO_BIT    EQU 5                                                           ; флаг, трюм занят беженцами либо десантом
MS_MARK5_BIT    EQU 4                                                           ; флаг, пятая отметка общей последовательности заданий
MS_MARK4_BIT    EQU 3                                                           ; флаг, выдана награда третьей миссии, четвёртая отметка войны
MS_MARK3_BIT    EQU 2                                                           ; флаг, третья миссия выдана либо система освобождена десантом
MS_MARK2_BIT    EQU 1                                                           ; флаг, вторая миссия выдана либо выполнена военная поставка
MS_MARK1_BIT    EQU 0                                                           ; флаг, первая миссия выдана либо выполнена эвакуация
MS_ACCEPT_MASK  EQU 1 << MS_ACCEPT_BIT                                          ; маска признака MS_ACCEPT_BIT
MS_CLOAK_MASK   EQU 1 << MS_CLOAK_BIT                                           ; маска признака MS_CLOAK_BIT
MS_CARGO_MASK   EQU 1 << MS_CARGO_BIT                                           ; маска признака MS_CARGO_BIT
MS_MARK5_MASK   EQU 1 << MS_MARK5_BIT                                           ; маска признака MS_MARK5_BIT
MS_MARK4_MASK   EQU 1 << MS_MARK4_BIT                                           ; маска признака MS_MARK4_BIT
MS_MARK3_MASK   EQU 1 << MS_MARK3_BIT                                           ; маска признака MS_MARK3_BIT
MS_MARK2_MASK   EQU 1 << MS_MARK2_BIT                                           ; маска признака MS_MARK2_BIT
MS_MARK1_MASK   EQU 1 << MS_MARK1_BIT                                           ; маска признака MS_MARK1_BIT
MS_START_MASK   EQU MS_ACCEPT_MASK | MS_CLOAK_MASK | MS_MARK5_MASK              ; сохраняемые биты при начале вторжения, маска #D0
M3_HIT_BIT      EQU 3                                                           ; флаг, отмечено попадание в специальную цель
M3_STAGE_BIT    EQU 2                                                           ; бит числового этапа, разрешающий сохранить отметку попадания
ALIEN_OWN_BIT   EQU 0                                                           ; флаг, установлен ALIEN COMPUTER
ALIEN_OWN_MASK  EQU 1 << ALIEN_OWN_BIT                                          ; маска наличия ALIEN COMPUTER
ALIEN_COUNT_MSK EQU #FE                                                         ; биты 7..1, числовая часть счётчика обработки удаляемой модели
MIN_BLOCK_BIT   EQU 7                                                           ; флаг, живая колония недоступна
MIN_SIZE_MASK   EQU #7F                                                         ; числовая часть состояния колонии
INV_ATTACK_BIT  EQU 7                                                           ; флаг, наступательная фаза вторжения
INV_RADIUS_MASK EQU #7F                                                         ; числовая часть состояния фронта
INV_ACTIVE_MASK EQU #FE                                                         ; маска проверки состояния, отличного от 0 и 1
INV_ACTIVE_MIN  EQU 2                                                           ; минимальное состояние с активной геометрией фронта
INV_START       EQU #81                                                         ; начальная наступательная фаза
INV_RETREAT_MAX EQU #7F                                                         ; код после переполнения наступательной фазы

ECM_ON_BIT      EQU 7                                                           ; флаг, ECM активна до окончания таймера
ECM_ON_MASK     EQU 1 << ECM_ON_BIT                                             ; маска текущей активности ECM
ECM_LEVEL_MASK  EQU #7F                                                         ; числовая часть кода установленной ECM

                ; один исходный код одновременно инициализирует ранг и фронт
                ASSERT RANK_START_CODE == INV_START

                endif                                                           ; ~_CONST_COMMANDER_
