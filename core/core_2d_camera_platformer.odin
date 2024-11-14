/*******************************************************************************************
*
*   raylib [core] example - 2D Camera platformer
*
*   Example originally created with raylib 2.5, last time updated with raylib 3.0
*
*   Example contributed by arvyy (@arvyy) and reviewed by Ramon Santamaria (@raysan5)
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2019-2024 arvyy (@arvyy)
*
********************************************************************************************/

package main

import rl "vendor:raylib"

G :: 400
PLAYER_JUMP_SPD :: 350.0
PLAYER_HOR_SPD :: 200.0

Player :: struct {
	position: rl.Vector2,
	speed:    f32,
	can_jump: bool,
}

EnvItem :: struct {
	rect:     rl.Rectangle,
	blocking: bool,
	color:    rl.Color,
}

CameraUpdateFunc :: #type proc(
	camera: ^rl.Camera2D,
	player: ^Player,
	env_items: []EnvItem,
	delta: f32,
	width: i32,
	height: i32,
)

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: proc() {
	SCREEN_WIDTH :: 800
	SCREEN_HEIGHT :: 450

	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib [core] example - 2d camera")

	player := Player {
		position = rl.Vector2{400, 280},
		speed    = 0,
		can_jump = false,
	}

	env_items := []EnvItem {
		{rect = {0, 0, 1000, 400}, blocking = false, color = rl.LIGHTGRAY},
		{rect = {0, 400, 1000, 200}, blocking = true, color = rl.GRAY},
		{rect = {300, 200, 400, 10}, blocking = true, color = rl.GRAY},
		{rect = {250, 300, 100, 10}, blocking = true, color = rl.GRAY},
		{rect = {650, 300, 100, 10}, blocking = true, color = rl.GRAY},
	}

	// int envItemsLength = sizeof(envItems)/sizeof(envItems[0]);

	camera := rl.Camera2D {
		target   = player.position,
		offset   = {f32(SCREEN_WIDTH) / 2, f32(SCREEN_HEIGHT) / 2},
		rotation = 0,
		zoom     = 1,
	}

	// Store pointers to the multiple update camera functions
	camera_updaters := []CameraUpdateFunc {
		update_camera_center,
		update_camera_center_inside_map,
		update_camera_center_smooth_follow,
		update_camera_even_out_on_landing,
		update_camera_player_bounds_push,
	}

	camera_option := 0
	// int cameraUpdatersLength = sizeof(cameraUpdaters)/sizeof(cameraUpdaters[0]);

	camera_descriptions := []cstring {
		"Follow player center",
		"Follow player center, but clamp to map edges",
		"Follow player center; smoothed",
		"Follow player center horizontally; update player center vertically after landing",
		"Player push camera on getting too close to screen edge",
	}

	rl.SetTargetFPS(60)
	//--------------------------------------------------------------------------------------

	// Main game loop
	for !rl.WindowShouldClose() {
		// Update
		//----------------------------------------------------------------------------------
		delta_time := rl.GetFrameTime()

		update_player(&player, env_items[:], delta_time)

		camera.zoom += f32(rl.GetMouseWheelMove()) * 0.05
		camera.zoom = clamp(camera.zoom, 0.25, 3.0)

		if rl.IsKeyPressed(.R) {
			camera.zoom = 1.0
			player.position = {400, 280}
		}

		if rl.IsKeyPressed(.C) {
			camera_option = (camera_option + 1) % len(camera_updaters)
		}

		// Call update camera function by its pointer
		camera_updaters[camera_option](
			&camera,
			&player,
			env_items[:],
			delta_time,
			SCREEN_WIDTH,
			SCREEN_HEIGHT,
		)
		//----------------------------------------------------------------------------------

		// Draw
		//----------------------------------------------------------------------------------
		rl.BeginDrawing()
		defer rl.EndDrawing()

		rl.ClearBackground(rl.LIGHTGRAY)

		rl.BeginMode2D(camera)

		for item in env_items {
			rl.DrawRectangleRec(item.rect, item.color)
		}

		player_rect := rl.Rectangle{player.position.x - 20, player.position.y - 40, 40, 40}
		rl.DrawRectangleRec(player_rect, rl.RED)
		rl.DrawCircleV(player.position, 5, rl.GOLD)

		rl.EndMode2D()

		rl.DrawText("Controls:", 20, 20, 10, rl.BLACK)
		rl.DrawText("- Right/Left to move", 40, 40, 10, rl.DARKGRAY)
		rl.DrawText("- Space to jump", 40, 60, 10, rl.DARKGRAY)
		rl.DrawText("- Mouse Wheel to Zoom in-out, R to reset zoom", 40, 80, 10, rl.DARKGRAY)
		rl.DrawText("- C to change camera mode", 40, 100, 10, rl.DARKGRAY)
		rl.DrawText("Current camera mode:", 20, 120, 10, rl.BLACK)
		rl.DrawText(camera_descriptions[camera_option], 40, 140, 10, rl.DARKGRAY)

		//----------------------------------------------------------------------------------
	}

	// De-Initialization
	//--------------------------------------------------------------------------------------
	rl.CloseWindow() // Close window and OpenGL context
	//--------------------------------------------------------------------------------------
}

