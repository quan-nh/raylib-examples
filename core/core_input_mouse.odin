/*******************************************************************************************
*
*   raylib [core] example - Mouse input
*
*   Example originally created with raylib 1.0, last time updated with raylib 4.0
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

	rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "raylib [core] example - mouse input")

	ballPosition := rl.Vector2{-100.0, -100.0}
	ballColor := rl.DARKBLUE

	rl.SetTargetFPS(60) // Set our game to run at 60 frames-per-second
	//---------------------------------------------------------------------------------------

	// Main game loop
	for !rl.WindowShouldClose() {
		// Update
		ballPosition = rl.GetMousePosition()

		if rl.IsMouseButtonPressed(.LEFT) {
			ballColor = rl.MAROON
		} else if rl.IsMouseButtonPressed(.MIDDLE) {
			ballColor = rl.LIME
		} else if rl.IsMouseButtonPressed(.RIGHT) {
			ballColor = rl.DARKBLUE
		} else if rl.IsMouseButtonPressed(.SIDE) {
			ballColor = rl.PURPLE
		} else if rl.IsMouseButtonPressed(.EXTRA) {
			ballColor = rl.YELLOW
		} else if rl.IsMouseButtonPressed(.FORWARD) {
			ballColor = rl.ORANGE
		} else if rl.IsMouseButtonPressed(.BACK) {
			ballColor = rl.BEIGE
		}

		// Draw
		rl.BeginDrawing()
		defer rl.EndDrawing()

		rl.ClearBackground(rl.RAYWHITE)
		rl.DrawCircleV(ballPosition, 40, ballColor)
		rl.DrawText(
			"move ball with mouse and click mouse button to change color",
			10,
			10,
			20,
			rl.DARKGRAY,
		)
	}

	// De-Initialization
	rl.CloseWindow()
}
