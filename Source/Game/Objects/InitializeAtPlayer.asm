                module Objects
                module InitializeAtPlayer
; -----------------------------------------
; инициализация выбранного слота около игрока с эффектами версии
; исходный диапазон #B950..#B96A
; In:
;   AF - A индекс модели
;   IX - выделенный слот
; Out:
;   AF - A=0 и Z=1
;   IX - инициализированный слот
; Corrupt:
;   HL, DE, BC, AF, IY
; Note:
;   #5EC5 вызывает #B898 и также меняет боезапас/груз или подменяет модель по оборудованию
;   RES7 у IX+0E и IX+16 разворачивает два компонента ориентации
;   обнуляются X дробный/целый, Y целый и Z дробный/целый, остальные компоненты задаёт инициализатор
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #B950
Entry:          CALL Game.Extensions.CreateMissileOrMissionCraft.Entry
                RES 7, (IX+FSpaceObject.AxisX.Z+FSignWord.SignHigh)
                RES 7, (IX+FSpaceObject.AxisZ.X+FSignWord.SignHigh)
                LD (IX+FSpaceObject.X.Fraction), A
                LD (IX+FSpaceObject.X.Low), A
                LD (IX+FSpaceObject.Y.Low), A
                LD (IX+FSpaceObject.Z.Fraction), A
                LD (IX+FSpaceObject.Z.Low), A
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #B96B
                endmodule
                endmodule
