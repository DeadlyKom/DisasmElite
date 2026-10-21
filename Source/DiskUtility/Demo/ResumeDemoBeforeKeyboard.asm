; -----------------------------------------
; Кадровый вызов корутины перед опросом клавиатуры
; исходный диапазон #E6AE..#E6B3
; In:
;   вызов из IM2 вместо Game.Input.ScanKeyboardMatrix.Entry
; Out:
;   один участок демо выполнен, затем обычный опрос Game.Input.ScanKeyboardMatrix.Entry
; Corrupt:
;   HL, DE, BC, AF, IX, IY по корутине
; Note:
;   Подмена операнда Game.Input.KeyboardControlInterrupt.KeyboardCall сохраняет существующий обработчик прерывания и его стек
; -----------------------------------------
                ; возобновление демо завершается уступкой кадра, затем штатно сканируются клавиши
FrameHook:      CALL DemoDispatch
                JP @Game.Input.ScanKeyboardMatrix.Entry
