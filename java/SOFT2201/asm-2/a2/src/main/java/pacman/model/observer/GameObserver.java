package pacman.model.observer;

// define GameObserver method used to notify the observer changes
public interface GameObserver {
    void updateLives(int numLives);
    void updateScore(int scores);
    void notifyGameOver();
}
