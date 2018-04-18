import java.awt.*;
import java.util.*;
/**
 * Draws a face
 * 
 * @author Yan Chen
 */
public class Checkerboard {
    public static final int WIDTH = 50; //width of squares
    public static final int H = 540; //height of panel
    public static final int W = 540; //width of panel
    public static final int MIN_ROW = 1; //row minimum
    public static final int MAX_ROW = 10; //row maximum
    public static final int MIN_COLOR = 0; //color minimum
    public static final int MAX_COLOR = 255; //color maximum
    public static final int FIRST_X = 20; //left corner x of first square
    public static final int FIRST_Y = 20; //left corner y of first square
    /**
     * Declares the variables, computes the position, and prints the results.
     * 
     * @param args
     *            command line arguments
     */
    public static void main(String[] args) {
        // Set up Scanner for console
        Scanner in = new Scanner(System.in);
        //Prompt for input of number of rows
        System.out.print ("Number of rows (1-10):");
        int row = in.nextInt();
        //truncate row between 1 and 10
        if (row < MIN_ROW) {
            row = MIN_ROW;
        }
        if (row > MAX_ROW) {
            row = MAX_ROW;
        }
        
        //Prompt for input of color combination
        System.out.print ("Red value (0-255):");
        int red = in.nextInt();
        System.out.print ("Green value (0-255):");
        int green = in.nextInt();
        System.out.print ("Blue value (0-255):");
        int blue = in.nextInt();
        //truncate color between 0 and 255
        if (red < MIN_COLOR) {
            red = MIN_COLOR;
        }
        if (red > MAX_COLOR) {
            red = MAX_COLOR;
        }
        if (green < MIN_COLOR) {
            green = MIN_COLOR;
        }
        if (green > MAX_COLOR) {
            green = MAX_COLOR;
        }
        if (blue < MIN_COLOR) {
            blue = MIN_COLOR;
        }
        if (blue > MAX_COLOR) {
            blue = MAX_COLOR;
        }
        //begin to draw
        DrawingPanel panel = new DrawingPanel(H, W);
        Graphics g = panel.getGraphics();
        int x,y;   // Top-left corner of square
       
        for ( int i = 0;  i < row;  i++ ) {
          
            for ( int j = 0;  j < row;  j++) {
                x = FIRST_X + j * WIDTH;
                y = FIRST_Y + i * WIDTH;
                if ( (i % 2) == (j % 2) ) {
                    g.setColor(new Color(red, green, blue));
                    drawFilledSquare(g, x, y, WIDTH);
                } else {
                    drawSquare(g, x, y, WIDTH);
                }
            } 
          
        } // end for row
     }   
   //Draws a filled square at (x,y) with the given width
    //NOTE: Use BOTH the drawRect() and fillRect() methods in this method,
    //which will make your checkerboard look better!
    public static void drawFilledSquare(Graphics g, int x, int y, int width) {
        g.fillRect(x,y,width,width);
    }
        
    //Draws an "unfilled" square at (x,y) with the given width
    public static void drawSquare(Graphics g, int x, int y, int width) {
        g.drawRect(x,y,width,width);
    }
  }