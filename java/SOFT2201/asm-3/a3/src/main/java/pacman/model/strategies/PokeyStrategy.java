package pacman.model.strategies;

import pacman.model.entity.dynamic.ghost.Ghost;
import pacman.model.entity.dynamic.physics.Vector2D;

/**
 * Implements the targeting behaviour for the "Pokey" ghost.
 * findTargetLoc() Manage the target location for "Pokey" ghost.
 */
public class PokeyStrategy implements ChaseStrategy{
    private static final double pokeyDistance = 8.0;
    private static final int BOTTOM_Y_POSITION_OF_MAP = 16 * 34;
    @Override
    public Vector2D findTargetLoc(Vector2D pacmanPosition, Ghost ghost) {
        double distanceAwayToPacman = Vector2D.calculateEuclideanDistance(ghost.getPosition(), pacmanPosition);
        if (distanceAwayToPacman > pokeyDistance){
            return pacmanPosition;
        } else {
            // go to bottom-left corner
            return new Vector2D(0, BOTTOM_Y_POSITION_OF_MAP);
        }
    }
}
