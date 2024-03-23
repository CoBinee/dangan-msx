; Enemy.s : エネミー
;


; モジュール宣言
;
    .module Enemy

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
    .include    "Missile.inc"
    .include    "Bomb.inc"
    .include    "Character.inc"
    .include    "Player.inc"
    .include	"Enemy.inc"

; 外部変数宣言
;
    .globl  _largeTable

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; エネミーを初期化する
;
_EnemyInitialize::
    
    ; レジスタの保存
    
    ; エネミーの初期化
    ld      hl, #(_enemy + 0x0000)
    ld      de, #(_enemy + 0x0001)
    ld      bc, #(ENEMY_LENGTH * ENEMY_ENTRY - 0x0001)
    ld      (hl), #0x00
    ldir

    ; カウントの初期化
    xor     a
    ld      (enemyCount), a

    ; スプライトの初期化
    xor     a
    ld      (enemySpriteRotate), a

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを更新する
;
_EnemyUpdate::
    
    ; レジスタの保存

    ; エネミーの走査
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
100$:
    push    bc

    ; 処理の取得
    ld      l, CHARACTER_PROC_L(ix)
    ld      h, CHARACTER_PROC_H(ix)
    ld      a, h
    or      l
    jr      z, 190$

    ; ヒットの確認
    bit     #CHARACTER_FLAG_HIT_BIT, CHARACTER_FLAG(ix)
    jr      z, 110$
    res     #CHARACTER_FLAG_HIT_BIT, CHARACTER_FLAG(ix)
    ld      e, CHARACTER_LIFE_L(ix)
    ld      d, CHARACTER_LIFE_H(ix)
    ld      a, d
    or      e
    jr      z, 110$
    ld      CHARACTER_HIT_FRAME(ix), #CHARACTER_HIT_FRAME_DAMAGE
    dec     de
    ld      CHARACTER_LIFE_L(ix), e
    ld      CHARACTER_LIFE_H(ix), d
    ld      a, d
    or      e
    jr      nz, 110$

    ; 死亡
    ld      l, ENEMY_DEAD_L(ix)
    ld      CHARACTER_PROC_L(ix), l
    ld      h, ENEMY_DEAD_H(ix)
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
110$:

    ; ヒットの更新
    ld      a, CHARACTER_HIT_FRAME(ix)
    or      a
    jr      z, 120$
    dec     CHARACTER_HIT_FRAME(ix)
120$:
    ld      a, CHARACTER_BLINK(ix)
    or      a
    jr      z, 121$
    dec     CHARACTER_BLINK(ix)
121$:

    ; 種類別の処理
    ld      de, #130$
    push    de
    jp      (hl)
;   pop     hl
130$:

    ; 矩形の取得
    call    _CharacterCalcRect

    ; 次のエネミーへ
190$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    100$

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーを描画する
;
_EnemyRender::

    ; レジスタの保存

    ; エネミーの走査
    ld      ix, #_enemy
    ld      de, #enemySprite
    ld      b, #ENEMY_ENTRY
100$:
    push    bc

    ; 描画の確認
    ld      a, CHARACTER_PROC_H(ix)
    or      CHARACTER_PROC_L(ix)
    jr      z, 190$

    ; エネミーの描画
    ld      hl, #119$
    push    hl
    ld      a, CHARACTER_BLINK(ix)
    and     #CHARACTER_BLINK_INTERVAL
    jr      nz, 110$
    ld      l, ENEMY_PRINT_L(ix)
    ld      h, ENEMY_PRINT_H(ix)
    jr      111$
110$:
    ld      l, ENEMY_ERASE_L(ix)
    ld      h, ENEMY_ERASE_H(ix)
;   jr      111$
111$:
    jp      (hl)
;   pop     hl
119$:

    ; 次のエネミーへ
190$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    100$

    ; スプライトのクリア
    ld      hl, #(enemySprite + 0x0020)
    or      a
    sbc     hl, de
    jr      z, 29$
    ld      b, l
    ld      a, #0xcc
20$:
    ld      (de), a
    inc     de
    djnz    20$
29$:

    ; スプライトの転送
    ld      a, (enemySpriteRotate)
    ld      e, a
    ld      d, #0x00
    ld      ix, #enemySpriteTransfer
    add     ix, de
    ld      hl, (_game + GAME_SPRITE_ENEMY_L)
    ld      e, 0x02(ix)
    ld      d, 0x03(ix)
    add     hl, de
    ex      de, hl
    ld      l, 0x00(ix)
    ld      h, 0x01(ix)
    ld      c, 0x04(ix)
    ld      b, #0x00
    ldir
    ld      hl, (_game + GAME_SPRITE_ENEMY_L)
    ld      e, 0x0a(ix)
    ld      d, 0x0b(ix)
    add     hl, de
    ex      de, hl
    ld      l, 0x08(ix)
    ld      h, 0x09(ix)
    ld      c, 0x0c(ix)
