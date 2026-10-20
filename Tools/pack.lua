-- Финальная упаковка выполняется внутри sjasmplus после EMPTYTRD и семи SAVETRD
-- Все смещения в образе и файлах отсчитываются от нуля
-- Исходные файлы игры не служат источником её собранного содержимого

local diskPath = "ELITE3HL.TRD"
local gameSize = 0xC000
local gameBase = 0x4000
local gameDiskOffset = 0x5400
local diskSize = 0xA0000
local freeOffset = 0x12800

-- Чтение двоичного файла с обязательной проверкой размера
local function readFile(path, expectedSize)
    local file, reason = io.open(path, "rb")
    assert(file, "Не удалось открыть " .. path .. ", " .. tostring(reason))
    local data = file:read("*a")
    assert(file:close())
    assert(data and #data == expectedSize, "Неверная длина " .. path)
    return data
end

-- Запись готовых данных только после проверки всей структуры диска
local function writeFile(path, data)
    local file, reason = io.open(path, "wb")
    assert(file, "Не удалось создать " .. path .. ", " .. tostring(reason))
    assert(file:write(data))
    assert(file:close())
end

-- Получение слова в порядке младший байт, старший байт
local function word(data, offset)
    return data:byte(offset + 1) + 256 * data:byte(offset + 2)
end

-- Замена диапазона без изменения длины образа
local function replace(data, offset, bytes)
    assert(offset >= 0 and offset + #bytes <= #data, "Замена выходит за границы")
    return data:sub(1, offset) .. bytes .. data:sub(offset + #bytes + 1)
end

-- Каталог, который обязан создать SAVETRD до восстановления исходных метаданных
-- Поле parameter у BASIC обозначает полную длину файла
-- У двух программ C временный адрес буфера отличается от исходного поля каталога
local files = {
    { name = "ELITE3HLB", file = "00_ELITE3HL.B", size = 16754,
      offset = 4096, sectors = 66, parameter = 16754, originalParameter = 16754, line = 10 },
    { name = "ELITE3  B", file = "01_ELITE3.B", size = 385,
      offset = 20992, sectors = 2, parameter = 385, originalParameter = 385, line = 10 },
    { name = "ELITE3  C", file = "02_ELITE3.C", size = 49152,
      offset = 21504, sectors = 192, parameter = 16384, originalParameter = 65510 },
    { name = "cl      C", file = "03_cl.C", size = 4352,
      offset = 70656, sectors = 17, parameter = 0, originalParameter = 24576 },
    { name = "boot    B", file = "04_boot.B", size = 32,
      offset = 75008, sectors = 1, parameter = 32, originalParameter = 32, line = 1 },
    { name = "QS1     C", file = "05_QS1.C", size = 102,
      offset = 75264, sectors = 1, parameter = 0, originalParameter = 0 },
    { name = "DEADLY  C", file = "06_DEADLY.C", size = 102,
      offset = 75520, sectors = 1, parameter = 0, originalParameter = 0 }
}

-- Проверка записи каталога с учётом особого порядка двух длин BASIC
local function checkEntry(data, index, entry, original)
    local base = (index - 1) * 16
    local expectedParameter = original and entry.originalParameter or entry.parameter
    assert(data:sub(base + 1, base + 9) == entry.name,
        "Неверное имя файла каталога " .. entry.file)
    assert(word(data, base + 9) == expectedParameter,
        "Неверный параметр каталога " .. entry.file)
    assert(word(data, base + 11) == entry.size,
        "Неверная длина каталога " .. entry.file)
    assert(data:byte(base + 14) == entry.sectors,
        "Неверное число секторов " .. entry.file)
    local sector = data:byte(base + 15)
    local track = data:byte(base + 16)
    assert((track * 16 + sector) * 256 == entry.offset,
        "Неверное положение файла " .. entry.file)
end

-- Проверка служебной записи диска и конца занятого пространства
local function checkService(data)
    assert(data:byte(0x8E1 + 1) == 8 and data:byte(0x8E2 + 1) == 18,
        "Неверное положение первого свободного сектора")
    assert(data:byte(0x8E3 + 1) == 0x16, "Неверный тип диска")
    assert(data:byte(0x8E4 + 1) == 7, "Неверное число файлов")
    assert(word(data, 0x8E5) == 2264, "Неверное число свободных секторов")
    assert(data:byte(7 * 16 + 1) == 0, "После семи файлов найден лишний файл")
end

-- Чтение образа, только что созданного EMPTYTRD и семью SAVETRD
-- Собранные файлы берутся из этого образа, промежуточные BIN не требуются
local disk = readFile(diskPath, diskSize)
local decoded = disk:sub(gameDiskOffset + 1, gameDiskOffset + gameSize)
local system = readFile("Tools/Disasm/Disk/track00.bin", 4096)
local freeSpace = readFile("Tools/Disasm/Disk/unallocated.bin", diskSize - freeOffset)
local patches = dofile("Tools/Disasm/Disk/Keys/GameEncoding.lua")

-- Проверка исходных семян до восстановления XOR-кодирования
-- decoded содержит открытые команды, но начальные дисковые байты генератора
-- Это представление исходников, оно отличается от RAM после работы загрузчика
-- Шесть байтов задают три слова #57BC, #0A82, #AD63 в порядке младший байт первым
-- При запуске загрузчик сам получит из них конечные D1 AD 4D A7 CC 45
-- Сохранение конечных семян на диске изменило бы последовательность декодирования
assert(decoded:sub(0xDEC0 - gameBase + 1, 0xDEC5 - gameBase + 1)
    == string.char(0xBC, 0x57, 0x82, 0x0A, 0x63, 0xAD),
    "В исходнике игры изменены начальные семена генератора")
assert(type(patches) == "table" and #patches == 244, "Неверное число XOR-поправок")
checkService(disk)
checkService(system)

-- Проверка размещения семи файлов, записанных SAVETRD
-- Сохранение их собранного содержимого в памяти до восстановления хвостов
for index, entry in ipairs(files) do
    checkEntry(disk, index, entry, false)
    checkEntry(system, index, entry, true)
    entry.compiled = disk:sub(entry.offset + 1, entry.offset + entry.size)
    entry.tail = readFile("Tools/Disasm/Extracted/Active/" .. entry.file .. ".tail.bin",
        entry.sectors * 256 - entry.size)
    -- Проверка маркера автозапуска до замены хвостов секторов
    if entry.line then
        local marker = string.char(0x80, 0xAA, entry.line % 256, entry.line // 256)
        assert(disk:sub(entry.offset + entry.size + 1, entry.offset + entry.size + 4)
            == marker, "Неверный маркер автозапуска " .. entry.file)
        assert(entry.tail:sub(1, 4) == marker,
            "Исходный хвост содержит другой автозапуск " .. entry.file)
    end
end

-- Обратное кодирование 244 байт на диске
-- Возвращаем изменённые биты, которые исходный загрузчик снимет перед входом в игру
-- Для того же адреса и той же маски операция XOR отменяет предыдущую операцию XOR
-- Поэтому к каждому открытому байту применяется маска из исходной последовательности
-- Таблица относится к данному образу и его исходному состоянию генератора
-- Она не вычисляется заново вызовом загрузчика на уже подготовленной памяти
-- Из 245 записей загрузчика исключена запись в текущее состояние по #DEC2
-- Она меняла #06 в #26 во время работы, исходный дисковый байт там равен #82
-- Исходные шесть байтов состояния уже находятся в decoded и остаются неизменными
local encoded = decoded
local seen = {}
for _, patch in ipairs(patches) do
    local offset, mask, address = patch[1], patch[2], patch[3]
    -- Проверка адреса, маски и отсутствия повторного XOR одного байта
    assert(offset >= 0 and offset < gameSize and offset % 1 == 0,
        "Смещение XOR выходит за пределы файла")
    assert(address == offset + gameBase, "Адрес XOR не соответствует смещению")
    assert(address < 0xDEC0 or address > 0xDEC5, "XOR затрагивает семена генератора")
    assert(mask >= 1 and mask <= 128 and (mask & (mask - 1)) == 0,
        "Маска XOR должна содержать один бит")
    assert(not seen[offset], "Повторное смещение XOR")
    seen[offset] = true
    -- Расчёт дискового представления из собранного открытого байта
    encoded = replace(encoded, offset, string.char(encoded:byte(offset + 1) ~ mask))
end

-- Восстановление служебной дорожки, секторных хвостов и свободной области
-- track00.bin возвращает игре исходное поле #FFE6, а утилите поле #6000
-- Ни один логический файл при восстановлении этих областей не заменяется
disk = replace(disk, gameDiskOffset, encoded)
disk = replace(disk, 0, system)
for index, entry in ipairs(files) do
    disk = replace(disk, entry.offset + entry.size, entry.tail)
    -- Проверка неприкосновенности логического содержимого после восстановления хвоста
    local expected = index == 3 and encoded or entry.compiled
    assert(disk:sub(entry.offset + 1, entry.offset + entry.size) == expected,
        "Восстановление хвоста изменило файл " .. entry.file)
end
disk = replace(disk, freeOffset, freeSpace)

-- Запись восстановленного TRD без внешнего упаковщика и промежуточных файлов
assert(#disk == diskSize, "Финальная длина диска изменилась")
writeFile(diskPath, disk)

-- Проверка каждого байта уже записанного образа по неизменному оригиналу
-- Оригинал служит только эталоном проверки и не подменяет собранные файлы
local result = readFile(diskPath, diskSize)
local original = readFile("Tools/Disasm/Disk/original.trd", diskSize)
for index = 1, diskSize do
    assert(result:byte(index) == original:byte(index),
        string.format("TRD отличается от оригинала по смещению #%06X", index - 1))
end

-- Проверка семи логических файлов непосредственно внутри готового TRD
local fileReports = {}
for index, entry in ipairs(files) do
    local sourcePath = "Tools/Disasm/Extracted/Active/" .. entry.file
    local source = readFile(sourcePath, entry.size)
    local payload = result:sub(entry.offset + 1, entry.offset + entry.size)
    assert(payload == source, "Логический файл отличается от оригинала " .. entry.file)
    fileReports[index] = string.format(
        '    { "file": "%s", "bytes": %d, "disk_offset": %d, ' ..
        '"source": "%s", "identical": true }',
        entry.file, entry.size, entry.offset, sourcePath)
end

-- Сохранение результата именно этой сборки, SHA-256 здесь не вычисляется
-- Совпадение байтов не является доказательством полноты смысловых комментариев
local report = '{\n  "checked_at_utc": "' .. os.date("!%Y-%m-%dT%H:%M:%SZ") ..
    '",\n  "status": "passed",\n  "method": "sjasmplus_lua",' ..
    '\n  "assembler": "Tools/Sjasmplus/sjasmplus.exe",' ..
    '\n  "image": "ELITE3HL.TRD",\n  "original": "Tools/Disasm/Disk/original.trd",' ..
    '\n  "image_bytes": 655360,\n  "byte_identical": true,\n  "files": [\n' ..
    table.concat(fileReports, ",\n") .. '\n  ],' ..
    '\n  "semantic_audit": "Tools/Disasm/Reports/SemanticAudit.json"\n}\n'
writeFile("Tools/Disasm/Reports/BuildVerification.json", report)
print("TRD восстановлен, 7 файлов, 244 XOR-поправки, 655360 байт")
