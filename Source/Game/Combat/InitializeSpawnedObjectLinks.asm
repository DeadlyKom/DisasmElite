                module Combat
                module InitializeSpawnedObjectLinks
; -----------------------------------------
; инициализация дочернего объекта и его расширенных связей
; исходный диапазон #B71C..#B73C
; In:
;   BC, C содержит номер модели
;   IX, выделенный слот
; Out:
;   AF, Z при успешном создании
;   IX, созданный объект
; Corrupt:
;   HL, DE, BC, IY
; Note:
; 7EC8 получает соответствующую расширенную запись, её первый байт временно копируется в B454.
; После штатной инициализации повторно извлекаются метаданные и вызывается 7A9E.
; Стек сохраняет основной слот отдельно от указателя расширенной записи.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #B71C
                ; поиск исходных метаданных и сохранение их контекста
Entry:          PUSH IX
                CALL Game.Universe.GetObjectMetadataAddress.Entry
                LD A, (IX+FSpaceObject.X.Fraction)
                LD (ObjectEffects.Phase), A
                LD A, C
                POP IX
                PUSH IX
                CALL Game.Objects.InitializeObject.Entry
                POP HL
                RET NZ                                                          ; выход, если штатный инициализатор не подтвердил создание объекта

                PUSH HL
                CALL Game.Universe.GetObjectMetadataAddress.Entry
                EX (SP), IX
                POP HL
                CALL Game.Universe.InitializeExtendedObjectMetadata.Entry
                XOR A
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #B73D
                endmodule
                endmodule
