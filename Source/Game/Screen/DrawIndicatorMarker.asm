                module Screen
                module DrawIndicatorMarker
; -----------------------------------------
; настройка общего рисования на отдельный маркер
; In:
;   DE, адрес слова с экранной позицией
;   AF, A содержит величину
; Out:
;   нарисован маркер полосы
; Corrupt:
;   HL, DE, BC, AF, BC'
; Note:
;   меняет непосредственные операнды IndicatorDraw.BodyFill и IndicatorDraw.FullFill на 0 вместо #FF
;   начальная маска IndicatorDraw.BoundaryMask становится 3, затем выполняется общий вход Game.Screen.DrawIndicatorBar.ReadBarAddress
;   это данные самомодифицируемых LD, а не отдельные переменные
; -----------------------------------------
                ; проверка исходного размещения
                ASSERT $ == #8540
                ; настройка пустых полных байтов и маски маркера
Entry:          LD B, A
                XOR A
                LD (IndicatorDraw.BodyFill), A
                LD (IndicatorDraw.FullFill), A
                LD A, #03
                LD (IndicatorDraw.BoundaryMask), A
                JR Game.Screen.DrawIndicatorBar.ReadBarAddress

                ASSERT $ == #854F
                endmodule
                endmodule
