                module Trade
                module GetEquipmentStateAddress
; -----------------------------------------
; Адрес состояния оборудования
; исходный диапазон #EB38..#EB3D
; In:
;   TradeSnapshot.Selection = номер пункта
; Out:
;   HL=State.Mission1+номер, DE=номер
; Corrupt:
;   HL, DE, AF
; Note:
;   Используется линейными диапазонами оборудования, лазеры обрабатываются отдельно
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #EB38
                ; индекс оборудования переводится в поле сериализуемого командира
                ; общие поля миссий и обычного полёта, адрес State.Mission1 служит базой индекса оборудования, состояние миссии не читается
                ; описание в Docs/Manual.md, раздел mission-shared-state
Entry:          LD HL, State.Mission1
                LD A, (TradeSnapshot.Selection)                                 ; далее Game.Trade.AddByteOffsetToHL.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #EB3E
                endmodule
                endmodule
