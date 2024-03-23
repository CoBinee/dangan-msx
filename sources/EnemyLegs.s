; EnemyLegs.s : レッグス
;


; モジュール宣言
;
    .module Enemy

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include    "Stage.inc"
    .include    "Bomb.inc"
    .include    "Character.inc"
    .include    "Player.inc"
    .include	"Enemy.inc"

; 外部変数宣言
;

; マクロの定義
;
ENEMY_LEGS_LIMIT_LEFT           =   0x20
ENEMY_LEGS_LIMIT_RIGHT          =   0xe4
ENEMY_LEGS_LIMIT_NEAR           =   0x40
ENEMY_LEGS_LIFE_MAXIMUM         =   0x00c0
ENEMY_LEGS_LIFE_ATTACK          =   0x08
ENEMY_LEGS_FIRE_COUNT           =   0x07

; CODE 領域
;
    .area   _CODE

; エネミーを登場させる
;
_EnemyLegsSpawn::
    
    ; レジスタの保存

    ; ix < エネミー
    ; de < Y/X 位置
    ; c  < 向き
    
    ; エネミーの初期化
    push    bc
    push    de
    ld      hl, #enemyLegsDefault
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     de
    pop     bc

    ; 位置の設定
    ld      CHARACTER_POSITION_X_H(ix), e
    ld      CHARACTER_POSITION_Y_H(ix), d

    ; 向きの設定
    ld      a, c
    or      a
    jr      z, 30$
    set     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
30$:

    ; ENEMY_THINK_0 : 照準

    ; ENEMY_THINK_1 : 発射回数

    ; ENEMY_THINK_6-7 : ライフ

    ; カウントの更新
    call    _EnemyIncCount

    ; パターンの作成
    ld      bc, #((0x10 << 8) | 0x00)
    call    _EnemyBuildPattern8x8

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーが歩く
;
EnemyLegsWalk:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; ENEMY_THINK_6-7 : ライフ
    ld      a, CHARACTER_LIFE_L(ix)
    ld      ENEMY_THINK_6(ix), a
    ld      a, CHARACTER_LIFE_H(ix)
    ld      ENEMY_THINK_7(ix), a

    ; アニメーションの開始
    ld      hl, #enemyLegsAnimationIdleLeft
    ld      de, #enemyLegsAnimationIdleRight
    call    _CharacterStartDirectionAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

;   ; プレイの監視
;   call    _GameIsPlay
;   jr      nc, 190$

    ; アニメーションの監視
    call    _CharacterIsDoneAnimation
    jp      nc, 190$

    ; 向きの確認
    call    _PlayerGetPosition
    ld      c, e
    ld      b, d
    bit     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    jr      nz, 120$

    ; 左向き
110$:
    ld      a, CHARACTER_POSITION_X_H(ix)
    cp      #ENEMY_LEGS_LIMIT_LEFT
    jr      c, 180$
    jr      z, 180$
    call    _PlayerIsLive
    jr      nc, 119$
    ld      a, CHARACTER_POSITION_X_H(ix)
    cp      c
    jr      nc, 111$
    call    160$
    jr      c, 180$
    jr      119$
111$:
    call    160$
    jr      c, 181$
119$:
    ld      hl, #enemyLegsAnimationWalkLeft
    call    _CharacterStartAnimation
    jr      190$

    ; 右向き
120$:
    ld      a, CHARACTER_POSITION_X_H(ix)
    cp      #ENEMY_LEGS_LIMIT_RIGHT
    jr      nc, 180$
    call    _PlayerIsLive
    jr      nc, 129$
    ld      a, CHARACTER_POSITION_X_H(ix)
    cp      c
    jr      c, 121$
    call    160$
    jr      c, 180$
    jr      129$
121$:
    call    160$
    jr      c, 181$
129$:
    ld      hl, #enemyLegsAnimationWalkRight
    call    _CharacterStartAnimation
    jr      190$

    ; ライフの確認
160$:
    ld      l, ENEMY_THINK_6(ix)
    ld      h, ENEMY_THINK_7(ix)
    ld      e, CHARACTER_LIFE_L(ix)
    ld      d, CHARACTER_LIFE_H(ix)
    or      a
    sbc     hl, de
    ld      de, #ENEMY_LEGS_LIFE_ATTACK
    or      a
    sbc     hl, de
    ccf
    ret

    ; 方向転換
180$:
    ld      hl, #EnemyLegsTurn
    jr      189$

    ; 攻撃
181$:
    ld      a, CHARACTER_POSITION_X_H(ix)
    sub     c
    jr      nc, 182$
    neg
182$:
    cp      #ENEMY_LEGS_LIMIT_NEAR
    jr      c, 183$
    call    _SystemGetRandom
    and     #0x22
    jr      z, 183$
    ld      hl, #EnemyLegsFire
    jr      189$
