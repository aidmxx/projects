package WizardTD;

import processing.core.PApplet;
import processing.core.PImage;
import processing.data.JSONObject;
import processing.event.MouseEvent;

import java.awt.Graphics2D;
import java.awt.geom.AffineTransform;
import java.awt.image.BufferedImage;

import java.io.*;
import java.util.*;
import processing.data.JSONArray;

/**
 * The App class represents a Tower Defense game app, leveraging the capabilities of the PApplet library.
 * It initializes game elements, handles game settings, and controls the game loop and mechanics.
 */
public class App extends PApplet {

    public static final int CELLSIZE = 32;
    public static final int SIDEBAR = 120;
    public static final int TOPBAR = 40;
    public static final int BOARD_WIDTH = 20;
    public static int WIDTH = CELLSIZE*BOARD_WIDTH+SIDEBAR;
    public static int HEIGHT = BOARD_WIDTH*CELLSIZE+TOPBAR;
    public static final int FPS = 60;
    public String configPath;
    public Random random = new Random();
    public ArrayList<ArrayList<Integer>> grid = null;
    public int[] randomPoint = null;
    private JSONObject jsonObject;
    private String read_level;
    private JSONArray waves;
    public JSONArray monsterList = new JSONArray();
    public int totalMonsterQuantity = 0;
    public float duration, perWavePause;
    public long eachMonsterStartTime;
    public long eachWaveStartTime;
    private PImage shrubImage;
    private PImage grassImage;
    private PImage path0Image;
    private PImage path1Image;
    private PImage path2Image;
    private PImage path3Image;
    private PImage houseImage;
    private PImage gremlinDead1;
    private PImage gremlinDead2;
    private PImage gremlinDead3;
    private PImage gremlinDead4;
    private PImage gremlinDead5;
    public static final List<List<int[]>> shortestPaths = new ArrayList<>();
    public static final List<int[]> currentPath = new ArrayList<>();
    public ArrayList<int[]> grassList = new ArrayList<>();
    int[] house_locate;
    private static int minPathLength = Integer.MAX_VALUE;
    ArrayList<Buttons> buttonsList = new ArrayList<>();
    /**
     * Constructor initializes the game with the default configuration path.
     */
    public App() {
        this.configPath = "config.json";
    }
    boolean active = false;
    ArrayList<Towers> towers = new ArrayList<Towers>();

    /**
     * Initialise the setting of the window size.
     */
    @Override
    public void settings() {
        size(WIDTH, HEIGHT);
    }

    /**
     * Load all resources such as images. Initialise the elements such as the player, enemies and map elements.
     */
    @Override
    public void setup() {
        frameRate(FPS);
        jsonObject = loadJSONObject(configPath);
        read_level = jsonObject.getString("layout");
        waves = jsonObject.getJSONArray("waves");
        shrubImage = loadImage("src/main/resources/WizardTD/shrub.png");
        grassImage = loadImage("src/main/resources/WizardTD/grass.png");
        path0Image = loadImage("src/main/resources/WizardTD/path0.png");
        path1Image = loadImage("src/main/resources/WizardTD/path1.png");
        path2Image = loadImage("src/main/resources/WizardTD/path2.png");
        path3Image = loadImage("src/main/resources/WizardTD/path3.png");
        houseImage = loadImage("src/main/resources/WizardTD/wizard_house.png");
        buttonsList.add(new Buttons(this, 650, 50, 40, 40, "FF", "2x speed", 'F'));
        buttonsList.add(new Buttons(this, 650, 100, 40, 40, "P", "PAUSE", 'P'));
        buttonsList.add(new TowerButton(this, 650, 150, 40, 40, "T", "Build tower", 'T'));
        buttonsList.add(new Buttons(this, 650, 200, 40, 40, "U1", "Upgrade range", '1'));
        buttonsList.add(new Buttons(this, 650, 250, 40, 40, "U2", "Upgrade speed", '2'));
        buttonsList.add(new Buttons(this, 650, 300, 40, 40, "U3", "Upgrade damage", '3'));
        buttonsList.add(new Buttons(this, 650, 350, 40, 40, "M", "Mana pool cost: 100", 'M'));

    }

    /**
     * Receive key pressed signal from the keyboard.
     */
    @Override
    public void keyPressed(){

    }

    /**
     * Receive key released signal from the keyboard.
     */

