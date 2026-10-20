                module Wireframe
                module DrawClippedLine
                ; выбор единственного байта уже адресованной маски, IX указывает в таблицу #B400
MaskByte:       EQU 0
; -----------------------------------------
; отсечение отрезка и наложение его растрового изображения в буфер #C000
;
; In:
;   HL, H модуль X и L модуль Y первого конца
;   DE, D модуль X и E модуль Y второго конца
;   BC, C содержит пары знаков, биты 0..1 для HL, 2..3 для DE
;   PROJ_POSY_BIT каждой пары задаёт Y=63+модуль вместо 63-модуль
;   PROJ_NEGX_BIT каждой пары задаёт X=127-модуль вместо 127+модуль
;   #9CBB заранее выбирает OR или XOR в четырёх изменяемых командах
; Out:
;   пиксели отрезка наложены выбранной операцией либо отрезок отброшен
; Corrupt:
;   HL, DE, BC, AF, HL', DE', BC', AF'
;
; отсечение пересчитывает внешние концы отношением приращений в формате 8.8
; #B29F учитывает девятые разряды, #B286 умножает наклон на превышение границы
; после каждого отсечения управление возвращается к проверке новых концов
; предел Y равен 63, внешняя X исправляется на 119
; предварительный тест отбрасывает оба модуля X >=120 с одним знаком
; последующая проверка допускает модуль 120 у одного конца, условие сохранено
; тест одинаковой внешней стороны Y использует AND модулей, а не две CP
; это точное поведение оригинала, упрощать его до идеального clip нельзя
;
; крутые линии выводят по одному пикселю на строку с накоплением ошибки
; пологие линии выводят горизонтальные группы по таблице масок #B400
; #9CD1 выбирает OR при нулевом #7120 и XOR при ненулевом
; коды #B6/#AE записываются в #B1B7, #B232, #B244 и #B252
; сортировка концов делает приращение X всегда положительным
; протяжённость X равна разности модулей при одном знаке и сумме плюс 1 при разных
; поэтому горизонталь с общим знаком X не включает правый конец
; протяжённость Y всегда содержит дополнительную строку, включая оба конца
; наклон Y выбирает INC H или DEC H и два разных перехода между знакоместами
; ветви вверх #B1DB и #B273 исполняются после изменения смещений JR
;
; самомодификация крутого цикла:
;   #B1B5 код шага по строке, #B1BD дробный шаг, #B1C7 смещение ветви
; самомодификация пологого цикла:
;   #B20D код шага, #B20F целая часть, #B212 дробная часть
;   #B231 смещение маски, #B25D следующий бит, #B25F смещение ветви
; IX сохраняется и восстанавливается в пологом цикле
; ROM #22B1 вычисляет адрес пикселя, память ROM нужна во время выполнения
; -----------------------------------------
                ; проверка исходного начала процедуры
                ASSERT $ == #B044
                ; проверка пар #FF, которыми проекция отмечает предельные координаты
Entry:          LD A, D
                AND L
                INC A
                RET Z                                                           ; выход, если D и L одновременно равны #FF

                LD A, E
                AND H
                INC A
                RET Z                                                           ; выход, если E и H одновременно равны #FF

                ; разделение двух пар знаков, B для HL, C для DE
                LD B, C
                RR C
                RR C
                ; быстрое отбрасывание концов по одну сторону горизонтальной границы
ClipAgain:      LD A, B
                XOR C
                RRCA
                JR C, CheckXSide                                                ; переход, если знаки Y концов различаются

                EX AF, AF'
                LD A, E
                AND L
                CP #40
                RET NC                                                          ; выход, если общий результат E AND L не меньше 64

                EX AF, AF'
                ; проверка общей внешней стороны по X
CheckXSide:     RRCA
                JR C, Measure                                                   ; переход, если знаки X концов различаются

                LD A, D
                CP #78
                JR C, Measure                                                   ; переход, если модуль X конца DE меньше 120

                LD A, H
                CP #78
                RET NC                                                          ; выход, если оба конца с общим знаком X имеют модули не меньше 120

                ; сохранение концов и знаков во втором наборе регистров