183$:
    ld      hl, #EnemyLegsRun
;   jr      189$

    ; 処理の更新
189$:
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
;   jr      190$

    ; 歩くの完了
190$:

    ; アニメーションの更新
    call    _CharacterUpdateAnimation

    ; 位置の調整
    ld      a, CHARACTER_POSITION_X_H(ix)
    cp      #ENEMY_LEGS_LIMIT_LEFT
    jr      nc, 80$
    ld      CHARACTER_POSITION_X_H(ix), #ENEMY_LEGS_LIMIT_LEFT
    ld      CHARACTER_POSITION_X_L(ix), #0x00
    jr      89$
80$:
    cp      #ENEMY_LEGS_LIMIT_RIGHT
    jr      c, 89$
    ld      CHARACTER_POSITION_X_H(ix), #ENEMY_LEGS_LIMIT_RIGHT
    ld      CHARACTER_POSITION_X_L(ix), #0x00
;   jr      89$
89$:

    ; 終了
    ret

; エネミー走る
;
EnemyLegsRun:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; アニメーションの開始
    ld      hl, #enemyLegsAnimationIdleLeft
    ld      de, #enemyLegsAnimationIdleRight
    call    _CharacterStartDirectionAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; アニメーションの監視
    call    _CharacterIsDoneAnimation
    jr      nc, 190$

    ; 向きの確認
    call    _PlayerGetPosition
    ld      c, e
    ld      b, d
    bit     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    jr      nz, 120$

    ; 左向き
110$:
    ld      a, CHARACTER_POSITION_X_H(ix)
    cp      #ENEMY_LEGS_LIMIT_LEFT
    jr      c, 180$
    jr      z, 180$
    ld      hl, #enemyLegsAnimationRunLeft
    call    _CharacterStartAnimation
    jr      190$

    ; 右向き
120$:
    ld      a, CHARACTER_POSITION_X_H(ix)
    cp      #ENEMY_LEGS_LIMIT_RIGHT
    jr      nc, 180$
    ld      hl, #enemyLegsAnimationRunRight
    call    _CharacterStartAnimation
    jr      190$

    ; 処理の更新
180$:
    ld      hl, #EnemyLegsTurn
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
;   jr      190$

    ; 歩くの完了
190$:

    ; アニメーションの更新
    call    _CharacterUpdateAnimation

    ; 位置の調整
    ld      a, CHARACTER_POSITION_X_H(ix)
    cp      #ENEMY_LEGS_LIMIT_LEFT
    jr      nc, 80$
    ld      CHARACTER_POSITION_X_H(ix), #ENEMY_LEGS_LIMIT_LEFT
    ld      CHARACTER_POSITION_X_L(ix), #0x00
    jr      89$
80$:
    cp      #ENEMY_LEGS_LIMIT_RIGHT
    jr      c, 89$
    ld      CHARACTER_POSITION_X_H(ix), #ENEMY_LEGS_LIMIT_RIGHT
    ld      CHARACTER_POSITION_X_L(ix), #0x00
;   jr      89$
89$:

    ; 終了
    ret

; エネミーが方向転換する
;
EnemyLegsTurn:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; フラグの更新
    ld      a, CHARACTER_FLAG(ix)
    xor     #CHARACTER_FLAG_RIGHT
    ld      CHARACTER_FLAG(ix), a

    ; アニメーションの開始
    ld      hl, #enemyLegsAnimationTurnLeft
    ld      de, #enemyLegsAnimationTurnRight
    call    _CharacterStartDirectionAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; アニメーションの監視
    call    _CharacterIsDoneAnimation
    jr      nc, 190$

    ; 処理の更新
    ld      hl, #EnemyLegsWalk
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
;   jr      190$

    ; 待機の完了
190$:

    ; アニメーションの更新
    call    _CharacterUpdateAnimation

    ; 終了
    ret

; エネミーが発射する
;
EnemyLegsFire:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; ENEMY_THINK_0 : 照準
    bit     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    ld      a, #ENEMY_AIM_1200
    jr      z, 00$
    inc     a
00$:
    ld      ENEMY_THINK_0(ix), a

    ; ENEMY_THINK_1 : 発射回数
    ld      ENEMY_THINK_1(ix), #(ENEMY_LEGS_FIRE_COUNT + 1)

    ; アニメーションの開始
    ld      hl, #enemyLegsAnimationAimLeft
    ld      de, #enemyLegsAnimationAimRight
    call    _CharacterStartDirectionAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; アニメーションの監視
    call    _CharacterIsDoneAnimation
    jr      nc, 190$

    ; 発射回数の更新
    ld      a, ENEMY_THINK_1(ix)
    or      a
    jr      z, 180$
    dec     ENEMY_THINK_1(ix)
    jr      z, 170$

    ; ミサイルの発射
    ld      hl, #enemyLegsMuzzle
    ld      a, ENEMY_THINK_0(ix)
    call    _EnemyFireVertical
