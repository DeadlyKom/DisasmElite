; -----------------------------------------
; указатели приёмного и форматируемого потоков и параметр дальнейшего перехода
; исходный диапазон #CF96..#CF9B
; In:
;   ReadTrackMark, BuildTrackData, FormatTrack, ConfirmCopy
; Out:
;   три слова (Memory.Screen + #0120), DiskStream.Format, #0100
; Corrupt:
;   нет
; Note:
;   DiskUtility.Menu.ReadTrackBuffer используется как начальный адрес чтения дорожки.
;   DiskUtility.Menu.TrackBuffer задаёт буфер построения и отправки форматируемой дорожки.
;   DiskUtility.Menu.CopyParameter исходно #0100, ConfirmCopy заменяет его подтверждённым DE.
;   Чтение изменённого DiskUtility.Menu.CopyParameter собственным Menu не найдено.
; -----------------------------------------
ReadTrackBuffer DW #4120                                                        ; начало принимаемого потока дорожки
TrackBuffer     DW #4014                                                        ; начало потока форматируемой дорожки
CopyParameter   DW #0100                                                        ; подтверждённый параметр для перехода в копировщик
