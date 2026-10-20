                module Extensions
                module SetAggressionThenContinue
; -----------------------------------------
; установка поведения с продолжением основного обновления
; исходный диапазон #F9E1..#F9E6
; смысловое имя SetAggressionThenContinue
; In: IX — объект и режим окружения для #F9C9
; Out: после обновления битов выполняется #7D64
; Corrupt: AF и регистры продолжения #7D64
; CALL/JP образуют обёртку без дополнительного возврата наружу
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #F9E1
                ; применение расширенного правила поведения перед общим продолжением
Entry:          CALL Game.Extensions.SetObjectAggressionFlag.Entry
                JP Game.Universe.DispatchLinkedObjectAction.LaserHitLinks
                ; проверка исходного конца фрагмента
                ASSERT $ == #F9E7
                endmodule
                endmodule
