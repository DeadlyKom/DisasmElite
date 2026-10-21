TextByte        EQU 0                                                           ; нулевое смещение текущего символа, IX является курсором строки
; -----------------------------------------
; служебное меню счётчиков защитной отметки и допуска копирования
; исходный диапазон #CF1E..#CF95
; In:
;   DiskMark.Counters, три слова со смещениями 0, 2 и 4
;   DiskMark.Suffix, дополнительное поле
;   VerifyMark возвращает проверенный счётчик DE
; Out:
;   ожидание клавиши либо переход ConfirmCopy при допуске
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   VerifyMark читается до ClearWorkArea, его DE сохраняется на стеке.
;   Три слова от DiskMark.Counters печатаются до первого нулевого, дополнительное слово получает разделитель '-'.
;   Младший байт слова DiskMark.ByteSuffix при ненулевом значении дописывается после ':' тремя цифрами.
;   Остаток B сохраняется PUSH BC и извлекается POP AF в A, все три заполненных поля дают A=0.
;   При A=0 меню только ждёт клавишу, при D!=0 допускает ConfirmCopy.
;   При D=0 печатает число 256-DE и сообщение перед общим ожиданием.
;   Прямые входящие переходы на этот служебный вход в проверенном коде не найдены.
;   Эта запись описывает механизм допуска, исторический смысл трёх чисел не выводится из их арифметики.
;   На текущем TRD VerifyMark возвращает DE=0 для всех значений измерителя, поэтому этот путь не допускает ConfirmCopy.
; -----------------------------------------
                ; проверка отметки и подготовка экрана служебного меню
CopyMenu:       CALL @Game.Disk.BlackAttributesAndOverlayState.Entry            ; очистка 768 атрибутных байтов, на выходе HL=(Memory.Attributes + #0300) и BC=0
                CALL VerifyMark
                PUSH DE
                LD BC, #16DF
                CALL ClearWorkArea
                CALL @Game.Text.ClearViewAndFrame.Entry
                LD IX, CounterText
                LD HL, DiskMark.Counters
                LD B, #03
                ; чтение и преобразование очередного числового поля
FormatCounter:  LD E, (HL)
                INC HL
                LD D, (HL)
                INC HL
                EX DE, HL
                LD A, H
                OR L
                JR Z, ExtraCounter                                              ; переход, если очередное поле равно нулю и основной список чисел завершён

                INC IX
                PUSH DE
                CALL FormatDecimal
                POP DE
                EX DE, HL
                DJNZ FormatCounter

                ; добавление необязательного числового суффикса
ExtraCounter:   LD HL, (DiskMark.Suffix)
                LD A, H
                OR L
                JR Z, ByteCounter                                               ; переход, если дополнительное слово DiskMark.Suffix равно нулю и суффикс '-' не нужен

                LD (IX + TextByte), #2D
                INC IX
                CALL FormatDecimal
ByteCounter:    LD HL, (DiskMark.ByteSuffix)
                XOR A
                LD H, A
                OR L
                JR Z, FinishCounters                                            ; переход, если младший байт DiskMark.ByteSuffix нулевой и суффикс ':' не нужен

                LD (IX + TextByte), #3A
                INC IX
                CALL ThreeDigits
                ; завершение строки и проверка условий допуска
FinishCounters: LD (IX + TextByte), #D3
                LD (IX + TextByte + 1), #00
                PUSH BC
                LD HL, CopyText
                CALL @Game.Text.PrintDescriptionString.Entry                    ; вывод строки HL до нулевого байта штатным обработчиком игры
                POP AF
                POP DE
                AND A
                JP Z, WaitAndReturn                                             ; переход, если все три основных числовых поля заполнены и остаётся только ожидать клавишу

                LD A, D
                OR A
                JR NZ, ConfirmCopy                                              ; переход, если старший байт подтверждённого счётчика ненулевой и разрешено подтверждение копирования

                LD IX, MissingDigits
                LD HL, #0100
                SBC HL, DE
                CALL ThreeDigits
                LD HL, MissingText
                JP PrintAndWait
