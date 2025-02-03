package pacman.model.level;

import org.json.simple.JSONObject;
import pacman.ConfigurationParseException;
import pacman.model.engine.GameConfigurationReader;
import pacman.model.engine.GameEngineImpl;
import pacman.model.entity.Renderable;
import pacman.model.entity.dynamic.DynamicEntity;
import pacman.model.entity.dynamic.ghost.Ghost;
import pacman.model.entity.dynamic.ghost.GhostMode;
import pacman.model.entity.dynamic.physics.Direction;
import pacman.model.entity.dynamic.physics.PhysicsEngine;
import pacman.model.entity.dynamic.player.Controllable;
import pacman.model.entity.dynamic.player.Pacman;
import pacman.model.entity.staticentity.StaticEntity;
import pacman.model.entity.staticentity.collectable.Collectable;
import pacman.model.maze.Maze;
import pacman.model.observer.GameObserver;
import pacman.model.observer.GameSubject;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Concrete implement of Pac-Man level
 */
public class LevelImpl implements Level, GameSubject {

    private static final int START_LEVEL_TIME = 200;
    private final Maze maze;
    private List<Renderable> renderables;
    // used to get lives
    GameConfigurationReader configReader = new GameConfigurationReader("src/main/resources/config.json");
    private Controllable player;
    private List<Ghost> ghosts;
    private int tickCount;
    private Map<GhostMode, Integer> modeLengths;
    private int numLives;
    private List<Renderable> collectables;
    private GhostMode currentGhostMode;
    private Direction queueDirection;
    // boolean values to determine the situation of pacMan is able to turn or not
    public static boolean possibleUp = true;
    public static boolean possibleDown = true;
    public static boolean possibleLeft = true;
    public static boolean possibleRight = true;
    private static LevelImpl instance;
    private List<GameObserver> observers;
    private int score;

    public LevelImpl(JSONObject levelConfiguration,
                     Maze maze) {
        this.renderables = new ArrayList<>();
        this.maze = maze;
        this.tickCount = 0;
        this.modeLengths = new HashMap<>();
        this.currentGhostMode = GhostMode.SCATTER;
        this.queueDirection = Direction.LEFT;
        this.score = 0;
        //System.out.println(GameEngineImpl.getInstance("src/main/resources/config.json").currentLevelNo);
        // the pacMan lives only be initialised in the first time
        if (GameEngineImpl.getInstance("src/main/resources/config.json").currentLevelNo == 0){
            //System.out.println("Only once");
            this.numLives = getNumLives();
        }
        this.observers = new ArrayList<>();

        initLevel(new LevelConfigurationReader(levelConfiguration));
    }

    // singleton usage
    public static LevelImpl getInstance(JSONObject levelConfiguration, Maze maze) {
        //System.out.println("A new level is initialised");
        instance = new LevelImpl(levelConfiguration, maze);
        return instance;
    }

    private void initLevel(LevelConfigurationReader levelConfigurationReader) {
        // Fetch all renderables for the level
        this.renderables = maze.getRenderables();

        // Set up player
        if (!(maze.getControllable() instanceof Controllable)) {
            throw new ConfigurationParseException("Player entity is not controllable");
        }
        this.player = (Controllable) maze.getControllable();
        this.player.setSpeed(levelConfigurationReader.getPlayerSpeed());

        // update lives when next level is initialised
        if (GameEngineImpl.getInstance("src/main/resources/config.json").currentLevelNo == 0) {
            setNumLives(configReader.getNumLives());
        }

        // Set up ghosts
        this.ghosts = maze.getGhosts().stream()
                .map(element -> (Ghost) element)
                .collect(Collectors.toList());
        Map<GhostMode, Double> ghostSpeeds = levelConfigurationReader.getGhostSpeeds();

        player.reset();
        for (Ghost ghost : this.ghosts) {
            ghost.setSpeeds(ghostSpeeds);
            ghost.setGhostMode(this.currentGhostMode);
            ghost.reset();
        }
        this.modeLengths = levelConfigurationReader.getGhostModeLengths();

        // Set up collectables
        this.collectables = new ArrayList<>(maze.getPellets());

        // update score when next level is initialised
        score += GameEngineImpl.getInstance("src/main/resources/config.json").getTotalScore();
        //numLives += GameEngineImpl.getInstance("src/main/resources/config.json").getTotalLives();
        //System.out.println("stored score: " + GameEngineImpl.getInstance("src/main/resources/config.json").getTotalScore());
    }

