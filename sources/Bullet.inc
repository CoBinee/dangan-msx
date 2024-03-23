; Bullet.inc : 銃弾
;


; マクロの定義
;

; 銃弾
BULLET_POSITION_X               =   0x00
BULLET_POSITION_Y               =   0x01
BULLET_ANIMATION                =   0x02
BULLET_LENGTH                   =   0x03

; 位置
BULLET_POSITION_NULL            =   0x00

; アニメーション
BULLET_ANIMATION_NULL           =   0x00

; 外部関数宣言
;

    .globl  _BulletInitialize
    .globl  _BulletUpdate
    .globl  _BulletRender
    .globl  _BulletEntry

; 外部変数宣言
;

    .globl  _bullet
