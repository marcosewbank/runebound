class_name Layers
extends Object

# Physics layer bit values (1-indexed layer N = bit 1 << (N-1))
const TERRAIN := 1
const PLAYER_BODY := 2
const ENEMY_BODY := 4
const PLAYER_HITBOX := 8
const ENEMY_HITBOX := 16
const PLAYER_HURTBOX := 32
const ENEMY_HURTBOX := 64
const PICKUP := 128
