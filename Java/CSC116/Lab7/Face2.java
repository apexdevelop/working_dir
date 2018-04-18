import java.awt.*;

/**
 * Draws a face
 * 
 * @author Yan Chen
 */
public class Face2 {
    /**
     * Declares the variables, computes the position, and prints the results.
     * 
     * @param args
     *            command line arguments
     */
    public static void main(String[] args) {
        DrawingPanel panel = new DrawingPanel(520, 180);
        Graphics g = panel.getGraphics();
        int y = 30;
        for (int i = 0; i<5; i++) {
            int x = 10 + i * 100;            
            drawFace(g,x,y);
        }
     }   
    /**
     * Draws a Face at the given x/y position.
     * 
     * @param g
     *            Graphics to draw
     * @param x
     *            x coordinate of shape
     * @param y
     *            y coordinate of shape
     */
     public static void drawFace (Graphics g, int x, int y) {
        g.setColor(Color.BLACK);
        g.drawOval(x, y, 100, 100); // face outline

        g.setColor(Color.BLUE);
        g.fillOval(x + 20, y + 30, 20, 20); // eyes
        g.fillOval(x + 60, y + 30, 20, 20);

        g.setColor(Color.RED); // mouth
        g.drawLine(x + 30 , y + 70, x + 70, y + 70);
    }
  }