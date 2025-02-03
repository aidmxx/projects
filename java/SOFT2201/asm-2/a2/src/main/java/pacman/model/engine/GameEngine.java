package pacman.model.engine;

import pacman.model.entity.Renderable;
import pacman.model.entity.dynamic.physics.Vector2D;
import pacman.view.GameWindow;

import java.util.List;


/**
 * The base interface for interacting with the Pac-Man model
 */
public interface GameEngine {

    /**
     * Gets the list of renderables in the game
     *
     * @return The list of renderables
     */
    List<Renderable> getRenderables();

    /**
     * Starts the game
     */
    void startGame();


    /**
     * Move the player up
     */
    void moveUp();

    /**
     * Move the player down
     */
    void moveDown();

    /**
     * Move the player left
     */
    void moveLeft();

    /**
     * Move the player right
     */
    void moveRight();

    /**
     * Instruct the model to progress forward in time by one increment.
     */
    void tick();

    void updateGhostsByPacmanPosition(Vector2D pacmanPosition);

    void setGameWindow(GameWindow window);

    // return total scores for inheritance to next levels
    int getTotalScore();
}
