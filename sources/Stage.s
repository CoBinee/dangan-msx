; Stage.s : ステージ
;


; モジュール宣言
;
    .module Stage

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include	"Stage.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ステージを初期化する
;
_StageInitialize::
    
    ; レジスタの保存
    
    ; ステージの初期化
    ld      hl, #(_stage + 0x0000)
    ld      de, #(_stage + 0x0001)
    ld      bc, #(STAGE_SIZE_X * STAGE_SIZE_Y - 0x0001)
    ld      (hl), #0x00
    ldir

    ; レジスタの復帰
    
    ; 終了
    ret

; ステージを更新する
;
_StageUpdate::
    
    ; レジスタの保存

    ; レジスタの復帰
    
    ; 終了
    ret

; ステージを描画する
;
_StageRender::

    ; レジスタの保存

    ; ステージの描画
    ld      hl, #_stage
    ld      de, #(_patternName + 0x0020 * APP_VIEW_Y)
    ld      bc, #(APP_VIEW_SIZE_X * APP_VIEW_SIZE_Y)
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; ステージを作成する
;
_StageBuild::

    ; レジスタの保存

    ; hl < ステージ

    ; ステージの設定
    ld      de, #_stage
    ld      bc, #(STAGE_SIZE_X * STAGE_SIZE_Y)
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; ステージの位置を取得する
;
_StageCalc::

    ; レジスタの保存
    push    de

    ; de < Y/X 位置
    ; hl > ステージ
    ; cf > 1 = ステージ外

    ; ステージの取得
    ld      a, d
    cp      #(STAGE_SIZE_Y * STAGE_SIZE_PIXEL)
    jr      nc, 10$
    srl     e
    srl     e
    srl     e
    ld      a, d
    and     #0xf8
    ld      d, #0x00
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, e
    ld      e, a
    ld      hl, #_stage
    add     hl, de
    or      a
    jr      19$
10$:
    scf
;   jr      19$
19$:

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; ステージを取得する
;
_StageGet::

    ; レジスタの保存
    push    hl

    ; de < Y/X 位置
    ; a  > ステージ

    ; ステージの取得
    call    _StageCalc
    jr      c, 10$
    ld      a, (hl)
    jr      19$
10$:
    ld      a, #STAGE_BLOCK_FIXED
;   jr      19$
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; 地面の Y 位置を取得する
;
_StageGetGroundY::

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; a < X 位置
    ; a > Y 位置

    ; 位置の取得
    and     #0xf8
    rrca
    rrca
    rrca
    ld      e, a
    ld      d, #0x00
    ld      hl, #(_stage + (STAGE_SIZE_Y - 0x01) * STAGE_SIZE_X)
    add     hl, de
    ld      de, #-STAGE_SIZE_X
    ld      b, #STAGE_SIZE_Y
10$:
    ld      a, (hl)
    cp      #STAGE_BLOCK
    jr      c, 11$
    add     hl, de
    djnz    10$
11$:
    ld      a, b
    add     a, a
    add     a, a
    add     a, a
    dec     a

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; ブロックかどうかを判定する
;
_StageIsBlock::

    ; レジスタの保存

    ; de < Y/X 位置
    ; cf > 1 = ブロック

    ; ブロックの判定
    call    _StageGet
    cp      #STAGE_BLOCK
    ccf

    ; レジスタの復帰

    ; 終了
    ret

_StageIsBlockDownable::

    ; レジスタの保存

    ; de < Y/X 位置
    ; cf > 1 = 降りられるブロック

    ; ブロックの判定
    call    _StageGet
    cp      #STAGE_BLOCK_DOWNABLE
    jr      z, 10$
    or      a
    jr      19$
10$:
    scf
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

_StageIsBlockNotDownable::

    ; レジスタの保存

    ; de < Y/X 位置
    ; cf > 1 = 降りられるないブロック

    ; ブロックの判定
    call    _StageGet
    cp      #STAGE_BLOCK
    jr      c, 10$
    cp      #STAGE_BLOCK_DOWNABLE
    jr      z, 10$
    scf
    jr      19$
10$:
    or      a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ダメージを受けるかどうかを判定する
;
_StageIsDamage::

    ; レジスタの保存

    ; de < Y/X 位置
    ; cf > 1 = ダメージ

    ; ブロックの判定
    call    _StageGet
    cp      #STAGE_DAMAGE
    ccf
    jr      nc, 19$
    cp      #STAGE_BLOCK
19$:

    ; レジスタの復帰

    ; 終了
    ret

; レイを飛ばす
;
_StageRay_0900::

    ; レジスタの保存
    push    hl

    ; de < 開始 Y/X 位置
    ; de > 終了 Y/X 位置

    ; レイを飛ばす
    call    _StageCalc
    jr      c, 190$
    ld      a, (hl)
    cp      #STAGE_BLOCK
    jr      nc, 190$
    ld      a, e
    and     #0xf8
    ld      e, a
    jr      z, 190$
100$:
    dec     hl
    ld      a, (hl)
    cp      #STAGE_BLOCK
    jr      nc, 190$
    ld      a, e
    sub     #0x08
    ld      e, a
    jr      nz, 100$
190$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

_StageRay_1030::

    ; レジスタの保存
    push    hl
    push    bc

    ; de < 開始 Y/X 位置
    ; de > 終了 Y/X 位置

    ; レイを飛ばす
    call    _StageCalc
    jp      c, 190$
    ld      a, (hl)
    cp      #STAGE_BLOCK
    jr      nc, 190$
    ld      a, e
    and     #0x07
    ld      c, a
    ld      a, d
    and     #0x07
    ld      b, a
    sub     c
    jr      z, 100$
    jr      c, 110$
    jr      120$
