package pacman.view.command;

import pacman.model.engine.GameEngine;
public class MoveRightCommand implements Command {
    private GameEngine engine;
    public MoveRightCommand(GameEngine engine){
        this.engine = engine;
    }

    @Override
    public void execute() {
        engine.moveRight();

    }
}
