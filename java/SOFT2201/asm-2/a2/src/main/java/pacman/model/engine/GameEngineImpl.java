package pacman.model.engine;

import org.json.simple.JSONArray;
import org.json.simple.JSONObject;
import pacman.model.entity.Renderable;
import pacman.model.entity.dynamic.ghost.Ghost;
import pacman.model.entity.dynamic.physics.Vector2D;
import pacman.model.entity.dynamic.player.Pacman;
import pacman.model.level.Level;
import pacman.model.level.LevelImpl;
import pacman.model.maze.Maze;
import pacman.model.maze.MazeCreator;
import pacman.model.observer.GameSubject;
import pacman.view.GameWindow;

import java.util.ArrayList;
import java.util.List;

/**
 * Implementation of GameEngine - responsible for coordinating the Pac-Man model
 */
public class GameEngineImpl implements GameEngine{

    private Level currentLevel;
    private int numLevels;
    public int currentLevelNo;
    private Maze maze;
    private JSONArray levelConfigs;
    private List<Ghost> ghosts;
    private static GameEngineImpl instance;
    private GameWindow gameWindow;
    private boolean isReady;
    private int readyCount;
    private int totalScore;
    public GameEngineImpl(String configPath) {
        this.currentLevelNo = 0;
        this.totalScore = 0;
        init(new GameConfigurationReader(configPath));
        // initialise ghosts
        ghosts = new ArrayList<>();
    }
    /**
     * A public method to get instance (Singleton used). This pattern can ensure only one instance of GameEngineImpl exists throughout the whole project. Which can also avoid the percentage of data duplication and wrong updates happen.
     * @param configPath The path to the configuration file
     * @return single instance of GameEngineImpl
     */
    public static GameEngineImpl getInstance(String configPath) {
        if (instance == null) {
            instance = new GameEngineImpl(configPath);
        }
        return instance;
    }

    // set the GameWindow
    public void setGameWindow(GameWindow gameWindow) {
        this.gameWindow = gameWindow;
    }

    private void init(GameConfigurationReader gameConfigurationReader) {
        // Set up map
        String mapFile = gameConfigurationReader.getMapFile();
        MazeCreator mazeCreator = new MazeCreator(mapFile);
        this.maze = mazeCreator.createMaze();
        this.maze.setNumLives(gameConfigurationReader.getNumLives());

        // Get level configurations
        this.levelConfigs = gameConfigurationReader.getLevelConfigs();
        this.numLevels = levelConfigs.size();
        if (levelConfigs.isEmpty()) {
            System.exit(0);
        }
    }

    @Override
    public List<Renderable> getRenderables() {
        return this.currentLevel.getRenderables();
    }

    @Override
    public void moveUp() {
        currentLevel.moveUp();
    }

    @Override
    public void moveDown() {
        currentLevel.moveDown();
    }

    @Override
    public void moveLeft() {
        currentLevel.moveLeft();
    }

    @Override
    public void moveRight() {
        currentLevel.moveRight();
    }

    @Override
    public void startGame() {
        startLevel();
        // to lead lives display
        gameWindow.updateLives(LevelImpl.getInstance((JSONObject) levelConfigs.get(currentLevelNo), maze).getNumLives());
    }

    private void startLevel() {
        JSONObject levelConfig = (JSONObject) levelConfigs.get(currentLevelNo);
        // reset renderables to starting state
        maze.reset();
        this.currentLevel = LevelImpl.getInstance(levelConfig, maze);
        // inherit the score before starting a new level
        //System.out.println("Update score: " + gameWindow.getUpdateScore());
        this.totalScore += getTotalScore();
        // get all ghosts from current level
        this.ghosts = currentLevel.getGhosts();
        // add the GameWindow as an observer
        ((GameSubject) currentLevel).addObserver(gameWindow);
        //System.out.println("Starting Level: " + currentLevelNo);
        // set READY UI
        readyPhrase();
    }

    @Override
    public void tick() {
        // setup READY frame
        if (isReady){
            if (readyCount < 100){
                readyCount++;
                return;
            }else {
                isReady = false;
            }
        }
        currentLevel.tick();
    }
    // update each ghost with pacMan position
    @Override
    public void updateGhostsByPacmanPosition(Vector2D pacmanPosition){
        for (Ghost ghost: ghosts){
            ghost.setPlayerPosition(pacmanPosition);
        }
    }

    public void readyPhrase(){
        // READY status setup
        isReady = true;
        // reset frame
        readyCount = 0;
        // display READY
        gameWindow.displayReady();
    }

    // method to handle the game win
    public void handleGameWin() {
        if (currentLevelNo == numLevels - 1) {  // check if this is the last level
            //System.out.println("The level" + numLevels);
            if (currentLevel.isLevelFinished()) {
                handleWin();  // finally show out win message when all pellets are eaten
            }
        } else {
            // move to the next level and start
            currentLevelNo++;
            //System.out.println("There are: " + numLevels +  "levels.");
            //System.out.println("The current level is: " + currentLevelNo);
            //gameWindow.getUpdateScore();
            startLevel();
        }
    }

    private void handleWin() {
        // clear all entities (pacMan and ghosts)
        currentLevel.getRenderables().removeIf(renderable -> renderable instanceof Pacman || renderable instanceof Ghost);
        gameWindow.displayWin();
    }

    // return total scores for inheritance to next levels
    @Override
    public int getTotalScore() {
        return totalScore;
    }

    // update pellets are collected
    public void updateScore(int score) {
        this.totalScore += score;
        //System.out.println(score);
        gameWindow.updateScore(this.totalScore);  // notify UI of score update
    }
}