;   jr      109$
109$:

    ; アニメーションの開始
    ld      hl, #enemyLegsAnimationFireLeft
    ld      de, #enemyLegsAnimationFireRight
    call    _CharacterStartDirectionAnimation
    jr      190$

    ; 構えを直す
170$:
    ld      hl, #enemyLegsAnimationFixLeft
    ld      de, #enemyLegsAnimationFixRight
    call    _CharacterStartDirectionAnimation
    jr      190$

    ; 処理の更新
180$:
    ld      hl, #EnemyLegsWalk
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
;   jr      190$

    ; 発射の完了
190$:

    ; アニメーションの更新
    call    _CharacterUpdateAnimation
    
    ; 終了
    ret

; エネミーが死亡する
;
EnemyLegsDead:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; 点滅の設定
    ld      CHARACTER_BLINK(ix), #0x60

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; 点滅の監視
    ld      a, CHARACTER_BLINK(ix)
    sub     #(CHARACTER_BLINK_INTERVAL - 0x01)
    jr      nz, 19$

    ; 処理の更新
;   xor     a
    ld      CHARACTER_PROC_L(ix), a
    ld      CHARACTER_PROC_H(ix), a
    ld      CHARACTER_STATE(ix), a

    ; カウントの更新
    call    _EnemyDecCount
;   jr      19$

    ; 死亡の完了
19$:

    ; 爆発
    ld      a, CHARACTER_BLINK(ix)
    and     #0x03
    jr      nz, 29$
    call    _SystemGetRandom
    and     #0x3f
    sub     #0x20
    jr      nc, 20$
    neg
    ld      e, a
    ld      a, CHARACTER_POSITION_X_H(ix)
    sub     e
    jr      c, 29$
    jr      21$
20$:
    add     a, CHARACTER_POSITION_X_H(ix)
    jr      c, 29$
21$:
    ld      e, a
    call    _SystemGetRandom
    and     #0x1f
    ld      d, a
    call    _SystemGetRandom
    and     #0x0f
    add     a, d
    sub     CHARACTER_POSITION_Y_H(ix)
    neg
    ld      d, a
    call    _BombEntry
29$:

    ; 終了
    ret

; 定数の定義
;

; エネミーの初期値
;
enemyLegsDefault:

    .dw     EnemyLegsWalk
    .db     CHARACTER_STATE_NULL
    .db     ENEMY_FLAG_COUNT ; CHARACTER_FLAG_NULL
    .dw     CHARACTER_POSITION_NULL
    .dw     CHARACTER_POSITION_NULL
    .dw     CHARACTER_SPEED_NULL
    .dw     CHARACTER_SPEED_NULL
    .db     0x40 ; CHARACTER_RECT_NULL
    .db     0x30 ; CHARACTER_RECT_NULL
    .db     CHARACTER_RECT_NULL
    .db     CHARACTER_RECT_NULL
    .db     CHARACTER_RECT_NULL
    .db     CHARACTER_RECT_NULL
    .db     CHARACTER_RECT_NULL
    .db     CHARACTER_RECT_NULL
    .dw     CHARACTER_ANIMATION_NULL
    .db     0x00 ; CHARACTER_ANIMATION_NULL
    .db     CHARACTER_ANIMATION_NULL
    .db     CHARACTER_BLINK_NULL
    .db     CHARACTER_HIT_NULL
    .db     CHARACTER_HIT_NULL
    .db     CHARACTER_HIT_NULL
    .db     CHARACTER_HIT_NULL
    .dw     ENEMY_LEGS_LIFE_MAXIMUM ; CHARACTER_LIFE_NULL
    .dw     EnemyLegsDead ; ENEMY_DEAD_NULL
    .dw     _EnemyPrintPattern8x8 ; ENEMY_PRINT_NULL
    .dw     _EnemyErasePattern8x8 ; ENEMY_ERASE_NULL
    .dw     ENEMY_STAGE_NULL
    .db     ENEMY_THINK_NULL
    .db     ENEMY_THINK_NULL
    .db     ENEMY_THINK_NULL
    .db     ENEMY_THINK_NULL
    .db     ENEMY_THINK_NULL
    .db     ENEMY_THINK_NULL
    .db     ENEMY_THINK_NULL
    .db     ENEMY_THINK_NULL

; 砲口
;
enemyLegsMuzzle:

    .db      0x00,  0x00
    .db      0x00,  0x00
    .db     -0x03, -0x30
    .db     -0x03, -0x30
    .db      0x00,  0x00
    .db      0x00,  0x00
    .db      0x00,  0x00
    .db      0x00,  0x00
    .db      0x00,  0x00

