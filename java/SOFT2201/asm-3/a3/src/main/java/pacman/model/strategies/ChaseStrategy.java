package pacman.model.strategies;

import pacman.model.entity.dynamic.ghost.Ghost;
import pacman.model.entity.dynamic.player.Pacman;
import pacman.model.entity.dynamic.physics.Vector2D;

// define a ChaseStrategy to manage different ghosts behaviours
public interface ChaseStrategy {
    Vector2D findTargetLoc(Vector2D pacmanPosition, Ghost ghost);
}
