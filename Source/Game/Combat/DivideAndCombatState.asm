                module Combat
                module DivideAndCombatState
; -----------------------------------------
; совместимый вход деления и рабочие поля боевого цикла
; исходный диапазон #9C89..#9C9B
; In:
;   HL, остаток
;   DE, делитель
;   AF, A содержит следующие биты делимого
; Out:
;   BC, частное по контракту Divide
; Corrupt:
;   HL, AF
; Note:
; Первый JP передаёт управление Divide. Следующие данные содержат старые JP Game.Wireframe.DrawClippedLine.Entry и JP Game.Combat.ProcessLaserAndEcm.Entry.
; CombatState.SpawnCounter, счётчик появления объектов. CombatState.ShipsPresent, наличие обычного корабля. CombatState.DestroyAll, массовый запрос уничтожения.
; CombatState.ObjectsPresent, наличие отображаемого объекта. CombatState.CrosshairTarget, номер цели прицела.
; CombatState.Danger, опасная обстановка. CombatState.DockRequest, запрос стыковки. CombatState.EcmTimer, время действия ECM.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #9C89
                ; переход к общему делению
Entry:          JP Game.Math.Divide

                ; сохранённые совместимые переходы и рабочие поля боевого цикла

; -----------------------------------------
; совместимый переход к выводу пространственного ребра
; In:
;   HL, DE, проекции концов
;   BC, C содержит знаки координат
; Out:
;   действие и результат построителя Game.Wireframe.DrawClippedLine.Entry
; Corrupt:
;   HL, DE, BC, AF, HL', DE', BC', AF'
; Note:
;   сохранённый вход таблицы совместимости, прямые входящие переходы не найдены
;   JP не добавляет адрес возврата, контракт совпадает с Game.Wireframe.DrawClippedLine.Entry
; -----------------------------------------
LineVector:     ; совместимый переход к выводу пространственного ребра
                JP Game.Wireframe.DrawClippedLine.Entry

; -----------------------------------------
; совместимый переход к обработке прицела, лазера и ECM
; In:
;   состояния FlightState.PlayerDead, FlightState.View, лазеры State.FrontLaser..State.RightLaser и события InputState.DeviceKeys
; Out:
;   прицел, лазер и ECM обновлены через Game.Combat.ProcessLaserAndEcm.Entry
; Corrupt:
;   HL, DE, BC, AF, IX, IY
; Note:
;   сохранённый вход таблицы совместимости, прямые входящие переходы не найдены
; -----------------------------------------
Weapons:        ; совместимый переход к обработке прицела, лазера и ECM
                JP Game.Combat.ProcessLaserAndEcm.Entry

                ; исходные байты вне раскрываемого входа
                DB #00                                                          ; сохранённый байт исходного блока
SpawnCounter    DB #00                                                          ; счётчик появления, уменьшение до нуля запускает диспетчер объектов
ShipsPresent    DB #00                                                          ; флаг, в текущем обходе найден объект без ObjectFlag2.NotShip
DestroyAll      DB #00                                                          ; массовый запрос уничтожения от энергетической бомбы, снимается в конце кадра
ObjectsPresent  DB #00                                                          ; ненулевой байт последнего занятого слота, допускает сканер и обход взрывов
CrosshairTarget DB #AF                                                          ; номер цели прицела, 0 без цели, патч проекции данной версии пишет только 0
                DB #00                                                          ; сохранённый байт исходного блока
Danger          DB #00                                                          ; флаг, обнаружен опасный враждебный объект, сбрасывается при пустой сцене
DockRequest     DB #00                                                          ; запрос стыковки после совмещения со станцией, обходящий клавиатурные допуски
EcmTimer        DB #00                                                          ; оставшиеся такты ECM, влияет на ракеты, индикатор и расход энергии
                ; проверка исходного конца фрагмента
                ASSERT $ == #9C9C
                endmodule
                endmodule
