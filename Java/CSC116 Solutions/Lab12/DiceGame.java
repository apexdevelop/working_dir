import java.util.*;

/**
 * This class simulates continuously rolling dice until the                            
 * sum of the rolls equals the desired sum entered by the user.
 *
 * @author Michelle Glatz
 */
public class DiceGame {
    
    /** The maximum sum of two die rolls */
    public static final int MAX_SUM = 12;
    /** The minimum sum of two die rolls */
    public static final int MIN_SUM = 2;
    /** The maximum single die roll */
    public static final int MAX_ROLL = 6;

    /**
     * Starts the program
     *
     * @param args command line arguments (not used)
     */     
    public static void main(String[] args) {
        Scanner console = new Scanner(System.in);
        diceSum(console);
        
    }

    
    /**
     * Continuously simulates rolling 2 die until the sum
     * of the rolls equals the desired sum entered by the user.
     *
     * @param console the Scanner object with which to get user input
     */    
    public static void diceSum(Scanner console) {
        Random rand = new Random();
        System.out.print("\nDesired dice sum? ");
        int desiredSum = getInt(console);

        while (desiredSum < MIN_SUM || desiredSum > MAX_SUM) {
            // ASSSERT: desired sum is not valid
            System.out.print("Invalid dice sum.  Try again: ");
            desiredSum = getInt(console);
        }

        // ASSERT: desired sum is valid
        int sum = 0;
        while (sum != desiredSum) {
            // ASSERT:  sum != desired sum
            int dice1 = rand.nextInt(MAX_ROLL) + 1;
            int dice2 = rand.nextInt(MAX_ROLL) + 1;
            sum = dice1 + dice2;
            System.out.println(dice1 + " and " + dice2 + " = " + sum);
        }

        // ASSERT: sum == desiredSum 
    }

    /**
    * Continuosly tests user input until an integer ie entered.
    * Reads in bad input and prinst out invalid message with reprompt when
    * non-integer is entered.
    *
    * @param  console console Scanner object
    * @return entered integer
    */   
    public static int getInt(Scanner console) {
        while (!console.hasNextInt()) {
            // ASSERT: user did not enter an integer
            console.next();
            System.out.print("Not an integer.  Try again: ");
        }
        // ASSERT: user entered an integer
        return console.nextInt();
    }
  
}