;   ld      b, #0x00
    ldir
    add     a, #0x10
    and     #0x7f
    ld      (enemySpriteRotate), a

    ; レジスタの復帰

    ; 終了
    ret

; 何もしない
;
EnemyNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; エネミーが生存しているかどうかを判定する
;
_EnemyIsLive::

    ; レジスタの保存

    ; cf > 1 = 生存している

    ; エネミーの確認
    ld      a, (enemyCount)
    or      a
    jr      z, 10$
    scf
10$:

    ; レジスタの復帰

    ; 終了
    ret

; エネミーのカウントを更新する
;
_EnemyIncCount::

    ; レジスタの保存
    push    hl

    ; カウントの更新
    ld      hl, #enemyCount
    inc     (hl)

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret
    
_EnemyDecCount::

    ; レジスタの保存
    push    hl

    ; カウントの更新
    ld      hl, #enemyCount
    dec     (hl)

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret
    
; エネミーが死亡する
;
_EnemyDead1x1::

    ; レジスタの保存

    ; ix < エネミー

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; ENEMY_THINK_0 : フレーム
    ld      ENEMY_THINK_0(ix), #0x04

    ; 爆発
    ld      e, CHARACTER_RECT_O_X(ix)
    ld      d, CHARACTER_RECT_O_Y(ix)
    call    _BombEntry

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; フレームの更新
    dec     ENEMY_THINK_0(ix)
    jr      nz, 19$

    ; エネミーの消去
    ld      hl, #10$
    push    hl
    ld      l, ENEMY_ERASE_L(ix)
    ld      h, ENEMY_ERASE_H(ix)
    jp      (hl)
;   pop     hl
10$:

    ; エネミーの削除
    xor     a
    ld      CHARACTER_PROC_L(ix), a
    ld      CHARACTER_PROC_H(ix), a
;   ld      CHARACTER_STATE(ix), a

    ; カウントの更新
    bit     #ENEMY_FLAG_COUNT_BIT, CHARACTER_FLAG(ix)
    call    nz, _EnemyDecCount
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 照準の位置を取得する
;
EnemyGetAimPosition:

    ; レジスタの保存
    push    hl
    push    bc

    ; ix < エネミー
    ; hl < 砲口テーブル
    ; a  < 照準
    ; de > 照準 Y/X 位置
    ; cf > 1 = 照準が有効

    ; 開始位置の取得
    add     a, a
    ld      e, a
    ld      d, #0x00
    add     hl, de
    ld      a, (hl)
    bit     #0x07, a
    jr      z, 10$
    neg
    ld      b, a
    ld      a, CHARACTER_POSITION_X_H(ix)
    sub     b
    jr      c, 18$
    jr      11$
10$:
    add     a, CHARACTER_POSITION_X_H(ix)
    jr      c, 18$
11$:
    ld      e, a
    inc     hl
    ld      a, (hl)
    bit     #0x07, a
    jr      z, 12$
    neg
    ld      b, a
    ld      a, CHARACTER_POSITION_Y_H(ix)
    sub     b
    jr      c, 18$
    jr      13$
12$:
    add     a, CHARACTER_POSITION_Y_H(ix)
    jr      c, 18$
13$:
    ld      d, a
    scf
    jr      19$
18$:
    or      a
;   jr      19$
19$:

    ; レジスタの復帰
    pop     bc
    pop     hl

    ; 終了
    ret

; 照準の向きを取得する
;
EnemyGetAimDirection:

    ; レジスタの保存
    push    hl
    push    de

    ; a < 照準
    ; c > 向き

    ; 向きの取得
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyAimDirection
    add     hl, de
    ld      c, (hl)

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; プレイヤのいる向きを取得する
;
_EnemyGetPlayerDirection::

    ; レジスタの保存
    push    hl
    push    de

    ; ix < エネミー
    ; a  > 向き

    ; 角度の取得
    call    _PlayerGetCenter
    ld      a, CHARACTER_RECT_O_Y(ix)
    srl     a
    srl     d
    sub     d
    ld      l, a
    ld      a, CHARACTER_RECT_O_X(ix)
    srl     a
    srl     e
    sub     e
    neg
    ld      h, a
    call    _MathGetAtan2

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; プレイヤのいる照準を取得する
;
_EnemyGetPlayerAim::

    ; レジスタの保存
    push    hl
    push    de

    ; ix < エネミー
    ; a  > 照準

    ; 照準の取得
    call    _EnemyGetPlayerDirection
    add     a, #0x10
    and     #0xe0
    rlca
    rlca
    rlca
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyDirectionAim
    add     hl, de
    ld      a, (hl)

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; レイを飛ばす
;
_EnemyRay::

    ; レジスタの保存
    push    bc

    ; ix < エネミー
    ; hl < 砲口テーブル
    ; a  < 照準
    ; hl > 開始 Y/X 位置
    ; de > 終了 Y/X 位置
    ; cf > 1 = レイが有効

    ; 開始位置の取得
    ld      c, a
    call    EnemyGetAimPosition
    jr      nc, 80$
    ld      l, e
    ld      h, d

    ; レイを飛ばす
    ld      a, c
    or      a
    jr      z, 20$
    dec     a
    jr      z, 21$
    dec     a
    jr      z, 22$
    dec     a
    jr      z, 22$
    dec     a
    jr      z, 23$
    jr      24$
