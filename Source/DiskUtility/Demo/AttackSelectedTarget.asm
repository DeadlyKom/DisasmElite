; -----------------------------------------
; Сценарий переключения сканера и атаки цели
; исходный диапазон #EA82..#EB51
; In:
;   IX, Keyboard, начало восьми полурядов виртуальной клавиатуры
;   IY выбранная цель
; Out:
;   наведение, стрельба и защита до исчезновения допустимой цели
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   X/Y/Z совпадают в первых девяти байтах объекта, солнца и планеты
;   50 кадров Caps Shift входят в паузу,5 кадров L переключают сканер, далее PauseWithMark и 20 кадров пробела
;   выходят и разгоняют
;   В цикле DiskUtility.Demo.ActionTimer=500, вид 1, при близкой цели или текущем тангаже выполняется Brake
;   После YieldWithBrake вычисляется AimAtObject, проверяются полные X/Y, затем младшие биты до допуска
;   стрельбы
;   A выставляется только при ненулевой энергии объекта, сумме координат<50 и неотрицательной Z
;   CountMissiles обнаруживает направленные на игрока ракеты и включает E, AllowAttack с C=0 завершает весь
;   сценарий
; -----------------------------------------
                ; подготовка сценария через паузу и переключение проекции сканера
AttackTarget:   CALL CheckRestart
                CALL YieldWithBrake
                LD B, #32
                ; пятьдесят кадров Caps Shift, каждый раз очищаются прочие строки
PauseKeyFrames: CALL ClearMainKeys
                SET KEYBOARD_CS_BIT, (IX + FKeyboardRows.RowShiftZXCV)
                CALL YieldWithBrake
                DJNZ PauseKeyFrames

                RES KEYBOARD_CS_BIT, (IX + FKeyboardRows.RowShiftZXCV)
                LD B, #05
                ; пять кадров L переключают проекцию внутри паузы
ScanKeyFrames:  CALL ClearMainKeys
                SET KEYBOARD_L_BIT, (IX + FKeyboardRows.RowEnterLKJH)
                CALL YieldWithBrake
                DJNZ ScanKeyFrames

                CALL PauseWithMark
                LD B, #14
                ; двадцать кадров пробела после PauseWithMark выходят из меню и разгоняют
SpeedKeyFrames: PUSH BC
                CALL ClearMainKeys
                SET KEYBOARD_SP_BIT, (IX + FKeyboardRows.RowSpaceSMNB)
                CALL YieldWithBrake
                POP BC
                DJNZ SpeedKeyFrames

                ; передний вид и интервал 500 перед оценкой скорости сближения
SetAttackView:  LD HL, #01F4
                LD (ActionTimer), HL
                SET KEYBOARD_1_BIT, (IX + FKeyboardRows.Row12345)
                LD A, (IY + FSpaceObject.Z.SignHigh)
                AND #7F
                JR NZ, SpeedForPitch                                            ; переход, если старший модуль Z ненулевой, выбирать скорость с учётом поворота

                LD DE, #0009
                CALL CompareRange
                JR NC, SpeedForPitch                                            ; переход, если сумма координат не меньше 9, выбирать скорость с учётом поворота

                CALL Brake
                JR RecheckTarget

                ; базовое торможение сохраняется при текущем тангаже
SpeedForPitch:  RES KEYBOARD_SP_BIT, (IX + FKeyboardRows.RowSpaceSMNB)
                SET KEYBOARD_SS_BIT, (IX + FKeyboardRows.RowSpaceSMNB)
                BIT KEYBOARD_X_BIT, (IX + FKeyboardRows.RowShiftZXCV)
                JR NZ, RecheckTarget                                            ; переход, если выставлена клавиша X, оставить торможение

                BIT KEYBOARD_S_BIT, (IX + FKeyboardRows.RowASDFG)
                JR NZ, RecheckTarget                                            ; переход, если выставлена клавиша S, оставить торможение

                SET KEYBOARD_SP_BIT, (IX + FKeyboardRows.RowSpaceSMNB)
                RES KEYBOARD_SS_BIT, (IX + FKeyboardRows.RowSpaceSMNB)
                ; повторная проверка допустимости цели перед защитой и наведением
RecheckTarget:  CALL AllowAttack
                RET NC                                                          ; выход, если объект перестал удовлетворять условиям боевой цели

                CALL CheckRestart
                ; проверка перезапуска, боевых защит и летящих на игрока ракет
                CALL DefenceKeys
                RES KEYBOARD_J_BIT, (IX + FKeyboardRows.RowEnterLKJH)
                CALL CountMissiles
                JR Z, AimAfterFrame                                             ; переход, если ракет с целью игрока нет, не выставлять E

                SET KEYBOARD_E_BIT, (IX + FKeyboardRows.RowQWERT)
                ; уступка кадра и расчёт наведения по актуальному объекту
AimAfterFrame:  CALL YieldWithBrake
                CALL AimAtObject
                ; проверка целых компонент X/Y перед точной зоной стрельбы
                LD A, (IY + FSpaceObject.X.SignHigh)
                OR (IY + FSpaceObject.Y.SignHigh)
                AND #7F
                OR (IY + FSpaceObject.X.Low)
                OR (IY + FSpaceObject.Y.Low)
                JP NZ, SetAttackView                                            ; переход, если целые компоненты X/Y ненулевые, продолжить основное наведение

                ; проверка старших двух битов дробного отклонения
                LD A, (IY + FSpaceObject.X.Fraction)
                OR (IY + FSpaceObject.Y.Fraction)
                AND #C0
                JR Z, CheckFireRange                                            ; переход, если старшие два бита дробных X/Y нулевые, проверить возможность выстрела

                LD A, (IX + FKeyboardRows.RowSpaceSMNB)
                CP #03
                JR C, RecheckTarget                                             ; переход, если значение строки Space/Symbol меньше 3, продолжить бой без смены скорости

                JP SetAttackView

                ; выстрел требует ненулевой энергии цели впереди и суммы удаления меньше 50
CheckFireRange: LD A, (IY + FSpaceObject.Energy)
                AND A
                JR Z, RecheckTarget                                             ; переход, если энергия объекта обнулилась, вернуться к проверке цели

                LD DE, #0032
                CALL CompareRange
                JR NC, ResumeAttack                                             ; переход, если цель не ближе 50, выстрел не разрешён

                BIT 7, (IY + FSpaceObject.Z.SignHigh)
                JR NZ, ResumeAttack                                             ; переход, если цель сзади, выстрел не разрешён

                SET KEYBOARD_A_BIT, (IX + FKeyboardRows.RowASDFG)
ResumeAttack:   JP RecheckTarget
