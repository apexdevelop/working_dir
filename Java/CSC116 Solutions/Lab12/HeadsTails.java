import java.util.*;

/**
 * Program flips a coin until the results of the coin toss are three heads in a
 * row.
 * 
 * @author Jessica Young Schmidt
 */
public class HeadsTails {
    /**
     * Starts program
     * 
     * @param args command line argument
     */
    public static void main(String[] args) {
        Scanner console = new Scanner(System.in);
        System.out.print("Number of games: ");
        while (!console.hasNextInt()) {
            console.next();
            System.out.print("You must enter an integer. Number of games: ");
        }
        int numGames = console.nextInt();
        for (int i = 0; i < numGames; i++) {
            threeHeads();
            // threeHeadsB();
        }

    }

    /**
     * Flips a coin until the results of the coin toss are three heads in a row.
     * Uses while loop
     */
    public static void threeHeadsB() {
        Random rand = new Random();
        int heads = 0;
        int count = 0;
        while (heads < 3) {
            //ASSERT:  heads < 3
            int flip = rand.nextInt(2); // flip coin
            count++;
            if (flip == 0) { // heads
                // ASSERT: flip == 0
                heads++;
                System.out.print("H ");
            } else { // tails
                //ASSERT: flip != 0
                heads = 0;
                System.out.print("T ");
            }
        }
        //ASSERT: heads >= 3
        System.out.println();
        System.out.println("Three heads in a row after " + count + " flips!");
    }

    /**
     * Flips a coin until the results of the coin toss are three heads in a row.
     * Uses do-while loop
     */
    public static void threeHeads() {
        Random r = new Random();
        int heads = 0;
        int count = 0;
        do {
            count++;
            if (r.nextBoolean()) { // tails
                heads = 0;
                System.out.print("T ");
            } else { // heads
                heads++;
                System.out.print("H ");
            }
        } while (heads < 3);
        //ASSERT: heads >= 3
        System.out.println();
        System.out.println("Three heads in a row after " + count + " flips!");
    }

}
