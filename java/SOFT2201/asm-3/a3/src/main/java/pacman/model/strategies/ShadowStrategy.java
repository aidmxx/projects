package pacman.model.strategies;

import pacman.model.entity.dynamic.ghost.Ghost;
import pacman.model.entity.dynamic.physics.Vector2D;

/**
 * Implements the targeting behaviour for the "Shadow" ghost.
 * findTargetLoc() Manage the target location for "Shadow" ghost.
 */
public class ShadowStrategy implements ChaseStrategy{

    @Override
    public Vector2D findTargetLoc(Vector2D pacmanPosition, Ghost ghost) {
        // this ghost's task is Pac-Man’s position
        return pacmanPosition;
    }
}
