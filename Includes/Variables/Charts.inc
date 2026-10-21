                ifndef _VARIABLES_CHARTS_
                define _VARIABLES_CHARTS_

TextInput       EQU Game.Trade.RestoreTextPosition.InputData                    ; адрес структуры FTextInput
.Length         EQU TextInput + FTextInput.Length                               ; число введённых символов
.Cursor         EQU TextInput + FTextInput.Cursor                               ; адрес следующего символа в буфере ввода
.LastKey        EQU TextInput + FTextInput.LastKey                              ; последний принятый код клавиши
InputPrompt     EQU Game.Charts.FindSystemNameDialog.PromptToken                ; токен приглашения строкового редактора
InputBuffer     EQU Game.Charts.FindSystemNameDialog.InputBuffer                ; адрес начала редактируемой строки
InputLimit      EQU Game.Charts.TextInputLoop.LengthLimit                       ; изменяемый предел длины строки в операнде CP
MapViewport     EQU Game.Charts.MapCursorTransformAndKeys.Viewport              ; адрес структуры FMapViewport
.CrosshairSize  EQU MapViewport + FMapViewport.CrosshairSize                    ; полуширина перекрестия карты в пикселях
.Top            EQU MapViewport + FMapViewport.Top                              ; верхняя строка области карты
.Bottom         EQU MapViewport + FMapViewport.Bottom                           ; нижняя строка области карты
MapNameLength   EQU Game.Menus.ReadVisibleObjectByte.NameLength                 ; длина имени системы при размещении подписи на карте
LocalMapLeft    EQU Game.Menus.VisitLocalChartSystems.LeftLimit                 ; изменяемая включённая левая граница X в CP
LocalMapRight   EQU Game.Menus.VisitLocalChartSystems.RightLimit                ; изменяемая исключённая правая граница X в CP
LocalMapTop     EQU Game.Menus.VisitLocalChartSystems.TopLimit                  ; изменяемая включённая верхняя граница Y в CP
LocalMapBottom  EQU Game.Menus.VisitLocalChartSystems.BottomLimit               ; изменяемая исключённая нижняя граница Y в CP
LocalMapVisit   EQU Game.Menus.VisitLocalChartSystems.SystemHandler             ; адрес обработчика видимой системы в операнде CALL
MapCircleX      EQU Game.Interface.DispatchDiskAndCommanderState.CircleX        ; координата X окружности карты
MapCircleY      EQU Game.Interface.DispatchDiskAndCommanderState.CircleY        ; координата Y окружности карты
MapRadius       EQU Game.Interface.DispatchDiskAndCommanderState.CircleRadius   ; радиус окружности дальности на карте

GalaxyDotMask   EQU Game.Menus.PlotGalaxySystem.PixelMask                       ; второй байт SET n,B, номер пиксельного бита задаётся результатом ROM
StarProfile     EQU Game.Menus.LocalSystemPixelPosition.StarProfile             ; семь параметров малого круга, индексы радиуса 2..8
CircleProfile   EQU StarProfile - 2                                             ; база индексирования профиля радиусом, допустимые данные начинаются при радиусе 2

                endif                                                           ; ~_VARIABLES_CHARTS_
