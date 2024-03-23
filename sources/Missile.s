; Missile.s : ミサイル
;


; モジュール宣言
;
    .module Missile

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Math.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include    "Stage.inc"
    .include    "Character.inc"
    .include    "Player.inc"
    .include    "Bomb.inc"
    .include	"Missile.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ミサイルを初期化する
;
_MissileInitialize::
    
    ; レジスタの保存
    
    ; ミサイルの初期化
    ld      hl, #(_missile + 0x0000)
    ld      de, #(_missile + 0x0001)
    ld      bc, #(MISSILE_LENGTH * MISSILE_ENTRY - 0x0001)
    ld      (hl), #0x00
    ldir

    ; スプライトの初期化
    xor     a
    ld      (missileSpriteRotate), a

    ; ベクトルの初期化
    ld      hl, #missileVector
    ld      c, #0x00
30$:
    ld      a, c
    call    _MathGetSin
    ld      (hl), e
    inc     hl
    ld      (hl), d
    inc     hl
    ld      a, c
    add     a, #0x80
    call    _MathGetCos
    ld      (hl), e
    inc     hl
    ld      (hl), d
    inc     hl
    inc     c
    jr      nz, 30$

    ; レジスタの復帰
    
    ; 終了
    ret

; ミサイルを更新する
;
_MissileUpdate::
    
    ; レジスタの保存

    ; ミサイルの走査
    ld      ix, #_missile
    ld      b, #MISSILE_ENTRY
10$:
    push    bc

    ; 処理の取得
    ld      l, MISSILE_PROC_L(ix)
    ld      h, MISSILE_PROC_H(ix)
    ld      a, h
    or      l
    jr      z, 19$

    ; 種類別の処理
    ld      de, #11$
    push    de
    jp      (hl)
;   pop     hl
11$:

    ; 次のミサイルへ
19$:
    ld      bc, #MISSILE_LENGTH
    add     ix, bc
    pop     bc
    djnz    10$

    ; レジスタの復帰
    
    ; 終了
    ret

; ミサイルを描画する
;
_MissileRender::

    ; レジスタの保存

    ; ミサイルの走査
    ld      ix, #_missile
    ld      a, (missileSpriteRotate)
    ld      e, a
    ld      d, #0x00
    ld      b, #MISSILE_ENTRY
100$:
    push    bc

    ; 描画の確認
    ld      a, MISSILE_PROC_H(ix)
    or      MISSILE_PROC_L(ix)
    jr      z, 190$

    ; スプライトの描画
110$:
    ld      hl, (_game + GAME_SPRITE_MISSILE_L)
    add     hl, de
    push    de
    ex      de, hl
    ld      a, MISSILE_DIRECTION(ix)
    add     a, #0x10
    and     #0xe0
    rrca
    rrca
    rrca
    ld      c, a
    ld      b, #0x00
    ld      hl, #missileSprite
    add     hl, bc
    ld      a, MISSILE_POSITION_Y_H(ix)
    add     a, (hl)
    add     a, #(APP_VIEW_Y * APP_VIEW_PIXEL)
    ld      (de), a
    inc     hl
    inc     de
    ld      c, #0x00
    ld      a, MISSILE_POSITION_X_H(ix)
    cp      #0x80
    jr      nc, 111$
    add     a, #0x20
    ld      c, #0x80
111$:
    add     a, (hl)
;   add     a, #(APP_VIEW_X * APP_VIEW_PIXEL)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    or      c
    ld      (de), a
;   inc     hl
;   inc     de
    pop     de
    ld      a, e
    add     a, #0x04
    cp      #(MISSILE_ENTRY * 0x04)
    jr      c, 112$
    xor     a
112$:
    ld      e, a
;   jr      190$

    ; 次のミサイルへ
190$:
    ld      bc, #MISSILE_LENGTH
    add     ix, bc
    pop     bc
    djnz    100$

    ; スプライトの更新
    ld      a, (missileSpriteRotate)
    add     a, #0x04
    cp      #(MISSILE_ENTRY * 0x04)
    jr      c, 20$
    xor     a
20$:
    ld      (missileSpriteRotate), a

    ; レジスタの復帰

    ; 終了
    ret

