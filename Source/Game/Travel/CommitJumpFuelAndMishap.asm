                module Travel
                module CommitJumpFuelAndMishap
; -----------------------------------------
; Списание топлива и выбор обычного выхода либо межзвёздной встречи
; исходный диапазон #DC8E..#DCE8
; In:
;   DEF6 = расстояние в десятых, D082 = топливо
; Out:
;   Топливо уменьшено, legalstatus поделён на 2, переход в DCE9 либо DE4C
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Ненулевой D081 перенаправляет в отмену миссии DC4E, клавишный бит 6 FC0E либо случайное F9
;   вызывает межзвёздное пространство, координаты текущей и целевой систем заменяются
;   полусуммой, имена очищаются
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DC8E
                ; списание топлива и изменение правового статуса при обычном переходе
Entry:          LD A, (State.Mission1)
                AND A
                JR NZ, @Game.Travel.TickJumpCountdown.ClearMissions             ; переход, если первая миссия активна, использовать специальную обработку перехода

                LD A, (GalaxyState.Distance)
                LD B, A
                LD A, (State.Fuel)
                SUB B
                LD C, A
                CALL Game.Travel.SetFuelAndGauge.Entry
                LD A, #46
                SUB C
                LD B, A
                LD A, (GalaxyState.Economy)
                SLA A
                ADD A, B
                NOP
                NOP
                NOP
                LD HL, State.LegalStatus
                SRL (HL)
                LD A, (InputState.Config)
                BIT INPUT_MJ_BIT, A
                JR NZ, Witchspace                                               ; переход, если установлен бит 6 настройки, принудительно выбрать межзвёздный выход

                CALL Game.Circles.SelectJumpAndContinueLeftFill.Entry
                CP #F9
                JR NZ, Game.Travel.EnterTargetSystem.Entry                      ; переход, если случайный байт не равен F9, завершить обычный выход у системы

Witchspace:     INC A
                LD (FlightState.SpaceMode), A
                LD HL, State.SystemSeed + FSystemSeed.X
                LD DE, TargetX
                LD A, (DE)
                ADD A, (HL)
; вариант исполнения #DCCC, RR A
; вариант исполнения #DCCD, RRA
                DB #CB, #1F                                                     ; перекрывающиеся команды, байты сохранены буквально
                LD (HL), A
                LD (DE), A
                LD HL, State.SystemSeed + FSystemSeed.Y
                LD DE, TargetY
                LD A, (DE)
                ADD A, (HL)
                RR A
                LD (HL), A
                LD (DE), A
                XOR A
                LD (FlightState.StationZone), A
                LD (GalaxyState.CurrentName), A
                LD (GalaxyState.TargetName), A
                JP @Game.Travel.LaserTypeAndArrivalEvents.FinishArrival
                ; проверка исходного конца фрагмента
                ASSERT $ == #DCE9
                endmodule
                endmodule
