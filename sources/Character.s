; Character.s : キャラクタ
;


; モジュール宣言
;
    .module Character

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include    "Stage.inc"
    .include	"Character.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; キャラクタを移動する
;
CharacterTranslateX:

    ; レジスタの保存
    push    hl
    push    de

    ; ix < キャラクタ
    ; de < 移動量

    ; 移動
    ld      l, CHARACTER_POSITION_X_L(ix)
    ld      h, CHARACTER_POSITION_X_H(ix)
    bit     #0x07, d
    jr      z, 110$

    ; ←
100$:
    ld      a, d
    cpl
    ld      d, a
    ld      a, e
    cpl
    ld      e, a
    inc     de
    or      a
    sbc     hl, de
    jr      nc, 101$
    ld      hl, #0x0000
    jr      190$
101$:
    ld      e, h
    ld      d, CHARACTER_POSITION_Y_H(ix)
    bit     #CHARACTER_FLAG_THROUGH_BIT, CHARACTER_FLAG(ix)
    jr      nz, 102$
    call    _StageIsBlock
    jr      c, 103$
    jr      190$
102$:
    call    _StageIsBlockNotDownable
    jr      c, 103$
    jr      190$
103$:
    ld      a, h
    and     #0xf8
    add     a, #0x08
    ld      h, a
    ld      l, #0x00
    jr      190$

    ; →
110$:
    add     hl, de
    jr      nc, 111$
    ld      hl, #0xffff
    jr      190$
111$:
    ld      e, h
    ld      d, CHARACTER_POSITION_Y_H(ix)
    bit     #CHARACTER_FLAG_THROUGH_BIT, CHARACTER_FLAG(ix)
    jr      nz, 112$
    call    _StageIsBlock
    jr      c, 113$
    jr      190$
112$:
    call    _StageIsBlockNotDownable
    jr      c, 113$
    jr      190$
113$:
    ld      a, h
    and     #0xf8
    dec     a
    ld      h, a
    ld      l, #0xff
;   jr      190$

    ; 移動の完了
190$:
    ld      CHARACTER_POSITION_X_L(ix), l
    ld      CHARACTER_POSITION_X_H(ix), h

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

CharacterTranslateY:

    ; レジスタの保存
    push    hl
    push    de

    ; ix < キャラクタ
    ; de < 移動量

    ; 移動
    ld      l, CHARACTER_POSITION_Y_L(ix)
    ld      h, CHARACTER_POSITION_Y_H(ix)
    bit     #0x07, d
    jr      z, 110$

    ; ↑
100$:
    ld      a, d
    cpl
    ld      d, a
    ld      a, e
    cpl
    ld      e, a
    inc     de
    or      a
    sbc     hl, de
    jr      nc, 101$
    ld      hl, #0x0000
    jr      190$
101$:
    ld      e, CHARACTER_POSITION_X_H(ix)
    ld      d, h
    bit     #CHARACTER_FLAG_THROUGH_BIT, CHARACTER_FLAG(ix)
    jr      nz, 102$
    call    _StageIsBlock
    jr      c, 103$
    jr      190$
102$:
    call    _StageIsBlockNotDownable
    jr      c, 103$
    jr      190$
103$:
    ld      a, h
    and     #0xf8
    add     a, #0x08
    ld      h, a
    ld      l, #0x00
    jr      190$

    ; ↓
110$:
    add     hl, de
    ld      a, h
    cp      #(STAGE_SIZE_Y * STAGE_SIZE_PIXEL)
    jr      c, 111$
    ld      hl, #((STAGE_SIZE_Y * STAGE_SIZE_PIXEL - 0x0001) << 8)
    jr      190$
111$:
    ld      e, CHARACTER_POSITION_X_H(ix)
    ld      d, h
    bit     #CHARACTER_FLAG_THROUGH_BIT, CHARACTER_FLAG(ix)
    jr      nz, 112$
    call    _StageIsBlock
    jr      c, 113$
    jr      190$
112$:
    call    _StageIsBlockNotDownable
    jr      c, 113$
    jr      190$
113$:
    ld      a, h
    and     #0xf8
    dec     a
    ld      h, a
    ld      l, #0xff
;   jr      190$

    ; 移動の完了