Measure:        PUSH HL
                PUSH DE
                PUSH BC
                EXX
                POP BC
                POP DE
                POP HL
                ; расчёт вертикальной протяжённости с включением последней строки
                LD A, B
                XOR C
                RRCA
                LD B, A
                LD A, E
                JR NC, SubtractY                                                ; переход, если знаки Y одинаковы, нужна разность модулей

                ADC A, L
                JR StoreYSpan

SubtractY:      SUB L
                JR NC, IncludeLastY                                             ; переход, если разность модулей Y неотрицательна

                NEG
IncludeLastY:   ADD A, #01
StoreYSpan:     LD E, A
                ; расчёт горизонтальной протяжённости и её переноса в девятый разряд
                RR B
                LD A, D
                JR NC, SubtractX                                                ; переход, если знаки X одинаковы, нужна разность модулей

                ADC A, H
                JR StoreXSpan

SubtractX:      SUB H
                JR NC, StoreXSpan                                               ; переход, если разность модулей X неотрицательна

                NEG
                AND A
StoreXSpan:     LD D, A
                RR B
                EXX
                ; выбор границы отсечения, сначала ограничение модуля Y
                LD A, E
                OR L
                CP #40
                JR NC, ClipY                                                    ; переход, если хотя бы один модуль Y не меньше 64

                ; проверка модулей X относительно 120 и выбор внешнего конца
                LD A, #78
                CP D
                JR C, ClipX                                                     ; переход, если модуль X конца DE больше 120

                CP H
                JP NC, SortEnds                                                 ; переход, если оба модуля X не больше 120, отсечение завершено

                EX DE, HL
                LD A, B
                LD B, C
                LD C, A
                ; расчёт превышения границы X=119 и отношения приращений Y/X
ClipX:          LD A, D
                SUB #77
                EXX
                PUSH BC
                EX AF, AF'
                LD H, E
                LD L, D
                ; перенос девятых разрядов протяжённостей в аргумент делителя
                RLC B
                RR C
                RLC B
                RR C
                CALL Game.Wireframe.UnscaleClippingRatio.Entry
                EX AF, AF'
                CALL Game.Wireframe.MultiplyClippingDistance.Entry
                POP BC
                EXX
                ; перенос рассчитанного смещения Y к отсечённому концу
                EX AF, AF'
                LD A, B
                XOR C
                RRCA
                JR C, SubtractYClip                                             ; переход, если знаки Y различаются, смещение направлено к оси

                LD A, E
                CP L
                JR NC, SubtractYClip                                            ; переход, если модуль Y конца DE не меньше модуля конца HL

                ; увеличение модуля Y с насыщением при переполнении байта
                EX AF, AF'
                ADD A, E
                JR NC, StoreYClip                                               ; переход, если увеличение модуля Y не переполнило байт

                SBC A, A
                JR StoreYClip

                ; вычитание модуля Y, пересечение оси требует смены его знака
SubtractYClip:  EX AF, AF'
                SUB E
                JR NC, FlipYSign                                                ; переход, если смещение достигло или пересекло ось Y

                NEG
StoreYClip:     LD E, A
                JR ClipXDone

FlipYSign:      LD E, A
                LD A, C
                XOR PROJ_POSY_MASK
                LD C, A
                ; установка X=119 и повторная проверка нового отрезка
ClipXDone:      LD D, #77
                JP ClipAgain

                ; выбор конца, для которого модуль Y не меньше 64
ClipY:          LD A, E
                CP #40
                JR NC, MeasureYClip                                             ; переход, если конец DE уже находится за границей Y

                LD A, B
                LD B, C
                LD C, A
                EX DE, HL
                LD A, E
                ; расчёт превышения границы Y=63 и отношения приращений X/Y
