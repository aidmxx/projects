package pacman.model.factories;

import javafx.scene.image.Image;
import pacman.ConfigurationParseException;
import pacman.model.entity.Renderable;
import pacman.model.entity.dynamic.ghost.GhostImpl;
import pacman.model.entity.dynamic.ghost.GhostMode;
import pacman.model.entity.dynamic.physics.*;
import pacman.model.strategies.ChaseStrategy;
import pacman.model.strategies.PokeyStrategy;

public class ClydeFactory implements RenderableFactory{
    private static final int BOTTOM_Y_POSITION_OF_MAP = 16 * 34;

    private static final Image CLYDE_IMAGE = new Image("maze/ghosts/clyde.png");
    Vector2D bottomLeftCorner = new Vector2D(0, BOTTOM_Y_POSITION_OF_MAP);
    private int getRandomNumber(int min, int max) {
        return (int) ((Math.random() * (max - min)) + min);
    }
    private ChaseStrategy pokeyStrategy = new PokeyStrategy();
    @Override
    public Renderable createRenderable(
            Vector2D position
    ) {
        try {
            position = position.add(new Vector2D(4, -4));

            BoundingBox boundingBox = new BoundingBoxImpl(
                    position,
                    CLYDE_IMAGE.getHeight(),
                    CLYDE_IMAGE.getWidth()
            );

            KinematicState kinematicState = new KinematicStateImpl.KinematicStateBuilder()
                    .setPosition(position)
                    .build();

            return new GhostImpl(
                    CLYDE_IMAGE,
                    boundingBox,
                    kinematicState,
                    GhostMode.SCATTER,
                    bottomLeftCorner,
                    pokeyStrategy);
        } catch (Exception e) {
            throw new ConfigurationParseException(
                    String.format("Invalid ghost configuration | %s ", e));
        }
    }
}
