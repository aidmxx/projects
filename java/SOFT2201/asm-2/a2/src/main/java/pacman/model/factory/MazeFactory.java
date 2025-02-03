package pacman.model.factory;

import javafx.scene.image.Image;
import pacman.model.entity.Renderable;
import pacman.model.entity.dynamic.ghost.GhostImpl;
import pacman.model.entity.dynamic.ghost.GhostMode;
import pacman.model.entity.dynamic.physics.*;
import pacman.model.entity.dynamic.player.Pacman;
import pacman.model.entity.dynamic.player.PacmanVisual;
import pacman.model.entity.staticentity.StaticEntityImpl;
import pacman.model.entity.staticentity.collectable.Pellet;
import pacman.model.maze.RenderableType;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;

public class MazeFactory extends GameEntityFactory {
    // stable four corners for ghosts to direction under SCATTER mode
    private static final Vector2D[] theCorner = {
        new Vector2D(0, 0), new Vector2D(480, 0), new Vector2D(0, 560), new Vector2D(480, 560)
    };

    private static MazeFactory instance;

    private MazeFactory() {}
    // MazeFactory instance implementation
    public static MazeFactory getInstance() {
        if (instance == null) {
            instance = new MazeFactory();
        }
        return instance;
    }

    public Renderable create(char renderableType, int x, int y) {
        Random random = new Random();
        switch (renderableType) {
            case RenderableType.PACMAN:
                Image pacmanDefaultImage = new Image(getClass().getResourceAsStream("/maze/pacman/playerLeft.png"));
                Map<PacmanVisual, Image> pacmanImages = new HashMap<>();
                pacmanImages.put(PacmanVisual.CLOSED, new Image(getClass().getResourceAsStream("/maze/pacman/playerClosed.png")));
                pacmanImages.put(PacmanVisual.UP, new Image(getClass().getResourceAsStream("/maze/pacman/playerUp.png")));
                pacmanImages.put(PacmanVisual.DOWN, new Image(getClass().getResourceAsStream("/maze/pacman/playerDown.png")));
                pacmanImages.put(PacmanVisual.LEFT, pacmanDefaultImage);
                pacmanImages.put(PacmanVisual.RIGHT, new Image(getClass().getResourceAsStream("/maze/pacman/playerRight.png")));
                BoundingBox pacBoundingBox = new BoundingBoxImpl(new Vector2D(x - 4, y - 4), pacmanDefaultImage.getHeight(), pacmanDefaultImage.getWidth());
                KinematicState pacmanKinematicState = new KinematicStateImpl.KinematicStateBuilder()
                        .setPosition(new Vector2D(x - 4, y - 4))
                        .setSpeed(2.0)
                        .setDirection(Direction.LEFT)
                        .build();
                return new Pacman(pacmanDefaultImage, pacmanImages, pacBoundingBox, pacmanKinematicState);

            case RenderableType.PELLET:
                Image pelletImage = new Image(getClass().getResourceAsStream("/maze/pellet.png"));
                BoundingBox pelletBoundingBox = new BoundingBoxImpl(new Vector2D(x, y), pelletImage.getHeight(), pelletImage.getWidth());
                return new Pellet(pelletBoundingBox, Renderable.Layer.FOREGROUND, pelletImage, 100);

            case RenderableType.GHOST:
                Image ghostImage = new Image(getClass().getResourceAsStream("/maze/ghosts/ghost.png"));
                BoundingBox ghostBoundingBox = new BoundingBoxImpl(new Vector2D(x + 4, y - 4), ghostImage.getHeight(), ghostImage.getWidth());
                KinematicState ghostKinematicState = new KinematicStateImpl.KinematicStateBuilder()
                        .setPosition(new Vector2D(x + 4, y - 4))
                        .setSpeed(2.0)
                        .setDirection(Direction.LEFT)
                        .build();
                Vector2D targetCorner = theCorner[random.nextInt(theCorner.length)];
                return new GhostImpl(ghostImage, ghostBoundingBox, ghostKinematicState, GhostMode.SCATTER, targetCorner, Direction.UP);

            case RenderableType.HORIZONTAL_WALL:
                Image wallImage1 = new Image(getClass().getResourceAsStream("/maze/walls/horizontal.png"));
                return new StaticEntityImpl(new BoundingBoxImpl(new Vector2D(x, y), 16, 16), Renderable.Layer.BACKGROUND, wallImage1);

            case RenderableType.VERTICAL_WALL:
                Image wallImage2 = new Image(getClass().getResourceAsStream("/maze/walls/vertical.png"));
                return new StaticEntityImpl(new BoundingBoxImpl(new Vector2D(x, y), 16, 16), Renderable.Layer.BACKGROUND, wallImage2);

            case RenderableType.UP_LEFT_WALL:
                Image wallImage3 = new Image(getClass().getResourceAsStream("/maze/walls/upLeft.png"));
                return new StaticEntityImpl(new BoundingBoxImpl(new Vector2D(x, y), 16, 16), Renderable.Layer.BACKGROUND, wallImage3);

            case RenderableType.UP_RIGHT_WALL:
                Image wallImage4 = new Image(getClass().getResourceAsStream("/maze/walls/upRight.png"));
                return new StaticEntityImpl(new BoundingBoxImpl(new Vector2D(x, y), 16, 16), Renderable.Layer.BACKGROUND, wallImage4);

            case RenderableType.DOWN_LEFT_WALL:
                Image wallImage5 = new Image(getClass().getResourceAsStream("/maze/walls/downLeft.png"));
                return new StaticEntityImpl(new BoundingBoxImpl(new Vector2D(x, y), 16, 16), Renderable.Layer.BACKGROUND, wallImage5);

            case RenderableType.DOWN_RIGHT_WALL:
                Image wallImage6 = new Image(getClass().getResourceAsStream("/maze/walls/downRight.png"));
                return new StaticEntityImpl(new BoundingBoxImpl(new Vector2D(x, y), 16, 16), Renderable.Layer.BACKGROUND, wallImage6);

            default:
                return null;
        }
    }

}
