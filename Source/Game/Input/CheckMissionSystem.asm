                module Input
                module CheckMissionSystem
; -----------------------------------------
; проверка особой системы по координатам и состоянию задания
; исходный диапазон #FCEA..#FD01
; смысловое имя CheckMissionSystem
; In: State.RankState — флаги, State.SystemSeed + FSystemSeed.Y/State.SystemSeed + FSystemSeed.X — координаты системы
; Out: полный путь возвращает Z=1 при Y=#5C,X=#03, ранний выход имеет отдельное условие Z
; Corrupt: HL, DE, BC, AF по контракту Game.Text.CheckMissionRegion.Entry
; Бит 6 State.RankState означает отставку и немедленно возвращает NZ
; Game.Text.CheckMissionRegion.Entry при активном вторжении поглощает #3C как порог, иначе этот байт выполняется как INC A
; LD A,(State.SystemSeed + FSystemSeed.Y) и INC A сохраняют C от геометрической проверки, RET NC использует именно этот перенос
; При раннем C=0 результат Z=1 также возможен для Y=#FF, поскольку INC A обнуляет аккумулятор, X тогда не проверяется
; На полном пути C=1 проверяются Y=#5C и X=#03, оба XOR очищают перенос
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #FCEA
                ; миссия 7+4, проверка запрета после отставки и координат секретной базы
                ; описание в Docs/Manual.md, раздел mission-7-4
                ; проверка отставки, она запрещает поиск секретной базы миссии INVASION
Entry:          LD A, (State.RankState)
                AND RANK_RSV_MASK
                RET NZ                                                          ; выход, если пилот в отставке, поиск секретной базы запрещён

                ; проверка вторжения с встроенным порогом и координаты Y системы
                CALL Game.Text.CheckMissionRegion.Entry
                INC A
                LD A, (State.SystemSeed + FSystemSeed.Y)
                INC A
                RET NC                                                          ; выход, если проверка задания не дала C=1

                XOR #5D
                RET NZ                                                          ; выход, если координата State.SystemSeed + FSystemSeed.Y отличается от #5C

                ; проверка координаты X системы
                LD A, (State.SystemSeed + FSystemSeed.X)
                XOR #03
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #FD02
                endmodule
                endmodule
