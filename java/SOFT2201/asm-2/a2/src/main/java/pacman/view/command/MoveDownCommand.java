package pacman.view.command;

import pacman.model.engine.GameEngine;

public class MoveDownCommand implements Command {
    private GameEngine engine;
    public MoveDownCommand(GameEngine engine){
        this.engine = engine;
    }

    @Override
    public void execute() {
        engine.moveDown();

    }
}
