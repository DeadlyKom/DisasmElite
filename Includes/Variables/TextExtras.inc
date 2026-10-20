                ifndef _VARIABLES_TEXT_EXTRAS_
                define _VARIABLES_TEXT_EXTRAS_

LaserThreshold  EQU Game.Extensions.ScheduleLinkedObjectLaser.LaserThreshold    ; порог и накопитель лазерного допуска
TextScreenHigh  EQU Game.Text.DrawCharacter8x8.ScreenHigh                       ; старший байт экранной базы текста
SmallProfile    EQU Game.Extensions.AllocateVariantObjectSlot.ProfileBase       ; маски профиля, первые два байта совпадают с командами
RomFont         EQU #3D00                                                       ; глиф пробела в знакогенераторе ROM
                ; база для формулы (код - #20) * 8, первый глиф по ExtraGlyphs имеет код #2C
ExtraFontBase   EQU Game.Extensions.UpdateStationAndFinishGlyph.ExtraGlyphs - 12 * 8
ScratchStack    EQU Memory.Screen + #00F0                                       ; 48 байтов временного стека внутри экранной области
ScratchBackup   EQU #10000 - #0030                                              ; 48 байтов сохранения экрана в конце RAM, временное наложение

Blueprint       EQU Game.Extensions.DrawModelAndResources.Missile               ; начало массива заголовков моделей
.Coriolis       EQU Game.Extensions.DrawModelAndResources.Coriolis              ; заголовок FModel, станция Coriolis
.Missile        EQU Game.Extensions.DrawModelAndResources.Missile               ; заголовок FModel, ракета
.EscapePod      EQU Game.Extensions.DrawModelAndResources.EscapePod             ; заголовок FModel, спасательная капсула
.Alloys         EQU Game.Extensions.DrawModelAndResources.Alloys                ; заголовок FModel, обломки сплавов
.Cargo          EQU Game.Extensions.DrawModelAndResources.Cargo                 ; заголовок FModel, грузовой контейнер
.Minerals       EQU Game.Extensions.DrawModelAndResources.Minerals              ; заголовок FModel, минеральный обломок
.Asteroid       EQU Game.Extensions.DrawModelAndResources.Asteroid              ; заголовок FModel, обычный астероид
.AsteroidArmed  EQU Game.Extensions.DrawModelAndResources.AsteroidArmed         ; заголовок FModel, особый астероид с запускаемыми объектами
.Viper          EQU Game.Extensions.DrawModelAndResources.Viper                 ; заголовок FModel, полицейский Viper
.CobraTrader    EQU Game.Extensions.DrawModelAndResources.CobraTrader           ; заголовок FModel, торговая Cobra Mk III
.PythonTrader   EQU Game.Extensions.DrawModelAndResources.PythonTrader          ; заголовок FModel, торговый Python
.PythonPirate   EQU Game.Extensions.DrawModelAndResources.PythonPirate          ; заголовок FModel, пиратский Python
.CobraPirate    EQU Game.Extensions.DrawModelAndResources.CobraPirate           ; заголовок FModel, пиратская Cobra Mk III
.Asp            EQU Game.Extensions.DrawModelAndResources.Asp                   ; заголовок FModel, Asp Mk II
.FerDeLance     EQU Game.Extensions.DrawModelAndResources.FerDeLance            ; заголовок FModel, Fer-de-Lance
.Thargoid       EQU Game.Extensions.DrawModelAndResources.Thargoid              ; заголовок FModel, Thargoid
.Sidewinder     EQU Game.Extensions.DrawModelAndResources.Sidewinder            ; заголовок FModel, Sidewinder
.Adder          EQU Game.Extensions.DrawModelAndResources.Adder                 ; заголовок FModel, Adder
.Tharglet       EQU Game.Extensions.DrawModelAndResources.Tharglet              ; заголовок FModel, малый Tharglet
.Thargoid6      EQU Game.Extensions.DrawModelAndResources.Thargoid6             ; заголовок FModel, шестигранный Thargoid
.Fighter1       EQU Game.Extensions.DrawModelAndResources.Fighter1              ; заголовок FModel, дополнительный истребитель 1
.Fighter2       EQU Game.Extensions.DrawModelAndResources.Fighter2              ; заголовок FModel, дополнительный истребитель 2
.Krait          EQU Game.Extensions.DrawModelAndResources.Krait                 ; заголовок FModel, Krait

                endif                                                           ; ~_VARIABLES_TEXT_EXTRAS_
