import java.util.Scanner;

/**
 * accepts an integer maximum as its parameter and prints all "perfect numbers" up to and including that maximum
 * @author Yan Chen
 */
 
public class FindPerfectNumbers{
    /**
      * Starts the program.
      * @param args command line arguments
      */       
    public static void main(String[] args) {
        // Set up Scanner for console
        Scanner in = new Scanner(System.in);
        // Prompt for entering an integer
        System.out.print("Enter an integer: ");
        int num = in.nextInt();  
        perfectNumbers(num);    
    }

    public static void perfectNumbers(int n){
        if (n < 0) { //if n<0 throw exceptions
            throw new IllegalArgumentException("negative n");
        }
        int countP = 0; //count number of perfect numbers upto n
        System.out.print("Perfect numbers up to " + n + ":");
        //i is each integer up to n
        for (int i = 1; i <= n; i++) {
            int sum = 0;
            //j is potential factor of i
            for (int j = 1; j < i; j++) {
                if (i % j == 0) {
                    sum = sum+j;
                }
            }
            if (sum == i) {
                System.out.print(" " + i);
                countP+=1;
            }
        }
        if (countP==0) {
           System.out.print(" none");
        }
        System.out.println();
    }
}