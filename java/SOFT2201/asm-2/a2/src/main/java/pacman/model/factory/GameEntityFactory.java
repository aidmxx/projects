package pacman.model.factory;
import pacman.model.entity.Renderable;

public abstract class GameEntityFactory {
    /**
     * The abstract Factory pattern implemented to determine different game entities.
     * Where the subclass must implement this create() to specify initialisation and instances
     * @param renderableType determine game entity types
     * @param x entities position x display on map
     * @param y entities position y display on map
     * @return
     */
    public abstract Renderable create(char renderableType, int x, int y);
}
