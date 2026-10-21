                module Flight
                module RebaseSunAgainstStation
; -----------------------------------------
; Перевод трёх координат светила относительно станции
; исходный диапазон #71C0..#71CD
; In:
;   FlightState.Sun трёхбайтовые координаты,Memory.Station объект станции
; Out:
;   старшие слова трёх координат FlightState.Sun изменены, IX=Memory.Station + FSpaceObject.AxisX,IY=FlightState.Planet
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   Два CALL Game.Flight.RebaseCoordinateAxis.Entry и проваливание в третий обеспечивают обработку всех трёх осей
; -----------------------------------------
                ASSERT $ == #71C0
                ; перевод трёх координат солнца в систему отсчёта станции
Entry:          LD IY, FlightState.Sun
                LD IX, Memory.Station
                CALL Game.Flight.RebaseCoordinateAxis.Entry
                CALL Game.Flight.RebaseCoordinateAxis.Entry                     ; далее Game.Flight.RebaseCoordinateAxis.Entry без команды перехода
                ASSERT $ == #71CE
                endmodule
                endmodule