100$:
    ld      a, e
    sub     c
    ld      e, a
    ld      a, d
    sub     b
    ld      d, a
    jr      z, 190$
    ld      a, e
    or      a
    jr      z, 190$
    ld      bc, #-0x0021
101$:
    add     hl, bc
    ld      a, (hl)
    cp      #STAGE_BLOCK
    jr      nc, 190$
    ld      a, e
    sub     #0x08
    ld      e, a
    ld      a, d
    sub     #0x08
    ld      d, a
    jr      z, 190$
    ld      a, e
    or      a
    jr      z, 190$
    jr      101$
110$:
    ld      a, d
    sub     b
    ld      d, a
    ld      a, e
    sub     b
    ld      e, a
    and     #0x07
    ld      b, a
    ld      a, #0x08
    sub     b
    ld      c, a
    ld      a, d
    or      a
    jr      z, 190$
    jr      130$
120$:
    ld      a, e
    sub     c
    ld      e, a
    ld      a, d
    sub     c
    ld      d, a
    and     #0x07
    ld      c, a
    ld      a, #0x08
    sub     c
    ld      b, a
    ld      a, e
    or      e
    jr      z, 190$
    jr      140$
130$:
    push    de
    ld      de, #-0x0020
    add     hl, de
    pop     de
    ld      a, (hl)
    cp      #STAGE_BLOCK
    jr      nc, 190$
    ld      a, d
    sub     b
    ld      d, a
    ld      a, e
    sub     b
    ld      e, a
    jr      z, 190$
;   jr      140$
140$:
    dec     hl
    ld      a, (hl)
    cp      #STAGE_BLOCK
    jr      nc, 190$
    ld      a, e
    sub     c
    ld      e, a
    ld      a, d
    sub     c
    ld      d, a
    jr      z, 190$
    jr      130$
190$:

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

_StageRay_0000::

    ; レジスタの保存
    push    hl
    push    bc

    ; de < 開始 Y/X 位置
    ; de > 終了 Y/X 位置

    ; レイを飛ばす
    call    _StageCalc
    jr      c, 190$
    ld      a, (hl)
    cp      #STAGE_BLOCK
    jr      nc, 190$
    ld      a, d
    and     #0xf8
    ld      d, a
    jr      z, 190$
    ld      bc, #-0x0020
100$:
    add     hl, bc
    ld      a, (hl)
    cp      #STAGE_BLOCK
    jr      nc, 190$
    ld      a, d
    sub     #0x08
    ld      d, a
    jr      nz, 100$
190$:

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

_StageRay_0130::

    ; レジスタの保存
    push    hl
    push    bc

    ; de < 開始 Y/X 位置
    ; de > 終了 Y/X 位置

    ; レイを飛ばす
    call    _StageCalc
    jp      c, 190$
    ld      a, (hl)
    cp      #STAGE_BLOCK
    jp      nc, 190$
    ld      a, #0x07
    sub     e
    and     #0x07
    ld      c, a
    ld      a, d
    and     #0x07
    ld      b, a
    sub     c
    jr      z, 100$
    jr      c, 110$
    jr      120$
100$:
    ld      a, e
    add     a, c
    ld      e, a
    ld      a, d
    sub     b
    ld      d, a
    jr      z, 190$
    ld      a, e
    inc     a
    jr      z, 190$
    ld      bc, #-0x001f
101$:
    add     hl, bc
    ld      a, (hl)
    cp      #STAGE_BLOCK
    jr      nc, 190$
    ld      a, e
    add     a, #0x08
    ld      e, a
    ld      a, d
    sub     #0x08
    ld      d, a
    jr      z, 190$
    ld      a, e
    inc     a
    jr      z, 190$
    jr      101$
110$:
    ld      a, d
    sub     b
    ld      d, a
    ld      a, e
    add     a, b
    ld      e, a
    ld      a, #0x07
    sub     e
    and     #0x07
    ld      b, a
    ld      a, #0x08
    sub     b
    ld      c, a
    ld      a, d
    or      a
    jr      z, 190$
    jr      130$
120$:
    ld      a, e
    add     a, c
    ld      e, a
    ld      a, d
    sub     c
    ld      d, a
    and     #0x07
    ld      c, a
    ld      a, #0x08
    sub     c
    ld      b, a
    ld      a, e
    inc     a
    jr      z, 190$
    jr      140$
130$:
    push    de
    ld      de, #-0x0020
    add     hl, de
    pop     de
    ld      a, (hl)
    cp      #STAGE_BLOCK
    jr      nc, 190$
    ld      a, d
    sub     b
    ld      d, a
    ld      a, e
    add     a, b
    ld      e, a
    inc     a
    jr      z, 190$
;   jr      140$
140$:
    inc     hl
    ld      a, (hl)
    cp      #STAGE_BLOCK
    jr      nc, 190$
    ld      a, e
    add     a, c
    ld      e, a
    ld      a, d
    sub     c
    ld      d, a
    jr      z, 190$
    jr      130$
190$:

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

_StageRay_0300::

    ; レジスタの保存
    push    hl

    ; de < 開始 Y/X 位置
    ; de > 終了 Y/X 位置

    ; レイを飛ばす
    call    _StageCalc
    jr      c, 190$
    ld      a, (hl)
    cp      #STAGE_BLOCK
    jr      nc, 190$
    ld      a, e
    and     #0xf8
    add     a, #0x08
    ld      e, a
    jr      z, 101$
100$:
    inc     hl
    ld      a, (hl)
    cp      #STAGE_BLOCK
    jr      nc, 101$
    ld      a, e
    add     a, #0x08
    ld      e, a
    jr      nz, 100$
101$:
    dec     e
190$:

    ; レジスタの復帰
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

; ステージ
;
_stage::
    
    .ds     STAGE_SIZE_X * STAGE_SIZE_Y