; 何もしない
;
MissileNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; 空のミサイルを取得する
;
MissileGetEmpty:

    ; レジスタの保存
    push    de

    ; ix > ミサイル
    ; cf > 1 = 取得できた

    ; ミサイルの取得
    ld      ix, #_missile
    ld      de, #MISSILE_LENGTH
    ld      b, #MISSILE_ENTRY
10$:
    ld      a, MISSILE_PROC_H(ix)
    or      MISSILE_PROC_L(ix)
    jr      z, 11$
    add     ix, de
    djnz    10$
    or      a
    jr      19$
11$:
    scf
19$:

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; ミサイルを発射する
;
MissileFire:

    ; レジスタの保存
    push    ix

    ; hl < 処理
    ; de < Y/X 位置
    ; c  < 向き

    ; ミサイルの設定
    call    MissileGetEmpty
    jr      nc, 19$
    xor     a
    ld      MISSILE_PROC_L(ix), l
    ld      MISSILE_PROC_H(ix), h
    ld      MISSILE_STATE(ix), a
    ld      MISSILE_POSITION_X_L(ix), a
    ld      MISSILE_POSITION_X_H(ix), e
    ld      MISSILE_POSITION_Y_L(ix), a
    ld      MISSILE_POSITION_Y_H(ix), d
    ld      MISSILE_DIRECTION(ix), c
    ld      MISSILE_SPEED_0(ix), a
    ld      MISSILE_SPEED_1(ix), a
    ld      MISSILE_FRAME(ix), a
19$:

    ; レジスタの復帰
    pop     ix

    ; 終了
    ret

; ミサイルが移動する
;
MissileMove:

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; ix < ミサイル

    ; 速度の更新
    ld      a, MISSILE_SPEED_0(ix)
    or      a
    jr      z, 10$
    dec     MISSILE_SPEED_0(ix)
    jp      90$

    ; 画面外の初期化
10$:
    ld      c, #0x00

    ; ベクトルの取得
    ld      a, MISSILE_DIRECTION(ix)
    ld      d, #0x00
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      e, a
    ld      hl, #missileVector
    add     hl, de

    ; X の移動
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    inc     hl
    push    hl
    ld      l, MISSILE_POSITION_X_L(ix)
    ld      h, MISSILE_POSITION_X_H(ix)
    bit     #0x07, d
    jr      z, 20$
    ld      a, e
    cpl
    ld      e, a
    ld      a, d
    cpl
    ld      d, a
    inc     de
    or      a
    sbc     hl, de
    jr      nc, 29$
    ld      hl, #0x0000
    inc     c
    jr      29$
20$:
    or      a
    adc     hl, de
    jr      nc, 29$
    ld      hl, #0xffff
    inc     c
;   jr      29$
29$:
    ld      MISSILE_POSITION_X_L(ix), l
    ld      MISSILE_POSITION_X_H(ix), h
    pop     hl

    ; Y の移動
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
;   push    hl
    ld      l, MISSILE_POSITION_Y_L(ix)
    ld      h, MISSILE_POSITION_Y_H(ix)
    bit     #0x07, d
    jr      z, 30$
    ld      a, e
    cpl
    ld      e, a
    ld      a, d
    cpl
    ld      d, a
    inc     de
    or      a
    sbc     hl, de
    jr      nc, 39$
    ld      hl, #0x0000
    inc     c
    jr      39$
30$:
    add     hl, de
    ld      a, h
    cp      #(STAGE_SIZE_Y * STAGE_SIZE_PIXEL)
    jr      c, 39$
    ld      hl, #(((STAGE_SIZE_Y * STAGE_SIZE_PIXEL) << 8) - 0x0001)
    inc     c
;   jr      39$
39$:
    ld      MISSILE_POSITION_Y_L(ix), l
    ld      MISSILE_POSITION_Y_H(ix), h
;   pop     hl

    ; 速度の更新
    ld      a, MISSILE_SPEED_1(ix)
    or      a
    jr      z, 49$
    dec     a
    ld      MISSILE_SPEED_1(ix), a
    srl     a
    ld      MISSILE_SPEED_0(ix), a
49$:

    ; 画面外の判定
    ld      a, c
    or      a
    jr      z, 90$

    ; ミサイルの削除
    xor     a
    ld      MISSILE_PROC_L(ix), a
    ld      MISSILE_PROC_H(ix), a
