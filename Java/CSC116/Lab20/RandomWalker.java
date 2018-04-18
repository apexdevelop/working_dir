/** A Point object represents a pair of (x, y) coordinates.
* Second version: state and behavior.
*/
import java.util.*;
public class RandomWalker {
    int x;
    int y;
    int steps;
    
    /** Constructor */
    public RandomWalker() {
        this.x=0;
        this.y=0;
        this.steps=0;
    }
    
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
    

    /** Instructs this random walker to randomly make one of the 4 possible moves (up, down, left, or right).
    */
    public void move() {
        Random r = new Random();
        int result = r.nextInt(4);
        if (result==0) {
            x-=1;
        } else if(result==1) {
            x+=1;
        } else if(result==2) {
            y+=1;
        } else {
            y-=1;
        }
        steps+=1; 
    }    

    /** Returns the number of steps this random walker has taken
    @return int
    */
    public int getSteps() {
        return steps;
    }

}