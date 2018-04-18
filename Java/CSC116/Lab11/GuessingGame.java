import java.util.*;
import java.util.Random;

/**
 * Determines if a user guessed the correct random number
 * @author Yan Chen
 */
public class GuessingGame {
    public static final int MAX = 50;
    /**
     * Starts program
     * 
     * @param args array of command line arguments
     */
    public static void main(String[] args) {
    
        Random r = new Random();
        int rn = r.nextInt(MAX) + 1; // generating random number between 1 and 50
        //System.out.println(rn);
        readConsole(rn);
    
    }
    
    /**
     * Reads user's guess for the secret number and compare them
     */
    public static void readConsole(int rn) {
        
        Scanner in = new Scanner(System.in);
        System.out.print("Make a guess(an integer value from 1 - 50)): ");
        int guess = in.nextInt();
        
        while (guess != rn) {
            if (guess <=50 && guess >=1){
                if (guess > rn){
                    System.out.println("it is larger than the secret number");
                    System.out.print("Make another guess(an integer value from 1 - 50)): ");
                    guess = in.nextInt();
                } else {
                    System.out.println("it is smaller than the secret number");
                    System.out.print("Make another guess(an integer value from 1 - 50)): ");
                    guess = in.nextInt();
                }
            } else {
                   System.out.println("number is invalid");
                   System.out.print("Make another guess(an integer value from 1 - 50)): ");
                   guess = in.nextInt();
            }
            
        }
        System.out.println("you guessed the secret number and win");
    }
}