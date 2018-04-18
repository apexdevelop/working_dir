import java.util.*;
//import java.util.Random;

/**
 * flip a coin until three heads showed up in a row
 * @author Yan Chen
 */
public class HeadsTails {
    /**
     * Starts program
     * 
     * @param args array of command line arguments
     */
    public static void main(String[] args) {
        Scanner in = new Scanner(System.in);
        System.out.print("Enter number of games (an integer): ");
        while (!in.hasNextInt()) {
               in.next(); // discard input
               System.out.print("Not an int; try again: ");
        }
        // ASSERT: n is integer 
        int n = in.nextInt();
        for (int i = 1; i<=n; i++) {
            threeHeads();
        }
    
    }
    
    /**
     * flip a coin until three heads showed up in a row
     */
    public static void threeHeads() {
        int rn;
        int flipCount = 0;
        int hCount = 0;
        boolean isthreeHeads = false;
        Random r = new Random();
        while (!isthreeHeads){
            rn = r.nextInt(2); // generating random number between 0 and 1           
            if (rn == 1) {
                System.out.print("H ");
                hCount +=1;
            } else {
              System.out.print("T ");
              hCount = 0;
            }

            flipCount +=1; //keeps counting
            
            if (hCount == 3) {
               isthreeHeads=true;
               System.out.println();
               System.out.println("Three heads in a row after " + flipCount + " flips!");
            }
        }
    }
}