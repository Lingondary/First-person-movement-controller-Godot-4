# First Person Controller (Godot 4)

A simple **First Person Controller** made for **Godot 4**.  
This project includes a demo scene, fully functional input system, and scripts for smooth first-person movement and camera behavior.

---

## Features

- Full first-person movement system  
- Smooth walking, sprinting, crouching, and jumping  
- Head bobbing animation  
- Camera tilt and landing/jump effects  
- Adjustable sensitivity, acceleration, and movement speeds  
- Obstacle check when standing up from crouch  

---

## Scripts Overview

### `InputHandler.gd`
Handles all input actions and emits relevant signals for other controllers.  

---

### `MovementController.gd`
Handles player physics and movement logic:  
- Walking, sprinting, crouching, and jumping  
- Smooth acceleration and friction  
- Air control and gravity  
- Dynamic capsule collider resizing during crouch  

---

### `CameraController.gd`
Controls the camera position and tilt effects:  
- Head bobbing while moving  
- Camera tilt while strafing  
- Jump and landing camera bounce  

---

## Input Map Setup

Add the following input actions in **Project Settings → Input Map**:

| Action Name     | Default Key |
|-----------------|--------------|
| `input_forward` | W |
| `input_backward`| S |
| `input_left`    | A |
| `input_right`   | D |
| `jump`          | Space |
| `accelerate`    | Shift |
| `crouch`        | Ctrl |

---

## License

This project is licensed under the **MIT License** — free to use, modify, and distribute in your own projects.


