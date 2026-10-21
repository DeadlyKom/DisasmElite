                module Travel
                module CommitJumpFuelAndMishap
; -----------------------------------------
; Списание топлива и выбор обычного выхода либо межзвёздной встречи
; исходный диапазон #DC8E..#DCE8
; In:
;   GalaxyState.Distance = расстояние в десятых, State.Fuel = топливо
; Out:
;   Топливо уменьшено, legalstatus поделён на 2, переход в Game.Travel.EnterTargetSystem.Entry либо Game.Travel.LaserTypeAndArrivalEvents.FinishArrival
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Ненулевой State.Mission1 перенаправляет в отмену миссии Game.Travel.TickJumpCountdown.ClearMissions, клавишный бит 6 InputState.Config либо случайное F9
;   вызывает межзвёздное пространство, координаты текущей и целевой систем заменяются
;   полусуммой, имена очищаются
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #DC8E
                ; списание топлива и изменение правового статуса при обычном переходе
                ; миссия 1, беженцы, активная первая миссия направляет переход в общий сброс заданий
                ; описание в Docs/Manual.md, раздел mission-1
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
; обычный путь Witchspace исполняет всю команду RR A
; перекрывающий вход на втором байте RR A исполняет RRA
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
