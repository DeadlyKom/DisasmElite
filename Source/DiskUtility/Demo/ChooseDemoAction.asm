; -----------------------------------------
; Выбор боевого режима или смены обзорного экрана
; исходный диапазон #EA35..#EA7F
; In:
;   IX, Keyboard, начало восьми полурядов виртуальной клавиатуры
;    общий таймер DiskUtility.Demo.ActionTimer
; Out:
;   найденная цель передаётся AttackTarget, иначе CollectCargo и периодическая команда
; Corrupt:
;   HL, DE, BC, AF, IY
; Note:
;   Нулевой 16-битный таймер загружается 100, исходный 100
;   Для вида 0..3 R&3 выбирает L при 1 с таймером 300, ENTER при 2, либо виды 1/2 при 0/3
;   Для информационного вида выбирается передний или задний по чётности номера, сохранённый RET после PressViewOne
;   не используется
; -----------------------------------------
                ; сначала проверка перезапуска и поиск боевой цели
ChooseAction:   CALL CheckRestart
                CALL FindTarget
                JR C, AttackTarget                                              ; переход, если найдена допустимая цель, начать боевой сценарий

                ; без цели пробуется подбор груза и уменьшается таймер смены вида
                CALL CollectCargo
                LD HL, (ActionTimer)
                DEC HL
                LD (ActionTimer), HL
                LD A, H
                OR L
                RET NZ                                                          ; выход, если таймер выбора экрана ещё не истёк

                ; новый интервал 100 и выбор действия по текущему виду либо R
                LD HL, #0064
                LD (ActionTimer), HL
                LD A, (FlightState.View)
                CP #04
                JR NC, ChooseViewKey                                            ; переход, если текущий вид информационный, выбрать 1/2 по его чётности

                LD A, R
                AND #03
                DEC A
                JR Z, PressScanner                                              ; переход, если случайный вариант равен 1, выбрать L с таймером 300

                DEC A
                JR Z, PressEnter                                                ; переход, если случайный вариант равен 2, выбрать ENTER

                ; чётность выбирает клавишу 1 или 2
ChooseViewKey:  AND #01
                JR NZ, PressViewOne                                             ; переход, если остаток выбора нечётен, установить клавишу 1

                SET KEYBOARD_2_BIT, (IX + FKeyboardRows.Row12345)
                RET

PressViewOne:   SET KEYBOARD_1_BIT, (IX + FKeyboardRows.Row12345)
                RET

                RET

                ; экран по L получает увеличенный интервал 300
PressScanner:   LD HL, #012C
                LD (ActionTimer), HL
                SET KEYBOARD_L_BIT, (IX + FKeyboardRows.RowEnterLKJH)
                RET

                ; альтернативное действие нажимает ENTER
PressEnter:     SET KEYBOARD_EN_BIT, (IX + FKeyboardRows.RowEnterLKJH)
                RET
