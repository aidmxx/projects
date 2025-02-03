package pacman.model.decorator;

import javafx.scene.image.Image;
import pacman.model.entity.Renderable;
import pacman.model.entity.dynamic.ghost.Ghost;
import pacman.model.entity.dynamic.ghost.GhostImpl;
import pacman.model.entity.dynamic.ghost.GhostMode;
import pacman.model.entity.dynamic.physics.BoundingBox;
import pacman.model.entity.dynamic.physics.Direction;
import pacman.model.entity.dynamic.physics.Vector2D;
import pacman.model.level.Level;

import java.util.Map;
import java.util.Set;

/**
 * A docorator method to determine the host behaviours under frightened mode
 * Ghost ghost Pass the ghost to implement
 * Vector2D respawnPosition Control ghost respawn position
 * collideWith() Manage the ghost and pacman behaviours after colliding
 */
public class FrightenedGhostDecorator extends GhostDecorator {
    private final Vector2D respawnPosition;
    private int numOfConsecutiveEaten;

    public FrightenedGhostDecorator(Ghost ghost, Vector2D respawnPosition) {
        super(ghost);
        this.respawnPosition = respawnPosition;
        this.numOfConsecutiveEaten = 0;
    }

    @Override
    public void update() {

    }

    @Override
    public Vector2D getPositionBeforeLastUpdate() {
        return null;
    }

    @Override
    public boolean collidesWith(Renderable renderable) {
        return false;
    }

    @Override
    public void collideWith(Level level, Renderable renderable) {
        if (wrappedGhost instanceof GhostImpl) {
            ((GhostImpl) wrappedGhost).reset();
        }

    }

    @Override
    public void setPossibleDirections(Set<Direction> possibleDirections) {

    }

    @Override
    public Direction getDirection() {
        return null;
    }

    @Override
    public Vector2D getCenter() {
        return null;
    }

    /**
     * Returns the points awarded based on the number of consecutive ghosts eaten in this frightened mode period.
     */
    public int getEatenPoints() {
        return switch (numOfConsecutiveEaten) {
            case 1 -> 200;
            case 2 -> 400;
            case 3 -> 800;
            case 4 -> 1600;
            default -> 200;
        };
    }


    @Override
    public Image getImage() {
        return null;
    }

    @Override
    public double getWidth() {
        return 0;
    }

    @Override
    public double getHeight() {
        return 0;
    }

    @Override
    public Vector2D getPosition() {
        return null;
    }

    @Override
    public Layer getLayer() {
        return null;
    }

    @Override
    public BoundingBox getBoundingBox() {
        return null;
    }

    @Override
    public void reset() {

    }

    @Override
    public void setSpeeds(Map<GhostMode, Double> speeds) {

    }

    @Override
    public void setGhostMode(GhostMode ghostMode) {

    }

    @Override
    public GhostMode getGhostMode() {
        return null;
    }

    @Override
    public void setImage(Image image) {

    }

    @Override
    public void update(Vector2D position) {

    }
}