;   jr      90$

    ; 移動の完了
90$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 直進するミサイルを発射する
;
_MissileFireStraight::

    ; レジスタの保存
    push    hl

    ; de < Y/X 位置
    ; c  < 向き

    ; ミサイルの発射
    ld      hl, #MissileStraight
    call    MissileFire

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

MissileStraight:

    ; レジスタの保存

    ; 初期化
    ld      a, MISSILE_STATE(ix)
    or      a
    jr      nz, 09$

    ; 速度の設定
    ld      MISSILE_SPEED_0(ix), #(MISSILE_SPEED_INITIAL >> 1)
    ld      MISSILE_SPEED_1(ix), #MISSILE_SPEED_INITIAL

    ; 初期化の完了
    inc     MISSILE_STATE(ix)
09$:

    ; 移動
    call    MissileMove

    ; 移動の完了
190$:

    ; レジスタの復帰

    ; 終了
    ret

; 誘導するミサイルを発射する
;
_MissileFireHoming::

    ; レジスタの保存
    push    hl

    ; de < Y/X 位置
    ; c  < 向き

    ; ミサイルの発射
    ld      hl, #MissileHoming
    call    MissileFire

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

MissileHoming:

    ; レジスタの保存

    ; 初期化
    ld      a, MISSILE_STATE(ix)
    or      a
    jr      nz, 09$

    ; 速度の設定
    ld      MISSILE_SPEED_0(ix), #(MISSILE_SPEED_INITIAL >> 1)
    ld      MISSILE_SPEED_1(ix), #MISSILE_SPEED_INITIAL

    ; フレームの設定
    ld      MISSILE_FRAME(ix), #0x30

    ; 初期化の完了
    inc     MISSILE_STATE(ix)
09$:

    ; フレームの更新
    ld      a, MISSILE_FRAME(ix)
    or      a
    jr      z, 109$
    dec     MISSILE_FRAME(ix)
109$:
    jr      nz, 180$

    ; プレイヤを狙う
    call    _PlayerIsLive
    jr      nc, 119$
    call    _PlayerGetCenter
    ld      a, MISSILE_POSITION_Y_H(ix)
    srl     a
    srl     d
    sub     d
    ld      l, a
    ld      a, MISSILE_POSITION_X_H(ix)
    srl     a
    srl     e
    sub     e
    neg
    ld      h, a
    call    _MathGetAtan2
    cp      MISSILE_DIRECTION(ix)
    jr      z, 119$
    jp      p, 110$
    dec     MISSILE_DIRECTION(ix)
    jr      119$
110$:
    inc     MISSILE_DIRECTION(ix)
;   jr      119$
119$:

    ; 移動
180$:
    call    MissileMove

    ; 移動の完了
190$:

    ; レジスタの復帰

    ; 終了
    ret

_MissileFireHomingSharp::

    ; レジスタの保存
    push    hl

    ; de < Y/X 位置
    ; c  < 向き

    ; ミサイルの発射
    ld      hl, #MissileHomingSharp
    res     #0x00, c
    call    MissileFire

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

MissileHomingSharp:

    ; レジスタの保存

    ; 初期化
    ld      a, MISSILE_STATE(ix)
    or      a
    jr      nz, 09$

    ; 速度の設定
    ld      MISSILE_SPEED_0(ix), #(MISSILE_SPEED_INITIAL >> 1)
    ld      MISSILE_SPEED_1(ix), #MISSILE_SPEED_INITIAL

    ; フレームの設定
    ld      MISSILE_FRAME(ix), #0x30

    ; 初期化の完了
    inc     MISSILE_STATE(ix)
09$:

    ; フレームの更新
    ld      a, MISSILE_FRAME(ix)
    or      a
    jr      z, 109$
    dec     MISSILE_FRAME(ix)
109$:
    jr      nz, 180$

    ; プレイヤを狙う
    call    _PlayerIsLive
    jr      nc, 119$
    call    _PlayerGetCenter
    ld      a, MISSILE_POSITION_Y_H(ix)
    srl     a
    srl     d
    sub     d
    ld      l, a
    ld      a, MISSILE_POSITION_X_H(ix)
    srl     a
    srl     e
    sub     e
    neg
    ld      h, a
    call    _MathGetAtan2
    and     #0xfe
    cp      MISSILE_DIRECTION(ix)
    jr      z, 119$
    jp      p, 110$
    dec     MISSILE_DIRECTION(ix)
    dec     MISSILE_DIRECTION(ix)
    jr      119$
