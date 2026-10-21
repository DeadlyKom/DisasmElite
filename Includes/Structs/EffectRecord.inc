                ifndef _STRUCT_EFFECT_RECORD_
                define _STRUCT_EFFECT_RECORD_

; -----------------------------------------
; расширенные данные одного объекта, параллельный пул из восьми записей
; основной пул начинается в Memory.Station с шагом FSpaceObject
; расширенный пул начинается в ObjectEffects.Records с шагом FEffectRecord10
; указатель текущей записи хранится в ObjectEffects.Current
; размер и смещения описывают существующие байты, память здесь не выделяется
; -----------------------------------------
                struct FEffectRecord10                                          ; связи, экранные точки и состояние расширенного эффекта
; -----------------------------------------
; битовые поля расширенной записи, обычный формат TypeFlags
;       7    6    5    4    3    2    1    0
;     +----+----+----+----+----+----+----+----+
;     | AC | GM | TM | SR | EN | IT | GP | GP |
;     +----+----+----+----+----+----+----+----+
; AC [7] - флаг, запись допускается как цель расширенного взаимодействия
;   Game.Universe.TryObjectInteraction.Entry отклоняет цель при AC=0
;   Game.Universe.UpdateExtendedObjectEffects.FindPartner временно снимает AC у источника на время поиска, затем
;   устанавливает
; GM [6] - флаг, взаимодействие цели проверяется по двухбитным группам
;   Game.Universe.TryObjectInteraction.Entry при GM=1 требует различные GP и дополнительный допуск IT
;   при GM=0 проверяет IT, совпадение собственного номера цели и случайный допуск
;   Game.Extensions.ChooseLinkedObjectTarget.CheckSearch требует GM вместе с SR для поиска новой резервной цели
; TM [5] - флаг, запись участвует в ветви обновления таймера и особого эффекта
;   Game.Universe.UpdateExtendedObjectEffects.ProcessSlot обновляет Timer при AC=GM=1 либо при TM=1
;   после истечения таймера GM=0 направляет запись к круговому эффекту
;   при GM=1 и TM=1 применяются дополнительные условия энергии, группы и случайности
; SR [4] - флаг, разрешён поиск новой резервной цели
;   Game.Extensions.ChooseLinkedObjectTarget.CheckSearch требует SR=1 и GM=1 после отказа всех сохранённых ссылок
;   поиск проверяет семь записей с верхней тетрадой #9, затем возможность станции
; EN [3] - флаг, используется энергетический эффект вместо обычного каркаса
;   Game.Universe.SpawnDestructionContentsAndEffects.CheckEffects после исключения кругового типа проверяет EN и
; выбирает энергетическую ветвь
;   Game.Universe.InitializeExtendedObjectMetadata.StoreFlags разрешает случайную установку EN только при
; установленном бите MS_CLOAK_BIT поля State.MissionFlags
; IT [2] - флаг, разрешающий признак взаимодействия с отдельными целями
;   Game.Universe.TryObjectInteraction.Entry проверяет его у цели либо источника в зависимости от GM и типа источника
;   Game.Wireframe.MergeInverseHostilityFlag.Entry добавляет IT результату, если у другого участника IT сброшен
;   Game.Extensions.ChooseLinkedObjectTarget.CheckSearch запрещает выбирать станцию резервной целью при IT=1
; GP [1..0] - числовое поле, группа 0..3, не два независимых флага
;   Game.Universe.InitializeExtendedObjectMetadata.CompareModel объединяет исходный тип каталога с фазой
; ObjectEffects.Phase AND 3, кроме типа #C0
;   Game.Universe.TryObjectInteraction.CompareGroups отклоняет одинаковые группы источника и цели
;   Game.Extensions.ScheduleLinkedObjectLaser.Entry группа 0 дополнительно требует разрешения FX_ALLOW_BIT в
;   ObjectEffects.Flags
;
; TypeFlags, отдельный формат кругового эффекта #A0..#A7
;       7    6    5    4    3    2    1    0
;     +----+----+----+----+----+----+----+----+
;     | 1  | 0  | 1  | 0  | 0  | PH | PH | PH |
;     +----+----+----+----+----+----+----+----+
; PH [2..0] - числовое поле, фаза 0..7
;   Game.Universe.SpawnDestructionContentsAndEffects.CheckEffects и Game.Universe.AdvanceCircularObjectEffect.Entry
; распознают весь тип условием TypeFlags AND #F8 = #A0
;   Game.Universe.UpdateExtendedObjectEffects.StartCircle записывает #A0,
; Game.Universe.AdvanceCircularObjectEffect.Entry увеличивает фазу и при её обнулении удаляет объект
;   биты 7..3 являются постоянным кодом типа 10100, не пятью отдельными флагами
;   распознавание кругового типа требует всей маски #F8, одного установленного бита недостаточно
;
; -----------------------------------------
TypeFlags       DB #00                                                          ; +00, тип и признаки, младшие два бита группа, #A0..#A7 фаза кругового эффекта
; -----------------------------------------
; FirstFlags и SecondFlags, смещения +1 и +4
;       7    6    5    4    3    2    1    0
;     +----+----+----+----+----+----+----+----+
;     | PR | .. | .. | .. | .. | .. | SX | SY |
;     +----+----+----+----+----+----+----+----+
; PR [7] - флаг, пометка непроецируемой вершины, возвращённая Game.Wireframe.ReadProjectedVertex.Entry
;   Game.Universe.InitializeExtendedObjectMetadata.ReadLaserPoint сохраняет исходный байт признаков вершины, в
; Game.Universe.UpdateExtendedObjectEffects.Entry PR отдельно не проверяется
; SX [1] - флаг, при выводе линии X=127-модуль вместо X=127+модуль
; SY [0] - флаг, при выводе линии Y=63+модуль вместо Y=63-модуль
; .. [6..2] - назначение как отдельных флагов расширенной точки не установлено
;   Game.Universe.UpdateExtendedObjectEffects.PackLine упаковывает только SX/SY двух точек в знаки отрезка для
;   Game.Wireframe.DrawClippedLine.Entry
;   Game.Extensions.StorePairedObjectDirections.Entry записывает обеим точкам общий байт C от проекции центра
;   Game.Extensions.GetViewAdjustedProjectedPoint.Entry для нечётного вида инвертирует SX перед сохранением
;   особое значение всего байта #FF обозначает недействительную точку
;   Game.Text.InvalidateObjectLineCache.Entry записывает #FF в оба поля,
; Game.Universe.UpdateExtendedObjectEffects.CheckEndpoint и предшествующий код проверяют весь байт
;   при двух #FF линия не выводится, один #FF заменяется случайным дальним концом
;
; -----------------------------------------
FirstFlags      DB #00                                                          ; +01, признаки первой экранной точки, #FF означает отсутствие проекции
FirstX          DB #00                                                          ; +02, модуль горизонтальной координаты первой точки
FirstY          DB #00                                                          ; +03, модуль вертикальной координаты первой точки
; -----------------------------------------
; формат признаков совпадает с FirstFlags, схема выше перед первым концом
; -----------------------------------------
SecondFlags     DB #00                                                          ; +04, признаки второй экранной точки, #FF означает отсутствие проекции
SecondX         DB #00                                                          ; +05, модуль горизонтальной координаты второй точки
SecondY         DB #00                                                          ; +06, модуль вертикальной координаты второй точки
; -----------------------------------------
; Timer остаётся числовым обратным отсчётом, отдельные разряды выбирают фазу работы
; FX_SEARCH_TICK [0] разрешает новый поиск резервной цели при нечётном таймере
; FX_LASER_TICK  [1] запрещает лазер при непустых ссылках, чередуя пары тактов
; эти проверки не превращают Timer в набор независимо устанавливаемых флагов
; -----------------------------------------
Timer           DB #00                                                          ; +07, обратный отсчёт взаимодействия, начальное значение #18
; -----------------------------------------
; Links, смещение +8, две числовые ссылки
;       7    6    5    4    3    2    1    0
;     +----+----+----+----+----+----+----+----+
;     | PV | PV | PV | PV | CR | CR | CR | CR |
;     +----+----+----+----+----+----+----+----+
; PV [7..4] - числовое поле, предыдущий участник взаимодействия
; CR [3..0] - числовое поле, последний участник взаимодействия
;   эти биты не являются независимыми флагами
;   номер 0 означает отсутствие ссылки, 1..8 обозначают слоты в обратном порядке
;   номер 8 соответствует станции, адрес слота Memory.Station + (8-номер) * FSpaceObject
;   Game.Universe.TryObjectInteraction.CheckDistance сдвигает прежний CR в PV и записывает новый номер источника в CR
;   Game.Universe.DispatchLinkedObjectAction.Entry передаёт CR создаваемой ракете,
; Game.Extensions.ChooseLinkedObjectTarget.Entry проверяет CR перед PV
;   Game.Universe.DispatchLinkedObjectAction.LaserHitLinks при обработке попадания сдвигает CR в PV и очищает CR
;   Game.Universe.AwardUnlinkedDestructionBounty.Entry допускает денежную награду только при CR=0
;
; -----------------------------------------
Links           DB #00                                                          ; +08, младшая тетрада текущая ссылка, старшая тетрада предыдущая ссылка
; -----------------------------------------
; Fallback, смещение +9
;       7    6    5    4    3    2    1    0
;     +----+----+----+----+----+----+----+----+
;     | NS | .. | .. | .. | TG | TG | TG | TG |
;     +----+----+----+----+----+----+----+----+
; NS [7] - флаг, запрещён случайный выбор станции резервной целью
;   Game.Universe.InitializeExtendedObjectMetadata.Entry устанавливает его, если при создании записи станционный слот
; занят
;   Game.Extensions.ChooseLinkedObjectTarget.CheckSearch проверяет NS перед возможным выбором станции с номером 8
; TG [3..0] - числовое поле, резервный номер цели 0..8 по тому же правилу, что Links
; .. [6..4] - самостоятельные флаги не проверяются
;   Game.Extensions.ChooseLinkedObjectTarget.StoreTarget сохраняет только NS и записывает найденный номер, обнуляя
; биты 6..4
;   при недействительной TG ветвь Game.Extensions.ChooseLinkedObjectTarget.ClearReserve обнуляет весь Fallback, включая
;   NS
; -----------------------------------------
Fallback        DB #00                                                          ; +09, резервная ссылка в младшей тетраде, бит 7 запрещает резерв станции
                ends

