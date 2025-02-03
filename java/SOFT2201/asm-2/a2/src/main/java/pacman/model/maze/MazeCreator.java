package pacman.model.maze;

import pacman.model.entity.Renderable;
import pacman.model.factory.GameEntityFactory;
import pacman.model.factory.MazeFactory;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;

import static java.lang.System.exit;

/**
 * Responsible for creating renderables and storing it in the Maze
 */
public class MazeCreator {

    private final String fileName;
    public static final int RESIZING_FACTOR = 16;

    public MazeCreator(String fileName){
        this.fileName = fileName;
    }

    public Maze createMaze(){
        File f = new File(this.fileName);
        Maze maze = new Maze();
        GameEntityFactory entityFactory = MazeFactory.getInstance();
        try {
            Scanner scanner = new Scanner(f);

            int y = 0;

            while (scanner.hasNextLine()){

                String line = scanner.nextLine();
                char[] row = line.toCharArray();

                for (int x = 0; x < row.length; x++){
                    /**
                     * TO DO: Implement Factory Method Pattern
                     */
                    char renderableType = row[x];
                    // RESIZING_FACTOR to adjust entities position shown on UI
                    Renderable entity = entityFactory.create(renderableType, x * RESIZING_FACTOR, y * RESIZING_FACTOR);
                    if (entity != null) {
                        maze.addRenderable(entity, renderableType, x, y);
                    }
                }

                y += 1;
            }

            scanner.close();
        }
        catch (FileNotFoundException e){
            System.out.println("No maze file was found.");
            exit(0);
        } catch (Exception e){
            System.out.println("Error");
            System.out.println(e);
            exit(0);
        }

        return maze;
    }
}
