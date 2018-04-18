import java.awt.*;
import java.util.*;

//Add Javadoc
//You will not lose points for using magic numbers in the Animation program/methods. 
//However, try to define as many values as constants as you can.

public class Animation {
    
    public static final int WIDTH = 500;
    public static final int HEIGHT = 400;
    public static final int SLEEP_TIME = 200;
    public static final int INITIAL_X = 10;
    public static final int INITIAL_Y = 200;
    public static final int NUMBER_OF_UPDATES = 80;
    public static final int DX = 5;
    
    //The main method creates the animation by repeatedly drawing the background 
    //and figure, then "sleeping" (pausing) for a short time.
    //Feel free to change the size of the drawing panel, initial x-, y-coordinates
    //of the figure, the number of for loop iterations, and the sleep time to
    //whatever works best for your animation. You may also replace the drawFigure()
    //method with several methods to better imply motion.
    public static void main (String[] args) {
        
        DrawingPanel panel = new DrawingPanel(WIDTH, HEIGHT);
        Graphics g = panel.getGraphics();
        
        int x = INITIAL_X;
        int y = INITIAL_Y;
        for (int i = 0; i < NUMBER_OF_UPDATES; i++) {
            drawBackground(g);
            drawFigure(g, x + DX * i, y);
            panel.sleep(SLEEP_TIME);
        } 
         
        System.out.println("\n*CLOSE the Drawing Panel to exit the program*");
    }
    
    //Draws a small chicken. 
    public static void drawBackground(Graphics g) {
        //mouth
        g.setColor(Color.RED);
        Polygon poly = new Polygon();
        poly.addPoint(10, INITIAL_Y+20);
        poly.addPoint(20, INITIAL_Y+15);
        poly.addPoint(25, INITIAL_Y+25);
        g.fillPolygon(poly);
        
        //head
        g.setColor(Color.YELLOW);
        g.fillOval(20, INITIAL_Y+15, 13, 13);
        g.setColor(Color.BLACK);
        g.fillOval(25, INITIAL_Y+20, 5, 5);
        
        //body
        g.setColor(Color.YELLOW);
        g.fillRect(28, INITIAL_Y+23, 30, 20);
        
        //leg
        g.setColor(Color.BLACK);
        g.drawLine(36, INITIAL_Y+45, 36, INITIAL_Y+50);
        g.drawLine(50, INITIAL_Y+45, 50, INITIAL_Y+50);
    }
    
    //Draws two ovals
    public static void drawFigure(Graphics g, int x, int y) {
        g.setColor(Color.BLACK);
        g.drawOval(x, y, 80, 20);
        g.drawOval(x, y, 20, 80);
    } 
}