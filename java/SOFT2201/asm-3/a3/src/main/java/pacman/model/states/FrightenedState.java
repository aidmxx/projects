package pacman.model.states;

import pacman.model.decorator.FrightenedGhostDecorator;
import pacman.model.entity.dynamic.ghost.Ghost;
import pacman.model.entity.dynamic.physics.Vector2D;

import java.util.Random;

/**
 * A state pattern to implement the frightened behaviour and with the additional movement.
 * getTargetLocation() Find the location of ghosts and pacman under frightened mode
 */
public class FrightenedState implements GhostState{
    private Vector2D respawnPosition;
    private final Random random;
    public FrightenedState(Vector2D respawnPosition) {
        this.respawnPosition = respawnPosition;
        this.random = new Random();
    }
    @Override
    public Vector2D getTargetLocation(Vector2D playerPosition, Ghost ghost) {
        double randomX = random.nextDouble() * 10 - 5;
        double randomY = random.nextDouble() * 10 - 5;
        return ghost.getPosition().add(new Vector2D(randomX, randomY));
    }

    public Vector2D getRespawnPosition() {
        return respawnPosition;
    }
}
