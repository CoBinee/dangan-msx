; Character.inc : キャラクタ
;


; マクロの定義
;

; エネミー
CHARACTER_PROC_L                =   0x00
CHARACTER_PROC_H                =   0x01
CHARACTER_STATE                 =   0x02
CHARACTER_FLAG                  =   0x03
CHARACTER_POSITION_X_L          =   0x04
CHARACTER_POSITION_X_H          =   0x05
CHARACTER_POSITION_Y_L          =   0x06
CHARACTER_POSITION_Y_H          =   0x07
CHARACTER_SPEED_X_L             =   0x08
CHARACTER_SPEED_X_H             =   0x09
CHARACTER_SPEED_Y_L             =   0x0a
CHARACTER_SPEED_Y_H             =   0x0b
CHARACTER_RECT_SIZE_X           =   0x0c
CHARACTER_RECT_SIZE_Y           =   0x0d
CHARACTER_RECT_O_X              =   0x0e
CHARACTER_RECT_O_Y              =   0x0f
CHARACTER_RECT_LEFT             =   0x10
CHARACTER_RECT_TOP              =   0x11
CHARACTER_RECT_RIGHT            =   0x12
CHARACTER_RECT_BOTTOM           =   0x13
CHARACTER_ANIMATION_L           =   0x14
CHARACTER_ANIMATION_H           =   0x15
CHARACTER_ANIMATION_COLOR       =   0x16
CHARACTER_ANIMATION_FRAME       =   0x17
CHARACTER_BLINK                 =   0x18
CHARACTER_HIT_FRAME             =   0x19
CHARACTER_HIT_DAMAGE            =   0x1a
CHARACTER_HIT_SPEED_L           =   0x1b
CHARACTER_HIT_SPEED_H           =   0x1c
CHARACTER_LIFE_L                =   0x1d
CHARACTER_LIFE_H                =   0x1e
CHARACTER_LENGTH                =   0x1f

; 処理
CHARACTER_PROC_NULL             =   0x00

; 状態
CHARACTER_STATE_NULL            =   0x00

; フラグ
CHARACTER_FLAG_NULL             =   0x00
CHARACTER_FLAG_RIGHT_BIT        =   0x07
CHARACTER_FLAG_RIGHT            =   (1 << CHARACTER_FLAG_RIGHT_BIT)
CHARACTER_FLAG_THROUGH_BIT      =   0x06
CHARACTER_FLAG_THROUGH          =   (1 << CHARACTER_FLAG_THROUGH_BIT)
CHARACTER_FLAG_HIT_BIT          =   0x05
CHARACTER_FLAG_HIT              =   (1 << CHARACTER_FLAG_HIT_BIT)
CHARACTER_FLAG_2x2_BIT          =   0x04
CHARACTER_FLAG_2x2              =   (1 << CHARACTER_FLAG_2x2_BIT)

; 位置
CHARACTER_POSITION_NULL         =   0x00

; 速度
CHARACTER_SPEED_NULL            =   0x00

; 矩形
CHARACTER_RECT_NULL             =   0x00

; アニメーション
CHARACTER_ANIMATION_NULL        =   0x00
CHARACTER_ANIMATION_INTERVAL    =   0x00
CHARACTER_ANIMATION_MOVE        =   0x01
CHARACTER_ANIMATION_Y           =   0x02
CHARACTER_ANIMATION_X           =   0x03
CHARACTER_ANIMATION_PATTERN     =   0x04
CHARACTER_ANIMATION_SOUND       =   0x05
CHARACTER_ANIMATION_LENGTH      =   0x06

; 点滅
CHARACTER_BLINK_NULL            =   0x00
CHARACTER_BLINK_INTERVAL        =   0x01

; ヒット
CHARACTER_HIT_NULL              =   0x00
CHARACTER_HIT_FRAME_DAMAGE      =   0x04
CHARACTER_HIT_DAMAGE_BOMB       =   0x25

; ライフ
CHARACTER_LIFE_NULL             =   0x00

; 外部関数宣言
;

    .globl  _CharacterMoveX
    .globl  _CharacterMoveY
    .globl  _CharacterAccelX
    .globl  _CharacterAccelY
    .globl  _CharacterBrakeX
    .globl  _CharacterBrakeY
    .globl  _CharacterIsLand
    .globl  _CharacterCalcRect
    .globl  _CharacterIsPointInRect
    .globl  _CharacterStartAnimation
    .globl  _CharacterStartDirectionAnimation
    .globl  _CharacterStartIndexAnimation
    .globl  _CharacterUpdateAnimation
    .globl  _CharacterIsDoneAnimation
    .globl  _CharacterPrintSprite1x1
    .globl  _CharacterPrintSprite2x1
    .globl  _CharacterPrintSprite2x2
    .globl  _CharacterEraseSprite
    .globl  _CharacterPrintPattern1x1
    .globl  _CharacterPrintPattern2x2
    .globl  _CharacterErasePattern1x1
    .globl  _CharacterErasePattern2x2

; 外部変数宣言
;

