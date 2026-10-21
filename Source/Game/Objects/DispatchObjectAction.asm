                module Objects
                module DispatchObjectAction
; -----------------------------------------
; передача упакованной команды объекта обработчику Game.Disk.DrawScreenStripsAndPrivateStack.DrawStrips
; исходный диапазон #B867..#B869
; In:
;   AF - младшая тетрада A код действия, старшая параметр
;   IX - исходный объект
; Out:
;   результат выбранного обработчика, NZ может означать отсутствие свободного слота
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   обёртка Game.Disk.DrawScreenStripsAndPrivateStack.DrawStrips сохраняет SP в ScreenStack, использует стек Memory.Screen + #0020 и вызывает Game.Objects.SelectObjectAction.Entry при DI
;   сам этот трёхбайтовый вход содержит только JP, собственных локальных данных нет
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #B867
Entry:          JP @Game.Disk.DrawScreenStripsAndPrivateStack.DrawStrips

                ; проверка исходного конца фрагмента
                ASSERT $ == #B86A
                endmodule
                endmodule