190$:
    ld      CHARACTER_POSITION_Y_L(ix), l
    ld      CHARACTER_POSITION_Y_H(ix), h

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

_CharacterMoveX::

    ; レジスタの保存
    push    de

    ; ix < キャラクタ

    ; 移動
    ld      e, CHARACTER_SPEED_X_L(ix)
    ld      d, CHARACTER_SPEED_X_H(ix)
    call    CharacterTranslateX

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

_CharacterMoveY::

    ; レジスタの保存
    push    de

    ; ix < キャラクタ

    ; 移動
    ld      e, CHARACTER_SPEED_Y_L(ix)
    ld      d, CHARACTER_SPEED_Y_H(ix)
    call    CharacterTranslateY

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; 速度を更新する
;
CharacterAccel:

    ; レジスタの保存

    ; hl < 速度
    ; de < 加速度
    ; bc < 最大速度（絶対値）
    ; hl > 速度

    ; 加速
    bit     #0x07, d
    jr      z, 110$

    ; -
100$:
    or      a
    adc     hl, de
    jp      p, 190$
    ld      a, h
    cpl
    ld      h, a
    ld      a, l
    cpl
    ld      l, a
    inc     hl
    or      a
    sbc     hl, bc
    jr      nc, 101$
    add     hl, bc
    jr      102$
101$:
    ld      h, b
    ld      l, c
102$:
    ld      a, h
    cpl
    ld      h, a
    ld      a, l
    cpl
    ld      l, a
    inc     hl
    jr      190$

    ; +
110$:
    or      a
    adc     hl, de
    jp      m, 190$
    or      a
    sbc     hl, bc
    jr      nc, 111$
    add     hl, bc
    jr      190$
111$:
    ld      h, b
    ld      l, c
;   jr      190$

    ; 加速の完了
190$:

    ; レジスタの復帰

    ; 終了
    ret

_CharacterAccelX::

    ; レジスタの保存
    push    hl

    ; ix < キャラクタ
    ; de < 加速度
    ; bc < 最大速度（絶対値）

    ; 加速
    ld      l, CHARACTER_SPEED_X_L(ix)
    ld      h, CHARACTER_SPEED_X_H(ix)
    call    CharacterAccel
    ld      CHARACTER_SPEED_X_L(ix), l
    ld      CHARACTER_SPEED_X_H(ix), h

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

_CharacterAccelY::

    ; レジスタの保存
    push    hl

    ; ix < キャラクタ
    ; de < 加速度
    ; bc < 最大速度（絶対値）

    ; 加速
    ld      l, CHARACTER_SPEED_Y_L(ix)
    ld      h, CHARACTER_SPEED_Y_H(ix)
    call    CharacterAccel
    ld      CHARACTER_SPEED_Y_L(ix), l
    ld      CHARACTER_SPEED_Y_H(ix), h

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

CharacterBrake:

    ; レジスタの保存

    ; hl < 速度
    ; de < 減速度（絶対値）
    ; hl > 速度

    ; 減速
    bit     #0x07, h
    jr      z, 110$

    ; -
100$:
    or      a
    adc     hl, de
    jr      nc, 190$
    jr      180$

    ; +
110$:
    or      a
    sbc     hl, de
    jr      nc, 190$
;   jr      180$

    ; 減速の完了
180$:
    ld      hl, #0x0000
190$:

    ; レジスタの復帰

    ; 終了
    ret

_CharacterBrakeX::

    ; レジスタの保存
    push    hl

    ; ix < キャラクタ
    ; de < 減速度

    ; 減速
    ld      l, CHARACTER_SPEED_X_L(ix)
    ld      h, CHARACTER_SPEED_X_H(ix)
    call    CharacterBrake
    ld      CHARACTER_SPEED_X_L(ix), l
    ld      CHARACTER_SPEED_X_H(ix), h

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

