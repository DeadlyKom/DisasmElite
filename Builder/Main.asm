; -----------------------------------------
; сборка семи файлов исходного диска ELITE3HL
; адреса ORG здесь задают буфер ассемблера
; исполняемые адреса встроенных программ задаются их исходниками
; запуск из корня проекта, листинг и символы сохраняются в Tmp
; требуется sjasmplus 1.20 или новее со встроенным Lua 5.4 или новее
; задача Build напрямую запускает Tools/Sjasmplus/sjasmplus.exe
; -----------------------------------------
                ; сброс прежнего результата до первого прохода сборки
                LUA PASS1
                    local path = "Tools/Disasm/Reports/BuildVerification.json"
                    local file = assert(io.open(path, "wb"))
                    assert(file:write('{\n  "checked_at_utc": "' ..
                        os.date("!%Y-%m-%dT%H:%M:%SZ") ..
                        '",\n  "status": "in_progress",\n  "method": "sjasmplus_lua",' ..
                        '\n  "byte_identical": null\n}\n'))
                    assert(file:close())
                ENDLUA

                DEVICE ZXSPECTRUM48
                INCLUDE "../Includes/Structs/Include.inc"
                INCLUDE "../Includes/Const/Include.inc"
                INCLUDE "../Includes/Variables/Include.inc"

                ; создание диска средствами sjasmplus
                EMPTYTRD "ELITE3HL.TRD", "ELITE3HL"

                ; сборка инструкции и её BASIC-оболочки
                ORG 0
ManualBegin:    EQU $
                INCLUDE "../Source/Manual/Include.inc"
ManualEnd:      EQU $
                ; проверка длины первого файла без маркера автозапуска
                ASSERT ManualEnd - ManualBegin = 16754
                SAVETRD "ELITE3HL.TRD", "ELITE3HL.B", ManualBegin, 16754, 10, 16754

                ; сборка BASIC-загрузчика и встроенного кода по адресу #C800
                ORG 0
LoaderBegin:    EQU $
                INCLUDE "../Source/Loader/Include.inc"
LoaderEnd:      EQU $
                ; проверка длины загрузчика без маркера автозапуска
                ASSERT LoaderEnd - LoaderBegin = 385
                SAVETRD "ELITE3HL.TRD", "ELITE3.B", LoaderBegin, 385, 10, 385

                ; сборка игры в адресах, используемых её машинным кодом
                ; семена генератора в #DEC0..#DEC5 остаются исходными
                ORG #4000
GameBegin:      EQU $
                INCLUDE "../Source/Game/Include.inc"
GameEnd:        EQU $
                ; проверка покрытия всей области #4000..#FFFF
                ASSERT GameEnd - GameBegin = #C000
                SAVETRD "ELITE3HL.TRD", "ELITE3.C", GameBegin, #C000

                ; сборка двух дисковых оверлеев с исходными адресами исполнения
                ORG 0
UtilityBegin:   EQU $
                INCLUDE "../Source/DiskUtility/Include.inc"
UtilityEnd:     EQU $
                ; проверка длины утилиты и её данных
                ASSERT UtilityEnd - UtilityBegin = 4352
                SAVETRD "ELITE3HL.TRD", "cl.C", UtilityBegin, 4352

                ; сборка начальной строки BASIC
                ORG 0
BootBegin:      EQU $
                INCLUDE "../Source/Boot/Include.inc"
BootEnd:        EQU $
                ; проверка длины начальной строки без маркера автозапуска
                ASSERT BootEnd - BootBegin = 32
                SAVETRD "ELITE3HL.TRD", "boot.B", BootBegin, 32, 1, 32

                ; сборка исходного состояния командира QS1
                ORG 0
QS1Begin:       EQU $
                INCLUDE "../Source/Commanders/QS1.asm"
QS1End:         EQU $
                ; проверка длины состояния без секторного дополнения
                ASSERT QS1End - QS1Begin = 102
                SAVETRD "ELITE3HL.TRD", "QS1.C", QS1Begin, 102

                ; сборка исходного состояния командира DEADLY
                ORG 0
DeadlyBegin:    EQU $
                INCLUDE "../Source/Commanders/Deadly.asm"
DeadlyEnd:      EQU $
                ; проверка длины состояния без секторного дополнения
                ASSERT DeadlyEnd - DeadlyBegin = 102
                SAVETRD "ELITE3HL.TRD", "DEADLY.C", DeadlyBegin, 102

                ; восстановление дискового кодирования и побочных байт образа
                ; финализатор выполняется встроенным Lua в конце третьего прохода
                IF _ERRORS = 0
                LUA PASS3
                    local ok, reason = pcall(dofile, "Tools/pack.lua")
                    if not ok then
                        local path = "Tools/Disasm/Reports/BuildVerification.json"
                        local file = assert(io.open(path, "wb"))
                        assert(file:write('{\n  "checked_at_utc": "' ..
                            os.date("!%Y-%m-%dT%H:%M:%SZ") ..
                            '",\n  "status": "failed",\n  "method": "sjasmplus_lua",' ..
                            '\n  "byte_identical": null\n}\n'))
                        assert(file:close())
                        error(reason)
                    end
                ENDLUA
                ELSE
                LUA PASS3
                    local path = "Tools/Disasm/Reports/BuildVerification.json"
                    local file = assert(io.open(path, "wb"))
                    assert(file:write('{\n  "checked_at_utc": "' ..
                        os.date("!%Y-%m-%dT%H:%M:%SZ") ..
                        '",\n  "status": "failed",\n  "method": "sjasmplus_lua",' ..
                        '\n  "byte_identical": null\n}\n'))
                    assert(file:close())
                ENDLUA
                ENDIF