MeasureYClip:   SUB #3F
                EXX
                PUSH BC
                EX AF, AF'
                LD H, D
                LD L, E
                LD C, B
                CALL Game.Wireframe.UnscaleClippingRatio.Entry
                EX AF, AF'
                CALL Game.Wireframe.MultiplyClippingDistance.Entry
                POP BC
                EXX
                ; перенос рассчитанного смещения X к отсечённому концу
                EX AF, AF'
                LD A, B
                XOR C
                AND PROJ_NEGX_MASK
                JR NZ, SubtractXClip                                            ; переход, если знаки X различаются, смещение направлено к оси

                LD A, D
                CP H
                JR NC, SubtractXClip                                            ; переход, если модуль X конца DE не меньше модуля конца HL

                ; увеличение модуля X с насыщением при переполнении байта
                EX AF, AF'
                ADD A, D
                JR NC, StoreXClip                                               ; переход, если увеличение модуля X не переполнило байт

                SBC A, A
                JR StoreXClip

                ; вычитание модуля X с обработкой пересечения вертикальной оси
SubtractXClip:  EX AF, AF'
                SUB D
                JR NC, FlipXSign                                                ; переход, если смещение достигло или пересекло ось X

                NEG
StoreXClip:     LD D, A
                JR ClipYDone

FlipXSign:      LD D, A
                LD A, C
                XOR PROJ_NEGX_MASK
                LD C, A
                ; установка Y=63 и повторная проверка нового отрезка
ClipYDone:      LD E, #3F
                JP ClipAgain

                ; сортировка концов для движения по X слева направо
SortEnds:       LD A, B
                XOR C
                AND PROJ_NEGX_MASK
                JR Z, CompareX                                                  ; переход, если знаки X одинаковы, порядок определяется модулями

                LD A, B
                JR CheckSwap

CompareX:       LD A, D
                CP H
                LD A, B
                JR C, CheckSwap                                                 ; переход, если модуль X конца DE меньше модуля конца HL

                CPL
CheckSwap:      AND PROJ_NEGX_MASK
                JR Z, SetDirection                                              ; переход, если порядок концов уже соответствует движению вправо

                EX DE, HL
                LD A, B
                LD B, C
                LD C, A
                ; выбор шага по строкам, #24 для INC H или #25 для DEC H
SetDirection:   LD A, B
                XOR C
                RRCA
                LD H, #24
                LD B, #00
                JR NC, CompareY                                                 ; переход, если знаки Y одинаковы, направление определяется модулями

                LD A, C
                JR SelectRowStep

CompareY:       LD A, E
                CP L
                LD A, C
                JR NC, SelectRowStep                                            ; переход, если модуль Y конца DE не меньше модуля конца HL

                CPL
SelectRowStep:  RRCA
                JR NC, SaveDirection                                            ; переход, если движение требует INC H и нижней ветви

                INC H
                LD B, #13
                ; сохранение кода шага и смещения ветви перехода между знакоместами
SaveDirection:  LD L, B
                PUSH HL
                ; преобразование знако-модульных координат в y=63±E и x=127±D
PixelAddress:   RR C
                LD A, #3F
                JR C, AddCenterY                                                ; переход, если знак Y конца DE задаёт прибавление к 63

                SUB E
                JR PixelYReady

AddCenterY:     ADD A, E
PixelYReady:    LD B, A
                RR C
                LD A, #7F
                JR C, SubtractPixelX                                            ; переход, если знак X конца DE задаёт вычитание из 127

                ADD A, D
                JR PixelXReady

SubtractPixelX: SUB D
PixelXReady:    LD C, A
                ; преобразование B=y и C=x процедурой ROM, бит 7 переносит адрес в #C000
                LD A, B
                CALL Rom.PixelAddress
                SET 7, H
                LD C, A
                ; расчёт числа строк до ближайшей границы знакоместа
                LD A, H
                AND #07
                INC A
                LD B, A
                EX (SP), HL
                LD A, L
                AND A
                JR NZ, PrepareSlope                                             ; переход, если выбран DEC H, число строк до границы уже вычислено

                LD A, #09
                SUB B
                LD B, A
PrepareSlope:   EX (SP), HL
                ; расчёт наклона X/Y в формате 8.8 для выбора растрового цикла
                EXX
                LD H, D
                LD L, E
                CALL Game.Wireframe.DivideSlopeAndDrawScanner.Entry
                PUSH HL
                EXX
                POP DE
                LD A, D
                AND A
                JR Z, Steep                                                     ; переход, если наклон меньше единицы, нужен одиночный пиксель

                DEC A
                JR NZ, Shallow                                                  ; переход, если целая часть наклона больше единицы

                OR E
                JR NZ, Shallow                                                  ; переход, если наклон больше ровно #0100

                ; подготовка крутого отрезка, один пиксель на строку
