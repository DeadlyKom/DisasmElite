                module Circles
                module ApplyCircleViewportPatches
; -----------------------------------------
; применение байтовой таблицы патчей окружности
; исходный диапазон #8E77..#8F0C
; смысловое имя ApplyCircleViewportPatches
; In: HL — значения патчей, (CircleState.PatchCount) — количество, обычно 32, прерывания заранее запрещены
; Out: байты распределены по адресам таблицы CircleViewport.Addresses, SP восстановлен, EI выполнен
; Corrupt: HL, DE, BC, AF, CircleState.SavedSP/CircleState.SavedSP + 1
; SP временно читает список адресов через POP DE, LDI копирует по одному байту
; BC не задаёт число копирований и лишь уменьшается побочным эффектом LDI, цикл считает A
; CircleViewport содержит 32 значения для карты, CircleViewport.Flight, 32 значения для области обзора
; CircleViewport.Addresses содержит 32 слова адресов изменяемых операндов и команд, все адреса исходные
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #8E77
                ; сохранение SP и чтение таблицы адресов через временный стек
Entry:          LD (CircleState.SavedSP), SP
                LD A, (CircleState.PatchCount)
                LD SP, CircleViewport.Addresses
                ; копирование одного байта патча по очередному абсолютному адресу
ApplyByte:      POP DE
                LDI
                DEC A
                JR NZ, ApplyByte                                                ; переход, если остались неприменённые байты таблицы патчей

                ; восстановление реального стека и разрешение прерываний
                LD SP, (CircleState.SavedSP)
                EI
                RET

                ; патч 0, карта, значение #60 записывается по Game.Circles.DispatchClippedCircle.Entry + #0D