_CharacterBrakeY::

    ; レジスタの保存
    push    hl

    ; ix < キャラクタ
    ; de < 減速度

    ; 減速
    ld      l, CHARACTER_SPEED_Y_L(ix)
    ld      h, CHARACTER_SPEED_Y_H(ix)
    call    CharacterBrake
    ld      CHARACTER_SPEED_Y_L(ix), l
    ld      CHARACTER_SPEED_Y_H(ix), h

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; キャラクタが着地しているかどうかを判定する
;
_CharacterIsLand::

    ; レジスタの保存
    push    de

    ; ix < キャラクタ
    ; cf > 1 = 着地

    ; 着地の判定
    ld      e, CHARACTER_POSITION_X_H(ix)
    ld      d, CHARACTER_POSITION_Y_H(ix)
    inc     d
    call    _StageIsBlock

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; 矩形を取得する
;
_CharacterCalcRect::

    ; レジスタの保存
    push    bc

    ; ix < キャラクタ

    ; 矩形の取得
    ld      b, CHARACTER_POSITION_X_H(ix)
    ld      c, CHARACTER_RECT_SIZE_X(ix)
    ld      a, b
    srl     c
    sub     c
    jr      nc, 10$
    xor     a
10$:
    ld      CHARACTER_RECT_LEFT(ix), a
    ld      a, b
    dec     c
    add     a, c
    jr      nc, 11$
    ld      a, #0xff
11$:
    ld      CHARACTER_RECT_RIGHT(ix), a
    ld      CHARACTER_RECT_O_X(ix), b
    ld      b, CHARACTER_POSITION_Y_H(ix)
    ld      c, CHARACTER_RECT_SIZE_Y(ix)
    ld      a, b
    ld      CHARACTER_RECT_BOTTOM(ix), a
    dec     c
    sub     c
    jr      nc, 12$
    xor     a
12$:
    ld      CHARACTER_RECT_TOP(ix), a
    ld      a, b
    inc     c
    srl     c
    sub     c
    jr      nc, 13$
    xor     a
13$:
    ld      CHARACTER_RECT_O_Y(ix), a

    ; レジスタの復帰
    pop     bc

    ; 終了
    ret

; 点が矩形内にあるかどうかを判定する
;
_CharacterIsPointInRect::

    ; レジスタの保存
    
    ; ix < キャラクタ
    ; de < Y/X 位置
    ; cf > 1 = 矩形内にある

    ; 矩形の判定
    ld      a, e
    cp      CHARACTER_RECT_LEFT(ix)
    jr      c, 18$
    cp      CHARACTER_RECT_RIGHT(ix)
    jr      z, 10$
    jr      nc, 18$
10$:
    ld      a, d
    cp      CHARACTER_RECT_TOP(ix)
    jr      c, 18$
    cp      CHARACTER_RECT_BOTTOM(ix)
    jr      z, 11$
    jr      nc, 18$
11$:
    scf
    jr      19$
18$:
    or      a
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; アニメーションを開始する
;
_CharacterStartAnimation::
    
    ; レジスタの保存
    push    hl
    push    de

    ; ix < キャラクタ
    ; hl < アニメーション

    ; フレームの設定
    ld      a, (hl)
    ld      CHARACTER_ANIMATION_FRAME(ix), a
    inc     hl

    ; 移動
    ld      d, (hl)
    ld      e, #0x00
    call    CharacterTranslateX
    inc     hl

    ; アニメーションの設定
    ld      CHARACTER_ANIMATION_L(ix), l
    ld      CHARACTER_ANIMATION_H(ix), h

    ; SE の再生
    ld      de, #(CHARACTER_ANIMATION_SOUND - CHARACTER_ANIMATION_Y)
    add     hl, de
    ld      a, (hl)
    or      a
    call    nz, _SoundPlaySeA

    ; レジスタの復帰
    pop     de
    pop     hl
    
    ; 終了
    ret

_CharacterStartDirectionAnimation::
    
    ; レジスタの保存
    push    hl
    push    de

    ; ix < キャラクタ
    ; hl < 左向きアニメーション
    ; de < 右向きアニメーション

    ; アニメーションの開始
    bit     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    jr      z, 10$
    ex      de, hl
10$:
    call    _CharacterStartAnimation

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

