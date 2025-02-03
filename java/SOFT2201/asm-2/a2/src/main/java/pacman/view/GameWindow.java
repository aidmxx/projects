package pacman.view;

import javafx.animation.KeyFrame;
import javafx.animation.Timeline;
import javafx.scene.Node;
import javafx.scene.Scene;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.HBox;
import javafx.scene.layout.Pane;
import javafx.scene.text.Font;
import javafx.scene.text.Text;
import javafx.util.Duration;
import pacman.model.engine.GameEngine;
import pacman.model.entity.Renderable;
import pacman.model.entity.dynamic.physics.Vector2D;
import pacman.model.entity.dynamic.player.Pacman;
import pacman.model.maze.Maze;
import pacman.model.factory.MazeFactory;
import pacman.model.maze.RenderableType;
import pacman.model.observer.GameObserver;
import pacman.view.background.BackgroundDrawer;
import pacman.view.background.StandardBackgroundDrawer;
import pacman.view.entity.EntityView;
import pacman.view.entity.EntityViewImpl;
import pacman.view.keyboard.KeyboardInputHandler;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

/**
 * Responsible for managing the Pac-Man Game View
 */
public class GameWindow implements GameObserver {

    public static final File FONT_FILE = new File("src/main/resources/maze/PressStart2P-Regular.ttf");

    private final Scene scene;
    private final Pane pane;
    private final GameEngine model;
    private final List<EntityView> entityViews;
    private final Pacman pacman;
    private final Maze maze;

    private HBox liveDisplay;
    private Text scoreDisplay;
    private int currLives;
    private int score = 0;
    private List<ImageView> livesIcons = new ArrayList<>();
    private final Image pacmanLifeIcon;
    // apply the font to score and game messages
    Font font = Font.loadFont(getClass().getResourceAsStream("/maze/PressStart2P-Regular.ttf"), 20);

    public GameWindow(GameEngine model, int width, int height, Maze maze) {
        this.model = model;
        this.maze = maze;
        pane = new Pane();
        scene = new Scene(pane, width, height);

        pacmanLifeIcon = new Image(getClass().getResourceAsStream("/maze/pacman/playerRight.png"));
        // Set up score display
        scoreDisplay = new Text(Integer.toString(score));
        scoreDisplay.setStyle("-fx-font-size: 18; -fx-fill: white;");
        scoreDisplay.setX(10);
        scoreDisplay.setY(40);
        scoreDisplay.setFont(font);
        // set up lives display
        liveDisplay = new HBox(5);  // 5px spacing between life icons
        liveDisplay.setLayoutX(10);
        liveDisplay.setLayoutY(height - 30);  // place at the bottom

        pane.getChildren().addAll((Node) scoreDisplay, liveDisplay);

        entityViews = new ArrayList<>();
        MazeFactory factory = MazeFactory.getInstance();
        this.pacman = (Pacman) factory.create(RenderableType.PACMAN, (int) pane.getWidth(), (int) pane.getHeight());
        // pacMan update in maze
        maze.setPacman(pacman);

        KeyboardInputHandler keyboardInputHandler = new KeyboardInputHandler(model);
        scene.setOnKeyPressed(keyboardInputHandler::handlePressed);

        BackgroundDrawer backgroundDrawer = new StandardBackgroundDrawer();
        backgroundDrawer.draw(model, pane);
    }

    public Scene getScene() {
        return scene;
    }

    public void run() {
        Timeline timeline = new Timeline(new KeyFrame(Duration.millis(34),
                t -> this.draw()));

        timeline.setCycleCount(Timeline.INDEFINITE);
        timeline.play();

        model.startGame();
    }

    private void draw() {
        model.tick();

        List<Renderable> entities = model.getRenderables();

        for (EntityView entityView : entityViews) {
            entityView.markForDelete();
        }

        Vector2D pacManPosition = pacman.getPosition();
        // method to pass pacman position with ghosts
        model.updateGhostsByPacmanPosition(pacManPosition);

        for (Renderable entity : entities) {
            boolean notFound = true;
            for (EntityView view : entityViews) {
                if (view.matchesEntity(entity)) {
                    notFound = false;
                    view.update();
                    break;
                }
            }
            if (notFound) {
                EntityView entityView = new EntityViewImpl(entity);
                entityViews.add(entityView);
                pane.getChildren().add(entityView.getNode());
            }
        }

        for (EntityView entityView : entityViews) {
            if (entityView.isMarkedForDelete()) {
                pane.getChildren().remove(entityView.getNode());
            }
        }

        entityViews.removeIf(EntityView::isMarkedForDelete);
    }
    // UI pacMan lives count update
    @Override
    public void updateLives(int lives) {
        currLives = lives;
        updateLivesDisplay();
    }
    // UI pallet scores update
    @Override
    public void updateScore(int newScore) {
        this.score = newScore;
        //System.out.println("The score: " + score);
        scoreDisplay.setText(Integer.toString(score));
    }
    // UI pacMan icon lives update
    private void updateLivesDisplay() {
        liveDisplay.getChildren().clear();
        for (int i = 0; i < currLives; i++) {
            ImageView lifeIcon = new ImageView(pacmanLifeIcon);
            livesIcons.add(lifeIcon);
            liveDisplay.getChildren().add(lifeIcon);
        }
    }
    // game over message display
    @Override
    public void notifyGameOver() {
        Text gameOverText = new Text("GAME OVER");
        gameOverText.setStyle("-fx-font-size: 18; -fx-fill: red;");
        gameOverText.setX(143);
        gameOverText.setY(340);
        pane.getChildren().add(gameOverText);
        gameOverText.setFont(font);
        Timeline delayTimeline = new Timeline(new KeyFrame(Duration.seconds(5), event -> {
            // after 5 seconds will exit the application
            System.exit(0);
        }));
        // delay timeline
        delayTimeline.play();
    }
    // ready message display
    public void displayReady() {
        Text readyText = new Text("READY!");
        readyText.setStyle("-fx-font-size: 18; -fx-fill: yellow;");
        readyText.setX(175);
        readyText.setY(340);
        readyText.setFont(font);
        pane.getChildren().add(readyText);
        // schedule removal after 100 frames
        Timeline timeline = new Timeline(new KeyFrame(Duration.seconds(3), evt -> {
            pane.getChildren().remove(readyText);
        }));
        timeline.setCycleCount(1);
        timeline.play();
    }
    // game win message display
    public void displayWin() {
        Text winText = new Text("YOU WIN!");
        winText.setStyle("-fx-font-size: 18; -fx-fill: white;");
        winText.setX(155);
        winText.setY(340);
        winText.setFont(font);
        pane.getChildren().add(winText);
        winText.setFont(font);
        Timeline delayTimeline = new Timeline(new KeyFrame(Duration.seconds(5), event -> {
            // after 5 seconds will exit the application
            System.exit(0);
        }));
        // delay timeline
        delayTimeline.play();
    }
}