    public void updateCollectables() {
        this.collectables = new ArrayList<>(maze.getPellets());
    }

    @Override
    public List<Renderable> getRenderables() {
        return this.renderables;
    }

    private List<DynamicEntity> getDynamicEntities() {
        return renderables.stream().filter(e -> e instanceof DynamicEntity).map(e -> (DynamicEntity) e).collect(
                Collectors.toList());
    }

    private List<StaticEntity> getStaticEntities() {
        return renderables.stream().filter(e -> e instanceof StaticEntity).map(e -> (StaticEntity) e).collect(
                Collectors.toList());
    }

    @Override
    public void tick() {
        if (tickCount == modeLengths.get(currentGhostMode)) {

            // update ghost mode
            this.currentGhostMode = GhostMode.getNextGhostMode(currentGhostMode);
            for (Ghost ghost : this.ghosts) {
                ghost.setGhostMode(this.currentGhostMode);
            }

            tickCount = 0;
        }

        if (tickCount % Pacman.PACMAN_IMAGE_SWAP_TICK_COUNT == 0) {
            this.player.switchImage();
        }

        // detect there's a wall on the current way
        detectIsPossibleMove();
        // Update the dynamic entities
        List<DynamicEntity> dynamicEntities = getDynamicEntities();

        for (DynamicEntity dynamicEntity : dynamicEntities) {
            maze.updatePossibleDirections(dynamicEntity);
            dynamicEntity.update();
        }

        for (int i = 0; i < dynamicEntities.size(); ++i) {
            DynamicEntity dynamicEntityA = dynamicEntities.get(i);

            // handle collisions between dynamic entities
            for (int j = i + 1; j < dynamicEntities.size(); ++j) {
                DynamicEntity dynamicEntityB = dynamicEntities.get(j);

                if (dynamicEntityA.collidesWith(dynamicEntityB) ||
                        dynamicEntityB.collidesWith(dynamicEntityA)) {
                    dynamicEntityA.collideWith(this, dynamicEntityB);
                    dynamicEntityB.collideWith(this, dynamicEntityA);
                }
            }

            // handle collisions between dynamic entities and static entities
            for (StaticEntity staticEntity : getStaticEntities()) {
                if (dynamicEntityA.collidesWith(staticEntity)) {
                    dynamicEntityA.collideWith(this, staticEntity);
                    PhysicsEngine.resolveCollision(dynamicEntityA, staticEntity);
                }
            }
        }
        // handle when all levels are finished
        if (isLevelFinished()) {
//            System.out.println("Level is finished"); //test
            GameEngineImpl.getInstance("src/main/resources/config.json").handleGameWin();
            return;
        }

        tickCount++;
    }

    @Override
    public boolean isPlayer(Renderable renderable) {
        return renderable == this.player;
    }

    @Override
    public boolean isCollectable(Renderable renderable) {
        return maze.getPellets().contains(renderable) && ((Collectable) renderable).isCollectable();
    }

    @Override
    public void moveLeft() {
        player.left();
        queueDirection = Direction.LEFT;
    }

    @Override
    public void moveRight() {
        player.right();
        queueDirection = Direction.RIGHT;
    }

    @Override
    public void moveUp() {
        player.up();
        queueDirection = Direction.UP;
    }

    @Override
    public void moveDown() {
        player.down();
        queueDirection = Direction.DOWN;
    }