ChartValues     DB #60                                                          ; 32 значения патчей полного экрана карты
                ; патч 1, карта, значение #60 записывается по Game.Circles.DispatchClippedCircle.FinishCenterX + #06
                DB #60                                                          ; данные #8E8E..#8E8E
                ; патч 2, карта, значение #80 записывается по Game.Circles.DispatchClippedCircle.FinishCenterX + #0C
                DB #80                                                          ; данные #8E8F..#8E8F
                ; патч 3, карта, значение #80 записывается по Game.Circles.DispatchClippedCircle.InnerCenter + #05
                DB #80                                                          ; данные #8E90..#8E90
                ; патч 4, карта, значение #80 записывается по Game.Circles.DispatchClippedCircle.CheckHalfWidth + #05
                DB #80                                                          ; данные #8E91..#8E91
                ; патч 5, карта, значение #80 записывается по Game.Circles.DrawWideCircleAcrossBothSides.FarSideLimit + #01
                DB #80                                                          ; данные #8E92..#8E92
                ; патч 6, карта, значение #80 записывается по Game.Circles.DrawWideCircleAcrossBothSides.SaveFarLimit + #02
                DB #80                                                          ; данные #8E93..#8E93
                ; патч 7, карта, значение #7F записывается по Game.Circles.DrawOneSideClippedCircle.SideLimit + #02
                DB #7F                                                          ; данные #8E94..#8E94
                ; патч 8, карта, значение #1F записывается по Game.Circles.SetRightContourBoundary.Entry + #04
                DB #1F                                                          ; данные #8E95..#8E95
                ; патч 9, карта, значение #00 записывается по Game.Circles.PrepareLeftClippedCircle.Entry + #12
                DB #00                                                          ; данные #8E96..#8E96
                ; патч 10, карта, значение #00 записывается поCircleRaster
                DB #00                                                          ; данные #8E97..#8E97
                ; патч 11, карта, значение #00 записывается по CircleRaster.LeftBuffer + 1
                DB #00                                                          ; данные #8E98..#8E98
                ; патч 12, карта, значение #00 записывается по CircleRaster.RightBuffer
                DB #00                                                          ; данные #8E99..#8E99
                ; патч 13, карта, значение #00 записывается по CircleRaster.RightBuffer + 1
                DB #00                                                          ; данные #8E9A..#8E9A
                ; патч 14, карта, значение #80 записывается по Game.Circles.PrepareBothClippedCoordinates.Entry + #05
                DB #80                                                          ; данные #8E9B..#8E9B
                ; патч 15, карта, значение #00 записывается по Game.Circles.SetBothContourBoundaries.Entry + #04
                DB #00                                                          ; данные #8E9C..#8E9C
                ; патч 16, карта, значение #FF записывается по Game.Circles.SkipViewportRowsUp.Entry + #04
                DB #FF                                                          ; данные #8E9D..#8E9D
                ; патч 17, карта, значение #00 записывается по Game.Circles.SkipViewportRowsUp.Entry + #08
                DB #00                                                          ; данные #8E9E..#8E9E
                ; патч 18, карта, значение #00 записывается по Game.Circles.SkipViewportRowsUp.Entry + #09
                DB #00                                                          ; данные #8E9F..#8E9F
                ; патч 19, карта, значение #28 записывается по Game.Circles.SkipViewportRowsUp.CheckTop + #02
                DB #28                                                          ; данные #8EA0..#8EA0
                ; патч 20, карта, значение #FF записывается по Game.Circles.SkipRowsDownAndDrawCircleContours.Entry + #04
                DB #FF                                                          ; данные #8EA1..#8EA1
                ; патч 21, карта, значение #00 записывается по Game.Circles.SkipRowsDownAndDrawCircleContours.Entry + #08
                DB #00                                                          ; данные #8EA2..#8EA2
                ; патч 22, карта, значение #00 записывается по Game.Circles.SkipRowsDownAndDrawCircleContours.Entry + #09
                DB #00                                                          ; данные #8EA3..#8EA3
                ; патч 23, карта, значение #58 записывается по Game.Circles.SkipRowsDownAndDrawCircleContours.CheckSkipLimit + #02
                DB #58                                                          ; данные #8EA4..#8EA4
                ; патч 24, карта, значение #57 записывается по Game.Circles.SkipRowsDownAndDrawCircleContours.RightCutBottom + #01
                DB #57                                                          ; данные #8EA5..#8EA5
                ; патч 25, карта, значение #3F записывается по Game.Circles.SkipRowsDownAndDrawCircleContours.RightCutArc + #0E
                DB #3F                                                          ; данные #8EA6..#8EA6
                ; патч 26, карта, значение #3F записывается по Game.Circles.SkipRowsDownAndDrawCircleContours.BothArc + #0B
                DB #3F                                                          ; данные #8EA7..#8EA7
                ; патч 27, карта, значение #57 записывается по Game.Circles.SkipRowsDownAndDrawCircleContours.BothArcBottom + #01
                DB #57                                                          ; данные #8EA8..#8EA8
                ; патч 28, карта, значение #57 записывается по Game.Circles.SkipRowsDownAndDrawCircleContours.LeftCutBottom + #01
                DB #57                                                          ; данные #8EA9..#8EA9
                ; патч 29, карта, значение #3F записывается по Game.Circles.SkipRowsDownAndDrawCircleContours.LeftCutArc + #0E
                DB #3F                                                          ; данные #8EAA..#8EAA
                ; патч 30, карта, значение #58 записывается по CircleRaster.NextRow
                DB #58                                                          ; данные #8EAB..#8EAB
                ; патч 31, карта, значение #3F записывается по CircleRaster.PreviousRow
                DB #3F                                                          ; данные #8EAC..#8EAC
                ; патч 0, обзор, значение #40 записывается по Game.Circles.DispatchClippedCircle.Entry + #0D
