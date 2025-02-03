package pacman.model.factories;

import javafx.scene.image.Image;
import pacman.ConfigurationParseException;
import pacman.model.entity.Renderable;
import pacman.model.entity.dynamic.ghost.GhostImpl;
import pacman.model.entity.dynamic.ghost.GhostMode;
import pacman.model.entity.dynamic.physics.*;
import pacman.model.strategies.BashfulStrategy;
import pacman.model.strategies.ChaseStrategy;


public class InkyFactory implements RenderableFactory{
    private static final int RIGHT_X_POSITION_OF_MAP = 448;
    private static final int BOTTOM_Y_POSITION_OF_MAP = 16 * 34;

    private static final Image INKY_IMAGE = new Image("maze/ghosts/inky.png");
    Vector2D bottomRightCorner = new Vector2D(RIGHT_X_POSITION_OF_MAP, BOTTOM_Y_POSITION_OF_MAP);
    private int getRandomNumber(int min, int max) {
        return (int) ((Math.random() * (max - min)) + min);
    }
    private ChaseStrategy inkyStrategy = new BashfulStrategy();
    @Override
    public Renderable createRenderable(
            Vector2D position
    ) {
        try {
            position = position.add(new Vector2D(4, -4));

            BoundingBox boundingBox = new BoundingBoxImpl(
                    position,
                    INKY_IMAGE.getHeight(),
                    INKY_IMAGE.getWidth()
            );

            KinematicState kinematicState = new KinematicStateImpl.KinematicStateBuilder()
                    .setPosition(position)
                    .build();

            return new GhostImpl(
                    INKY_IMAGE,
                    boundingBox,
                    kinematicState,
                    GhostMode.SCATTER,
                    bottomRightCorner,
                    inkyStrategy);
        } catch (Exception e) {
            throw new ConfigurationParseException(
                    String.format("Invalid ghost configuration | %s ", e));
        }
    }
}
