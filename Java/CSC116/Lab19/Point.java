/** A Point object represents a pair of (x, y) coordinates.
* Second version: state and behavior.
*/

public class Point {
    int x;
    int y;
    
    /** get the x axis.
    * @return int
    */
    
    public int getX() {
        return x;
    }
    
    /** get the y axis.
    * @return int
    */
    public int getY() {
        return y;
    }
    
    /** Returns the distance between this point and (0, 0).
    * @return double
    */
    public double distanceFromOrigin() {
        return Math.sqrt(x * x + y * y);
    }

    /** Shifts this point's location by the given amount.
    * @param int dx
    * @param in dy
    */
    public void translate(int dx, int dy) {
        x += dx;
        y += dy;
    }    
    
    /** Returns the distance between the current Point object and the given other Point object.
    * @param Point other
    * @return double distance
    */
    public double distance(Point other) {
        int dx = x - other.getX();
        int dy = y - other.getY();
        return Math.sqrt( dx*dx + dy*dy );
    }
    
    /** Returns the “Manhattan distance” between the current Point object and the given other Point object.
    * @param Point other
    * @return int distance
    */
    public int manhattanDistance(Point other) {
        int dx = x - other.getX();
        int dy = y - other.getY();
        return Math.abs(dx) + Math.abs(dy);
    }
    
    /** Returns which quadrant of the x/y plane the current Point object falls in.
    * @return int quadrant
    */
    public int quadrant() {
        int qua = 0;
        if (x>0 && y>0) {
            qua = 1;
        } else if (x<0 && y>0) {
            qua = 2;
        } else if (x<0 && y<0) {
            qua = 3;
        } else if (x>0 && y<0) {
            qua = 4;
        } else { qua = 0;}
        return qua;
    }
}