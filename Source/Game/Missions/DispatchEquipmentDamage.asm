                module Missions
                module DispatchEquipmentDamage
; -----------------------------------------
; совместимый вход повреждения топлива, устройства либо единицы груза, Game.Missions.DispatchEquipmentDamage.Entry
; исходный диапазон #D0F3..#D0F5
; In:
;   код текущего сообщения FlightMessage.Token и сохранённый полётный параметр FlightState.RandomByte
; Out:
;   выбранное состояние повреждено либо сохранено при запрещающей проверке
;   обычный груз освобождает одну тонну, повреждение устройства обновляет цвета приборов
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   индекс получается как FlightState.RandomByte >> 2, генератор случайных чисел здесь не вызывается
;   точные категории и коды сообщений описаны у DamageItem
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D0F3
Entry:          JP Game.Missions.RatingBountyDamageAndNewCommander.DamageItem

                ; проверка исходного конца фрагмента
                ASSERT $ == #D0F6
                endmodule
                endmodule
