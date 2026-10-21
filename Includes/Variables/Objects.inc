                ifndef _VARIABLES_OBJECTS_
                define _VARIABLES_OBJECTS_

FaceState       EQU Game.Objects.GenerateSpaceTraffic.FaceData                  ; адрес структуры FFaceState
.Object         EQU FaceState + FFaceState.Object                               ; сохранённый адрес исходного объекта из IX
.Scale          EQU FaceState + FFaceState.Scale                                ; сдвиг нормали из FModel.NormalScale
.PositionX      EQU FaceState + FFaceState.PositionX                            ; знако-модульная координата X для скалярного произведения
.PositionY      EQU FaceState + FFaceState.PositionY                            ; знако-модульная координата Y для скалярного произведения
.PositionZ      EQU FaceState + FFaceState.PositionZ                            ; знако-модульная координата Z для скалярного произведения
.NormalX        EQU FaceState + FFaceState.NormalX                              ; преобразованная знаковая компонента нормали X
.NormalY        EQU FaceState + FFaceState.NormalY                              ; преобразованная знаковая компонента нормали Y
.NormalZ        EQU FaceState + FFaceState.NormalZ                              ; преобразованная знаковая компонента нормали Z
SpawnAxis       EQU Game.Objects.ActivateEnemyECM.SpawnAxis                     ; переключатель чередования осей при создании объекта
RandomState     EQU Game.Combat.NextRandomByte.RandomSeed                       ; 16-битное состояние генератора NextRandomByte

ObjectTemplate  EQU Game.Objects.ActivateEnemyECM.ObjectTemplate                ; шаблон первых 31 байта объекта, копируется в поля X..Pitch
IntroMatrix     EQU Game.Objects.ActivateEnemyECM.IntroMatrix                   ; девять старших байтов осей модели заставки

                endif                                                           ; ~_VARIABLES_OBJECTS_
