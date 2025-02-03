package pacman.view.command;

import pacman.model.engine.GameEngine;

public class MoveUpCommand implements Command {
    private GameEngine engine;
    public MoveUpCommand(GameEngine engine){
        this.engine = engine;
    }

    @Override
    public void execute() {
        engine.moveUp();
    }
}