_CharacterStartIndexAnimation::

    ; レジスタの保存
    push    hl
    push    de

    ; ix < キャラクタ
    ; hl < アニメーションテーブル　
    ; a  < インデックス

    ; アニメーションの開始
    add     a, a
    ld      e, a
    ld      d, #0x00
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    call    _CharacterStartAnimation

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; アニメーションを更新する
;
_CharacterUpdateAnimation::
    
    ; レジスタの保存
    push    hl
    push    de

    ; ix < キャラクタ

    ; フレームの更新
    ld      a, CHARACTER_ANIMATION_FRAME(ix)
    or      a
    jr      z, 10$
    inc     a
    jr      z, 90$
    dec     CHARACTER_ANIMATION_FRAME(ix)
    jr      90$

    ; 次のアニメーション
10$:
    ld      l, CHARACTER_ANIMATION_L(ix)
    ld      h, CHARACTER_ANIMATION_H(ix)
    ld      de, #(CHARACTER_ANIMATION_LENGTH - CHARACTER_ANIMATION_Y)
    add     hl, de
    ld      a, (hl)
    or      a
    jr      z, 11$
    call    _CharacterStartAnimation
    jr      90$
11$:
    ld      CHARACTER_ANIMATION_FRAME(ix), #0xff
;   jr      90$

    ; 更新の完了
90$:

    ; レジスタの復帰
    pop     de
    pop     hl
    
    ; 終了
    ret

; アニメーションが完了したかどうかを判定する
;
_CharacterIsDoneAnimation::

    ; レジスタの保存
    push    hl

    ; ix < キャラクタ
    ; cf > 1 = 完了

    ; アニメーションの判定
    ld      a, CHARACTER_ANIMATION_FRAME(ix)
    inc     a
    jr      z, 10$
    or      a
    jr      19$
10$:
    scf
;   jr      19$
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; スプライトを描画する
;
_CharacterPrintSprite1x1::
    
    ; レジスタの保存
    push    hl
    push    bc

    ; ix < キャラクタ
    ; de < スプライト
    ; de > 次のスプライト

    ; 色の取得
    ld      c, #VDP_COLOR_BLACK
    ld      a, CHARACTER_HIT_FRAME(ix)
    or      a
    jr      z, 10$
    ld      c, #VDP_COLOR_MEDIUM_RED
10$:

    ; 位置の補正
    ld      b, #0x00
    ld      a, CHARACTER_POSITION_X_H(ix)
    cp      #0x80
    jr      nc, 11$
    ld      b, #0x20
    set     #0x07, c
11$:

    ; スプライトの描画
    ld      l, CHARACTER_ANIMATION_L(ix)
    ld      h, CHARACTER_ANIMATION_H(ix)
    ld      a, CHARACTER_POSITION_Y_H(ix)
    add     a, (hl)
    add     a, #(APP_VIEW_Y * APP_VIEW_PIXEL)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, CHARACTER_POSITION_X_H(ix)
    add     a, (hl)
    add     a, b
;   add     a, #(APP_VIEW_X * APP_VIEW_PIXEL)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
;   inc     hl
    inc     de
    ld      a, c
    ld      (de), a
;   inc     hl
    inc     de

    ; 描画の完了
90$:

    ; レジスタの復帰
    pop     bc
    pop     hl
    
    ; 終了
    ret

_CharacterPrintSprite2x1::
    
    ; レジスタの保存
    push    hl
    push    bc

    ; ix < キャラクタ
    ; de < スプライト
    ; de > 次のスプライト

    ; 色の取得
    ld      c, #VDP_COLOR_BLACK
    ld      a, CHARACTER_HIT_FRAME(ix)
    or      a
    jr      z, 10$
    ld      c, #VDP_COLOR_MEDIUM_RED
10$:

    ; 位置の補正
    ld      b, #0x00
    ld      a, CHARACTER_POSITION_X_H(ix)
    cp      #0x80
    jr      nc, 11$
    ld      b, #0x20
    set     #0x07, c
11$:

    ; スプライトの描画
    ld      l, CHARACTER_ANIMATION_L(ix)
    ld      h, CHARACTER_ANIMATION_H(ix)
200$:
    ld      a, CHARACTER_POSITION_Y_H(ix)
    add     a, (hl)
    add     a, #(APP_VIEW_Y * APP_VIEW_PIXEL)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, CHARACTER_POSITION_X_H(ix)
    add     a, (hl)
    add     a, b
