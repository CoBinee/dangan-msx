; Fade.s : フェード
;


; モジュール宣言
;
    .module Fade

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include	"Fade.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; フェードを初期化する
;
_FadeInitialize::
    
    ; レジスタの保存
    
    ; フェードの初期化
    ld      hl, #(_fade + 0x0000)
    ld      de, #(_fade + 0x0001)
    ld      bc, #(FADE_LENGTH * APP_VIEW_SIZE_Y - 0x0001)
    ld      (hl), #0x00
    ldir

    ; レジスタの復帰
    
    ; 終了
    ret

; フェードを描画する
;
_FadeRender::

    ; レジスタの保存

    ; フェードの描画
    ld      hl, #(_patternName + APP_VIEW_SIZE_X * APP_VIEW_Y)
    ld      de, #_fade
    ld      b, #APP_VIEW_SIZE_Y
10$:
    push    bc
    push    hl
    inc     de
    ld      a, (de)
    inc     de
    ld      c, a
    ld      b, #0x00
    add     hl, bc
    ld      a, (de)
    inc     de
    or      a
    jr      z, 19$
    ld      b, a
    ld      a, #APP_PATTERN_NAME_BLANK
11$:
    ld      (hl), a
    inc     hl
    djnz    11$
19$:
    pop     hl
    ld      bc, #APP_VIEW_SIZE_X
    add     hl, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; フェードインを開始する
;
_FadeInStart::

    ; レジスタの保存

    ; フェードの設定
    ld      hl, #_fade
    ld      b, #APP_VIEW_SIZE_Y
10$:
    call    _SystemGetRandom
    and     #0x07
    cp      #0x02
    jr      nc, 11$
    inc     a
    add     a, a
    inc     a
11$:
    ld      (hl), a
    inc     hl
    ld      (hl), #0x00
    inc     hl
    ld      (hl), #APP_VIEW_SIZE_X
    inc     hl
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; フェードインを更新する
;
_FadeInUpdate::
    
    ; レジスタの保存

    ; フェードの更新
    ld      hl, #_fade
    ld      e, #APP_VIEW_SIZE_X
    ld      b, #APP_VIEW_SIZE_Y
10$:
    ld      a, (hl)
    inc     hl
    add     a, (hl)
    cp      e
    jr      nc, 11$
    ld      (hl), a
    inc     hl
    sub     e
    neg
    ld      (hl), a
    inc     hl
    jr      19$
11$:
    ld      (hl), e
    inc     hl
    ld      (hl), #0x00
    inc     hl
;   jr      19$
19$:
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; フェードインが完了したかどうかを判定する
;
_FadeInIsDone::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; cf > 1 = 完了

    ; フェードの判定
    ld      hl, #(_fade + FADE_FILL)
    ld      de, #FADE_LENGTH
    ld      b, #APP_VIEW_SIZE_Y
10$:
    ld      a, (hl)
    or      a
    jr      nz, 19$
    add     hl, de
    djnz    10$
    scf
19$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; フェードアウトを開始する
;
_FadeOutStart::

    ; レジスタの保存

    ; フェードの設定
    ld      hl, #_fade
    ld      b, #APP_VIEW_SIZE_Y
10$:
    call    _SystemGetRandom
    and     #0x07
    cp      #0x02
    jr      nc, 11$
    inc     a
    add     a, a
    inc     a
11$:
    ld      (hl), a
    inc     hl
    xor     a
    ld      (hl), a
    inc     hl
    ld      (hl), a
    inc     hl
    djnz    10$

    ; レジスタの復帰

    ; 終了
    ret

; フェードアウトを更新する
;
_FadeOutUpdate::
    
    ; レジスタの保存

    ; フェードの更新
    ld      hl, #_fade
    ld      e, #APP_VIEW_SIZE_X
    ld      b, #APP_VIEW_SIZE_Y
10$:
    ld      a, (hl)
    inc     hl
    inc     hl
    add     a, (hl)
    cp      e
    jr      c, 11$
    ld      a, e
11$:
    ld      (hl), a
    inc     hl
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; フェードアウトが完了したかどうかを判定する
;
_FadeOutIsDone::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; cf > 1 = 完了

    ; フェードの判定
    ld      hl, #(_fade + FADE_FILL)
    ld      de, #FADE_LENGTH
    ld      bc, #((APP_VIEW_SIZE_Y << 8) | APP_VIEW_SIZE_X)
10$:
    ld      a, (hl)
    cp      c
    jr      c, 18$
    add     hl, de
    djnz    10$
    scf
    jr      19$
18$:
    or      a
19$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 定数の定義
;


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; フェード
;
_fade::
    
    .ds     FADE_LENGTH * APP_VIEW_SIZE_Y

