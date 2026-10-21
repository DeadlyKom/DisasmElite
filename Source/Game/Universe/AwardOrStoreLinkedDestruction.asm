                module Universe
                module AwardOrStoreLinkedDestruction
; -----------------------------------------
; приращение рейтинга либо сохранение номера участника уничтожения, Game.Universe.AwardOrStoreLinkedDestruction.Entry
; исходный диапазон #7DB5..#7DC4
; In:
;   DE, приращение рейтинга
;   IX, уничтоженный объект
;   ObjectEffects.Current, адрес расширенной записи объекта
; Out:
;   DE, BC и IX сохранены
;   IY, расширенная запись объекта
;   при нулевой младшей тетраде Links рейтинг увеличен через Game.Missions.DispatchRatingAndMissionEnd.Entry
;   при ненулевой ссылке её номер сохранён в Hostility уничтоженного объекта
; Corrupt:
;   HL, AF
; Note:
;   это отдельная операция от денежной выплаты Game.Universe.AwardUnlinkedDestructionBounty.Entry
;   UpdateAllSpaceObjects передаёт половину слова FModel.Rating
;   присваивание Hostility заменяет весь байт, прежние флаги враждебности не сохраняются
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #7DB5
                ; проверка ссылки участника перед начислением или сохранением номера
Entry:          LD IY, (ObjectEffects.Current)
                LD A, (IY+FEffectRecord10.Links)
                AND FX_LINK_MASK
                JP Z, Game.Missions.DispatchRatingAndMissionEnd.Entry           ; переход, если младшая ссылка нулевая и приращение рейтинга относится к игроку

                LD (IX+FSpaceObject.Hostility), A
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #7DC5
                endmodule
                endmodule
