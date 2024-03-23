; Missile.inc : ミサイル
;


; マクロの定義
;

; ミサイル
MISSILE_PROC_L                  =   0x00
MISSILE_PROC_H                  =   0x01
MISSILE_STATE                   =   0x02
MISSILE_POSITION_X_L            =   0x03
MISSILE_POSITION_X_H            =   0x04
MISSILE_POSITION_Y_L            =   0x05
MISSILE_POSITION_Y_H            =   0x06
MISSILE_DIRECTION               =   0x07
MISSILE_SPEED_0                 =   0x08
MISSILE_SPEED_1                 =   0x09
MISSILE_FRAME                   =   0x0a
MISSILE_LENGTH                  =   0x0b

; 処理
MISSILE_PROC_NULL               =   0x00

; 状態
MISSILE_STATE_NULL              =   0x00

; 位置
MISSILE_POSITION_NULL           =   0x00

; 向き
MISSILE_DIRECTION_NULL          =   0x00

; 速度
MISSILE_SPEED_NULL              =   0x00
MISSILE_SPEED_INITIAL           =   0x08

; フレーム
MISSILE_FRAME_NULL              =   0x00

; エントリ
MISSILE_ENTRY                   =   0x08

; 外部関数宣言
;

    .globl  _MissileInitialize
    .globl  _MissileUpdate
    .globl  _MissileRender
    .globl  _MissileFireStraight
    .globl  _MissileFireHoming
    .globl  _MissileFireHomingSharp
    .globl  _MissileFireParabola
    .globl  _MissileFireHorizontal
    .globl  _MissileFireVertical

; 外部変数宣言
;

    .globl  _missile
