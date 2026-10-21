; -----------------------------------------
; Вход установщика демонстрационного оверлея
; исходный диапазон #C800..#C803
; In:
;   оверлей загружен в DiskUtility.DemoSetup.EnterInstaller
; Out:
;   переход в InstallDemo по DiskUtility.DemoSetup.InstallDemo
; Corrupt:
;   по контракту InstallDemo
; Note:
;   NOP сохранён, остаточный LegacyMenuExit пропускается безусловным JP
; -----------------------------------------
                ; вход сразу передаёт управление установщику, сохранившийся выход пропускается
EnterInstaller: NOP
                JP InstallDemo
