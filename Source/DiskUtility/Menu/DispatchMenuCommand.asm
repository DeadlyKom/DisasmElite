; -----------------------------------------
; клавиатурный цикл выбора загрузки, сохранения, демонстрации и командира
; исходный диапазон #CB1E..#CB68
; In:
;   каталог DiskBuffer.Catalog, состояние выбора SaveSelection и SavePageStart
; Out:
;   SPACE возвращает A=#20/Z=1
;   1 передаёт управление LoadCommander, 2 EditSaveName, 3 Game.Disk.BlackAttributesAndOverlayState.LoadDemo
; Corrupt:
;   HL, DE, BC, AF, IX
; Note:
;   Выбор подсвечивается через входной C=1, при перемещении подсветка снимается с C=0.
;   S/X перемещают на одну запись, N/M на восемь записей.
;   PreviousSave/NextSave сохраняют B, поэтому DJNZ действительно считает шаги перемещения.
;   Пять исходных NOP между обработкой 2 и 3 сохранены без назначения новых действий.
; -----------------------------------------
MenuInput:      SCF
                CALL PaintSelection
                CALL MenuBeep
                CALL WaitMenuKey
                CP #31
                JP Z, LoadCommander                                             ; переход, если нажата 1 и запрошена загрузка выбранного командира

                CP #32
                JP Z, EditSaveName                                              ; переход, если нажата 2 и запрошен ввод имени сохранения

                NOP
                NOP
                NOP
                NOP
                NOP
                CP #33
                JP Z, @Game.Disk.BlackAttributesAndOverlayState.LoadDemo        ; переход, если нажата 3 и запрошен вход в демонстрацию Game.Disk.BlackAttributesAndOverlayState.LoadDemo

                PUSH AF
                AND A
                CALL PaintSelection
                POP AF
                CP #20
                RET Z                                                           ; выход, если нажат SPACE и меню закрывается

                LD B, #01
                CP #53
                JR Z, MoveBack                                                  ; переход, если нажата S и требуется один шаг назад

                CP #58
                JR Z, MoveForward                                               ; переход, если нажата X и требуется один шаг вперёд

                LD B, #08
                CP #4D
                JR Z, MoveForward                                               ; переход, если нажата M и требуется восемь шагов вперёд

                CP #4E
                JR Z, MoveBack                                                  ; переход, если нажата N и требуется восемь шагов назад

                JR NZ, MenuInput                                                ; переход, если клавиша не соответствует ни одной команде перемещения

MoveBack:       CALL PreviousSave
                DJNZ MoveBack

                JR MenuInput

MoveForward:    CALL NextSave
                DJNZ MoveForward

                JR MenuInput