FlightValues    DB #40                                                          ; 32 значения патчей области обзора
                ; патч 1, обзор, значение #40 записывается по Game.Circles.DispatchClippedCircle.FinishCenterX + #06
                DB #40                                                          ; данные #8EAE..#8EAE
                ; патч 2, обзор, значение #78 записывается по Game.Circles.DispatchClippedCircle.FinishCenterX + #0C
                DB #78                                                          ; данные #8EAF..#8EAF
                ; патч 3, обзор, значение #78 записывается по Game.Circles.DispatchClippedCircle.InnerCenter + #05
                DB #78                                                          ; данные #8EB0..#8EB0
                ; патч 4, обзор, значение #78 записывается по Game.Circles.DispatchClippedCircle.CheckHalfWidth + #05
                DB #78                                                          ; данные #8EB1..#8EB1
                ; патч 5, обзор, значение #88 записывается по Game.Circles.DrawWideCircleAcrossBothSides.FarSideLimit + #01
                DB #88                                                          ; данные #8EB2..#8EB2
                ; патч 6, обзор, значение #78 записывается по Game.Circles.DrawWideCircleAcrossBothSides.SaveFarLimit + #02
                DB #78                                                          ; данные #8EB3..#8EB3
                ; патч 7, обзор, значение #77 записывается по Game.Circles.DrawOneSideClippedCircle.SideLimit + #02
                DB #77                                                          ; данные #8EB4..#8EB4
                ; патч 8, обзор, значение #1E записывается по Game.Circles.SetRightContourBoundary.Entry + #04
                DB #1E                                                          ; данные #8EB5..#8EB5
                ; патч 9, обзор, значение #01 записывается по Game.Circles.PrepareLeftClippedCircle.Entry + #12
                DB #01                                                          ; данные #8EB6..#8EB6
                ; патч 10, обзор, значение #CB записывается поCircleRaster
                DB #CB                                                          ; данные #8EB7..#8EB7
                ; патч 11, обзор, значение #FC записывается по CircleRaster.LeftBuffer + 1
                DB #FC                                                          ; данные #8EB8..#8EB8
                ; патч 12, обзор, значение #CB записывается по CircleRaster.RightBuffer
                DB #CB                                                          ; данные #8EB9..#8EB9
                ; патч 13, обзор, значение #FC записывается по CircleRaster.RightBuffer + 1
                DB #FC                                                          ; данные #8EBA..#8EBA
                ; патч 14, обзор, значение #88 записывается по Game.Circles.PrepareBothClippedCoordinates.Entry + #05
                DB #88                                                          ; данные #8EBB..#8EBB
                ; патч 15, обзор, значение #01 записывается по Game.Circles.SetBothContourBoundaries.Entry + #04
                DB #01                                                          ; данные #8EBC..#8EBC
                ; патч 16, обзор, значение #F7 записывается по Game.Circles.SkipViewportRowsUp.Entry + #04
                DB #F7                                                          ; данные #8EBD..#8EBD
                ; патч 17, обзор, значение #CB записывается по Game.Circles.SkipViewportRowsUp.Entry + #08
                DB #CB                                                          ; данные #8EBE..#8EBE
                ; патч 18, обзор, значение #FC записывается по Game.Circles.SkipViewportRowsUp.Entry + #09
                DB #FC                                                          ; данные #8EBF..#8EBF
                ; патч 19, обзор, значение #C0 записывается по Game.Circles.SkipViewportRowsUp.CheckTop + #02
                DB #C0                                                          ; данные #8EC0..#8EC0
                ; патч 20, обзор, значение #F7 записывается по Game.Circles.SkipRowsDownAndDrawCircleContours.Entry + #04
                DB #F7                                                          ; данные #8EC1..#8EC1
                ; патч 21, обзор, значение #CB записывается по Game.Circles.SkipRowsDownAndDrawCircleContours.Entry + #08
                DB #CB                                                          ; данные #8EC2..#8EC2
                ; патч 22, обзор, значение #FC записывается по Game.Circles.SkipRowsDownAndDrawCircleContours.Entry + #09
                DB #FC                                                          ; данные #8EC3..#8EC3
                ; патч 23, обзор, значение #D0 записывается по Game.Circles.SkipRowsDownAndDrawCircleContours.CheckSkipLimit + #02
                DB #D0                                                          ; данные #8EC4..#8EC4
                ; патч 24, обзор, значение #CF записывается по Game.Circles.SkipRowsDownAndDrawCircleContours.RightCutBottom + #01
                DB #CF                                                          ; данные #8EC5..#8EC5
                ; патч 25, обзор, значение #BF записывается по Game.Circles.SkipRowsDownAndDrawCircleContours.RightCutArc + #0E
                DB #BF                                                          ; данные #8EC6..#8EC6
                ; патч 26, обзор, значение #BF записывается по Game.Circles.SkipRowsDownAndDrawCircleContours.BothArc + #0B
                DB #BF                                                          ; данные #8EC7..#8EC7
                ; патч 27, обзор, значение #CF записывается по Game.Circles.SkipRowsDownAndDrawCircleContours.BothArcBottom + #01
                DB #CF                                                          ; данные #8EC8..#8EC8
                ; патч 28, обзор, значение #CF записывается по Game.Circles.SkipRowsDownAndDrawCircleContours.LeftCutBottom + #01
                DB #CF                                                          ; данные #8EC9..#8EC9
                ; патч 29, обзор, значение #BF записывается по Game.Circles.SkipRowsDownAndDrawCircleContours.LeftCutArc + #0E
                DB #BF                                                          ; данные #8ECA..#8ECA
                ; патч 30, обзор, значение #D0 записывается по CircleRaster.NextRow
                DB #D0                                                          ; данные #8ECB..#8ECB
                ; патч 31, обзор, значение #BF записывается по CircleRaster.PreviousRow
                DB #BF                                                          ; данные #8ECC..#8ECC
                ; адрес патча 0, Game.Circles.DispatchClippedCircle.Entry + #0D, карта #60, обзор #40
