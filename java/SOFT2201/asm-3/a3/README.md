# PacMan Game
The PacMan Game is a player-controlled single-player mini-game, which aims to avoid ghosts and eat beans to pass the level.

Key features include:

- FRIGHTENED mode extension (not finished at collision and points adding)
- Power pellet show on UI
- Four types ghosts SCATTER/CHASE mode

# How To Run This Game?
To run this PacMan game, type the following command into the command line:

```gradle clean build run```

# Design Patterns

## Strategy Pattern
The Strategy Pattern is implemented to separate different types of ghosts with different CHASE types. This enables each ghost to adopt a distinct movement and dynamically modify its objective in response to its own behaviour.

**Related classes**
- `ChaseStrategy`: An interface that defines the `findTargetLoc()` method, which serves as the foundation for various ghost chase behaviours.
- `BashfulStrategy`: Implement `ChaseStrategy` method to define the bashful ghost behaviour.
- `ShadowStrategy`: Implement `ChaseStrategy` method to define the shadow ghost behaviour.
- `PokeyStrategy`: Implement `ChaseStrategy` method to define the pokey ghost behaviour.
- `SpeedyStrategy`: Implement `ChaseStrategy` method to define the speedy ghost behaviour.

**Package**: `strategies`

## State Pattern
The State Pattern is employed to create different kinds of mode (`FRIGHTENED`, `CHASE`, `SCATTER`) for ghosts to change during the game.

**Related classes**
- `GhostState`: An interface that defines the `getTargetLocation()` method, which serves as the foundation for various mode behaviours.
- `FrightenedState`: Implement `GhostState` method to define the ghost frightened mode.
- `ScatterState`: Implement `GhostState` method to define the ghost scatter mode.
- `ChaseState`: Implement `GhostState` method to define the ghost chase mode.

**Package**: `states`

## Decorator Pattern
The Decorator Pattern (Decorator Pattern) is used to ghost them into `FRIGHTENED` mode. This pattern allows dynamic behavioral modifications to be made to ghosts without changing their class structure. However, this design pattern is not finished and failed to implement the structure on pacman can eat ghosts.

**Related classes**

- `GhostDecorator`: An abstract class is used to delegate the behaviours for ghosts. This provides the additional on ghosts into `FRIGHTENED` mode.
- `FrightenedGhostDecorator`: An extension class defines the behaviour of ghosts into `FRIGHTENED` mode. This should allow the pacman to eat ghosts and then getting the extra points.

**Package**: `decorator`


# Additional changes
- Implement a setter method for Frightened mode image change by `setImage()` in `GhostImpl.java`.
- `PowerPelletFactory` class defines the new types of pellets for changing into `FRIGHTENED` mode.
- Change length of mode into ticks per second by multiplying 34.