package pacman.model.observer;

/**
 * define an observer subject in the Observer design pattern. This allows observers to track and react to changes then quickly updates to game UI and handles messages
 *
 * addObserver(GameObserver observer): create a new observer to receive updates on the game changes
 * removeObserver(GameObserver observer): remove an observer to stop receiving the further updates
 * notifyLivesChanged(int lives): notify all observers of changes in PacMan lives
 * notifyScoreChanged(int score): notify all observers of changes in score increment
 * notifyGameOver(): notify all observers of changes when game losing
 */

public interface GameSubject {
    void addObserver(GameObserver observer);
    void removeObserver(GameObserver observer);
    void notifyLivesChanged(int lives);
    void notifyScoreChanged(int score);
    void notifyGameOver();
}
