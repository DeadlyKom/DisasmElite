; -----------------------------------------
; Переключаемый вход первого запуска и возобновления
; исходный диапазон #E6E0..#E6E2
; In:
;   стек вызова из FrameHook
; Out:
;   первый вызов StartCoroutine, следующие ResumeDemo
; Corrupt:
;   по выбранному пути
; Note:
;   StartCoroutine меняет адрес по E6E1 с E6E3 на E6F3
; -----------------------------------------
                ; SMC, после первого запуска адрес этого JP заменяется с StartCoroutine на ResumeDemo
DemoDispatch:   JP StartCoroutine