update_player :: proc(player: ^Player, env_items: []EnvItem, delta: f32) {
	if rl.IsKeyDown(.LEFT) do player.position.x -= PLAYER_HOR_SPD * delta
	if rl.IsKeyDown(.RIGHT) do player.position.x += PLAYER_HOR_SPD * delta
	if rl.IsKeyDown(.SPACE) && player.can_jump {
		player.speed = -PLAYER_JUMP_SPD
		player.can_jump = false
	}

	hit_obstacle := false
	for item in env_items {
		if item.blocking &&
		   item.rect.x <= player.position.x &&
		   item.rect.x + item.rect.width >= player.position.x &&
		   item.rect.y >= player.position.y &&
		   item.rect.y <= player.position.y + player.speed * delta {
			hit_obstacle = true
			player.speed = 0
			player.position.y = item.rect.y
			break
		}
	}

	if !hit_obstacle {
		player.position.y += player.speed * delta
		player.speed += G * delta
		player.can_jump = false
	} else {
		player.can_jump = true
	}
}

update_camera_center :: proc(
	camera: ^rl.Camera2D,
	player: ^Player,
	env_items: []EnvItem,
	delta: f32,
	width: i32,
	height: i32,
) {
	camera.offset = {f32(width) / 2, f32(height) / 2}
	camera.target = player.position
}

update_camera_center_inside_map :: proc(
	camera: ^rl.Camera2D,
	player: ^Player,
	env_items: []EnvItem,
	delta: f32,
	width: i32,
	height: i32,
) {
	camera.target = player.position
	camera.offset = {f32(width) / 2, f32(height) / 2}

	min_x, min_y: f32 = 1000.0, 1000.0
	max_x, max_y: f32 = -1000.0, -1000.0

	for item in env_items {
		min_x = min(item.rect.x, min_x)
		max_x = max(item.rect.x + item.rect.width, max_x)
		min_y = min(item.rect.y, min_y)
		max_y = max(item.rect.y + item.rect.height, max_y)
	}

	max := rl.GetWorldToScreen2D({max_x, max_y}, camera^)
	min := rl.GetWorldToScreen2D({min_x, min_y}, camera^)

	if max.x < f32(width) do camera.offset.x = f32(width) - (max.x - f32(width) / 2)
	if max.y < f32(height) do camera.offset.y = f32(height) - (max.y - f32(height) / 2)
	if min.x > 0 do camera.offset.x = f32(width) / 2 - min.x
	if min.y > 0 do camera.offset.y = f32(height) / 2 - min.y
}

update_camera_center_smooth_follow :: proc(
	camera: ^rl.Camera2D,
	player: ^Player,
	env_items: []EnvItem,
	delta: f32,
	width: i32,
	height: i32,
) {
	MIN_SPEED :: 30
	MIN_EFFECT_LENGTH :: 10
	FRACTION_SPEED :: 0.8

	camera.offset = {f32(width) / 2, f32(height) / 2}
	diff := player.position - camera.target
	length := rl.Vector2Length(diff)

	if length > MIN_EFFECT_LENGTH {
		speed := max(FRACTION_SPEED * length, MIN_SPEED)
		camera.target = camera.target + diff * speed * delta / length
	}
}

update_camera_even_out_on_landing :: proc(
	camera: ^rl.Camera2D,
	player: ^Player,
	env_items: []EnvItem,
	delta: f32,
	width: i32,
	height: i32,
) {
	EVEN_OUT_SPEED :: 700

	@(static) evening_out := false
	@(static) even_out_target: f32 = 0

	camera.offset = {f32(width) / 2, f32(height) / 2}
	camera.target.x = player.position.x

	if evening_out {
		if even_out_target > camera.target.y {
			camera.target.y += EVEN_OUT_SPEED * delta
			if camera.target.y > even_out_target {
				camera.target.y = even_out_target
				evening_out = false
			}
		} else {
			camera.target.y -= EVEN_OUT_SPEED * delta
			if camera.target.y < even_out_target {
				camera.target.y = even_out_target
				evening_out = false
			}
		}
	} else {
		if player.can_jump && player.speed == 0 && player.position.y != camera.target.y {
			evening_out = true
			even_out_target = player.position.y
		}
	}
}

update_camera_player_bounds_push :: proc(
	camera: ^rl.Camera2D,
	player: ^Player,
	env_items: []EnvItem,
	delta: f32,
	width: i32,
	height: i32,
) {
	BBOX_X :: 0.2
	BBOX_Y :: 0.2

	bbox_world_min := rl.GetScreenToWorld2D(
		{(1 - BBOX_X) * 0.5 * f32(width), (1 - BBOX_Y) * 0.5 * f32(height)},
		camera^,
	)
	bbox_world_max := rl.GetScreenToWorld2D(
		{(1 + BBOX_X) * 0.5 * f32(width), (1 + BBOX_Y) * 0.5 * f32(height)},
		camera^,
	)
	camera.offset = {(1 - BBOX_X) * 0.5 * f32(width), (1 - BBOX_Y) * 0.5 * f32(height)}

	if player.position.x < bbox_world_min.x do camera.target.x = player.position.x
	if player.position.y < bbox_world_min.y do camera.target.y = player.position.y
	if player.position.x > bbox_world_max.x {
		camera.target.x = bbox_world_min.x + (player.position.x - bbox_world_max.x)
	}
	if player.position.y > bbox_world_max.y {
		camera.target.y = bbox_world_min.y + (player.position.y - bbox_world_max.y)
	}
}
