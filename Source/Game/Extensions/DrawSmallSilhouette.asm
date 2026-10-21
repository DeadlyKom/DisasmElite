                module Extensions
                module DrawSmallSilhouette
; -----------------------------------------
; рисование малого силуэта с горизонтальным отсечением
; исходный диапазон #FB32..#FBDF
; смысловое имя DrawSmallSilhouette
; In: CircleState.OffsetY и OffsetX задают проекцию, Flags содержит знаки, Radius содержит радиус
; Out: маска наложена через OR на буфер выбранного экрана, IX сохранён
; Corrupt: HL, DE, BC, AF, AF', рабочий профиль ProjectedVerts
; Прямой вход XOR A выбирает стандартный профиль, вход Game.Extensions.DrawSmallSilhouetteAlternate.Entry выбирает альтернативный
; При виде >=4 либо радиусе вне 2..8 вывод пропускается
; Центр рассчитывается относительно X=127 и Y=64 с учётом знаков координат
; Крайние столбцы отсекаются флагами D, пиксельный сдвиг распределяет строку по трём байтам
; -----------------------------------------
; D, признаки бокового отсечения и направления профиля
;      7    6    5    4    3    2    1    0
;   +----+----+----+----+----+----+----+----+
;   | BK | .. | .. | .. | .. | .. | RC | LC |
;   +----+----+----+----+----+----+----+----+
;
;   BK      [7]     - флаг, обратный обход профиля, SIL_BACK_BIT
;   RC      [1]     - флаг, третий байт за правым краем, SIL_RIGHT_BIT
;   LC      [0]     - флаг, первый байт за левым краем, SIL_LEFT_BIT
;   признаки краёв создаются INC D и двумя INC D, затем читаются через RRC B
; -----------------------------------------
; Rom.PixelFromA преобразует координаты в адрес экрана, SET 7,H выбирает буфер
; Профиль читается вперёд до середины, затем назад для симметричной второй половины
; Рендер допускает адреса ниже #6000 либо #C000..#CFFF, остальные строки не записываются
; -----------------------------------------
                ; смещения описывают исходные данные, память не выделяется
ProfileByte:    EQU 0                                                           ; текущий байт контура, индекс IX проходит профиль от ProjectedVerts

                ; проверка исходного начала фрагмента
                ASSERT $ == #FB32
                ; вход XOR A для стандартного профиля, байт также является операндом Game.Extensions.DrawSmallSilhouetteAlternate.Entry
                ; XOR A при прямом входе, операнд LD A,#AF при входе Game.Extensions.DrawSmallSilhouetteAlternate.Entry
Entry:          DB #AF                                                          ; данные #FB32..#FB32
                ; перенос выбранного профиля в AF' и проверка экрана и радиуса
                EX AF, AF'
                LD A, (FlightState.View)
                CP #04
                LD A, (CircleState.Radius)
                RET NC                                                          ; выход, если номер экрана не меньше 4

                CP #09
                RET NC                                                          ; выход, если радиус не меньше 9

                CP #02
                RET C                                                           ; выход, если радиус меньше 2

                CALL Game.Extensions.BuildSmallCircleProfile.Entry
                LD HL, (CircleState.OffsetY)
                LD A, (CircleState.Flags)
                LD B, A
                LD A, #7F
                CP H
                JR C, RejectCentre                                              ; переход, если модуль X больше 127, силуэт вне допустимого диапазона

                ADD A, H
                RRC B
                JR C, ClipLeft                                                  ; переход, если знак X установлен, оставить сумму 127+X

                SUB H
                SUB H
                ; проверка левого и правого края, флаги отсечения накапливаются в D
ClipLeft:       LD C, A
                CP #08
                JR NC, ClipRight                                                ; переход, если центр X не меньше 8, левый край полностью помещается

                INC D
ClipRight:      CP #F8
                JR C, CheckHeight                                               ; переход, если центр X меньше 248, правый край полностью помещается

                INC D
                INC D
                ; проверка вертикального диапазона центра
CheckHeight:    LD A, #48
                CP L
                JR NC, ScreenY                                                  ; переход, если модуль Y не больше 72, вычислить экранную строку

RejectCentre:   XOR A
                RET

                ; расчёт экранной строки относительно 64 с учётом знака и радиуса
ScreenY:        LD A, #40
                ADD A, L
                RRC B
                JR NC, AddRadius                                                ; переход, если знак Y сброшен, оставить сумму 64+Y

                SUB L
                SUB L
AddRadius:      ADD A, E
                ; преобразование пиксельных координат в адрес и выбор буфера
                CALL Rom.PixelFromA
                SET 7, H
DrawRaster:     LD C, A
                PUSH IX
                LD IX, ProjectedVerts
                XOR A
NextScanline:   PUSH AF
                LD A, H
                DEC H
                AND #07
                CALL Z, Game.Screen.PreviousCharacterRow.Entry                  ; вызов, если переход пересёк восьмистрочную полосу, скорректировать адрес вверх
                ; проверка допустимых диапазонов экранной памяти
                LD A, H
                CP #60
                JR C, BuildRowMask                                              ; переход, если старший байт адреса меньше #60, строку можно записать

                CP #D0
                JR NC, AdvanceProfile                                           ; переход, если старший байт адреса не меньше #D0, пропустить строку

                CP #C0
                JR C, AdvanceProfile                                            ; переход, если старший байт адреса меньше #C0, пропустить строку

                ; расчёт трёхбайтовой маски строки из профиля и пиксельного смещения
BuildRowMask:   PUSH HL
                LD A, (IX+ProfileByte)
                LD B, #08
MirrorMask:     RLCA
                RR H
                DJNZ MirrorMask

                ADD A, A
                ; сдвиг 24-битной маски к нужной позиции внутри байта
                LD L, A
                LD A, #08
                SUB C
                LD B, A
                XOR A
ShiftRowMask:   ADD HL, HL
                RLA
                DJNZ ShiftRowMask

                ; наложение трёх байтов с учётом отсечения боковых краёв
                LD B, D
                EX DE, HL
                EX (SP), HL
                RRC B
                JR C, WriteCentre                                               ; переход, если левый край отсечён, не писать первый байт

                DEC HL
                CALL Game.Extensions.OrSpriteByte.Entry
                INC HL
WriteCentre:    LD A, D
                CALL Game.Extensions.OrSpriteByte.Entry
                RRC B
                JR C, RestoreClip                                               ; переход, если правый край отсечён, не писать третий байт

                INC HL
                LD A, E
                CALL Game.Extensions.OrSpriteByte.Entry
                DEC HL
RestoreClip:    POP DE
                ; переход по прямой или обратной половине симметричного профиля
AdvanceProfile: POP AF
                BIT SIL_BACK_BIT, D
                JR NZ, ReverseRow                                               ; переход, если включена обратная половина профиля, уменьшать индекс

                INC A
                INC IX
                CP E
                JR NZ, NextScanline                                             ; переход, если первая половина ещё не достигла радиуса, продолжить вперёд

                ; разворот обхода профиля после достижения радиуса
                SET SIL_BACK_BIT, D
                DEC IX
ReverseRow:     DEC IX
                DEC A
                JR NZ, NextScanline                                             ; переход, если обратная половина ещё не закончилась, продолжить вывод

                POP IX
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #FBE0
                endmodule
                endmodule
