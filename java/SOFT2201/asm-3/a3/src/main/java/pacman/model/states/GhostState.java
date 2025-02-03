package pacman.model.states;

import pacman.model.entity.dynamic.ghost.Ghost;
import pacman.model.entity.dynamic.physics.Vector2D;

// define a GhostState change behaviours when its internal state changed
public interface GhostState {
    Vector2D getTargetLocation(Vector2D playerPosition, Ghost ghost);
}
