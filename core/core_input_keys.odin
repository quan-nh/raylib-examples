/*******************************************************************************************
*
*   raylib [core] example - Keyboard input
*
*   Example originally created with raylib 1.0, last time updated with raylib 1.0
*
*   Example licensed under an unmodified zlib/libpng license, which is an OSI-certified,
*   BSD-like license that allows static linking with closed source software
*
*   Copyright (c) 2014-2024 Ramon Santamaria (@raysan5)
*
********************************************************************************************/

package main

import rl "vendor:raylib"

//------------------------------------------------------------------------------------
// Program main entry point
//------------------------------------------------------------------------------------
main :: proc() {
	// Initialization
	SCREEN_WIDTH :: 800
	SCREEN_HEIGHT :: 450

	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib [core] example - keyboard input")

	ballPosition := rl.Vector2{f32(SCREEN_WIDTH) / 2, f32(SCREEN_HEIGHT) / 2}

	rl.SetTargetFPS(60) // Set our game to run at 60 frames-per-second
	//--------------------------------------------------------------------------------------

	// Main game loop
	for !rl.WindowShouldClose() {
		// Update
		if rl.IsKeyDown(.RIGHT) do ballPosition.x += 2.0
		if rl.IsKeyDown(.LEFT) do ballPosition.x -= 2.0
		if rl.IsKeyDown(.UP) do ballPosition.y -= 2.0
		if rl.IsKeyDown(.DOWN) do ballPosition.y += 2.0

		// Draw
		rl.BeginDrawing()
		defer rl.EndDrawing()

		rl.ClearBackground(rl.RAYWHITE)
		rl.DrawText("move the ball with arrow keys", 10, 10, 20, rl.DARKGRAY)
		rl.DrawCircleV(ballPosition, 50, rl.MAROON)
	}

	// De-Initialization
	rl.CloseWindow()
}
