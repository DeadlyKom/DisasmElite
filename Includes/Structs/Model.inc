                ifndef _STRUCT_MODEL_
                define _STRUCT_MODEL_

; -----------------------------------------
; описание модели, 23 байта без выделения памяти
; IY указывает на начало описания при создании, движении и выводе объекта
; смещения геометрии относительны началу описания и допускают общие потоки
; формат потоков геометрии восстановлен по потребителям этой версии
; подробности упаковки в Tools/Disasm/Reports/ModelGeometry.json
; -----------------------------------------
                struct FModel
Cargo           DB #00                                                          ; +00, маска/тип подбираемого груза, потребитель Game.Combat.HandleObjectCollision.Entry
Collision       DB #00                                                          ; +01, порог столкновения, потребители Game.Combat.HandleObjectCollision.Entry и Game.Combat.UpdateAllSpaceObjects.CheckMission
LaserChance     DB #00                                                          ; +02, порог случайного лазерного выстрела, Game.Motion.SteerObjectAndTryLaser.Entry
VertexCount     DB #00                                                          ; +03, число вершин, потребитель Game.Wireframe.BuildProjectedVertexTable.Entry
EdgeCount       DB #00                                                          ; +04, число рёбер, потребитель Game.Extensions.DrawCompressedEdges.Entry
NormalCount     DB #00                                                          ; +05, число нормалей, потребитель Game.Objects.ComputeFaceVisibility.Entry
MaxSpeed        DB #00                                                          ; +06, предельная скорость, Game.Objects.InitializeObject.Entry задаёт половину при создании
MaxEnergy       DB #00                                                          ; +07, начальная энергия, Game.Objects.InitializeObject.Entry копирует в FSpaceObject.Energy
Bounty          DW #0000                                                        ; +08..09, денежная награда, потребитель Game.Combat.UpdateAllSpaceObjects.ReleaseObject
; -----------------------------------------
;      7    6    5    4    3    2    1    0
;   +----+----+----+----+----+----+----+----+
;   | TY | TY | TY | TY | .. | LC | LC | LC |
;   +----+----+----+----+----+----+----+----+
;
;   TY      [7..4]  - код выбора действия при запуске, маска MODEL_SHOT_MASK
;   LC      [2..0]  - маска начального случайного запаса запусков, OBJ_LAUNCH_MASK
;   ..      [3]     - не входит в запас запусков и код выбора действия
;   это два числовых поля, отдельные биты не являются независимыми флагами
; -----------------------------------------
LaunchMask      DB #00                                                          ; +0A, параметры запуска объектов, потребители Game.Text.CheckObjectRandomGate.Entry и Game.Motion.ProcessObjectEnergyAndTactics.Entry
DotDistance     DB #00                                                          ; +0B, порог перехода от каркаса к точке, потребитель Game.Motion.ProjectObjectAndSelectDetail.SelectDetail
Vertices        DW #0000                                                        ; +0C..0D, относительный адрес потока вершин, Game.Wireframe.LocateVertexCoordinateData.Entry
; -----------------------------------------
; байт порога в потоке рёбер, на который указывает блок Edges
;      7    6    5    4    3    2    1    0
;   +----+----+----+----+----+----+----+----+
;   | V2 | V1 | DT | LD | LD | LD | LD | LD |
;   +----+----+----+----+----+----+----+----+
;
;   DT      [5]     - флаг, прямой байт порога, номер EDGE_DIRECT_BIT
;   V1      [6]     - старший разряд номера первой вершины, EDGE_V1_BIT
;   V2      [7]     - старший разряд номера второй вершины, EDGE_V2_BIT
;   LD      [4..0]  - числовой порог детализации, EDGE_LOD_MASK, 31 без ограничения
;   если DT=0, весь байт является счётчиком повторов, следующий байт задаёт порог
;   V1/V2 не самостоятельные флаги, дополняют тетрады пары индексов вершин
; -----------------------------------------
Edges           DW #0000                                                        ; +0E..0F, относительный адрес блока рёбер, Game.Extensions.DrawCompressedEdges.Entry
Normals         DW #0000                                                        ; +10..11, относительный адрес потока нормалей, Game.Wireframe.LocateFaceNormalData.Entry
; -----------------------------------------
;      7    6    5    4    3    2    1    0
;   +----+----+----+----+----+----+----+----+
;   | EP | LW | LW | .. | FS | HT | AR | QS |
;   +----+----+----+----+----+----+----+----+
;
;   EP      [7]     - флаг, спасательная капсула, переносится в FSpaceObject.Flags
;   FS      [3]     - флаг, удаление при существующей станции
;   HT      [2]     - флаг, начальная враждебность корабля
;   AR      [1]     - флаг, разрешено включить враждебность по рейтингу игрока
;   QS      [0]     - флаг, увеличенный в четыре раза предел скорости
;   LW      [6..5]  - признаки опасности и изменения законности, маска OBJ_LAW_MASK
;   ..      [4]     - не копируется в Hostility, назначение отдельного бита не установлено
;   MODEL_AI_MASK переносит биты 6, 5 и 3..0 в FSpaceObject.Hostility
;   флаг EP имеет номер OBJ_ESCAPE_BIT, остальные известные биты совпадают с Hostility
; -----------------------------------------
Flags           DB #00                                                          ; +12, исходные признаки объекта, потребитель Game.Objects.InitializeObject.Entry
NormalScale     DB #00                                                          ; +13, число сдвигов при нормализации, Game.Objects.ComputeFaceVisibility.Entry и Game.Motion.TransformNormalWithObjectCoordinate.Entry
LaserVertex     DB #00                                                          ; +14, номер вершины начала лазерного луча, Game.Wireframe.DrawWireframeObject.Entry
Rating          DW #0000                                                        ; +15..16, прибавка рейтинга, Game.Combat.UpdateAllSpaceObjects.ReleaseObject предварительно делит на 2
                ends

