package pacman.model.states;

import pacman.model.entity.dynamic.ghost.Ghost;
import pacman.model.entity.dynamic.physics.Vector2D;
import pacman.model.strategies.ChaseStrategy;

/**
 * A state pattern to implement the chasing behaviour and using chaseStrategy to calculate Pacman position.
 * getTargetLocation() Find the location of ghosts and pacman under chase mode
 */
public class ChaseState implements GhostState{
    private final ChaseStrategy chaseStrategy;

    public ChaseState(ChaseStrategy chaseStrategy) {
        this.chaseStrategy = chaseStrategy;
    }

    @Override
    public Vector2D getTargetLocation(Vector2D playerPosition, Ghost ghost) {
        return chaseStrategy.findTargetLoc(playerPosition, ghost);
    }
}
