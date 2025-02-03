package pacman.view.keyboard;

import javafx.scene.input.KeyCode;
import javafx.scene.input.KeyEvent;
import pacman.model.engine.GameEngine;
import pacman.model.entity.dynamic.player.Pacman;
import pacman.view.command.*;

/**
 * Responsible for handling keyboard input from player
 */
public class KeyboardInputHandler {

    private Command moveUpCommand;
    private Command moveDownCommand;
    private Command moveLeftCommand;
    private Command moveRightCommand;

    public KeyboardInputHandler(GameEngine engine) {
        this.moveUpCommand = new MoveUpCommand(engine);
        this.moveDownCommand = new MoveDownCommand(engine);
        this.moveLeftCommand = new MoveLeftCommand(engine);
        this.moveRightCommand = new MoveRightCommand(engine);
    }

    public void handlePressed(KeyEvent keyEvent) {
        KeyCode keyCode = keyEvent.getCode();
        switch (keyCode) {
            case LEFT:
                moveLeftCommand.execute();
                break;
            case RIGHT:
                moveRightCommand.execute();
                break;
            case DOWN:
                moveDownCommand.execute();
                break;
            case UP:
                moveUpCommand.execute();
                break;
            default:
                break;
        }
    }
}