    @Override
    public void mousePressed(MouseEvent e) {
        for (Buttons button: buttonsList) {
            button.checkClick(mouseX, mouseY);
            if (button.isClicked() && button instanceof TowerButton) {
                // create a tower here based on button type
                ((TowerButton) button).createTower();
            }
        }
    }
    /**
     * Handles mouse release events, such as completing tower placements.
     * @param e MouseEvent object containing information about the mouse event.
     */
    @Override
    public void mouseReleased(MouseEvent e) {
        for (Buttons button: buttonsList) {
            if (!active && button instanceof TowerButton) {
                // create a tower here based on button type
                ((TowerButton) button).createTower();
            }
        }
    }

    /*@Override
    public void mouseDragged(MouseEvent e) {

    }*/

    int count = 0;
    ArrayList<Monsters> monsterReleaseList = new ArrayList<>();
    int currentWazeNum = 0;
    int monsterIdx = 0;
    int totalMonsterIdx = 0;
    JSONObject wave = new JSONObject();

    /**
     * Represents the game loop. This is where all the game logic runs, game rendering is handled,
     * and game elements are updated.
     */
    @Override
    public void draw() {
        background(148, 138, 124);
        File f = new File(read_level);
        List<Object> backgroundList = drawBackground(f);
        ArrayList<int[]> pathList = (ArrayList<int[]>) backgroundList.get(0);
        int[] house = (int[]) backgroundList.get(1);
        house_locate = (int[]) backgroundList.get(2);
        drawMap(pathList);
        ArrayList<Object> result = path_and_point(f);
        grid = (ArrayList<ArrayList<Integer>>) result.get(0);
        if (currentWazeNum < waves.size()) {
            if (eachWaveStartTime == 0) {
                eachWaveStartTime = System.currentTimeMillis();  // Set the start time once
            }
            getMonsterInfo();
            // Assuming startTime is a class-level variable and it's initialized to 0
            if (System.currentTimeMillis() - eachWaveStartTime >= (long) (perWavePause * 1000)) {
                if (eachMonsterStartTime == 0) {
                    eachMonsterStartTime = System.currentTimeMillis();  // Set the start time once
                    totalMonsterIdx = monsterList.size();
                }

                if (count < totalMonsterQuantity) {
                    if (System.currentTimeMillis() - eachMonsterStartTime >= (long) ((duration/totalMonsterQuantity) * 1000)) {
                        Collections.shuffle(shortestPaths);
                        randomPoint = (int[]) result.get(1);
                        findShortestPaths(grid, randomPoint, house);

                        if (monsterIdx < totalMonsterIdx) {
                            wave = monsterList.getJSONObject(monsterIdx);
                            monsterIdx++;
                        }
                        Monsters monster = new Monsters(this, wave);
                        monsterReleaseList.add(monster);
                        count++;

                        eachMonsterStartTime = System.currentTimeMillis(); // Capture start time when first monster is release
                    }
                } else if (count == totalMonsterQuantity) {
                    currentWazeNum++;
                    count = 0;
                    eachMonsterStartTime = 0;
                    eachWaveStartTime = 0;
                }
            }
        }

        for (Monsters monster : monsterReleaseList) {
            monster.update();
        }

        //start from a centre point
        imageMode(CENTER);
        /*Override a houseImage to put a 48x48 pixels image upon 32x32 pixels' centre
          and also correctly the centre point
         */
        image(houseImage, house_locate[0] + 16, house_locate[1] + 16, 48, 48);
        //back to draw from a left corner point
        imageMode(CORNER);
        for (Buttons button: buttonsList) {
            button.display();
            button.displaySideText();
        }

        for (Towers tower : towers) {
            tower.draw();
        }
    }


