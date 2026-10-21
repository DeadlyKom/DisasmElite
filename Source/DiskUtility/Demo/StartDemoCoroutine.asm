; -----------------------------------------
; Первый запуск корутины на отдельном стеке
; исходный диапазон #E6E3..#E6F2
; In:
;   SP стека игры
; Out:
;   DiskUtility.Demo.SavedStacks сохранён, SP=DiskUtility.Demo.StackTop, переход InitScenario
; Corrupt:
;   HL, SP
; Note:
;   Начальное направление JP меняется на ResumeDemo до переключения стека
; -----------------------------------------
                ; выбор следующего пути возобновления до переключения стека
StartCoroutine: LD HL, ResumeDemo
                LD (DemoDispatch+1), HL
                ; сохранение стека игрового обработчика и создание стека демо вниз от DiskUtility.Demo.StackTop
                LD (SavedStacks), SP
                LD SP, StackTop
                JP InitScenario
