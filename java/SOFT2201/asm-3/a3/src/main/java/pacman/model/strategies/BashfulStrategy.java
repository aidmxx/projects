package pacman.model.strategies;

import pacman.model.entity.dynamic.ghost.Ghost;
import pacman.model.entity.dynamic.physics.Vector2D;

/**
 * Implements the targeting behaviour for the "Bashful" ghost.
 * findTargetLoc() Manage the target location for "Bashful" ghost.
 */
public class BashfulStrategy implements ChaseStrategy{
    private static final int bashfulSpace = 2;
    @Override
    public Vector2D findTargetLoc(Vector2D pacmanPosition, Ghost ghost) {
        Vector2D bashfulPosition = ghost.getPosition();

        Vector2D needToAhead;
        if (pacmanPosition.getX() > ghost.getPositionBeforeLastUpdate().getX()){
            // move to right
            needToAhead = new Vector2D(bashfulSpace, 0);
        } else if (pacmanPosition.getX() < ghost.getPositionBeforeLastUpdate().getX()) {
            // move to left
            needToAhead = new Vector2D(-bashfulSpace, 0);
        } else if (pacmanPosition.getY() > ghost.getPositionBeforeLastUpdate().getY()) {
            // move to down
            needToAhead = new Vector2D(0, bashfulSpace);
        } else {
            // move to up
            needToAhead = new Vector2D(0, -bashfulSpace);
        }

        Vector2D aheadOfPacman = pacmanPosition.add(needToAhead);
        double vectorToAheadX = aheadOfPacman.getX() - bashfulPosition.getX();
        double vectorToAheadY = aheadOfPacman.getY() - bashfulPosition.getY();

        double doubleVectorX = vectorToAheadX * 2;
        double doubleVectorY = vectorToAheadY * 2;
        Vector2D doubleVector = new Vector2D(doubleVectorX, doubleVectorY);

        return pacmanPosition.add(doubleVector);
    }
}