110$:
    inc     MISSILE_DIRECTION(ix)
    inc     MISSILE_DIRECTION(ix)
;   jr      119$
119$:

    ; 移動
180$:
    call    MissileMove

    ; 移動の完了
190$:

    ; レジスタの復帰

    ; 終了
    ret

; 放物線を描くミサイルを発射する
;
_MissileFireParabola::

    ; レジスタの保存
    push    hl

    ; de < Y/X 位置
    ; c  < 向き

    ; ミサイルの発射
    ld      hl, #MissileParabola
    call    MissileFire

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

MissileParabola:

    ; レジスタの保存

    ; 初期化
    ld      a, MISSILE_STATE(ix)
    or      a
    jr      nz, 09$

    ; 速度の設定
    ld      MISSILE_SPEED_0(ix), #(MISSILE_SPEED_INITIAL >> 1)
    ld      MISSILE_SPEED_1(ix), #MISSILE_SPEED_INITIAL

    ; フレームの設定
    ld      MISSILE_FRAME(ix), #0x10

    ; 初期化の完了
    inc     MISSILE_STATE(ix)
09$:

    ; フレームの更新
    ld      a, MISSILE_FRAME(ix)
    or      a
    jr      z, 109$
    dec     a
    ld      MISSILE_FRAME(ix), a
109$:
    jr      nz, 180$

    ; プレイヤを狙う
    call    _PlayerIsLive
    jr      nc, 119$
    call    _PlayerGetCenter
    ld      a, d
    cp      MISSILE_POSITION_Y_H(ix)
    jr      c, 119$
    ld      a, MISSILE_POSITION_Y_H(ix)
    srl     a
    srl     d
    sub     d
    ld      l, a
    ld      a, MISSILE_POSITION_X_H(ix)
    srl     a
    srl     e
    sub     e
    neg
    ld      h, a
    call    _MathGetAtan2
    ld      c, a
    ld      a, MISSILE_DIRECTION(ix)
    cp      #0x80
    jr      z, 119$
    jr      nc, 110$
    cp      c
    jr      nc, 119$
    inc     MISSILE_DIRECTION(ix)
    jr      119$
110$:
    cp      c
    jr      z, 119$
    jr      c, 119$
    dec     MISSILE_DIRECTION(ix)
;   jr      119$
119$:

    ; 移動
180$:
    call    MissileMove

    ; 移動の完了
190$:

    ; レジスタの復帰

    ; 終了
    ret

; 水平に狙うミサイルを発射する
;
_MissileFireHorizontal::

    ; レジスタの保存
    push    hl

    ; de < Y/X 位置
    ; c  < 向き

    ; ミサイルの発射
    ld      hl, #MissileHorizontal
    call    MissileFire

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

MissileHorizontal:

    ; レジスタの保存

    ; 初期化
    ld      a, MISSILE_STATE(ix)
    or      a
    jr      nz, 09$

    ; 速度の設定
    ld      MISSILE_SPEED_0(ix), #(MISSILE_SPEED_INITIAL >> 1)
    ld      MISSILE_SPEED_1(ix), #MISSILE_SPEED_INITIAL

    ; フレームの設定
    ld      MISSILE_FRAME(ix), #0x30

    ; 初期化の完了
    inc     MISSILE_STATE(ix)
09$:

    ; フレームの更新
    ld      a, MISSILE_FRAME(ix)
    or      a
    jr      z, 109$
    dec     MISSILE_FRAME(ix)
109$:
    jr      nz, 180$

    ; プレイヤを狙う
    call    _PlayerIsLive
    jr      nc, 119$
    call    _PlayerGetCenter
    ld      a, MISSILE_POSITION_Y_H(ix)
    srl     a
    srl     d
    sub     d
    ld      l, a
    ld      a, MISSILE_POSITION_X_H(ix)
    srl     a
    srl     e
    sub     e
    neg
    ld      h, a
    call    _MathGetAtan2
    ld      c, a
    bit     #0x07, MISSILE_DIRECTION(ix)
    jr      z, 111$
    bit     #0x07, c
    jr      z, 119$
    ld      a, MISSILE_DIRECTION(ix)
    cp      c
    jr      z, 119$
    jr      nc, 110$
    cp      #0xc7
    jr      nc, 119$
    inc     MISSILE_DIRECTION(ix)
    jr      119$
