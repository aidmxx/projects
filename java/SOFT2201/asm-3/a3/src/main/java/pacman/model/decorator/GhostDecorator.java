package pacman.model.decorator;

import pacman.model.entity.Renderable;
import pacman.model.entity.dynamic.ghost.Ghost;
import pacman.model.level.Level;

// define GhostDecorator method used to add new behaviours to ghost behaviours under frightened mode
public abstract class GhostDecorator implements Ghost {
    protected final Ghost wrappedGhost;

    public GhostDecorator(Ghost ghost) {
        this.wrappedGhost = ghost;
    }

    @Override
    public void collideWith(Level level, Renderable renderable) {
        wrappedGhost.collideWith(level, renderable);
    }

}
