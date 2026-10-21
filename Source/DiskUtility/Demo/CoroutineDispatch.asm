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
;   StartCoroutine меняет операнд перехода DemoDispatch + 1 с DiskUtility.Demo.StartCoroutine на DiskUtility.Demo.ResumeDemo
; -----------------------------------------
                ; SMC, после первого запуска адрес этого JP заменяется с StartCoroutine на ResumeDemo
DemoDispatch:   JP StartCoroutine
