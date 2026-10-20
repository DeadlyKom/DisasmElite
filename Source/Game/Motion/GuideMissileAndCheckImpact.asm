                module Motion
                module GuideMissileAndCheckImpact
; -----------------------------------------
; наведение ракеты на цель и проверка попадания
; исходный диапазон #A4B5..#A536
; In:
;   BC, low4 C содержит код цели, ноль означает игрока
;   IX, ракета
;   IY, описание модели ракеты
; Out:
;   IX, исходная ракета
;   IY, исходная модель
;   вектор наведения и флаги поражённой цели обновлены
; Corrupt:
;   HL, DE, BC, AF
; Note:
; При активном ECM тип ракеты проверяется расширением #7D3E, у поражаемой ракеты ставится IX+20.4.
; Код цели преобразуется в слот как #6021+(9-код)*39, для допустимых кодов 1..8.
; Разности трёх координат уменьшаются вчетверо, близость проверяется отдельно по каждой оси.
; Проверка X проходит через F97E, где обрабатываются особые виды целей.
; При попадании устанавливается IY+20.4, специальная миссионная цель дополнительно получает IY+26.7.
; При промахе общий хвост A4B2 передаёт вектор автопилоту.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #A4B5
                ; проверка воздействия ECM на ракету
Entry:          LD A, (CombatState.EcmTimer)
                AND A
                JR Z, FindTarget                                                ; переход, если ECM не активен и можно продолжать наведение

                CALL Game.Universe.ApplyEcmToStandardMissile.Entry
                RET NZ                                                          ; выход, если тип ракеты не подлежит уничтожению текущим ECM

                SET OBJ_DESTROY_BIT, (IX + FSpaceObject.Flags)
                RET

                ; поиск слота цели по её обратному номеру
FindTarget:     LD A, C
                AND #0F
                AND A
                JR Z, Game.Motion.CheckObjectBoxAndChooseCourse.FlyToward       ; переход, если целью ракеты является игрок

                PUSH IY
                LD IY, Memory.Station - FSpaceObject                            ; база на один слот перед станцией, цикл сначала прибавляет шаг
                LD DE, #0027
                SUB #0A
                CPL
                LD B, A
NextTarget:     ADD IY, DE
                DJNZ NextTarget

                PUSH IX
                ; расчёт трёх компонент вектора от ракеты к цели
                PUSH IY
                CALL Game.Motion.QuarterCoordinateDifference.Entry
                LD (SteeringVector.X), HL
                CALL Game.Motion.QuarterCoordinateDifference.Entry
                LD (SteeringVector.Y), HL
                CALL Game.Motion.QuarterCoordinateDifference.Entry
                LD (SteeringVector.Z), HL
                POP IY
                POP IX
                CALL Game.Motion.IsSmallSignedDistance.Entry
                JR NZ, SteerMissile                                             ; переход, если расстояние по Z ещё велико для попадания

                ; проверка близости по каждой координате
                LD HL, (SteeringVector.Y)
                CALL Game.Motion.IsSmallSignedDistance.Entry
                JR NZ, SteerMissile                                             ; переход, если расстояние по Y ещё велико для попадания

                LD HL, (SteeringVector.X)
                CALL Game.Extensions.ResolveSpecialObjectCollision.Entry
                JR NZ, SteerMissile                                             ; переход, если расширенная проверка X не подтверждает попадание

                BIT OBJ_SPECIAL_BIT, (IY + FSpaceObject.Flags2)
                JR Z, DestroyTarget                                             ; переход, если цель не требует специальной миссионной обработки

                LD HL, State.Mission3
                CALL Game.Text.HandleSpecialObjectMission.Entry
                JR NZ, RestoreTarget                                            ; переход, если миссионный обработчик вернул NZ, восстановить указатель модели и выйти

                LD HL, State.MarketStock + FGoods.AlienItems
                XOR A
                LD (HL), A
                LD DE, #FFFF
                CALL Game.Missions.DispatchRatingAndMissionEnd.Entry
                SET OBJ_HIT_BIT, (IY + FSpaceObject.Flags2)
                ; установка запроса уничтожения поражённой цели
DestroyTarget:  SET OBJ_DESTROY_BIT, (IY + FSpaceObject.Flags)
RestoreTarget:  POP IY
                RET

ClearMetadata:  LD (HL), A
                JP Game.Combat.UpdateAllSpaceObjects.NextSlot

                ; переход к автопилоту по рассчитанному вектору
SteerMissile:   POP IY
                JP Game.Motion.CheckObjectBoxAndChooseCourse.SteerCourse
                ; проверка исходного конца фрагмента
                ASSERT $ == #A537
                endmodule
                endmodule
