; Enemy.inc : エネミー
;


; マクロの定義
;

; エネミー
ENEMY_DEAD_L                    =   CHARACTER_LENGTH + 0x00
ENEMY_DEAD_H                    =   CHARACTER_LENGTH + 0x01
ENEMY_PRINT_L                   =   CHARACTER_LENGTH + 0x02
ENEMY_PRINT_H                   =   CHARACTER_LENGTH + 0x03
ENEMY_ERASE_L                   =   CHARACTER_LENGTH + 0x04
ENEMY_ERASE_H                   =   CHARACTER_LENGTH + 0x05
ENEMY_STAGE_L                   =   CHARACTER_LENGTH + 0x06
ENEMY_STAGE_H                   =   CHARACTER_LENGTH + 0x07
ENEMY_THINK_0                   =   CHARACTER_LENGTH + 0x08
ENEMY_THINK_1                   =   CHARACTER_LENGTH + 0x09
ENEMY_THINK_2                   =   CHARACTER_LENGTH + 0x0a
ENEMY_THINK_3                   =   CHARACTER_LENGTH + 0x0b
ENEMY_THINK_4                   =   CHARACTER_LENGTH + 0x0c
ENEMY_THINK_5                   =   CHARACTER_LENGTH + 0x0d
ENEMY_THINK_6                   =   CHARACTER_LENGTH + 0x0e
ENEMY_THINK_7                   =   CHARACTER_LENGTH + 0x0f
ENEMY_LENGTH                    =   CHARACTER_LENGTH + 0x10

; 処理
ENEMY_PROC_NULL                 =   0x00

; 状態
ENEMY_STATE_NULL                =   0x00

; フラグ
ENEMY_FLAG_NULL                 =   0x00
ENEMY_FLAG_COUNT_BIT            =   0x00
ENEMY_FLAG_COUNT                =   (1 << ENEMY_FLAG_COUNT_BIT)
ENEMY_FLAG_EJECT_BIT            =   0x01
ENEMY_FLAG_EJECT                =   (1 << ENEMY_FLAG_EJECT_BIT)

; 位置
ENEMY_POSITION_NULL             =   0x00

; 速度
ENEMY_SPEED_NULL                =   0x00

; 矩形
ENEMY_RECT_NULL                 =   0x00

; アニメーション
ENEMY_ANIMATION_NULL            =   0x00

; ヒット
ENEMY_HIT_NULL                  =   0x00

; ライフ
ENEMY_LIFE_NULL                 =   0x00

; 死亡
ENEMY_DEAD_NULL                 =   0x00

; 描画
ENEMY_PRINT_NULL                =   0x00

; 消去
ENEMY_ERASE_NULL                =   0x00

; ステージ
ENEMY_STAGE_NULL                =   0x00

; 思考
ENEMY_THINK_NULL                =   0x00

; エントリ
ENEMY_ENTRY                     =   0x08

; 照準
ENEMY_AIM_NULL                  =   0x00
ENEMY_AIM_0900                  =   0x00
ENEMY_AIM_1030                  =   0x01
ENEMY_AIM_1200                  =   0x02
ENEMY_AIM_0000                  =   0x03
ENEMY_AIM_0130                  =   0x04
ENEMY_AIM_0300                  =   0x05
ENEMY_AIM_0430                  =   0x06
ENEMY_AIM_0600                  =   0x07
ENEMY_AIM_0730                  =   0x08

; 外部関数宣言
;

    ; common
    .globl  _EnemyInitialize
    .globl  _EnemyUpdate
    .globl  _EnemyRender
    .globl  _EnemyIsLive
    .globl  _EnemyIncCount
    .globl  _EnemyDecCount
    .globl  _EnemyDead1x1
    .globl  _EnemyGetPlayerDirection
    .globl  _EnemyGetPlayerAim
    .globl  _EnemyRay
    .globl  _EnemyFireStraight
    .globl  _EnemyFireHoming
    .globl  _EnemyFireParabola
    .globl  _EnemyFireHorizontal
    .globl  _EnemyFireVertical
    .globl  _EnemyBuildPattern8x8
    .globl  _EnemyPrintPattern8x8
    .globl  _EnemyErasePattern8x8

    ; fort
    .globl  _EnemyFortSpawn

    ; turret
    .globl  _EnemyTurretSpawn

    ; gunner
    .globl  _EnemyGunnerSpawn

    ; homer
    .globl  _EnemyHomerSpawn

    ; legs
    .globl  _EnemyLegsSpawn

    ; monster
    .globl  _EnemyMonsterSpawn

    ; flier
    .globl  _EnemyFlierSpawn

    ; hand
    .globl  _EnemyHandSpawn

    ; head
    .globl  _EnemyHeadSpawn

    ; beamer
    .globl  _EnemyBeamerSpawn

; 外部変数宣言
;

    .globl  _enemy
    .globl  _enemyPattern8x8

