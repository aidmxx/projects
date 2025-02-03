# PacMan Game
The PacMan Game is a player-controlled single-player mini-game, which aims to avoid ghosts and eat beans to pass the level.

Key features include:

- Player is able to control the PacMan movement with the keyboard connection (UP/DOWN/LEFT/RIGHT)
- PacMan can earn points by eating pallets
- Ghosts have 2 modes randomly switch: 
  - CHASE: Ghosts chase the PacMan
  - SCATTER: Ghosts move towards pre-defined target corner
- UI message like `YOU WIN!`, `READY`, `GAME OVER` to tell the player status

# How To Run This Game?
To run this PacMan game, type the following command into the command line:

```gradle clean build run```

# Design Patterns

## Observer Pattern
The Observer Pattern is implemented to update UI of the game window (e.g., `GAME OVER`). This allows observers to track and react to changes then quickly updates to game UI and handles messages.

**Related classes**
- `GameObserver`: Methods to update UI based on game changes (lives and score changes)
- `GameSubject`: Manage the observers and notify changes to them
- `GameWindow`: Implement `GameObserver` to receive updates and then change UI
- `LevelImpl`: Implement `GameSubject` to notify the changes to observers

**Package**: `observer`

## Factory Method Pattern
The Factory Method Pattern is employed to create different game entities based on given `RenderableType`.

**Related classes**
- `GameEntityFactory`: Declare the factory method `create()` for game entities creation
- `MazeFactory`: Concrete class of `GameEntityFactory` that implements `create()`
- `RenderableType`: Enumeration class includes different types of game objects

**Package**: `factory`

## Singleton Pattern
The Singleton Pattern is used to ensure there is only one instance of the implemented class exists throughout the game lifecycle.

**Related classes**

The `getInstance()` method is implemented in the following classes:

- `GameEngineImpl`
- `LevelImpl`
- `Maze`
- `MazeFactory`

**Package**: `model.engine`, `model.level`, `model.maze`, `factory`

## Command Pattern
The Command Pattern is determined to handle keyboard input from the Player and move Pac-Man.

**Related classes**
- `Command`: Declare `execute()` to be implemented by the concrete command classes
- `KeyboardInputHandler`: Manage player inputs and direct PacMan with the appropriate commands
- Concrete command classes: Implement `Command` to do specific movements

**Package**: `command`


# Additional changes
- Some attributes are modified to `public` based on the usage in other class (e.g. `currentLevelNo` in `GameEngineImpl`).