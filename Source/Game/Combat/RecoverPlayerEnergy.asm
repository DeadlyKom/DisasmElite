                module Combat
                module RecoverPlayerEnergy
; -----------------------------------------
; восстановление энергии с учётом установленного энергоблока
; исходный диапазон #9ADB..#9AE1
; In:
;   память State.EnergyUnit, код энергоблока
; Out:
;   энергия и щиты восстановлены общим обработчиком
; Corrupt:
;   HL, DE, BC, AF
; Note:
; При State.EnergyUnit=0 выполняется один проход через последующий Game.Combat.RecoverOneEnergyUnit.Entry.
; При ненулевом State.EnergyUnit процедура Game.Screen.RepeatEnergyRecovery.Entry делает 256-State.EnergyUnit проходов и возвращает сюда для ещё одного.
; Кодировка улучшенного блока использует переполнение восьмибитного счётчика.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9ADB
                ; проверка энергоблока перед дополнительным восстановлением
Entry:          LD A, (State.EnergyUnit)
                AND A
                CALL NZ, Game.Screen.RepeatEnergyRecovery.Entry                 ; вызов процедуры, если установлен ненулевой код энергоблока и нужны дополнительные проходы, далее Game.Combat.RecoverOneEnergyUnit.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #9AE2
                endmodule
                endmodule
