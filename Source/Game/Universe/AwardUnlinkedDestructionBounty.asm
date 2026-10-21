                module Universe
                module AwardUnlinkedDestructionBounty
; -----------------------------------------
; денежная награда за уничтожение без связанного участника, Game.Universe.AwardUnlinkedDestructionBounty.Entry
; исходный диапазон #7DA4..#7DB4
; In:
;   DE, награда в десятых кредита, штатный диапазон 0..9999
;   IY, указатель модели, сохраняется
;   ObjectEffects.Current, адрес расширенной записи уничтоженного объекта
; Out:
;   при нулевой младшей тетраде Links сумма поступает в денежный счёт
;   рейтинг не изменяется, BC, IX и IY сохранены
; Corrupt:
;   HL, DE, AF
; Note:
;   ненулевая младшая тетрада Links отменяет выплату и сохраняет DE
;   при нулевой сумме событие не создаётся, иначе сумма записывается в FlightMessage.Reward и ставится FlightEvents + 4 * FFlightEvent + FFlightEvent.ColumnFlags.7
;   путь выплаты проходит Game.Missions.DispatchMissionEvents.PayBounty -> Game.Missions.RatingBountyDamageAndNewCommander.PayBounty -> AddCashLow
;   UpdateAllSpaceObjects передаёт сюда FModel.Bounty, отдельный вызов Game.Universe.AwardOrStoreLinkedDestruction.Entry начисляет рейтинг
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #7DA4
                ; проверка принадлежности уничтожения перед денежной выплатой
Entry:          PUSH IY
                LD IY, (ObjectEffects.Current)
                LD A, (IY+FEffectRecord10.Links)
                POP IY
                AND FX_LINK_MASK
                RET NZ                                                          ; выход, если младшая ссылка метаданных ненулевая и денежная награда игроку не начисляется

                JP Game.Missions.DispatchMissionEvents.PayBounty

                ; проверка исходного конца фрагмента
                ASSERT $ == #7DB5
                endmodule
                endmodule
