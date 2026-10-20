                module Charts
                module MapCursorTransformAndKeys
; -----------------------------------------
; Преобразование координат малого курсора и обработчики его движения
; исходный диапазон #E46F..#E52D
; In:
;   D0BB/D0BC = координаты цели, D099/D097 = текущая система, E52B = размер
; Out:
;   D051/D052 = экранные координаты, курсор инвертирован если видим
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   На общей карте X=цель X, Y=цель Y/2+24, на местной X=97+4*dx, Y=96+2*dy с отсечением
;   переполнений и Y вне 25..166, E4D4/E4E6 меняют Y на 2, E4F9/E509 меняют X на 1, E51A
;   возвращает координаты текущей системы, E52B..E52D параметры размера и границ
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #E46F
                ; малый крест карты стирается или рисуется тем же XOR-путём
Entry:          LD A, (MapViewport.CrosshairSize)
                CP #0A
                JR Z, GalacticMap                                               ; переход, если ширина режима равна 10, использовать координаты общей карты

                ; местная карта масштабирует горизонтальное смещение в четыре, вертикальное в два раза
                LD A, (State.SystemSeed + FSystemSeed.X)
                LD B, A
                LD A, (TargetX)
                SUB B
                JR C, LeftOfSystem                                              ; переход, если курсор левее текущей системы, вычислить отрицательное смещение X

                ADD A, A
                RET C                                                           ; выход, если первое удвоение смещения X переполнилось, курсор вне местной карты

                ADD A, A
                RET C                                                           ; выход, если второе удвоение смещения X переполнилось, курсор вне местной карты

                LD B, A
                LD A, #61
                ADD A, B
                RET C                                                           ; выход, если правая экранная координата X переполнила байт, курсор невидим

                JR StoreScreenX

LeftOfSystem:   NEG
                ADD A, A
                RET C                                                           ; выход, если первое удвоение левого смещения X переполнилось, курсор невидим

                ADD A, A
                RET C                                                           ; выход, если второе удвоение левого смещения X переполнилось, курсор невидим

                LD B, A
                LD A, #61
                SUB B
                RET C                                                           ; выход, если левая экранная координата X вышла за ноль, курсор невидим

StoreScreenX:   LD (MapCircleX), A
                LD A, (State.SystemSeed + FSystemSeed.Y)
                LD B, A
                LD A, (TargetY)
                SUB B
                JR C, AboveSystem                                               ; переход, если курсор выше текущей системы, вычислить отрицательное смещение Y

                ADD A, A
                RET C                                                           ; выход, если удвоение нижнего смещения Y переполнилось, курсор невидим

                LD B, A
                LD A, #60
                ADD A, B
                RET C                                                           ; выход, если нижняя экранная координата Y переполнила байт, курсор невидим

                JR ClipScreenY

AboveSystem:    NEG
                SLA A
                RET C                                                           ; выход, если удвоение верхнего смещения Y переполнилось, курсор невидим

                LD B, A
                LD A, #60
                SUB B
                RET C                                                           ; выход, если верхняя экранная координата Y вышла за ноль, курсор невидим

ClipScreenY:    CP #19
                RET C                                                           ; выход, если экранная координата Y меньше 25, курсор выше окна карты

                CP #A7
                RET NC                                                          ; выход, если экранная координата Y не меньше 167, курсор ниже окна карты

                LD (MapCircleY), A
                JR DrawCrosshair

                ; общая карта преобразует галактические координаты непосредственно в экранные
GalacticMap:    LD A, (TargetX)
                LD (MapCircleX), A
                LD A, (TargetY)
                SRL A
                ADD A, #18
                LD (MapCircleY), A
DrawCrosshair:  JP Game.Charts.XorMapCrosshair.Entry

                ; обработчики перемещения курсора карты и возврата к текущей системе
CursorUp:       CALL Entry
                LD A, (TargetY)
                DEC A
                DEC A
                CP #FE
                JR C, StoreUp                                                   ; переход, если уменьшение Y на 2 не завернулось в FE или FF, сохранить результат

                XOR A
StoreUp:        LD (TargetY), A
                JR RedrawCursor

CursorDown:     CALL Entry
                LD A, (TargetY)
                INC A
                INC A
                CP #02
                JR NC, StoreDown                                                ; переход, если увеличение Y на 2 не завернулось в 0 или 1, сохранить результат

                LD A, #FF
StoreDown:      LD (TargetY), A
                JR RedrawCursor

CursorLeft:     CALL Entry
                LD A, (TargetX)
                DEC A
                JR NZ, StoreLeft                                                ; переход, если уменьшенный X не равен нулю, дополнительное ограничение не нужно

                INC A
StoreLeft:      LD (TargetX), A
RedrawCursor:   JP Entry

CursorRight:    CALL Entry
                LD A, (TargetX)
                INC A
                CP #FF
                JR NZ, StoreRight                                               ; переход, если увеличенный X не равен FF, дополнительное ограничение не нужно

                DEC A
StoreRight:     LD (TargetX), A
                JR RedrawCursor

CurrentSystem:  CALL Entry
                LD A, (State.SystemSeed + FSystemSeed.X)
                LD (TargetX), A
                LD A, (State.SystemSeed + FSystemSeed.Y)
                LD (TargetY), A
                JR RedrawCursor
                ; ширина перекрестия, 10 для общей карты
CrosshairSize   DB #10                                                          ; полуширина перекрестия карты в пикселях
                ; верхняя граница области карты
Top             DB #18                                                          ; верхняя строка области карты
                ; нижняя граница области карты
Bottom          DB #A7                                                          ; нижняя строка области карты
                ; проверка исходного конца фрагмента
                ASSERT $ == #E52E
                endmodule
                endmodule
