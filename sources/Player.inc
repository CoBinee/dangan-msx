; Player.inc : プレイヤ
;


; マクロの定義
;

; プレイヤ
PLAYER_DAMAGE_L                 =   CHARACTER_LENGTH + 0x00
PLAYER_DAMAGE_H                 =   CHARACTER_LENGTH + 0x01
PLAYER_ACCEL_L                  =   CHARACTER_LENGTH + 0x02
PLAYER_ACCEL_H                  =   CHARACTER_LENGTH + 0x03
PLAYER_AIM                      =   CHARACTER_LENGTH + 0x04
PLAYER_RAY_X_0                  =   CHARACTER_LENGTH + 0x05
PLAYER_RAY_Y_0                  =   CHARACTER_LENGTH + 0x06
PLAYER_RAY_X_1                  =   CHARACTER_LENGTH + 0x07
PLAYER_RAY_Y_1                  =   CHARACTER_LENGTH + 0x08
PLAYER_LENGTH                   =   CHARACTER_LENGTH + 0x09

; 処理
PLAYER_PROC_NULL                =   0x00

; 状態
PLAYER_STATE_NULL               =   0x00

; フラグ
PLAYER_FLAG_NULL                =   0x00
PLAYER_FLAG_LAND_BIT            =   0x00
PLAYER_FLAG_LAND                =   (1 << PLAYER_FLAG_LAND_BIT)
PLAYER_FLAG_GUARD_BIT           =   0x01
PLAYER_FLAG_GUARD               =   (1 << PLAYER_FLAG_GUARD_BIT)

; 位置
PLAYER_POSITION_NULL            =   0x00

; 速度
PLAYER_SPEED_NULL               =   0x00
PLAYER_SPEED_X_MAXIMUM          =   0x0080
PLAYER_SPEED_X_HIT              =   0x00c0
PLAYER_SPEED_Y_JUMP             =   -0x0160
PLAYER_SPEED_Y_MAXIMUM          =   0x0800

; 矩形
PLAYER_RECT_NULL                =   0x00

; アニメーション
PLAYER_ANIMATION_NULL           =   0x00

; ヒット
PLAYER_HIT_NULL                 =   0x00

; ライフ　
PLAYER_LIFE_NULL                =   0x00
PLAYER_LIFE_MAXIMUM             =   999

; ダメージ
PLAYER_DAMAGE_NULL              =   0x00

; 加速度
PLAYER_ACCEL_NULL               =   0x00
PLAYER_ACCEL_X                  =   0x000c
PLAYER_ACCEL_JUMP               =   0x0007
PLAYER_ACCEL_GRAVITY            =   0x0010
PLAYER_BRAKE_X                  =   0x0006

; 照準
PLAYER_AIM_NULL                 =   0x00
PLAYER_AIM_0900                 =   0x00
PLAYER_AIM_1030                 =   0x01
PLAYER_AIM_1200                 =   0x02
PLAYER_AIM_0000                 =   0x03
PLAYER_AIM_0130                 =   0x04
PLAYER_AIM_0300                 =   0x05

; レイ
PLAYER_RAY_NULL                 =   0x00

; 爆発
PLAYER_BOMB_FRAME               =   0x00
PLAYER_BOMB_POSITION_X          =   0x01
PLAYER_BOMB_POSITION_Y          =   0x02
PLAYER_BOMB_LENGTH              =   0x03
PLAYER_BOMB_ENTRY               =   0x03
PLAYER_BOMB_NULL                =   0x00

; 外部関数宣言
;

    .globl  _PlayerInitialize
    .globl  _PlayerUpdate
    .globl  _PlayerRender
    .globl  _PlayerSpawn
    .globl  _PlayerIsLive
    .globl  _PlayerIsOver
    .globl  _PlayerGetPosition
    .globl  _PlayerGetCenter
    .globl  _PlayerIsLand
    .globl  _PlayerClearDamage
    .globl  _PlayerSetDamage
    .globl  _PlayerSetTurnLeft
    .globl  _PlayerSetTurnRight
    .globl  _PlayerStore
    .globl  _PlayerRestoreX
    .globl  _PlayerRestoreY
    .globl  _PlayerPrintLife

; 外部変数宣言
;

    .globl  _player