; アニメーション
;
enemyLegsAnimationIdleLeft:

    .db     0xff,  0x00, -0x3f - 0x00, -0x20, 0x00, SOUND_SE_NULL

enemyLegsAnimationIdleRight:

    .db     0xff,  0x00, -0x3f - 0x00, -0x20, 0x08, SOUND_SE_NULL

enemyLegsAnimationWalkLeft:

    .db     0x08,  0x00, -0x3f - 0x00, -0x20, 0x01, SOUND_SE_NULL
    .db     0x08, -0x04, -0x3f - 0x00, -0x20, 0x02, SOUND_SE_NULL
    .db     0x08, -0x04, -0x3f - 0x00, -0x20, 0x03, SOUND_SE_NULL
    .db     0x08, -0x04, -0x3f - 0x00, -0x20, 0x00, SOUND_SE_NULL
    .db     0x00

enemyLegsAnimationWalkRight:

    .db     0x08,  0x00, -0x3f - 0x00, -0x20, 0x09, SOUND_SE_NULL
    .db     0x08,  0x04, -0x3f - 0x00, -0x20, 0x0a, SOUND_SE_NULL
    .db     0x08,  0x04, -0x3f - 0x00, -0x20, 0x0b, SOUND_SE_NULL
    .db     0x08,  0x04, -0x3f - 0x00, -0x20, 0x08, SOUND_SE_NULL
    .db     0x00

enemyLegsAnimationRunLeft:

    .db     0x02,  0x00, -0x3f - 0x00, -0x20, 0x01, SOUND_SE_NULL
    .db     0x02, -0x04, -0x3f - 0x00, -0x20, 0x02, SOUND_SE_NULL
    .db     0x02, -0x04, -0x3f - 0x00, -0x20, 0x03, SOUND_SE_NULL
    .db     0x02, -0x04, -0x3f - 0x00, -0x20, 0x00, SOUND_SE_NULL
    .db     0x00

enemyLegsAnimationRunRight:

    .db     0x02,  0x00, -0x3f - 0x00, -0x20, 0x09, SOUND_SE_NULL
    .db     0x02,  0x04, -0x3f - 0x00, -0x20, 0x0a, SOUND_SE_NULL
    .db     0x02,  0x04, -0x3f - 0x00, -0x20, 0x0b, SOUND_SE_NULL
    .db     0x02,  0x04, -0x3f - 0x00, -0x20, 0x08, SOUND_SE_NULL
    .db     0x00

enemyLegsAnimationTurnLeft:

    .db     0x18,  0x00, -0x3f - 0x00, -0x20, 0x04, SOUND_SE_NULL
    .db     0x18,  0x00, -0x3f - 0x00, -0x20, 0x00, SOUND_SE_NULL
    .db     0x00

enemyLegsAnimationTurnRight:

    .db     0x18,  0x00, -0x3f - 0x00, -0x20, 0x0c, SOUND_SE_NULL
    .db     0x18,  0x00, -0x3f - 0x00, -0x20, 0x08, SOUND_SE_NULL
    .db     0x00

enemyLegsAnimationAimLeft:

    .db     0x08,  0x00, -0x3f - 0x00, -0x20, 0x05, SOUND_SE_NULL
    .db     0x10,  0x00, -0x3f - 0x00, -0x20, 0x06, SOUND_SE_NULL
    .db     0x00

enemyLegsAnimationAimRight:

    .db     0x08,  0x00, -0x3f - 0x00, -0x20, 0x0d, SOUND_SE_NULL
    .db     0x10,  0x00, -0x3f - 0x00, -0x20, 0x0e, SOUND_SE_NULL
    .db     0x00

enemyLegsAnimationFireLeft:

    .db     0x04,  0x00, -0x3f - 0x00, -0x20, 0x07, SOUND_SE_NULL
    .db     0x10,  0x00, -0x3f - 0x00, -0x20, 0x06, SOUND_SE_NULL
    .db     0x00

enemyLegsAnimationFireRight:

    .db     0x04,  0x00, -0x3f - 0x00, -0x20, 0x0f, SOUND_SE_NULL
    .db     0x10,  0x00, -0x3f - 0x00, -0x20, 0x0e, SOUND_SE_NULL
    .db     0x00

enemyLegsAnimationFixLeft:

    .db     0x08,  0x00, -0x3f - 0x00, -0x20, 0x05, SOUND_SE_NULL
    .db     0x08,  0x00, -0x3f - 0x00, -0x20, 0x00, SOUND_SE_NULL
    .db     0x00

enemyLegsAnimationFixRight:

    .db     0x08,  0x00, -0x3f - 0x00, -0x20, 0x0d, SOUND_SE_NULL
    .db     0x08,  0x00, -0x3f - 0x00, -0x20, 0x08, SOUND_SE_NULL
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

