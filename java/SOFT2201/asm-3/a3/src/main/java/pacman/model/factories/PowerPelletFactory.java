package pacman.model.factories;

import javafx.scene.image.Image;
import pacman.ConfigurationParseException;
import pacman.model.entity.Renderable;
import pacman.model.entity.dynamic.physics.BoundingBox;
import pacman.model.entity.dynamic.physics.BoundingBoxImpl;
import pacman.model.entity.dynamic.physics.Vector2D;
import pacman.model.entity.staticentity.collectable.PowerPellet;

public class PowerPelletFactory implements RenderableFactory{
    private static final Image PELLET_IMAGE = new Image("maze/pellet.png");
    public static final int DEFAULT_POINTS = 0;
    private final Renderable.Layer layer = Renderable.Layer.BACKGROUND;
    private static final double SIZE_INCREMENT = 2.0;
    private static final Vector2D OFFSET = new Vector2D(-8, -8);

    @Override
    public Renderable createRenderable(
            Vector2D position
    ) {
        try {
            // adjust the position with an offset
            Vector2D powerPelletPosition = position.add(OFFSET);
            BoundingBox boundingBox = new BoundingBoxImpl(
                    powerPelletPosition,
                    PELLET_IMAGE.getHeight() * SIZE_INCREMENT,
                    PELLET_IMAGE.getWidth() * SIZE_INCREMENT
            );

            return new PowerPellet(
                    boundingBox,
                    layer,
                    PELLET_IMAGE,
                    DEFAULT_POINTS
            );

        } catch (Exception e) {
            throw new ConfigurationParseException(
                    String.format("Invalid pellet configuration | %s", e));
        }
    }
}
