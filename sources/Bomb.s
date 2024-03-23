; Bomb.s : 爆発
;


; モジュール宣言
;
    .module Bomb

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include	"Bomb.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; 爆発を初期化する
;
_BombInitialize::
    
    ; レジスタの保存
    
    ; 爆発の初期化
    ld      hl, #(_bomb + 0x0000)
    ld      de, #(_bomb + 0x0001)
    ld      bc, #(BOMB_LENGTH * BOMB_ENTRY - 0x0001)
    ld      (hl), #0x00
    ldir

    ; エントリの初期化
    xor     a
    ld      (bombEntry), a

    ; スプライトの初期化
    xor     a
    ld      (bombSpriteRotate), a

    ; レジスタの復帰
    
    ; 終了
    ret

; 爆発を更新する
;
_BombUpdate::
    
    ; レジスタの保存

    ; 爆発の走査
    ld      ix, #_bomb
    ld      de, #BOMB_LENGTH
    ld      b, #BOMB_ENTRY
10$:
    
    ; フレームの更新
    ld      a, BOMB_FRAME(ix)
    or      a
    jr      z, 19$
    dec     a
    ld      BOMB_FRAME(ix), a

    ; 半径の取得
    cp      #BOMB_FRAME_DAMAGE
    ld      a, #BOMB_R_DAMAGE
    jr      z, 11$
    xor     a
11$:
    ld      BOMB_R(ix), a

    ; 次の爆発へ
19$:
    add     ix, de
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; 爆発を描画する
;
_BombRender::

    ; レジスタの保存

    ; 爆発の走査
    ld      ix, #_bomb
    ld      a, (bombSpriteRotate)
    ld      e, a
    ld      d, #0x00
    ld      b, #BOMB_ENTRY
100$:
    push    bc

    ; 描画の確認
    ld      a, BOMB_FRAME(ix)
    or      a
    jr      z, 190$

    ; スプライトの描画
110$:
    ld      hl, #(_sprite + GAME_SPRITE_BOMB)
    add     hl, de
    ld      a, BOMB_POSITION_Y(ix)
    add     a, #(-0x08 - 0x01 + APP_VIEW_Y * APP_VIEW_PIXEL)
    ld      (hl), a
    inc     hl
    ld      c, #(0x00 | VDP_COLOR_MEDIUM_RED)
    ld      a, BOMB_POSITION_X(ix)
    cp      #0x80
    jr      nc, 111$
    add     a, #0x20
    ld      c, #(0x80 | VDP_COLOR_MEDIUM_RED)
111$:
    add     a, #(-0x08 + APP_VIEW_X * APP_VIEW_PIXEL)
    ld      (hl), a
    inc     hl
    ld      a, BOMB_FRAME(ix)
    add     a, #0x08
    ld      (hl), a
    inc     hl
    ld      (hl), c
;   inc     hl
    ld      a, e
    add     a, #0x04
    cp      #(BOMB_ENTRY * 0x04)
    jr      c, 112$
    xor     a
112$:
    ld      e, a
;   jr      190$

    ; 次の爆発へ
190$:
    ld      bc, #BOMB_LENGTH
    add     ix, bc
    pop     bc
    djnz    100$

    ; スプライトの更新
    ld      a, (bombSpriteRotate)
    add     a, #0x04
    cp      #(BOMB_ENTRY * 0x04)
    jr      c, 20$
    xor     a
20$:
    ld      (bombSpriteRotate), a

    ; レジスタの復帰

    ; 終了
    ret

; 爆発を登録する
;
_BombEntry::

    ; レジスタの保存
    push    bc
    push    ix

    ; de < Y/X 位置

    ; 爆発の設定
    ld      a, (bombEntry)
    ld      c, a
    ld      b, #0x00
    ld      ix, #_bomb
    add     ix, bc
    ld      BOMB_FRAME(ix), #BOMB_FRAME_START
    ld      BOMB_R(ix), #0x00
    ld      BOMB_POSITION_X(ix), e
    ld      BOMB_POSITION_Y(ix), d

    ; エントリの更新
    add     a, #BOMB_LENGTH
    cp      #(BOMB_ENTRY * BOMB_LENGTH)
    jr      c, 20$
    xor     a
20$:
    ld      (bombEntry), a

    ; SE の再生
    ld      a, #SOUND_SE_BOMB
    call    _SoundPlaySeB

    ; レジスタの復帰
    pop     ix
    pop     bc

    ; 終了
    ret

; 定数の定義
;


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; 爆発
;
_bomb::
    
    .ds     BOMB_LENGTH * BOMB_ENTRY

; エントリ
;
bombEntry:

    .ds     0x01

; スプライト
;
bombSpriteRotate:

    .ds     0x01

