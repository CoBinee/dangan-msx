; Fade.inc : フェード
;


; マクロの定義
;

; フェード
FADE_SPEED                      =   0x00
FADE_HEAD                       =   0x01
FADE_FILL                       =   0x02
FADE_LENGTH                     =   0x03

; 外部関数宣言
;

    .globl  _FadeInitialize
    .globl  _FadeRender
    .globl  _FadeInStart
    .globl  _FadeInUpdate
    .globl  _FadeInIsDone
    .globl  _FadeOutStart
    .globl  _FadeOutUpdate
    .globl  _FadeOutIsDone

; 外部変数宣言
;

    .globl  _fade
