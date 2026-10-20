; -----------------------------------------
; Возобновление сохранённой корутины
; исходный диапазон #E6F3..#E708
; In:
;   E6DE указывает 12 байтов сохранённых регистров и адрес продолжения
; Out:
;   HL, DE, BC, AF, IX, IY восстановлены, SP демо активен
; Corrupt:
;   восстанавливает HL, DE, BC, AF, IX, IY и SP
; Note:
;   До смены стека ReadKeyboard обновляет физическое состояние 4700..4708
;   Изменяемый JP E706 идёт ResumePoint либо ManualControl, RET ResumePoint использует сохранённый адрес
;   CALL YieldToGame
; -----------------------------------------
                ; физические клавиши обновляются до восстановления регистров корутины
ResumeDemo:     CALL ReadKeyboard
                ; стек игры сохраняется поверх его текущих адресов возврата
                LD (SavedStacks), SP
                LD SP, (DemoStack)
                ; восстановление шести пар в обратном порядке относительно YieldToGame
                POP IY
                POP IX
                POP HL
                POP DE
                POP BC
                POP AF
                ; SMC, следующий шаг идёт к RET ResumePoint либо в ManualControl
ResumeJump:     JP ResumePoint
