                module Objects
                module AlternateSpawnAxes
; -----------------------------------------
; чередование двух вариантов изменения ориентации нового объекта
; исходный диапазон #BA27..#BA3E
; In:
;   IX - слот объекта
; Out:
;   SpawnAxis переключён, оси объекта изменены, IX восстановлен
; Corrupt:
;   BC, AF
; Note:
;   вариант 1 трижды меняет компоненты осей X/Y и инвертирует знак оси Z через Game.Objects.RotateSpawnAxisComponent.Entry
;   вариант 0 переходит на Game.Objects.RotateSpawnAxisComponent.RotateAxes и переставляет старшие компоненты X/Y с инверсией знаков
;   меняются старшие байты компонент, младшие байты не переставляются
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #BA27
                ; обновление переключателя двух вариантов ориентации
Entry:          LD A, (SpawnAxis)
                XOR #01
                LD (SpawnAxis), A
                JR Z, @Game.Objects.RotateSpawnAxisComponent.RotateAxes         ; переход, если переключатель ориентации стал нулевым

                PUSH IX
                CALL Game.Objects.RotateSpawnAxisComponent.Entry
                CALL Game.Objects.RotateSpawnAxisComponent.Entry
                CALL Game.Objects.RotateSpawnAxisComponent.Entry
                POP IX
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #BA3F
                endmodule
                endmodule
