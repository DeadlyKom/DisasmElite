; -----------------------------------------
; Три шаблона подмены прямого ввода и проверки объекта
; исходный диапазон #C8CA..#C8D5
; In:
;   InstallDemo, три последовательных LDIR начиная с InputPatches
; Out:
;   Game.Extensions.CreateMissileOrMissionCraft.DirectKeyRead читает Keyboard.RowASDFG, Game.Universe.ApplyEnhancedFlightControl.DirectKeyRead читает Keyboard.RowEnterLKJH с CPL, Game.Combat.UpdateAllSpaceObjects.EnergyRead читает энергию (IX + FSpaceObject.Energy)
; Corrupt:
;   AF у перенесённых фрагментов
; Note:
;   Первые 5 байтов читают Keyboard.RowASDFG и дополняются двумя NOP
;   следующие 4 читают Keyboard.RowEnterLKJH и инвертируют строку командой CPL
;   последние 3 читают (IX + FSpaceObject.Energy) вместо вызова чтения объекта
;   Шаблоны являются данными установщика, исходный поток их не исполняет
; -----------------------------------------
InputPatches    DB #3A, #01, #47, #00, #00, #3A, #06, #47                       ; данные #C8CA..#C8D1
                DB #2F, #DD, #7E, #22                                           ; данные #C8D2..#C8D5
