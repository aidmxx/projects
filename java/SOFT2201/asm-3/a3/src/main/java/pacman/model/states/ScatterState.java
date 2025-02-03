package pacman.model.states;

import pacman.model.entity.dynamic.ghost.Ghost;
import pacman.model.entity.dynamic.physics.Vector2D;

/**
 * A state to implement the scatter behaviour and targets the specific corner.
 * getTargetLocation() Find the location of ghosts and pacman under scatter mode
 */
public class ScatterState implements GhostState{
    private final Vector2D targetCorner;

    public ScatterState(Vector2D targetCorner) {
        this.targetCorner = targetCorner;
    }

    @Override
    public Vector2D getTargetLocation(Vector2D playerPosition, Ghost ghost) {
        return targetCorner;
    }
}
