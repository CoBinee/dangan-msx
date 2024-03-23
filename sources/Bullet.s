; Bullet.s : 銃弾
;


; モジュール宣言
;
    .module Bullet

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include	"Bullet.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 銃弾を初期化する
;
_BulletInitialize::
    
    ; レジスタの保存
    
    ; 銃弾の初期化
    ld      hl, #(_bullet + 0x0000)
    ld      de, #(_bullet + 0x0001)
    ld      bc, #(BULLET_LENGTH - 0x0001)
    ld      (hl), #0x00
    ldir

    ; レジスタの復帰
    
    ; 終了
    ret

; 銃弾を更新する
;
_BulletUpdate::
    
    ; レジスタの保存

    ; 銃弾の更新
    ld      hl, #(_bullet + BULLET_ANIMATION)
    ld      a, (hl)
    or      a
    jr      z, 19$
    dec     (hl)
19$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 銃弾を描画する
;
_BulletRender::

    ; レジスタの保存

    ; スプライトの描画
    ld      a, (_bullet + BULLET_ANIMATION)
    or      a
    jr      z, 19$
    ld      b, a
    ld      hl, #(_sprite + GAME_SPRITE_BULLET)
    ld      a, (_bullet + BULLET_POSITION_Y)
    add     a, #(-0x08 - 0x01)
    add     a, #(APP_VIEW_Y * APP_VIEW_PIXEL)
    ld      (hl), a
    inc     hl
    ld      a, (_bullet + BULLET_POSITION_X)
    ld      c, #0x00
    sub     #0x08
    jr      nc, 10$
    add     a, #0x20
    ld      c, #0x80
10$:
;   add     a, #(APP_VIEW_X * APP_VIEW_PIXEL)
    ld      (hl), a
    inc     hl
    ld      (hl), b
    inc     hl
    ld      a, #VDP_COLOR_MEDIUM_RED
    add     a, c
    ld      (hl), a
;   inc     hl
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 銃弾を登録する
;
_BulletEntry:

    ; レジスタの保存

    ; de < Y/X 位置

    ; 銃弾の設定
    ld      (_bullet + BULLET_POSITION_X), de
    ld      a, #(0x03 + 0x01)
    ld      (_bullet + BULLET_ANIMATION), a

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 銃弾
;
_bullet::
    
    .ds     BULLET_LENGTH

