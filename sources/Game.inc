; Game.inc : ゲーム
;


; マクロの定義
;

; スプライト
GAME_SPRITE_NULL                =   0x00
GAME_SPRITE_PLAYER              =   0x00
GAME_SPRITE_ENEMY               =   0x30
GAME_SPRITE_BULLET              =   0x70
GAME_SPRITE_MISSILE             =   0x10
GAME_SPRITE_BOMB                =   0x50
GAME_SPRITE_LEVEL               =   0x7c

; ゲーム
GAME_PROC_L                     =   0x00
GAME_PROC_H                     =   0x01
GAME_STATE                      =   0x02
GAME_FLAG                       =   0x03
GAME_INPUT_UP                   =   0x04
GAME_INPUT_DOWN                 =   0x05
GAME_INPUT_LEFT                 =   0x06
GAME_INPUT_RIGHT                =   0x07
GAME_INPUT_FIRE                 =   0x08
GAME_INPUT_JUMP                 =   0x09
GAME_SPRITE_MISSILE_L           =   0x0a
GAME_SPRITE_MISSILE_H           =   0x0b
GAME_SPRITE_ENEMY_L             =   0x0c
GAME_SPRITE_ENEMY_H             =   0x0d
GAME_LEVEL                      =   0x0e
GAME_FRAME                      =   0x0f
GAME_LENGTH                     =   0x10

; 処理
GAME_PROC_NULL                  =   0x00

; 状態
GAME_STATE_NULL                 =   0x00

; フラグ
GAME_FLAG_NULL                  =   0x00
GAME_FLAG_PLAY_BIT              =   0x00
GAME_FLAG_PLAY                  =   (1 << GAME_FLAG_PLAY_BIT)

; 入力
GAME_INPUT_NULL                 =   0x00

; レベル
GAME_LEVEL_NULL                 =   0x00

; フレーム
GAME_FRAME_NULL                 =   0x00

; 外部関数宣言
;

    .globl  _GameInitialize
    .globl  _GameUpdate
    .globl  _GameIsPlay
    
; 外部変数宣言
;

    .globl  _game
