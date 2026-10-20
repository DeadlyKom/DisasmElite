                ifndef _MANUAL_INCLUDE_
                define _MANUAL_INCLUDE_

                module Manual
                include "Constants.inc"

; файл ELITE3HL.B, исходный просмотрщик и руководство, 16754 логических байта
; адрес размещения файла задаётся внешним модулем, собственный ORG не используется
; BASIC-строка 0 содержит REM, bootstrap, код, шрифт и упакованные данные
FileBegin:      DB #00, #00
                ; исходная длина BASIC-строки 0 вместе с завершающим ENTER
                DW #3E80
                DB #EA
                include "Bootstrap.asm"
                ; проверка исходного смещения перемещаемого кода
                assert $ - FileBegin = #002D
                ; восстановление исходных адресов выполнения просмотрщика
                disp CODE_BASE
                include "Initialize.asm"
                include "Menu.asm"
                include "ShowSection.asm"
                include "LoadGame.asm"
                include "State.asm"
                include "ClearAndTitle.asm"
                include "PrintString.asm"
                include "Data.asm"
                include "Interrupt.asm"
                include "ScrollFrame.asm"
                include "RenderEdge.asm"
                include "AdvanceText.asm"
                include "LegacyLimit.asm"
                include "RenderGlyph.asm"
                include "UpdateKeys.asm"
                include "UndoDirection.asm"
                include "CheckBoundary.asm"
                include "ResumePixel.asm"
                include "ReadControls.asm"
                include "NextScanline.asm"
                include "PrevScanline.asm"
                include "UnpackText.asm"
                ent
                ; проверка смещения шрифта в исходном BASIC-файле
                assert $ - FileBegin = #053F
Font:           incbin "Resources/Font.bin"
                ; проверка смещения упакованного текста
                assert $ - FileBegin = #083F
PackedText:     incbin "Resources/PackedText.bin"
                ; проверка смещения завершающего ENTER строки 0
                assert $ - FileBegin = #3E83
                include "BasicTail.asm"
FileEnd:        EQU $
                ; проверка полного логического размера файла
                assert FileEnd - FileBegin = FILE_SIZE
                endmodule

                endif ; ~_MANUAL_INCLUDE_