20$:
    call    _StageRay_0900
    jr      29$
21$:
    call    _StageRay_1030
    jr      29$
22$:
    call    _StageRay_0000
    jr      29$
23$:
    call    _StageRay_0130
    jr      29$
24$:
    call    _StageRay_0300
;   jr      29$
29$:
    or      a
    sbc     hl, de
    jr      z, 90$
    add     hl, de
    scf
    jr      90$

    ; レイは飛ばせない
80$:
    or      a
;   jr      90$

    ; レイの完了
90$:

    ; レジスタの復帰
    pop     bc

    ; 終了
    ret

; ミサイルを発射する
;
_EnemyFireStraight::

    ; レジスタの保存
    push    bc
    push    de

    ; ix < エネミー
    ; hl < 砲口テーブル
    ; a  < 照準

    ; ミサイルの発射
    call    EnemyGetAimDirection
    call    EnemyGetAimPosition
    call    c, _MissileFireStraight

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

_EnemyFireHoming::

    ; レジスタの保存
    push    bc
    push    de

    ; ix < エネミー
    ; hl < 砲口テーブル
    ; a  < 照準

    ; ミサイルの発射
    call    EnemyGetAimDirection
    call    EnemyGetAimPosition
    call    c, _MissileFireHoming

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

_EnemyFireParabola::

    ; レジスタの保存
    push    bc
    push    de

    ; ix < エネミー
    ; hl < 砲口テーブル
    ; a  < 照準

    ; ミサイルの発射
    call    EnemyGetAimDirection
    call    EnemyGetAimPosition
    call    c, _MissileFireParabola

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

_EnemyFireHorizontal::

    ; レジスタの保存
    push    bc
    push    de

    ; ix < エネミー
    ; hl < 砲口テーブル
    ; a  < 照準

    ; ミサイルの発射
    call    EnemyGetAimDirection
    call    EnemyGetAimPosition
    call    c, _MissileFireHorizontal

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

_EnemyFireVertical::

    ; レジスタの保存
    push    bc
    push    de

    ; ix < エネミー
    ; hl < 砲口テーブル
    ; a  < 照準

    ; ミサイルの発射
    call    EnemyGetAimDirection
    call    EnemyGetAimPosition
    call    c, _MissileFireVertical

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

; パターンを作成する
;
_EnemyBuildPattern8x8::

    ; レジスタの保存
    push    hl
    push    bc
    push    de
    push    ix
    push    iy

    ; c < キャラクタ番号
    ; b < 作成する個数

    ; スプライトの取得
    ld      a, c
    ld      d, #0x00
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      e, a
    ld      ix, #_largeTable
    add     ix, de

    ; パターンの作成
    ld      iy, #_enemyPattern8x8
10$:
    push    bc
    ld      c, #0x00
    call    20$
    ld      c, #0x01
    call    20$
    pop     bc
    inc     c
    inc     c
    ld      a, c
    and     #0x0f
    jr      z, 11$
    ld      de, #(0x0002 * 0x0008)
    jr      19$
11$:
    ld      de, #(0x0012 * 0x0008)
;   jr      19$
19$:
    add     ix, de
    djnz    10$
    jr      90$

    ; 8x8 の作成
20$:
    push    hl
    push    bc
    push    de
    push    ix
    ld      b, #0x02
21$:
    push    bc
    ld      b, #0x04
22$:
    push    bc
    ld      h, 0x00(ix)
    ld      l, 0x08(ix)
    ld      d, 0x01(ix)
    ld      e, 0x09(ix)
    ld      b, #0x08
    bit     #0x00, c
    jr      z, 23$
    srl     h
    rr      l
    srl     d
    rr      e
23$:
    xor     a
    sla     l
    rl      h
    rla
    add     a, a
    sla     l
    rl      h
    rla
    sla     e
    rl      d
    rla
    sla     e
    rl      d
    rla
    add     a, #0x70
    ld      0x00(iy), a
    inc     iy
    djnz    23$
    inc     ix
    inc     ix
    pop     bc
    djnz    22$
    ld      bc, #(0x000f * 0x0008)
    add     ix, bc
    pop     bc
    djnz    21$
    pop     ix
    pop     de
    pop     bc
    pop     hl
    ret

    ; 作成の完了