;   add     a, #(APP_VIEW_X * APP_VIEW_PIXEL)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
;   inc     hl
    inc     de
    ld      a, c
    ld      (de), a
;   inc     hl
    inc     de
    dec     hl
    dec     hl
210$:
    ld      a, CHARACTER_POSITION_Y_H(ix)
    add     a, (hl)
    add     a, #(APP_VIEW_Y * APP_VIEW_PIXEL)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, CHARACTER_POSITION_X_H(ix)
    add     a, #0x10
    add     a, (hl)
    add     a, b
;   add     a, #(APP_VIEW_X * APP_VIEW_PIXEL)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    inc     a
    ld      (de), a
;   inc     hl
    inc     de
    ld      a, c
    ld      (de), a
;   inc     hl
    inc     de

    ; 描画の完了
90$:

    ; レジスタの復帰
    pop     bc
    pop     hl
    
    ; 終了
    ret

_CharacterPrintSprite2x2::
    
    ; レジスタの保存
    push    hl
    push    bc

    ; ix < キャラクタ
    ; de < スプライト
    ; de > 次のスプライト

    ; 色の取得
    ld      c, #VDP_COLOR_BLACK
    ld      a, CHARACTER_HIT_FRAME(ix)
    or      a
    jr      z, 10$
    ld      c, #VDP_COLOR_MEDIUM_RED
10$:

    ; 位置の補正
    ld      b, #0x00
    ld      a, CHARACTER_POSITION_X_H(ix)
    cp      #0x80
    jr      nc, 11$
    ld      b, #0x20
    set     #0x07, c
11$:

    ; スプライトの描画
    ld      l, CHARACTER_ANIMATION_L(ix)
    ld      h, CHARACTER_ANIMATION_H(ix)
200$:
    ld      a, CHARACTER_POSITION_Y_H(ix)
    add     a, (hl)
    add     a, #(APP_VIEW_Y * APP_VIEW_PIXEL)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, CHARACTER_POSITION_X_H(ix)
    add     a, (hl)
    add     a, b
;   add     a, #(APP_VIEW_X * APP_VIEW_PIXEL)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    ld      (de), a
;   inc     hl
    inc     de
    ld      a, c
    ld      (de), a
;   inc     hl
    inc     de
    dec     hl
    dec     hl
210$:
    ld      a, CHARACTER_POSITION_Y_H(ix)
    add     a, (hl)
    add     a, #(APP_VIEW_Y * APP_VIEW_PIXEL)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, CHARACTER_POSITION_X_H(ix)
    add     a, #0x10
    add     a, (hl)
    add     a, b
;   add     a, #(APP_VIEW_X * APP_VIEW_PIXEL)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    inc     a
    ld      (de), a
;   inc     hl
    inc     de
    ld      a, c
    ld      (de), a
;   inc     hl
    inc     de
    dec     hl
    dec     hl
220$:
    ld      a, CHARACTER_POSITION_Y_H(ix)
    add     a, #0x10
    add     a, (hl)
    add     a, #(APP_VIEW_Y * APP_VIEW_PIXEL)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, CHARACTER_POSITION_X_H(ix)
    add     a, (hl)
    add     a, b
;   add     a, #(APP_VIEW_X * APP_VIEW_PIXEL)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    add     a, #0x10
    ld      (de), a
;   inc     hl
    inc     de
    ld      a, c
    ld      (de), a
;   inc     hl
    inc     de
    dec     hl
    dec     hl
230$:
    ld      a, CHARACTER_POSITION_Y_H(ix)
    add     a, #0x10
    add     a, (hl)
    add     a, #(APP_VIEW_Y * APP_VIEW_PIXEL)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, CHARACTER_POSITION_X_H(ix)
    add     a, #0x10
    add     a, (hl)
    add     a, b
;   add     a, #(APP_VIEW_X * APP_VIEW_PIXEL)
    ld      (de), a
    inc     hl
    inc     de
    ld      a, (hl)
    add     a, #0x11
    ld      (de), a
;   inc     hl
    inc     de
    ld      a, c
    ld      (de), a
;   inc     hl
    inc     de
;   dec     hl
;   dec     hl

    ; 描画の完了
90$:

    ; レジスタの復帰
    pop     bc
    pop     hl
    
    ; 終了
    ret

