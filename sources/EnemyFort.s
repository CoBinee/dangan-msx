; EnemyFort.s : 砲台
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
    .include    "Character.inc"
    .include    "Player.inc"
    .include	"Enemy.inc"

; 外部変数宣言
;

; マクロの定義
;
ENEMY_FORT_LIFE_MAXIMUM         =   0x0010


; CODE 領域
;
    .area   _CODE

; エネミーを登場させる
;
_EnemyFortSpawn::
    
    ; レジスタの保存

    ; ix < エネミー
    ; de < Y/X 位置
    ; c  < 向き
    ; b  < ディレイ
    
    ; エネミーの初期化
    push    bc
    push    de
    ld      hl, #enemyFortDefault
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

    ; ENEMY_THINK_0 : ディレイ
    ld      ENEMY_THINK_0(ix), b

    ; ENEMY_THINK_1 : 待機時間

    ; ENEMY_THINK_2 : 発射回数

    ; カウントの更新
    call    _EnemyIncCount

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーが待機する
;
EnemyFortIdle:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; ENEMY_THINK_1 : 待機時間
    call    _SystemGetRandom
    and     #0x1f
    add     a, #0x50
    add     a, ENEMY_THINK_0(ix)
    ld      ENEMY_THINK_1(ix), a
    ld      ENEMY_THINK_0(ix), #0x00

    ; アニメーションの開始
    ld      hl, #enemyFortAnimationIdleLeft
    ld      de, #enemyFortAnimationIdleRight
    call    _CharacterStartDirectionAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; プレイの監視
    call    _GameIsPlay
    jr      nc, 190$

    ; プレイヤの存在
    call    _PlayerIsLive
    jr      nc, 190$

    ; プレイヤの位置の確認
    call    _PlayerGetPosition
    ld      a, CHARACTER_POSITION_X_H(ix)
    bit     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    jr      nz, 100$
    cp      e
    jr      c, 190$
    jr      110$
100$:
    cp      e
    jr      nc, 190$
;   jr      110$

    ; 待機時間の更新
110$:
    dec     ENEMY_THINK_1(ix)
    jr      nz, 190$

    ; 処理の更新
    ld      hl, #EnemyFortFire
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
EnemyFortFire:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; ENEMY_THINK_2 : 発射回数
    call    _SystemGetRandom
    and     #0x03
    jr      nz, 00$
    inc     a
00$:
    inc     a
    ld      ENEMY_THINK_2(ix), a

    ; アニメーションの開始
    ld      hl, #enemyFortAnimationAimLeft
    ld      de, #enemyFortAnimationAimRight
    call    _CharacterStartDirectionAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; アニメーションの監視
    call    _CharacterIsDoneAnimation
    jr      nc, 190$

    ; 発射回数の更新
    dec     ENEMY_THINK_2(ix)
    jr      z, 180$

    ; ミサイルの発射
    bit     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    jr      nz, 100$
    ld      a, #ENEMY_AIM_0900
    jr      101$
100$:
    ld      a, #ENEMY_AIM_0300
101$:
    ld      hl, #enemyFortMuzzle
    call    _EnemyFireStraight

    ; アニメーションの開始
    ld      hl, #enemyFortAnimationFireLeft
    ld      de, #enemyFortAnimationFireRight
    call    _CharacterStartDirectionAnimation
    jr      190$

    ; 処理の更新
180$:
    ld      hl, #EnemyFortIdle
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

; 定数の定義
;

; エネミーの初期値
;
enemyFortDefault:

    .dw     EnemyFortIdle
    .db     CHARACTER_STATE_NULL
    .db     ENEMY_FLAG_COUNT ; CHARACTER_FLAG_NULL
    .dw     CHARACTER_POSITION_NULL
    .dw     CHARACTER_POSITION_NULL
    .dw     CHARACTER_SPEED_NULL
    .dw     CHARACTER_SPEED_NULL
    .db     0x10 ; CHARACTER_RECT_NULL
    .db     0x0a ; CHARACTER_RECT_NULL
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
    .dw     ENEMY_FORT_LIFE_MAXIMUM ; CHARACTER_LIFE_NULL
    .dw     _EnemyDead1x1 ; ENEMY_DEAD_NULL
    .dw     _CharacterPrintPattern2x2 ; ENEMY_PRINT_NULL
    .dw     _CharacterErasePattern2x2 ; ENEMY_ERASE_NULL
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
enemyFortMuzzle:

    .db     -0x06, -0x07
    .db      0x00,  0x00
    .db      0x00,  0x00
    .db      0x00,  0x00
    .db      0x00,  0x00
    .db      0x05, -0x07
    .db      0x00,  0x00
    .db      0x00,  0x00
    .db      0x00,  0x00

; アニメーション
;
enemyFortAnimationIdleLeft:

    .db     0xff,  0x00, -0x0f, -0x08, 0x90, SOUND_SE_NULL

enemyFortAnimationIdleRight:

    .db     0xff,  0x00, -0x0f, -0x08, 0xa0, SOUND_SE_NULL

enemyFortAnimationAimLeft:

    .db     0x04,  0x00, -0x0f, -0x08, 0x90, SOUND_SE_NULL
    .db     0x00

enemyFortAnimationAimRight:

    .db     0x04,  0x00, -0x0f, -0x08, 0xa0, SOUND_SE_NULL
    .db     0x00

enemyFortAnimationFireLeft:

    .db     0x04,  0x00, -0x0f, -0x08, 0x94, SOUND_SE_NULL
    .db     0x1c,  0x00, -0x0f, -0x08, 0x90, SOUND_SE_NULL
    .db     0x00

enemyFortAnimationFireRight:

    .db     0x04,  0x00, -0x0f, -0x08, 0xa4, SOUND_SE_NULL
    .db     0x1c,  0x00, -0x0f, -0x08, 0xa0, SOUND_SE_NULL
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

