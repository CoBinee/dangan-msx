; Level.inc : レベル
;


; マクロの定義
;

; レベル
LEVEL_FLAG                      =   0x00
LEVEL_BUILD_L                   =   0x01
LEVEL_BUILD_H                   =   0x02
LEVEL_CHECK_L                   =   0x03
LEVEL_CHECK_H                   =   0x04
LEVEL_ANIMATION_L               =   0x05
LEVEL_ANIMATION_H               =   0x06
LEVEL_ANIMATION_FRAME           =   0x07
LEVEL_ANIMATION_COUNT           =   0x08
LEVEL_LENGTH                    =   0x09

; フラグ
LEVEL_FLAG_NULL                 =   0x00
LEVEL_FLAG_CLEAR_BIT            =   0x07
LEVEL_FLAG_CLEAR                =   (1 << LEVEL_FLAG_CLEAR_BIT)
LEVEL_FLAG_CONTINUE_BIT         =   0x06
LEVEL_FLAG_CONTINUE             =   (1 << LEVEL_FLAG_CONTINUE_BIT)

; 作成
LEVEL_BUILD_NULL                =   0x00

; 判定
LEVEL_CHECK_NULL                =   0x00

; アニメーション
LEVEL_ANIMATION_NULL            =   0x00

; 外部関数宣言
;

    .globl  _LevelInitialize
    .globl  _LevelUpdate
    .globl  _LevelRender
    .globl  _LevelBuild
    .globl  _LevelIsClear
    .globl  _LevelIsExist

; 外部変数宣言
;

    .globl  _level
