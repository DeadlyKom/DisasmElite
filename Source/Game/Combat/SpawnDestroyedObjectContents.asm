                module Combat
                module SpawnDestroyedObjectContents
; -----------------------------------------
; совместимый вход создания содержимого уничтоженного объекта
; исходный диапазон #B70F..#B711
; In:
;   IX, объект
;   IY, модель
; Out:
;   созданы допустимые обломки, груз или специальные объекты
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
; Хвостовой переход в расширенный обработчик Game.Universe.SpawnDestructionContentsAndEffects.Entry.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #B70F
                ; переход к выбору содержимого уничтоженного объекта
Entry:          JP Game.Universe.SpawnDestructionContentsAndEffects.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #B712
                endmodule
                endmodule