110$:
    cp      #0xb9
    jr      c, 119$
    dec     MISSILE_DIRECTION(ix)
    jr      119$
111$:
    bit     #0x07, c
    jr      nz, 119$
    ld      a, MISSILE_DIRECTION(ix)
    cp      c
    jr      z, 119$
    jr      nc, 112$
    cp      #0x47
    jr      nc, 119$
    inc     MISSILE_DIRECTION(ix)
    jr      119$
112$:
    cp      #0x3a
    jr      c, 119$
    dec     MISSILE_DIRECTION(ix)
;   jr      119$
119$:

    ; 移動
180$:
    call    MissileMove

    ; 移動の完了
190$:

    ; レジスタの復帰

    ; 終了
    ret

; 垂直に打ち上げて落下するミサイルを発射する
;
_MissileFireVertical::

    ; レジスタの保存
    push    hl

    ; de < Y/X 位置

    ; ミサイルの発射
    ld      hl, #MissileVertical
    ld      c, #0x00
    call    MissileFire

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

MissileVertical:

    ; レジスタの保存

    ; 初期化
    ld      a, MISSILE_STATE(ix)
    or      a
    jr      nz, 09$

    ; フレームの設定
    ld      MISSILE_FRAME(ix), #0x18

    ; 初期化の完了
    inc     MISSILE_STATE(ix)
09$:

    ; 移動
10$:
    bit     #0x07, MISSILE_STATE(ix)
    jr      nz, 20$

    ; 打ち上げる
    ld      a, MISSILE_POSITION_Y_H(ix)
    sub     #0x04
    ld      MISSILE_POSITION_Y_H(ix), a
    jr      nc, 90$

    ; 位置の設定
    ld      MISSILE_POSITION_Y_H(ix), #-0x08

    ; 状態の更新
    set     #0x07, MISSILE_STATE(ix)
    jr      90$

    ; フレームの更新
20$:
    dec     MISSILE_FRAME(ix)
    jr      nz, 90$

    ; 位置の設定
    call    _PlayerGetPosition
    ld      a, e
    sub     #0x20
    jr      nc, 30$
    xor     a
30$:
    cp      #0xc0
    jr      c, 31$
    ld      a, #0xc0
31$:
    ld      e, a
    call    _SystemGetRandom
    and     #0x3f
    add     a, e
    ld      MISSILE_POSITION_X_H(ix), a
    ld      MISSILE_POSITION_Y_H(ix), #0x00

    ; 向きの設定
    ld      MISSILE_DIRECTION(ix), #0x80

    ; 処理の更新
    ld      hl, #MissileStraight
    ld      MISSILE_PROC_L(ix), l
    ld      MISSILE_PROC_H(ix), h
    ld      MISSILE_STATE(ix), #0x00
;   jr      90$

    ; ミサイルの完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; スプライト
;
missileSprite:

    .db      0x00 - 0x01,  0x00, 0x04, VDP_COLOR_BLACK
    .db      0x00 - 0x01, -0x03, 0x06, VDP_COLOR_BLACK
    .db      0x00 - 0x01, -0x03, 0x05, VDP_COLOR_BLACK
    .db     -0x03 - 0x01, -0x03, 0x07, VDP_COLOR_BLACK
    .db     -0x03 - 0x01, -0x00, 0x04, VDP_COLOR_BLACK
    .db     -0x03 - 0x01,  0x00, 0x06, VDP_COLOR_BLACK
    .db      0x00 - 0x01,  0x00, 0x05, VDP_COLOR_BLACK
    .db      0x00 - 0x01,  0x00, 0x07, VDP_COLOR_BLACK


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ミサイル
;
_missile::
    
    .ds     MISSILE_LENGTH * MISSILE_ENTRY

; スプライト
;
missileSpriteRotate:

    .ds     0x01

; ベクトル
;
missileVector:

    .ds     0x0100 * 0x0004

