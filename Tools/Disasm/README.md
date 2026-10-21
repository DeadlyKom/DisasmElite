# Инструменты дизассемблирования Elite

[Проект](../../README.md) · [Проверка результата](../../Docs/Validation.md)

Здесь находятся исходные материалы, помощники анализа и проверочные реестры.
Задача `Build` по Ctrl+B напрямую запускает локальный
[sjasmplus](../Sjasmplus/sjasmplus.exe). Упаковка выполняется через
[Tools/pack.lua](../pack.lua) внутри ассемблера.

## Расположение материалов

| Папка | Назначение |
|---|---|
| [Disk](Disk) | исходный `original.trd`, каталог `manifest.json`, служебная дорожка, свободная область и `Keys/GameEncoding.lua` |
| [Extracted/Active](Extracted/Active) | семь логических файлов и их `.sectors.bin` / `.tail.bin` |
| [Reports](Reports) | реестры функций, ресурсов, семантики и результаты проверок |
| [Research](Research/README.md) | сценарии исследования, промежуточные дампы и справочные материалы |
| [Research/vendor/skoolkit-10.1](Research/vendor/skoolkit-10.1) | декодер и симулятор SkoolKit с лицензией |
| [Tmp](../../Tmp) | только листинг, символы и отладочная карта сборки |

Собранный образ сохраняется в [ELITE3HL.TRD](../../ELITE3HL.TRD).
Сборка не создаёт промежуточные игровые `.B/.C/.bin`.
Сохранённые двоичные результаты прежней сборки находятся в
[Research/BuildSnapshot](Research/BuildSnapshot); это архив проверки, а не входы
текущей сборки и не оригиналы из `Extracted/Active`.

## Поддерживаемые помощники

| Файл | Назначение |
|---|---|
| [ExtractTrd.py](ExtractTrd.py) | извлечение образа, каталога, файлов и секторных дополнений |
| [InspectZ80.py](InspectZ80.py) | чтение инструкций выбранного диапазона оригинала или открытого игрового блока |
| [VerifySourceMap.py](VerifySourceMap.py) | статическая сверка команд и данных с исходным разбором |
| [AuditDocumentation.py](AuditDocumentation.py) | проверка реестров и оформления комментариев |
| [CheckSourceLayout.py](CheckSourceLayout.py) | пробелы после запятых и пустые строки после переходов и выходов |
| [MarkFallThrough.py](MarkFallThrough.py) | именованные продолжения по границам файлов и порядок include |
| [VerifyCommanderRecords.py](VerifyCommanderRecords.py) | пять экземпляров FCommander, их байты и адреса вложенных полей |
| [VerifyTypedData.py](VerifyTypedData.py) | все физические F-инициализаторы игрового блока, байты, поля и сохранение прежних символов |
| [CheckDocumentationLinks.py](CheckDocumentationLinks.py) | относительные ссылки и якоря документации проекта |
| [ResolveCommentReferences.py](ResolveCommentReferences.py) | инвентаризация числовых ссылок в комментариях для ручной проверки |
| [AuditCodeTargets.py](AuditCodeTargets.py) | перечисление прямых переходов, косвенных входов и абсолютных записей в код |
| [VerifyBuild.ps1](VerifyBuild.ps1) | побайтовая проверка уже собранного TRD и SHA-256 его семи файлов |

Python-инструменты запускаются отдельно от сборки. SkoolKit 10.1 используется
из сохранённого локального пакета. Команды ниже выполняются из корня проекта.

### Просмотр команд

```powershell
python Tools/Disasm/InspectZ80.py decoded 0xE063 0xE07A
```

Пример показывает генератор состояния в открытом игровом блоке. Режим `game`
читает дисковое представление; `decoded` — сохранённый материал анализа
`Research/GameCode.bin`.

### Статическая сверка

```powershell
python Tools/Disasm/VerifySourceMap.py
```

Проверка использует символы из `Tmp/ELITE3HL.sym` последней сборки. Она не
запускает ассемблер. Аудиты документации и переходов также работают отдельно
и записывают свои результаты в `Reports`.

`python Tools/Disasm/CheckDocumentationLinks.py` проверяет наличие целей
локальных ссылок и Markdown-якорей. Внешние сайты эта проверка не открывает.