Steep:          EXX
                LD A, E
                EXX
                DEC D
                LD D, A
                LD A, E
                JR NZ, PatchSteep                                               ; переход, если наклон меньше единицы, дробь не требует коррекции

                DEC A
                ; запись дробного шага X в операнд ADD A и начальной ошибки #80
PatchSteep:     LD (LineRaster.SteepFraction), A
                LD E, #80
                ; настройка INC H или DEC H и ветви перехода к следующему знакоместу
                EX (SP), HL
                LD A, H
                LD (LineRaster.SteepStep), A
                LD A, L
                LD (LineRaster.SteepRowOffset), A
                POP HL
                ; создание однобитной маски из номера пикселя в байте
                XOR A
                SCF
                INC C
RotateMask:     RRA
                DEC C
                JR NZ, RotateMask                                               ; переход, если маска ещё не дошла до требуемого пикселя

                LD C, A
                ; первый проход поглощает код шага как операнд LD A
                DB #3E
                ; повторные проходы исполняют изменяемую команду INC H или DEC H
SteepOpcode     EQU $                                                           ; код INC H либо DEC H для крутого отрезка
SteepStep:      INC H
                ; наложение одного пикселя текущей операцией OR либо XOR
SteepPixel:     LD A, C
SteepPixelOp    EQU $                                                           ; код OR (HL) либо XOR (HL), наложение одиночного пикселя
                OR (HL)
                LD (HL), A
                DEC D
                RET Z                                                           ; выход, если выведены все строки крутого отрезка

                ; накопление дробного шага, перенос продвигает маску вправо
                LD A, E
SteepFraction   EQU $ + 1                                                       ; дробный шаг X в операнде ADD A для крутого отрезка
                ADD A, #00
                LD E, A
                JR NC, SteepRowJump                                             ; переход, если накопитель ещё не требует шага вправо

                RRC C
                JR NC, SteepRowJump                                             ; переход, если маска остаётся в текущем байте

                INC L
                ; изменяемое смещение 0 или #13 выбирает направление смены знакоместа
SteepRowOffset  EQU $ + 1                                                       ; смещение JR к направлению смены знакоместа крутого отрезка
SteepRowJump:   JR SteepDown

                ; переход к следующей строке, включая границы знакомест и третей экрана
SteepDown:      DJNZ SteepStep

                LD B, #08
                LD A, H
                SUB #07
                LD H, A
                LD A, L
                ADD A, #20
                LD L, A
                JR NC, SteepPixel                                               ; переход, если следующая строка знакомест остаётся в текущей трети

                LD A, H
                ADD A, B
                LD H, A
                JR SteepPixel

                ; переход к предыдущей строке, вход выбирает изменённый JR #B1C6
SteepUp:        DJNZ SteepStep

                LD B, #08
                LD A, H
                ADD A, #07
                LD H, A
                LD A, L
                SUB #20
                LD L, A
                JR NC, SteepPixel                                               ; переход, если предыдущая строка знакомест остаётся в текущей трети

                LD A, H
                SUB B
                LD H, A
                JR SteepPixel

                ; подготовка пологого отрезка, строка содержит горизонтальную группу
Shallow:        LD A, D
                LD (LineRaster.RunLength), A
                LD A, E
                LD (LineRaster.RunFraction), A
                ; настройка шага по строкам и направления перехода через знакоместа
                EX (SP), HL
                LD A, H
                LD (LineRaster.RunStep), A
                LD A, L
                LD (LineRaster.RunRowOffset), A
                POP HL
                EXX
                LD A, E
                EXX
                LD E, A
                ; сохранение IX и выбор страницы #B4 с масками горизонтальных групп
                PUSH IX
                LD IXH, #B4
                LD A, #80
                JR AddRunError
                ; изменяемая команда движения на одну строку
