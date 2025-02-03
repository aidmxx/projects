package pacman.model.factories;

import javafx.scene.image.Image;
import pacman.ConfigurationParseException;
import pacman.model.entity.Renderable;
import pacman.model.entity.dynamic.ghost.GhostImpl;
import pacman.model.entity.dynamic.ghost.GhostMode;
import pacman.model.entity.dynamic.physics.*;
import pacman.model.strategies.ChaseStrategy;
import pacman.model.strategies.SpeedyStrategy;


public class PinkyFactory implements RenderableFactory{
    private static final int TOP_Y_POSITION_OF_MAP = 16 * 3;
    private static final Image PINKY_IMAGE = new Image("maze/ghosts/pinky.png");
    Vector2D topLeftCorner = new Vector2D(0, TOP_Y_POSITION_OF_MAP);
    private int getRandomNumber(int min, int max) {
        return (int) ((Math.random() * (max - min)) + min);
    }
    private ChaseStrategy speedyStrategy = new SpeedyStrategy();
    @Override
    public Renderable createRenderable(
            Vector2D position
    ) {
        try {
            position = position.add(new Vector2D(4, -4));

            BoundingBox boundingBox = new BoundingBoxImpl(
                    position,
                    PINKY_IMAGE.getHeight(),
                    PINKY_IMAGE.getWidth()
            );

            KinematicState kinematicState = new KinematicStateImpl.KinematicStateBuilder()
                    .setPosition(position)
                    .build();

            return new GhostImpl(
                    PINKY_IMAGE,
                    boundingBox,
                    kinematicState,
                    GhostMode.SCATTER,
                    topLeftCorner,
                    speedyStrategy);
        } catch (Exception e) {
            throw new ConfigurationParseException(
                    String.format("Invalid ghost configuration | %s ", e));
        }
    }
}