; -----------------------------------------
; индексы четырёхбайтового каталога Memory.ModelIndex
; два дополнительных истребителя названы по совпавшей геометрии Fighter1/2
; имена Fighter1/2 обозначают две разные модели без неподтверждённых названий
; -----------------------------------------
                module ModelID
Coriolis:       EQU #00                                                         ; станция
Missile:        EQU #01                                                         ; управляемая ракета
EscapePod:      EQU #02                                                         ; спасательная капсула
Alloys:         EQU #03                                                         ; металлические обломки
Cargo:          EQU #04                                                         ; грузовой контейнер
Minerals:       EQU #05                                                         ; минеральный обломок
Asteroid:       EQU #06                                                         ; обычный астероид
AsteroidArmed:  EQU #07                                                         ; особый астероид с запускаемыми объектами
Viper:          EQU #08                                                         ; полицейский корабль
CobraTrader:    EQU #09                                                         ; торговая Cobra Mk III
PythonTrader:   EQU #0A                                                         ; торговый Python
PythonPirate:   EQU #0B                                                         ; пиратский Python
CobraPirate:    EQU #0C                                                         ; пиратская Cobra Mk III
Asp:            EQU #0D                                                         ; Asp Mk II
FerDeLance:     EQU #0E                                                         ; Fer-de-Lance
Thargoid:       EQU #0F                                                         ; Thargoid
Sidewinder:     EQU #10                                                         ; Sidewinder
Adder:          EQU #11                                                         ; Adder
Tharglet:       EQU #12                                                         ; малый корабль Tharglet
Thargoid6:      EQU #13                                                         ; шестигранный Thargoid
Fighter1:       EQU #14                                                         ; дополнительный истребитель с рисунком молнии
Fighter2:       EQU #15                                                         ; второй дополнительный истребитель
Krait:          EQU #16                                                         ; Krait
                endmodule

                struct FModelIndex
; -----------------------------------------
; исходный TypeFlags расширенной записи, схема находится у FEffectRecord10.TypeFlags
; InitializeExtendedObjectMetadata объединяет его с фазой и уточняет EN, SR и TM
; номера битов FX_* и маска группы FX_GROUP_MASK определены в Includes/Const/Objects.inc
; -----------------------------------------
Flags           DB #00                                                          ; +00, свойства модели для Game.Universe.InitializeExtendedObjectMetadata.NextBlueprint
Address         DW #0000                                                        ; +01..02, абсолютный адрес FModel, потребитель Game.Objects.InitializeObject.Entry
Class           DB #00                                                          ; +03, класс модели для выбора случайного объекта
                ends

                ; проверка точного размера без резервирования новых адресов
                ASSERT FModel == #17
                ASSERT FModel.Vertices == #0C
                ASSERT FModel.Edges == #0E
                ASSERT FModel.Normals == #10
                ASSERT FModel.Rating == #15
                ASSERT FModelIndex == 4
                endif
