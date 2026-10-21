                module Text
                module CheckSavedSystemRegion
; -----------------------------------------
; Проверка области для сохранённого семени планеты
; исходный диапазон #D675..#D679
; In:
;   GalaxyState.SavedSeed + FSystemSeed.Y/GalaxyState.SavedSeed + FSystemSeed.X = координаты, после CALL требуется один встроенный байт
; Out:
;   Результат общего обработчика Game.Text.CheckMissionRegion.CheckGalaxy в HL и CY
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Выбирает координаты сохранённого семени вместо текущей системы, дальнейшая обработка общая с
;   Game.Text.CheckMissionRegion.Entry
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D675
                ; дополнительный вход проверки координат выбранного, а не текущего семени
                ; миссия 7 INVASION, общая геометрия фронта применяется к сохранённому семени выбранной системы
                ; описание в Docs/Manual.md, раздел mission-7-invasion
Entry:          LD HL, GalaxyState.SavedSeed + FSystemSeed.Y
                JR Game.Text.CheckMissionRegion.CheckGalaxy

                ; проверка исходного конца фрагмента
                ASSERT $ == #D67A
                endmodule
                endmodule