RunOpcode       EQU $                                                           ; код INC H либо DEC H для пологого отрезка
ShallowStep:    INC H
                ; загрузка целой части наклона, накопитель дроби хранится в AF'
RunLength       EQU $ + 1                                                       ; целая часть числа пикселей на строку в операнде LD D
ShallowRow:     LD D, #00
                EX AF, AF'
RunFraction     EQU $ + 1                                                       ; дробная часть числа пикселей на строку в операнде ADD A
AddRunError:    ADD A, #00
                JR NC, GroupReady                                               ; переход, если дробь не добавляет пиксель к длине группы

                INC D
GroupReady:     EX AF, AF'
                ; расчёт номера последнего пикселя для следующей строки
                LD A, C
                ADD A, D
                AND #07
                LD (LineRaster.NextBit), A
                ; расчёт смещения группы масок по номеру первого пикселя
                LD A, C
                RLCA
                RLCA
                RLCA
                LD (LineRaster.MaskOffset), A
                ; выбор маски начального байта с ограничением длины восемью пикселями
                LD A, #08
                CP D
                JR C, SelectRunMask                                             ; переход, если длина группы больше восьми, выбрать предельную маску

                LD A, D
SelectRunMask:  AND #07
                LD IXL, A
MaskOffset      EQU $ + 2                                                       ; смещение IX при выборе маски первого байта группы
                LD A, (IX + MaskByte)
FirstPixelOp    EQU $                                                           ; код OR (HL) либо XOR (HL), наложение первого байта группы
                OR (HL)
                LD (HL), A
                ; проверка остатка горизонтальной группы после первого байта
                LD A, D
                ADD A, C
                SUB #08
                JR Z, NextRunByte                                               ; переход, если группа заканчивается точно на границе байта

                JR C, RowDone                                                   ; переход, если вся группа помещается в текущем байте

                ; вывод полных промежуточных байтов маской #FF
FullBytes:      INC HL
                SUB #08
                JR C, LastByte                                                  ; переход, если остаётся неполный последний байт

                LD D, A
                LD A, #FF
FullPixelOp     EQU $                                                           ; код OR (HL) либо XOR (HL), наложение полного байта группы
                OR (HL)
                LD (HL), A
                LD A, D
                JR FullBytes

                ; вывод неполного последнего байта
LastByte:       AND #07
                JR Z, RowDone                                                   ; переход, если неполного последнего байта нет

                LD IXL, A
                LD A, (IX + MaskByte)
LastPixelOp     EQU $                                                           ; код OR (HL) либо XOR (HL), наложение последнего байта группы
                OR (HL)
                LD (HL), A
                DEC HL
NextRunByte:    INC HL
                ; проверка завершения всех строк и восстановление IX
RowDone:        DEC E
                JR NZ, LoadNextBit                                              ; переход, если остаются строки пологого отрезка

                POP IX
                RET
                ; восстановление начального бита следующей строки из изменяемого операнда
NextBit         EQU $ + 1                                                       ; номер первого пикселя следующей строки в операнде LD C
LoadNextBit:    LD C, #00
RunRowOffset    EQU $ + 1                                                       ; смещение JR к направлению смены знакоместа пологого отрезка
                JR ShallowDown

                ; переход вниз через границу знакоместа для пологого отрезка
ShallowDown:    DJNZ ShallowStep

                LD B, #08
                LD A, H
                SUB #07
                LD H, A
                LD A, L
                ADD A, #20
                LD L, A
                JR NC, ShallowRow                                               ; переход, если следующая строка знакомест остаётся в текущей трети

                LD A, H
                ADD A, B
                LD H, A
                JR ShallowRow

                ; переход вверх через границу знакоместа, вход выбирает JR #B25E
ShallowUp:      DJNZ ShallowStep

                LD B, #08
                LD A, H
                ADD A, #07
                LD H, A
                LD A, L
                SUB #20
                LD L, A
                JR NC, ShallowRow                                               ; переход, если предыдущая строка знакомест остаётся в текущей трети

                LD A, H
                SUB B
                LD H, A
                JR ShallowRow
                ; проверка исходной границы процедуры
                ASSERT $ == #B286
                endmodule
                endmodule
