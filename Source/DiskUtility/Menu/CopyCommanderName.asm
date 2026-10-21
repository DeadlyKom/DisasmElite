; -----------------------------------------
; подстановка текущего имени командира для пустого нового имени
; исходный диапазон #CCB2..#CCBF
; In:
;   State.Name, имя активного командира
; Out:
;   восемь байтов SaveName заполнены именем, SaveName.Extension содержит C
;   BC=0, поток продолжается SaveCommander
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   LDIR копирует ровно 8 байтов, затем записывается расширение #43.
;   В отличие от EditSaveName этот вход оставляет C=0, проверка пустого имени сравнивает с нулём.
; -----------------------------------------
CopyPilotName:  LD HL, State.Name
                LD DE, SaveName
                LD BC, #0008
                LDIR
                LD A, #43
                LD (DE), A
                ; JP SaveCommander, продолжение в SaveNamedCommander.asm