; -----------------------------------------
; подтверждённые потребители структуры
; Game.Universe.InitializeExtendedObjectMetadata.Entry устанавливает тип, таймер и ссылки по каталогу модели
; Game.Universe.InitializeExtendedObjectMetadata.ReadLaserPoint и Game.Extensions.StorePairedObjectDirections.Entry
; сохраняют экранные точки, Game.Text.InvalidateObjectLineCache.Entry помечает их как отсутствующие
; Game.Universe.TryObjectInteraction.Entry записывает участника взаимодействия в Links, сдвигая прежний номер
; Game.Extensions.ChooseLinkedObjectTarget.Entry выбирает цель через Links и Fallback, номер 8 обозначает станцию
; Game.Universe.UpdateExtendedObjectEffects.Entry обновляет таймер и рисует связи,
; Game.Universe.SpawnDestructionContentsAndEffects.CheckEffects и Game.Universe.AdvanceCircularObjectEffect.Entry
; обслуживают эффект #A0
; признаки точек, бит 0 задаёт сторону Y, бит 1 сторону X
; значения #FF не разбираются как обычные признаки и координаты
                module EffectRecord
Count:          EQU 8                                                           ; число записей, соответствующих восьми основным слотам
Size:           EQU #0A                                                         ; шаг расширенного пула
NoPoint:        EQU #FF                                                         ; отсутствующая экранная точка
CircleType:     EQU #A0                                                         ; старшие пять битов кругового эффекта
TypeMask:       EQU #F8                                                         ; маска типа для проверки кругового эффекта
PhaseMask:      EQU #07                                                         ; фаза кругового эффекта от 0 до 7
                endmodule

                ; проверка размера и подтверждённых смещений структуры
                ASSERT FEffectRecord10 == #0A
                ASSERT FEffectRecord10.FirstFlags == #01
                ASSERT FEffectRecord10.SecondFlags == #04
                ASSERT FEffectRecord10.Timer == #07
                ASSERT FEffectRecord10.Links == #08
                ASSERT FEffectRecord10.Fallback == #09

                endif
