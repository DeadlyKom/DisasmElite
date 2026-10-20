                ifndef _STRUCTS_GOODS_
                define _STRUCTS_GOODS_

                struct FGoods                                                   ; количества товаров в трюме или на рынке [17 байт]
Food            DB #00                                                          ; продовольствие, т
Textiles        DB #00                                                          ; текстиль, т
Radioactives    DB #00                                                          ; радиоактивные материалы, т
Slaves          DB #00                                                          ; рабы, т
Liquor          DB #00                                                          ; алкоголь, т
Luxuries        DB #00                                                          ; предметы роскоши, т
Narcotics       DB #00                                                          ; наркотики, т
Computers       DB #00                                                          ; компьютеры, т
Machinery       DB #00                                                          ; промышленное оборудование, т
Alloys          DB #00                                                          ; сплавы, т
Firearms        DB #00                                                          ; огнестрельное оружие, т
Furs            DB #00                                                          ; меха, т
Minerals        DB #00                                                          ; минералы, т
Gold            DB #00                                                          ; золото, кг
Platinum        DB #00                                                          ; платина, кг
Gemstones       DB #00                                                          ; драгоценные камни, г
AlienItems      DB #00                                                          ; инопланетные предметы, т
                ends

                ASSERT FGoods == 17

                endif                                                           ; ~_STRUCTS_GOODS_