PatchAddresses  DB #FB, #86                                                     ; 32 адреса однобайтовых патчей
                ; адрес патча 1, Game.Circles.DispatchClippedCircle.FinishCenterX + #06, карта #60, обзор #40
                DB #14, #87                                                     ; данные #8ECF..#8ED0
                ; адрес патча 2, Game.Circles.DispatchClippedCircle.FinishCenterX + #0C, карта #80, обзор #78
                DB #1A, #87                                                     ; данные #8ED1..#8ED2
                ; адрес патча 3, Game.Circles.DispatchClippedCircle.InnerCenter + #05, карта #80, обзор #78
                DB #3B, #87                                                     ; данные #8ED3..#8ED4
                ; адрес патча 4, Game.Circles.DispatchClippedCircle.CheckHalfWidth + #05, карта #80, обзор #78
                DB #44, #87                                                     ; данные #8ED5..#8ED6
                ; адрес патча 5, Game.Circles.DrawWideCircleAcrossBothSides.FarSideLimit + #01, карта #80, обзор #88
                DB #FF, #87                                                     ; данные #8ED7..#8ED8
                ; адрес патча 6, Game.Circles.DrawWideCircleAcrossBothSides.SaveFarLimit + #02, карта #80, обзор #78
                DB #04, #88                                                     ; данные #8ED9..#8EDA
                ; адрес патча 7, Game.Circles.DrawOneSideClippedCircle.SideLimit + #02, карта #7F, обзор #77
                DB #9A, #88                                                     ; данные #8EDB..#8EDC
                ; адрес патча 8, Game.Circles.SetRightContourBoundary.Entry + #04, карта #1F, обзор #1E
                DB #DE, #8F                                                     ; данные #8EDD..#8EDE
                ; адрес патча 9, Game.Circles.PrepareLeftClippedCircle.Entry + #12, карта #00, обзор #01
                DB #B3, #89                                                     ; данные #8EDF..#8EE0
                ; адрес патча 10, CircleRaster, карта #00, обзор #CB
                DB #DA, #89                                                     ; данные #8EE1..#8EE2
                ; адрес патча 11, CircleRaster.LeftBuffer + 1, карта #00, обзор #FC
                DB #DB, #89                                                     ; данные #8EE3..#8EE4
                ; адрес патча 12, CircleRaster.RightBuffer, карта #00, обзор #CB
                DB #FB, #89                                                     ; данные #8EE5..#8EE6
                ; адрес патча 13, CircleRaster.RightBuffer + 1, карта #00, обзор #FC
                DB #FC, #89                                                     ; данные #8EE7..#8EE8
                ; адрес патча 14, Game.Circles.PrepareBothClippedCoordinates.Entry + #05, карта #80, обзор #88
                DB #1B, #8A                                                     ; данные #8EE9..#8EEA
                ; адрес патча 15, Game.Circles.SetBothContourBoundaries.Entry + #04, карта #00, обзор #01
                DB #FD, #8F                                                     ; данные #8EEB..#8EEC
                ; адрес патча 16, Game.Circles.SkipViewportRowsUp.Entry + #04, карта #FF, обзор #F7
                DB #08, #90                                                     ; данные #8EED..#8EEE
                ; адрес патча 17, Game.Circles.SkipViewportRowsUp.Entry + #08, карта #00, обзор #CB
                DB #0C, #90                                                     ; данные #8EEF..#8EF0
                ; адрес патча 18, Game.Circles.SkipViewportRowsUp.Entry + #09, карта #00, обзор #FC
                DB #0D, #90                                                     ; данные #8EF1..#8EF2
                ; адрес патча 19, Game.Circles.SkipViewportRowsUp.CheckTop + #02, карта #28, обзор #C0
                DB #2D, #90                                                     ; данные #8EF3..#8EF4
                ; адрес патча 20, Game.Circles.SkipRowsDownAndDrawCircleContours.Entry + #04, карта #FF, обзор #F7
                DB #36, #90                                                     ; данные #8EF5..#8EF6
                ; адрес патча 21, Game.Circles.SkipRowsDownAndDrawCircleContours.Entry + #08, карта #00, обзор #CB
                DB #3A, #90                                                     ; данные #8EF7..#8EF8
                ; адрес патча 22, Game.Circles.SkipRowsDownAndDrawCircleContours.Entry + #09, карта #00, обзор #FC
                DB #3B, #90                                                     ; данные #8EF9..#8EFA
                ; адрес патча 23, Game.Circles.SkipRowsDownAndDrawCircleContours.CheckSkipLimit + #02, карта #58, обзор #D0
                DB #5B, #90                                                     ; данные #8EFB..#8EFC
                ; адрес патча 24, Game.Circles.SkipRowsDownAndDrawCircleContours.RightCutBottom + #01, карта #57, обзор #CF
                DB #75, #90                                                     ; данные #8EFD..#8EFE
                ; адрес патча 25, Game.Circles.SkipRowsDownAndDrawCircleContours.RightCutArc + #0E, карта #3F, обзор #BF
                DB #6E, #90                                                     ; данные #8EFF..#8F00
                ; адрес патча 26, Game.Circles.SkipRowsDownAndDrawCircleContours.BothArc + #0B, карта #3F, обзор #BF
                DB #06, #91                                                     ; данные #8F01..#8F02
                ; адрес патча 27, Game.Circles.SkipRowsDownAndDrawCircleContours.BothArcBottom + #01, карта #57, обзор #CF
                DB #0D, #91                                                     ; данные #8F03..#8F04
                ; адрес патча 28, Game.Circles.SkipRowsDownAndDrawCircleContours.LeftCutBottom + #01, карта #57, обзор #CF
                DB #09, #92                                                     ; данные #8F05..#8F06
                ; адрес патча 29, Game.Circles.SkipRowsDownAndDrawCircleContours.LeftCutArc + #0E, карта #3F, обзор #BF
                DB #02, #92                                                     ; данные #8F07..#8F08
                ; адрес патча 30, CircleRaster.NextRow, карта #58, обзор #D0
                DB #18, #8E                                                     ; данные #8F09..#8F0A
                ; адрес патча 31, CircleRaster.PreviousRow, карта #3F, обзор #BF
                DB #FE, #8D                                                     ; данные #8F0B..#8F0C
                ; проверка исходного конца фрагмента
                ASSERT $ == #8F0D
                endmodule
                endmodule