; スプライトを消去する
;
_CharacterEraseSprite::
    
    ; レジスタの保存

    ; ix < キャラクタ
    ; de < スプライト

    ; レジスタの復帰
    
    ; 終了
    ret

; パターンを描画する
;
_CharacterPrintPattern1x1::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; ix < キャラクタ

    ; 色の取得
    ld      a, CHARACTER_HIT_FRAME(ix)
    or      a
    jr      z, 10$
    ld      a, #0x08
10$:
    ld      CHARACTER_ANIMATION_COLOR(ix), a

    ; パターンの描画
    ld      l, CHARACTER_ANIMATION_L(ix)
    ld      h, CHARACTER_ANIMATION_H(ix)
    ld      a, CHARACTER_POSITION_Y_H(ix)
    add     a, (hl)
    ld      d, a
    inc     hl
    ld      a, CHARACTER_POSITION_X_H(ix)
    add     a, (hl)
    ld      e, a
    inc     hl
    ld      a, CHARACTER_ANIMATION_COLOR(ix)
    add     a, (hl)
    ld      c, a
;   inc     hl
    call    _StageCalc
    ld      (hl), c
;   inc     hl
;   inc     c

    ; 描画の完了
90$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret

_CharacterPrintPattern2x2::
    
    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; ix < キャラクタ

    ; 色の取得
    ld      a, CHARACTER_HIT_FRAME(ix)
    or      a
    jr      z, 10$
    ld      a, #0x08
10$:
    ld      CHARACTER_ANIMATION_COLOR(ix), a

    ; パターンの描画
    ld      l, CHARACTER_ANIMATION_L(ix)
    ld      h, CHARACTER_ANIMATION_H(ix)
    ld      a, CHARACTER_POSITION_Y_H(ix)
    add     a, (hl)
    ld      d, a
    inc     hl
    ld      a, CHARACTER_POSITION_X_H(ix)
    add     a, (hl)
    ld      e, a
    inc     hl
    ld      a, CHARACTER_ANIMATION_COLOR(ix)
    add     a, (hl)
    ld      c, a
;   inc     hl
    call    _StageCalc
    ld      (hl), c
    inc     hl
    inc     c
    ld      (hl), c
    ld      de, #0x001f
    add     hl, de
    inc     c
    ld      (hl), c
    inc     hl
    inc     c
    ld      (hl), c
;   inc     hl
;   inc     c

    ; 描画の完了
90$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl
    
    ; 終了
    ret

; パターンを消去する
;
_CharacterErasePattern1x1::
    
    ; レジスタの保存
    push    hl
    push    de

    ; ix < キャラクタ

    ; パターンの消去
    ld      l, CHARACTER_ANIMATION_L(ix)
    ld      h, CHARACTER_ANIMATION_H(ix)
    ld      a, CHARACTER_POSITION_Y_H(ix)
    add     a, (hl)
    ld      d, a
    inc     hl
    ld      a, CHARACTER_POSITION_X_H(ix)
    add     a, (hl)
    ld      e, a
;   inc     hl
    call    _StageCalc
    ld      (hl), #STAGE_NULL
;   inc     hl

    ; 消去の完了
90$:

    ; レジスタの復帰
    pop     de
    pop     hl
    
    ; 終了
    ret

_CharacterErasePattern2x2::
    
    ; レジスタの保存
    push    hl
    push    de

    ; ix < キャラクタ

    ; パターンの消去
    ld      l, CHARACTER_ANIMATION_L(ix)
    ld      h, CHARACTER_ANIMATION_H(ix)
    ld      a, CHARACTER_POSITION_Y_H(ix)
    add     a, (hl)
    ld      d, a
    inc     hl
    ld      a, CHARACTER_POSITION_X_H(ix)
    add     a, (hl)
    ld      e, a
;   inc     hl
    call    _StageCalc
    ld      a, #STAGE_NULL
    ld      (hl), a
    inc     hl
    ld      (hl), a
    ld      de, #0x001f
    add     hl, de
    ld      (hl), a
    inc     hl
    ld      (hl), a
;   inc     hl

    ; 消去の完了
90$:

    ; レジスタの復帰
    pop     de
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

