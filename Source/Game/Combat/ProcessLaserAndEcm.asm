                module Combat
                module ProcessLaserAndEcm
; -----------------------------------------
; вывод прицела, обработка лазерного огня и ECM
; исходный диапазон #B7B4..#B82B
; In:
;   память 711F, состояние гибели
;   память 70E3, направление обзора
;   память D07D..D080, лазеры по направлениям
;   память FC0B, события управления
; Out:
;   прицел и оружие обновлены, расход ECM добавлен в 9CA2
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
; При наличии лазера рисует четыре коротких отрезка прицела и вызывает FireLaser.
; D0B0.7 совместно с режимом D0AF=4 запрещает дальнейшую обработку ECM.
; Бит 4 события клавиатуры снимается после чтения. При неактивном ECM управление передаётся B82C.
; Активный таймер 9C9B уменьшается, при нуле снимается старший бит D085.
; Ставит звук 7128.5 и добавляет единицу расхода энергии при ненулевом коде оборудования.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #B7B4
                ; проверка гибели и полётного вида
Entry:          LD A, (FlightState.PlayerDead)
                AND A
                JR NZ, Game.Combat.ClearLaserDisplayState.Entry                 ; переход, если игрок погиб и поля отображения лазера нужно очистить

                LD A, (FlightState.View)
                CP #04
                ; поиск лазера выбранного направления
                RET NC                                                          ; выход, если текущий экран не относится к видам кабины

                LD HL, State.FrontLaser
                LD D, #00
                LD E, A
                ADD HL, DE
                LD A, (HL)
                AND A
                JR Z, CheckEcmLock                                              ; переход, если в данном направлении лазер отсутствует

                LD HL, #0800
                LD DE, #1000
                LD C, #0A
                PUSH DE
                PUSH HL
                CALL Game.Wireframe.DrawClippedLine.Entry
                POP HL
                POP DE
                LD C, E
                CALL Game.Wireframe.DrawClippedLine.Entry
                LD HL, #0010
                LD DE, #0008
                LD C, D
                PUSH DE
                PUSH HL
                CALL Game.Wireframe.DrawClippedLine.Entry
                POP HL
                POP DE
                LD C, #05
                CALL Game.Wireframe.DrawClippedLine.Entry
                CALL Game.Combat.FirePlayerLaser.Entry
                ; проверка специального ограничения ECM
CheckEcmLock:   LD A, (State.MissionFlags)
                BIT MS_ACCEPT_BIT, A
                JR Z, ReadEcm                                                   ; переход, если специальный запрет D0B0.7 не установлен

                LD A, (State.Mission3)
                CP #04
                RET Z                                                           ; выход, если при установленном запрете действует режим 4

                ; чтение команды ECM и его текущего таймера
ReadEcm:        LD HL, InputState.DeviceKeys
                LD B, (HL)
                RES DEV_ECM_BIT, (HL)
                LD A, (State.ECM)
                LD C, A
                LD A, (CombatState.EcmTimer)
                AND A
                JR Z, Game.Objects.ActivateEnemyECM.Entry                       ; переход, если таймер ECM нулевой и нужно проверить новое включение

                ; уменьшение таймера и отключение по истечении
                DEC A
                LD (CombatState.EcmTimer), A
                JR NZ, EcmCost                                                  ; переход, если таймер ECM ещё не истёк

                RES ECM_ON_BIT, C
                ; звуковой запрос и расход энергии ECM
EcmCost:        LD HL, FlightState.SoundRequests
                SET SND_ECM_BIT, (HL)
                LD A, C
                AND A
                RET Z                                                           ; выход, если код оборудования ECM нулевой и расход не начисляется

                LD (State.ECM), A
                LD A, (CombatState.EnergyDrain)
                INC A
                LD (CombatState.EnergyDrain), A
                RET
                ; проверка исходного конца фрагмента
                ASSERT $ == #B82C
                endmodule
                endmodule
