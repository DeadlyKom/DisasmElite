                module Flight
                module RebaseSunAgainstStation
; -----------------------------------------
; Перевод трёх координат светила относительно станции
; исходный диапазон #71C0..#71CD
; In:
;   7107 трёхбайтовые координаты,6048 объект станции
; Out:
;   старшие слова трёх координат 7107 изменены, IX=6051,IY=7110
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   Два CALL71CE и проваливание в третий обеспечивают обработку всех трёх осей
; -----------------------------------------
                ASSERT $ == #71C0
                ; перевод трёх координат солнца в систему отсчёта станции
Entry:          LD IY, FlightState.Sun
                LD IX, Memory.Station
                CALL Game.Flight.RebaseCoordinateAxis.Entry
                CALL Game.Flight.RebaseCoordinateAxis.Entry
                ASSERT $ == #71CE
                endmodule
                endmodule
