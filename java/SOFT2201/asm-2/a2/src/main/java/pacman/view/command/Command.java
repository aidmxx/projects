package pacman.view.command;

/**
 * The Command pattern is employed to handle the keyboard connection to control pacMan movement (UP/DOWN/LEFT/RIGHT).
 *
 * execute(): each implementing command class need to define this method specifically which depending on its action represented.
 */
public interface Command {
    void execute();
}
