package pacman.model.strategies;

import pacman.model.entity.dynamic.ghost.Ghost;
import pacman.model.entity.dynamic.physics.Vector2D;

/**
 * Implements the targeting behaviour for the "Speedy" ghost.
 * findTargetLoc() Manage the target location for "Speedy" ghost.
 */
public class SpeedyStrategy implements ChaseStrategy{
    // four spaces ahead player
    private static final int speedAhead = 4;
    @Override
    public Vector2D findTargetLoc(Vector2D pacmanPosition, Ghost ghost) {
        Vector2D pinkPosition;
        if (pacmanPosition.getX() > ghost.getPositionBeforeLastUpdate().getX()){
            // move to right
            pinkPosition = new Vector2D(speedAhead, 0);
        } else if (pacmanPosition.getX() < ghost.getPositionBeforeLastUpdate().getX()) {
            // move to left
            pinkPosition = new Vector2D(-speedAhead, 0);
        } else if (pacmanPosition.getY() > ghost.getPositionBeforeLastUpdate().getY()) {
            // move to down
            pinkPosition = new Vector2D(0, speedAhead);
        } else {
            // move to up
            pinkPosition = new Vector2D(0, -speedAhead);
        }
        return pacmanPosition.add(pinkPosition);
    }
}