Инициализаторы `FCommander { ... }` проверяются по объявлениям из
`Includes/Structs`: учитываются все поля, вложенные структуры и массив имени.
Пропущенное значение или неверная вложенность останавливает проверку.
[CommanderInitializers.json](Reports/CommanderInitializers.json) содержит
сверку пяти записей с оригинальными байтами и адресами полей.
Отчёт обновляется командой `python Tools/Disasm/VerifyCommanderRecords.py`
после сборки, включая резерв `NewCommander` и все вложенные поля.

`python Tools/Disasm/VerifyTypedData.py` проверяет все 179 физических
F-инициализаторов игрового блока: 1786 байтов и 1172 адреса полей.
[TypedDataVerification.json](Reports/TypedDataVerification.json) содержит
результаты для каждого экземпляра. Оба помощника сравнивают прежние символы
с сохранённой контрольной картой
[BeforeTypedDataSymbols.json](Reports/BeforeTypedDataSymbols.json), поэтому
контрольные данные не теряются при очистке `Tmp`. Текущие символы берутся
из `Tmp/ELITE3HL.sym` после сборки. Удалённый нулевой кандидат локального поиска
имени перечислен отдельно, он не был объявлением или адресом данных.

`AuditSemanticNames.py` проверяет отсутствие адресных имён файлов и меток,
числовых целей прямых переходов и шаблонных комментариев к арифметике.
`UpdateNameIndex.py` сверяет новые метки с текущим `.sym` и обновляет
[указатель внутренних ветвей](../../Docs/Labels.md). Оба помощника работают без сборки.

### Оформление и переходы между файлами

```powershell
python Tools/Disasm/CheckSourceLayout.py
python Tools/Disasm/MarkFallThrough.py
```

Без дополнительных параметров обе команды только проверяют исходники и пишут
отчёты. `CheckSourceLayout.py --apply` добавляет пробелы после разделителей
операндов и пустые строки после `RET/JP/JR`, сохраняя строки данных.
`MarkFallThrough.py --apply` подписывает последовательные продолжения и номера
жёстко связанных include. Команды не вставляют инструкции перехода.

`ResolveCommentReferences.py` составляет список четырёхзначных чисел в комментариях.
Классификация и совпадение с именем из `.sym` сами по себе не доказывают назначение:
число может быть маской, порогом, исходным адресом байтов или адресом другого оверлея.
Проверенные замены и их основания сохраняются отдельно в
[ReviewedCommentReferences.json](Reports/ReviewedCommentReferences.json).
Итоговая ручная классификация чисел и проверенные замены диапазонов находятся
в [FinalCommentNumberReview.json](Reports/FinalCommentNumberReview.json).
[IndexedCommentNames.json](Reports/IndexedCommentNames.json) фиксирует замену
оставшихся числовых IX/IY-ссылок на проверенные поля и константы.
[FinalCommentReferences.json](Reports/FinalCommentReferences.json) содержит
инвентаризацию окончательных исходников; `CommentReferences.json` сохраняет
снимок, на котором основаны номера записей ручного разбора.
`RemainingCommentReferences.json`, `UnresolvedCommentReferences.json`
и `CommentStructureHandoff*.json` сохраняют ранние списки кандидатов и обмен
результатами этапов. Они не являются текущим перечнем незавершённых правок.

### Проверка готового образа

```powershell
.\Tools\Disasm\VerifyBuild.ps1
```

Сценарий проверяет существующий `ELITE3HL.TRD`, не собирая его повторно.
Отчёт находится в [Reports/BuildVerification.json](Reports/BuildVerification.json).

### Извлечение в отдельную папку

```powershell
python Tools/Disasm/ExtractTrd.py Tools/Disasm/Disk/original.trd --output "$env:TEMP/Elite-extracted"
```

Извлечение создаёт внутри указанной папки `Disk` и `Extracted/Active`.
Исходный TRD не изменяется. При обнаружении отличающегося существующего файла
помощник отказывается его перезаписывать.

## Исследовательский архив

[Research/README.md](Research/README.md) объясняет происхождение сохранённых
сценариев и дампов. Исторические генераторы исходников не являются готовой
цепочкой повторного создания проекта. Их массовый запуск может перезаписать
ручные комментарии, имена и разметку. Текущая сборка их не вызывает.

`AuditVariables.py` проверяет ручные карты `VariableNames*.json` по символам
свежей сборки, обнаруживает голые абсолютные и числовые индексные обращения
и обновляет [указатель переменных](../../Docs/Variables.md). Его проверка адресов
дополняет побайтовую проверку сборки и не заменяет смысловой разбор потребителей.
