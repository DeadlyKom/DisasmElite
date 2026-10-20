                module Objects
                module SpawnFromObject
; -----------------------------------------
; создание дочернего объекта с копией координат и осей родителя
; исходный диапазон #B91E..#B935
; In:
;   AF - A индекс модели
;   IX - родитель
; Out:
;   при успехе IX новый слот и Z установлен, при неудаче NZ
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   #FACA ищет слот и может изменить тип C для запуска со станции
;   #B71C инициализирует слот и связанную десятибайтовую запись состояния
;   LDIR копирует ровно 27 байт родителя, координаты и три оси, без скорости и флагов
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #B91E
Entry:          LD C, A
                PUSH IX
                CALL Game.Extensions.AllocateVariantObjectSlot.Entry
                POP HL
                RET NZ                                                          ; выход, если свободный слот не найден

                PUSH HL
                LD A, C
                CALL Game.Combat.InitializeSpawnedObjectLinks.Entry
                POP HL
                PUSH IX
                POP DE
                LD BC, #001B
                LDIR
                XOR A
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #B936
                endmodule
                endmodule