90$:

    ; レジスタの復帰
    pop     iy
    pop     ix
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret


; パターンを描画する
;
_EnemyPrintPattern8x8::

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

    ; パターンの消去
    ld      l, ENEMY_STAGE_L(ix)
    ld      h, ENEMY_STAGE_H(ix)
    ld      a, h
    or      l
    ld      a, #STAGE_NULL
    call    nz, EnemyFillPattern8x8

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
    ld      b, (hl)
    ld      c, #0x00
    srl     b
    rr      c
    ld      a, CHARACTER_POSITION_X_H(ix)
    and     #0x04
    add     a, a
    add     a, a
    add     a, a
    add     a, a
    add     a, c
    ld      c, a
    call    _StageCalc
    ld      ENEMY_STAGE_L(ix), l
    ld      ENEMY_STAGE_H(ix), h
    ex      de, hl
    ld      hl, #_enemyPattern8x8
    add     hl, bc
    ld      c, CHARACTER_ANIMATION_COLOR(ix)
    ld      b, #0x08
30$:
    push    bc
    ld      b, #0x08
31$:
    ld      a, (hl)
    add     a, c
    ld      (de), a
    inc     hl
    inc     de
    djnz    31$
    ex      de, hl
    ld      bc, #(0x0020 - 0x0008)
    add     hl, bc
    ex      de, hl
    pop     bc
    djnz    30$

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
_EnemyErasePattern8x8::

    ; レジスタの保存
    push    hl
    push    de

    ; ix < キャラクタ

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
;   inc     hl
    call    _StageCalc
    ld      a, #STAGE_NULL
    call    EnemyFillPattern8x8

    ; 描画の完了
90$:

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; パターンを塗りつぶす
;
EnemyFillPattern8x8:

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; hl < ステージ
    ; a  < キャラクタ

    ; パターンの描画
    ld      de, #(0x0020 - 0x0008)
    ld      c, #0x08
10$:
    ld      b, #0x08
11$:
    ld      (hl), a
    inc     hl
    djnz    11$
    add     hl, de
    dec     c
    jr      nz, 10$

    ; 描画の完了
90$:

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; 定数の定義
;

; 照準
;
enemyAimDirection:

    .db     0xc0
    .db     0xe0
    .db     0x00
    .db     0x00
    .db     0x20
    .db     0x40
    .db     0x60
    .db     0x80
    .db     0xa0

enemyDirectionAim:

    .db     ENEMY_AIM_1200
    .db     ENEMY_AIM_0130
    .db     ENEMY_AIM_0300
    .db     ENEMY_AIM_0430
    .db     ENEMY_AIM_0600
    .db     ENEMY_AIM_0730
    .db     ENEMY_AIM_0900
    .db     ENEMY_AIM_1030

; スプライト
;
enemySpriteTransfer:

    .dw     enemySprite + 0x0000, 0x0000, 0x0010, 0x0000
    .dw     enemySprite + 0x0010, 0x0010, 0x0010, 0x0000
    .dw     enemySprite + 0x0004, 0x0000, 0x001c, 0x0000
    .dw     enemySprite + 0x0000, 0x001c, 0x0004, 0x0000
    .dw     enemySprite + 0x0008, 0x0000, 0x0018, 0x0000
    .dw     enemySprite + 0x0000, 0x0018, 0x0008, 0x0000
    .dw     enemySprite + 0x000c, 0x0000, 0x0014, 0x0000
    .dw     enemySprite + 0x0000, 0x0014, 0x000c, 0x0000
    .dw     enemySprite + 0x0010, 0x0000, 0x0010, 0x0000
    .dw     enemySprite + 0x0000, 0x0010, 0x0010, 0x0000
    .dw     enemySprite + 0x0014, 0x0000, 0x000c, 0x0000
    .dw     enemySprite + 0x0000, 0x000c, 0x0014, 0x0000
    .dw     enemySprite + 0x0018, 0x0000, 0x0008, 0x0000
    .dw     enemySprite + 0x0000, 0x0008, 0x0018, 0x0000
    .dw     enemySprite + 0x001c, 0x0000, 0x0004, 0x0000
    .dw     enemySprite + 0x0000, 0x0004, 0x001c, 0x0000


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; エネミー
;
_enemy::
    
    .ds     ENEMY_LENGTH * ENEMY_ENTRY

; カウント
;
enemyCount:

    .ds     0x01

; スプライト
;
enemySprite:

    .ds     0x20

enemySpriteRotate:

    .ds     0x01

; パターンネーム
;
_enemyPattern8x8::

    .ds     0x40 * 0x02 * 0x10