    @Override
    public boolean isLevelFinished() {
        //System.out.println(collectables);
        return collectables.isEmpty();
    }

    @Override
    public int getNumLives() {
        return this.numLives;
    }

    private void setNumLives(int numLives) {
        this.numLives = numLives;
    }


    @Override
    public void handleGameEnd() {
        //System.out.println("Game Over!");
        notifyGameOver();
        // clear all entities (pacman+ghosts)
        renderables.removeIf(renderable -> renderable instanceof Pacman || renderable instanceof Ghost);
    }

    @Override
    public void collect(Collectable collectable) {
        // remove
        collectables.remove(collectable);
//        int scoreIncrement = GameEngineImpl.getInstance("src/main/resources/config.json").getTotalScore();
//        // update the local score
//        score += scoreIncrement;
        //System.out.println("What is the score? " + score);
        GameEngineImpl.getInstance("src/main/resources/config.json").updateScore(collectable.getPoints());
        // update scores
        notifyScoreChanged(score);
    }

    public List<Ghost> getGhosts() {
        return ghosts;
    }

    public void detectIsPossibleMove() {
        // Check if Pac-Man is at an intersection
        if (Maze.isAtIntersection(player.getPossibleDirections())) {
            // Check for a valid queued direction from the player
            if (queueDirection != null){
                // Move in the queued direction if valid
                // System.out.println(queueDirection);
                switch (queueDirection) {
                    case LEFT:
                        possibleLeft = true;
                        this.moveLeft();
                        break;
                    case RIGHT:
                        possibleRight = true;
                        this.moveRight();
                        break;
                    case UP:
                        possibleUp = true;
                        this.moveUp();
                        break;
                    case DOWN:
                        possibleDown = true;
                        this.moveDown();
                        break;
                }
            }
        }else{
            // if the pacMan is not at an intersection, then it will consider the single line turn (either up/down or left/right)
            if (player.getPossibleDirections().contains(Direction.UP) && player.getPossibleDirections().contains(Direction.DOWN)) {
                possibleUp = true;
                possibleDown = true;
                possibleLeft = false;
                possibleRight = false;
            }
            if (player.getPossibleDirections().contains(Direction.LEFT) && player.getPossibleDirections().contains(Direction.RIGHT)) {
                possibleLeft = true;
                possibleRight = true;
                possibleUp = false;
                possibleDown = false;
            }
        }
    }

    @Override
    public void addObserver(GameObserver observer) {
        observers.add(observer);
    }

    @Override
    public void removeObserver(GameObserver observer) {
        observers.remove(observer);
    }

    @Override
    public void notifyLivesChanged(int lives) {
        // update live changes by implementing observer method
        for (GameObserver observer : observers) {
            observer.updateLives(lives);
        }
    }

    @Override
    public void notifyScoreChanged(int score) {
        // update score changes by implementing observer method
        for (GameObserver observer : observers) {
            // UI score update
            observer.updateScore(score);
        }
    }

    @Override
    public void notifyGameOver() {
        // UI game over detect by implementing observer method
        for (GameObserver observer : observers) {
            observer.notifyGameOver();
        }
    }

    // when pacMan collect one pallet earns 100 points
    public void toCollect(Collectable collectable){
        score += 100;
        notifyScoreChanged(score);
    }

    // when pacMan collision with ghosts then lose one life
    @Override
    public void handleLoseLife() {
        numLives--;
        //System.out.println("How many I left:" + numLives);
        notifyLivesChanged(numLives);
        if (numLives > 0) {
            resetPositions();  // reset entities if the pacMan still have lives
        }else {
            handleGameEnd();  // handle game over
        }
    }

    private void resetPositions() {
        // reset pacMan and ghosts to its starting position
        player.reset();
        // reset back to default moving direction
        queueDirection = Direction.LEFT;
        for (Ghost ghost : ghosts) {
            ghost.reset();
        }
        GameEngineImpl.getInstance("src/main/resources/config.json").readyPhrase();
    }

}