    /**
     * Reads background configurations from a file and sets up the game's visual background.
     * @param f File object representing the configuration file.
     * @return Returns a list containing pathList, house and house_locate information.
     */
    public List<Object> drawBackground(File f) {
        ArrayList<int[]> pathList = new ArrayList<>();
        int[] house_locate = new int[2];
        int[] house = {-1, -1};
        try {
            Scanner scan = new Scanner(f);
            int x = 0;
            int y = 40;
            while (scan.hasNextLine()) {
                String line = scan.nextLine();
                for (int i = 0; i < line.length(); i++) {
                    if (line.length() < 20) {
                        int remaining = 20 - line.length();
                        for (int j = 0; j < remaining; j++) {
                            line += ' ';
                        }
                    }
                    char character = line.charAt(i);
                    if (character == 'S') {
                        image(shrubImage, x, y);
                        x += 32;
                    } else if (character == ' ') {
                        image(grassImage, x, y);
                        x += 32;
                    } else if (character == 'X') {
                        //initialise all path are horizontal paths
                        image(path0Image, x, y);
                        int[] array = {x, y};
                        //store each path's coordinate point into an Arraylist
                        pathList.add(array);
                        x += 32;
                    } else if (character == 'W') {
                        image(grassImage, x, y);
                        house_locate[0] = x;
                        house_locate[1] = y;
                        house[0] = y / 32 - 1;
                        house[1] = x / 32;
                        x += 32;
                    }
                }
                x = 0;
                y += 32;
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
        List<Object> backgroundList = new ArrayList<>();
        backgroundList.add(pathList);
        backgroundList.add(house);
        backgroundList.add(house_locate);
        return backgroundList;
    }

    /**
     * Draws a map using given path points. The method identifies various paths such as
     * straight paths, T-paths, turning paths, and crossing paths, based on the surrounding
     * points of each given path point. For each identified path, it places the corresponding
     * image on the map.
     *
     * The path identification is based on 4 directional points: top, left, right, and bottom
     * relative to each path point. Depending on the existence of neighboring points in these
     * directions, the path type is determined.
     *
     * @param pathList An ArrayList of int arrays, where each int array contains the x and y
     *                 coordinates of a path point.
     **/
    public void drawMap(ArrayList<int[]> pathList) {
        //rotated images to use in above methods
        PImage straight = rotateImageByDegrees(path0Image, 90.0);
        PImage upper_T = rotateImageByDegrees(path2Image, 180.0);
        PImage left_turning_T = rotateImageByDegrees(path2Image, 90.0);
        PImage right_turning_T = rotateImageByDegrees(path2Image, 270.0);
        PImage turning_right_down = rotateImageByDegrees(path1Image, 270.0);
        PImage turning_right_up = rotateImageByDegrees(path1Image, 180.0);
        PImage turning_left_up = rotateImageByDegrees(path1Image, 90.0);
        for (int[] currentArray : pathList) {
            //set initialise variables to find cross, straight, T and turning paths
            int count_cross = 0;
            int count_straight = 0;
            int count_T = 0;
            int up_T = 0;
            int down_T = 0;
            int left_T = 0;
            int right_T = 0;
            int left_turn = 0;
            int down_turn = 0;
            int up_turn = 0;
            int right_turn = 0;
            /*
              find upper, downer, left and right starting points for currentArray points
              this can be used to check any connection paths for currentArray points
             */
            int[] top_centre = {currentArray[0], currentArray[1] - 32};
            int[] left = {currentArray[0] - 32, currentArray[1]};
            int[] right = {currentArray[0] + 32, currentArray[1]};
            int[] bottom_centre = {currentArray[0], currentArray[1] + 32};
            for (int[] check : pathList) {
                /*
                starts to determine whether 4-directional points of currentArray points are appeared in path arrayList
                if appears, then variables of checking each paths will increment based on the chance of possible paths
                 */
                if (Arrays.equals(check, top_centre)) {
                    count_cross++;
                    count_straight++;
                    count_T++;
                    up_T++;
                    up_turn++;
                    left_T++;
                    right_T++;
                }
                if (Arrays.equals(check, left)) {
                    count_cross++;
                    count_T++;
                    left_turn++;
                    left_T++;
                    up_T++;
                    down_T++;
                }
                if (Arrays.equals(check, right)) {
                    count_cross++;
                    count_T++;
                    right_turn++;
                    right_T++;
                    up_T++;
                    down_T++;
                }
                if (Arrays.equals(check, bottom_centre)) {
                    count_cross++;
                    count_T++;
                    count_straight++;
                    down_T++;
                    down_turn++;
                    left_T++;
                    right_T++;
                }
            }
            // for path_points all appears in 4 directional-points will be crossing path
            if (count_cross == 4) {
                image(path3Image, currentArray[0], currentArray[1]);
                /*for path_points appears in 3/4 directional-points and are appearing in
                  top_centre, left and right will be up T path
                */
            } else if (count_T == 3 && up_T == 3) {
                image(upper_T, currentArray[0], currentArray[1]);
                /*for path_points appears in 3/4 directional-points and are appearing in
                  bottom_centre, left and right will be down T path
                */
            } else if (count_T == 3 && down_T == 3) {
                image(path2Image, currentArray[0], currentArray[1]);
                /*for path_points appears in 3/4 directional-points and are appearing in
                  top_centre, left and bottom_centre will be left T path
                */
            } else if (count_T == 3 && left_T == 3) {
                image(left_turning_T, currentArray[0], currentArray[1]);
                /*for path_points appears in 3/4 directional-points and are appearing in
                  top_centre, right and bottom_centre will be right T path
                */
            } else if (count_T == 3 && right_T == 3) {
                image(right_turning_T, currentArray[0], currentArray[1]);
                /*
                if path_point appears in left directional-point, it will be either
                up left turning path or down left turning path
                */
            } else if (left_turn == 1) {
                /*
                path_point appears in top_centre will be up left turning path
                */
                if (up_turn == 1) {
                    image(turning_left_up, currentArray[0], currentArray[1]);
                    /*
                    path_point appears in bottom_centre will be down left turning path
                    */
                } else if (down_turn == 1) {
                    image(path1Image, currentArray[0], currentArray[1]);
                }
                /*
                if path_point appears in right directional-point, it will be either
                up right turning path or down right turning path
                */
            } else if (right_turn == 1) {
                /*
                path_point appears in top_centre will be up right turning path
                */
                if (up_turn == 1) {
                    image(turning_right_up, currentArray[0], currentArray[1]);
                    /*
                    path_point appears in bottom_centre will be down right turning path
                    */
                } else if (down_turn == 1) {
                    image(turning_right_down, currentArray[0], currentArray[1]);
                }
                /*
                if path_point appears in top_centre and bottom_centre directional-points,
                or either appears in top_centre or bottom_centre directional-point,
                it should be a vertical path
                */
            } else if (count_straight == 2 || count_straight == 1) {
                image(straight, currentArray[0], currentArray[1]);
            }
        }
    }

    /**
     * Parses the provided file to extract path and starting point details.
     * Reads through the file to detect path points and potential starting positions.
     * Also selects a random starting point from the potential starting points.
     *
     * @param f The input file containing map details.
     * @return A list containing the only_distance grid and the randomly selected starting point.
     */
    //this function converts text file into a num list and it's used to find shortest paths
    public ArrayList<Object> path_and_point(File f) {
        ArrayList<Object> numPath = new ArrayList<>();
        try {
            ArrayList<ArrayList<Integer>> only_distance = new ArrayList<>();
            ArrayList<int[]> startPoint = new ArrayList<>();
            Scanner scan = new Scanner(f);
            int col = 0;
            int row = 0;
            // Create the only_distance grid
            while (scan.hasNextLine()) {
                String line = scan.nextLine();
                ArrayList<Integer> rowList = new ArrayList<>();
                // Ensure the line has a minimum length of 20 characters
                line = String.format("%-20s", line);
                for (char character : line.toCharArray()) {
                    if (character == 'X') {
                        rowList.add(1);
                        if (col == 0 || row == 0){
                            int[] index = {row, col};
                            startPoint.add(index);
                        }
                        col++;
                    } else if (character == 'W') {
                        rowList.add(2);
                        col++;
                    } else {
                        if (character == ' '){
                            int[] index = {col, row};
                            grassList.add(index);
                        }
                        rowList.add(0);
                        col++;
                    }
                }
                col = 0;
                only_distance.add(rowList);
                row++;
            }
            // Randomly select a starting point
            int randomIndex = random.nextInt(startPoint.size());
            int[] randomStarting = startPoint.get(randomIndex);
            numPath.add(only_distance);
            numPath.add(randomStarting.clone());
        } catch (IOException e) {
            e.printStackTrace();
        }
        return numPath;
    }

    /**
     * Recursive method to find the shortest paths using the depth-first search (DFS) method.
     * It recursively explores possible paths on the grid from the current point to the target house.
     *
     * @param grid The grid representation where '1' denotes a path point and '2' denotes the house.
     * @param currentpoint The current point being explored on the grid.
     * @param house The target house's coordinates on the grid.
     */
    // recursion function to find shortest paths (dfs method)
    public static void findShortestPaths(ArrayList<ArrayList<Integer>> grid, int[] currentpoint, int[] house) {
        if (currentpoint[0] < 0 || currentpoint[0] >= grid.size() || currentpoint[1] < 0 || currentpoint[1] >= grid.get(0).size() || grid.get(currentpoint[0]).get(currentpoint[1]) == 0) {
            return;
        }

        if (grid.get(currentpoint[0]).get(currentpoint[1]) == 2) {
            // Clone and add the current path to shortestPaths
            List<int[]> clonedPath = new ArrayList<>(currentPath);
            clonedPath.add(house);
            shortestPaths.add(clonedPath);
            return;
        }
        // Mark the current point as visited
        grid.get(currentpoint[0]).set(currentpoint[1], 0);

        int[] up = {currentpoint[0] - 1, currentpoint[1]};
        int[] down = {currentpoint[0] + 1, currentpoint[1]};
        int[] left = {currentpoint[0], currentpoint[1] - 1};
        int[] right = {currentpoint[0], currentpoint[1] + 1};

        // Clone and add the current point to the current path
        currentPath.add(currentpoint.clone());

        // Recursively explore all possible directions
        findShortestPaths(grid, up, house);
        findShortestPaths(grid, down, house);
        findShortestPaths(grid, left, house);
        findShortestPaths(grid, right, house);

        // Backtrack by removing the current point from the current path
        currentPath.remove(currentPath.size() - 1);
        // Restore the grid value (unmark it as visited)
        grid.get(currentpoint[0]).set(currentpoint[1], 1);
    }

    /**
     * Extracts monster details from a JSON wave object.
     * Parses the wave JSON object to obtain the wave's duration, pause time,
     * and the list of monsters in the wave.
     */
    public void getMonsterInfo(){
        JSONObject specificWave = waves.getJSONObject(currentWazeNum);
        duration = specificWave.getFloat("duration");
        perWavePause = specificWave.getFloat("pre_wave_pause");

        JSONArray monsters = specificWave.getJSONArray("monsters");
        totalMonsterQuantity = 0;
        monsterList = new JSONArray();
        for (int i = 0; i < monsters.size(); i++) {

            JSONObject monster = monsters.getJSONObject(i);
            int quantity = monster.getInt("quantity");
            totalMonsterQuantity += quantity;

            for (int j = 0; j < quantity; j++) {
                monsterList.append(monster);
            }
        }
        shuffleMonsterList();
    }

    /**
     * Shuffles the order of monsters in the monsterList.
     * Implements the Fisher-Yates shuffle algorithm to randomly arrange the monster list's order.
     */
    public void shuffleMonsterList() {
        int n = monsterList.size();

        // Loop through the monsterList in reverse order
        for (int i = n - 1; i > 0; i--) {
            // Generate a random index between 0 and i (inclusive)
            int index = (int) random(i + 1);

            // Swap monsters at index i and index
            JSONObject tempMonster = monsterList.getJSONObject(i);
            monsterList.setJSONObject(i, monsterList.getJSONObject(index));
            monsterList.setJSONObject(index, tempMonster);
        }
    }

    /**
     * Main method to launch the application.
     *
     * @param args Command-line arguments.
     */
    public static void main(String[] args) {
        PApplet.main("WizardTD.App");
    }

    /**
     * Source: https://stackoverflow.com/questions/37758061/rotate-a-buffered-image-in-java
     * @param pimg The image to be rotated
     * @param angle between 0 and 360 degrees
     * @return the new rotated image
     */
    public PImage rotateImageByDegrees(PImage pimg, double angle) {
        BufferedImage img = (BufferedImage) pimg.getNative();
        double rads = Math.toRadians(angle);
        double sin = Math.abs(Math.sin(rads)), cos = Math.abs(Math.cos(rads));
        int w = img.getWidth();
        int h = img.getHeight();
        int newWidth = (int) Math.floor(w * cos + h * sin);
        int newHeight = (int) Math.floor(h * cos + w * sin);

        PImage result = this.createImage(newWidth, newHeight, RGB);
        //BufferedImage rotated = new BufferedImage(newWidth, newHeight, BufferedImage.TYPE_INT_ARGB);
        BufferedImage rotated = (BufferedImage) result.getNative();
        Graphics2D g2d = rotated.createGraphics();
        AffineTransform at = new AffineTransform();
        at.translate((newWidth - w) / 2, (newHeight - h) / 2);

        int x = w / 2;
        int y = h / 2;

        at.rotate(rads, x, y);
        g2d.setTransform(at);
        g2d.drawImage(img, 0, 0, null);
        g2d.dispose();
        for (int i = 0; i < newWidth; i++) {
            for (int j = 0; j < newHeight; j++) {
                result.set(i, j, rotated.getRGB(i, j));
            }
        }

        return result;
    }
}
