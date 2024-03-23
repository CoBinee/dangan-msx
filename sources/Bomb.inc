; Bomb.inc : 爆発
;


; マクロの定義
;

; 爆発
BOMB_FRAME                      =   0x00
BOMB_R                          =   0x01
BOMB_POSITION_X                 =   0x02
BOMB_POSITION_Y                 =   0x03
BOMB_LENGTH                     =   0x04

; フレーム
BOMB_FRAME_NULL                 =   0x00
BOMB_FRAME_START                =   0x08
BOMB_FRAME_DAMAGE               =   0x04

; 半径
BOMB_R_NULL                     =   0x00
BOMB_R_DAMAGE                   =   0x0c

; 位置
BOMB_POSITION_NULL              =   0x00

; エントリ
BOMB_ENTRY                      =   0x03

; 外部関数宣言
;

    .globl  _BombInitialize
    .globl  _BombUpdate
    .globl  _BombRender
    .globl  _BombEntry

; 外部変数宣言
;

    .globl  _bomb
