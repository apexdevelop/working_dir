import java.util.Random;
import java.util.Scanner;

/**
 * generates a sequence of 20 random die tosses in an array.
 * @author Yan Chen
 */
public class DieTossesGame {
    public static final int LEN =20;
    public static final int BOUND =6;
    /**
     * Starts the program and calls the other methods
     * 
     * @param args command line arguments
     */
    public static void main(String[] args) {

        //int[] values = getRandomArray(LEN, BOUND);
        int[] values = {1, 2, 5, 5, 3, 1, 2, 4, 3, 2, 2, 2, 2, 3, 6, 5, 5, 6, 3, 1};
        printRun(values);
        System.out.println();
        printLongestRun(values);
        System.out.println();
        
    }


    /**
     * Creates an array with given length and stores the random values between 0
     * and (bound-1)
     * 
     * @param length The length of the array that will be created and returned
     * @param bound The upperbound for the range of values within the array
     * @return Array with length elements that were assigned random integers
     */
    public static int[] getRandomArray(int length, int bound) {
	int[] ret = new int[length];
	Random r = new Random();
	for(int i = 0; i < ret.length; i++){
	    ret[i] = r.nextInt(bound)+1;
	}
	return ret;
    }

    
    /**
     * prints the die values, marking the runs by including them in parentheses
     * @param values Array generated randomly
     */
    public static void printRun(int[] values) {
        boolean inRun = false;
    
        for (int i=0;i<values.length;i++) {
            if (inRun) {
                if (values[i]!=values[i-1]) {
                    System.out.print(") ");
                    inRun = false;
                } else {
            }
            
            if (!inRun && i < values.length - 1) {
                 if (values[i]== values[i+1]) {
                     System.out.print("(");
                     inRun = true;
                 }
            }
            System.out.print(values[i]+ " ");
         }
         if (inRun) {
             System.out.print(")");
         }
         
    }


 /**
     * mark the longest run
     * @param values Array generated randomly
     */
     
public static void printLongestRun(int[] values) {
    int[] countArr = new int[values.length];
    countArr[0]=0;
    for (int i=1;i<values.length;i++) {
        if (values[i]==values[i-1]) {
            countArr[i]=countArr[i-1]+1;
        } else {
            countArr[i]=0;
        }
    }
    
    int maxCount=0;
    int maxIndex=0;
    for (int i=0;i<values.length;i++) {
        //System.out.print(countArr[i]+" ");
        if (countArr[i]>maxCount) {
            maxCount=countArr[i];
            maxIndex=i;
        }
    }
    //System.out.println();
    for (int i=0;i<values.length;i++) {
        if(i==0 && i==maxIndex-maxCount){
           System.out.print("(");
           System.out.print(values[i]+" ");
        }
        if (i==maxIndex){
            System.out.print(values[i]);
            System.out.print(") ");
        } else {
        System.out.print(values[i]+" ");
        if (i==maxIndex-maxCount-1){
            System.out.print("(");
            
        }
        }
        
    }
    
    }
}