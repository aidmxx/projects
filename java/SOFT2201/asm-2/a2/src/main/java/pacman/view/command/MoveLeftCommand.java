package pacman.view.command;

import pacman.model.engine.GameEngine;

public class MoveLeftCommand implements Command {
    private GameEngine engine;
    public MoveLeftCommand(GameEngine engine){
        this.engine = engine;
    }

    @Override
    public void execute() {
        engine.moveLeft();

    }
}
