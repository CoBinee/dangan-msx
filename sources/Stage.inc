; Stage.inc : ステージ
;


; マクロの定義
;

; ステージ
STAGE_NULL                      =   0x70
STAGE_DAMAGE                    =   0x71
STAGE_BLOCK                     =   0xf0
STAGE_BLOCK_FIXED               =   0xf0
STAGE_BLOCK_DOWNABLE            =   0xf1
STAGE_SIZE_X                    =   0x20
STAGE_SIZE_Y                    =   0x0e
STAGE_SIZE_PIXEL                =   0x08

; 外部関数宣言
;

    .globl  _StageInitialize
    .globl  _StageUpdate
    .globl  _StageRender
    .globl  _StageBuild
    .globl  _StageCalc
    .globl  _StageGet
    .globl  _StageGetGroundY
    .globl  _StageIsBlock
    .globl  _StageIsBlockDownable
    .globl  _StageIsBlockNotDownable
    .globl  _StageIsDamage
    .globl  _StageRay_0900
    .globl  _StageRay_1030
    .globl  _StageRay_0000
    .globl  _StageRay_0130
    .globl  _StageRay_0300

; 外部変数宣言
;

    .globl  _stage
