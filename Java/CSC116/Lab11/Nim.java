import java.util.*;
import java.util.Random;

/**
 * Simulate Nim game
 * @author Yan Chen
 */
public class Nim {
    public static final int MAX = 100;
    public static final int MIN = 10;
    /**
     * Starts program
     * 
     * @param args array of command line arguments
     */
    public static void main(String[] args) {    
        Random r = new Random();        
        // Generate a random integer between 10 and 100 to denote the initial size of the pile.
        int n = r.nextInt(MAX-MIN+1) + MIN;
        //int n = 81;
        System.out.println("Start pile: " + n);
        // Generate a random boolean to decide whether the computer or the human takes the first turn.
        boolean b1 = r.nextBoolean();
        //boolean b1 = true;
        System.out.println("Human first: " + b1);
        //Generate a random boolean to decide whether the computer plays smart or stupid.
        boolean b2 = r.nextBoolean(); 
        //boolean b2 = false;
        System.out.println("Smart computer: " + b2);
        Playgame(n,b1,b2);    
    }
    
    public static void Playgame (int n, boolean b1, boolean b2) {
        Scanner in = new Scanner(System.in);
        int remain = n;
        int h = 0; // h is what human takes
        int c = 0; // h is what computer takes
        double t; // t is power of 2
        Random r = new Random();
        //human first
        if (b1) { 
        while ( remain >= 1) {
            if (remain >=2 ){
                System.out.print("How many marbles (between 1 and " + remain/2 + ") do you want to remove:");
                h = in.nextInt(); 
            } else {
                System.out.println("You (human) must remove the last marble.");
                h = 1;
            }
            remain = remain - h;
            System.out.println("Current pile: " + remain);
            if (remain == 0) {
                System.out.println("Human took last marble. Computer won!");
                break;
            }
            if (b2 == true) {
                if (remain == 3 || remain ==7 || remain== 15 || remain == 31 || remain == 63){            
                    c = r.nextInt(remain / 2) + 1;
                } else if (remain == 1) {
                    c = 1;
                } else {
                    c = 63;
                    while (c > remain/2) {
                      c = (c+1)/2 - 1;
                    }  
                }
            } else {
                if (remain == 1) {
                    c = 1;
                } else {
                c = r.nextInt(remain / 2) + 1;
                }
            }
            System.out.println("Computer removed " + c + " marble(s).");
            remain = remain - c;
            System.out.println("Current pile: " + remain);
            if (remain == 0) {
                System.out.println("Computer took last marble. Human won!");
            }
        }
        } else {
        // computer first
        while ( remain >= 1) {
            if (b2 == true) {
                if (remain == 3 || remain ==7 || remain== 15 || remain == 31 || remain == 63){            
                    c = r.nextInt(remain / 2) + 1;
                } else if (remain == 1) {
                    c = 1;
                } else {
                    c = 63;
                    while (c > remain/2) {
                      c = (c+1)/2 - 1;
                    }  
                }
            } else {
                if (remain == 1) {
                    c = 1;
                } else {
                  c = r.nextInt(remain / 2) + 1;
                }
            }
            System.out.println("Computer removed " + c + " marble(s).");
            remain = remain - c;
            System.out.println("Current pile: " + remain);
            
            if (remain == 0) {
                System.out.println("Computer took last marble. Human won!");
                break;
            }
            
            if (remain >=2 ){
                System.out.print("How many marbles (between 1 and " + remain/2 + ") do you want to remove:");
                h = in.nextInt();
            }
            if (remain == 1) {
              System.out.println("You (human) must remove the last marble.");
              h=1;
            }
            remain = remain - h;
            System.out.println("Current pile: " + remain);
            if (remain == 0) {
                System.out.println("Human took last marble. Computer won!");
            }
        }
        }
    }
}    