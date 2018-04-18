import java.util.Scanner;

/**
 * A program that checks if an array is a magic square.
 * 
 * @author Yan Chen
 */
public class MagicSquare {
     /**
     * Starts the program and calls the other methods
     * 
     * @param args command line arguments
     */
    public static void main(String[] args) {
        int[][] square = getArrayFromUser(4);        
        printMatrix(square);        
        boolean isMagic1=isExist(square);
        if(isMagic1) {
          boolean isMagic2=isEqual(square);
          if(isMagic2) {
              System.out.println("This is a MagicSquare!");
          } else {
              System.out.println("Not a MagicSquare!");
              System.exit(1);
          }  
        } else {
          System.out.println("Not a MagicSquare!");
          System.exit(1);
        }
        
    }
    
    /**
     * Creates a matrix in  4*4  and stores the values that are given
     * from the user.
     * 
     * @param size The now of rows and columns of the matrix that will be created and returned
     * @return Array with length elements that were given by the user
     */
    public static int[][] getArrayFromUser(int size) {
	int[][] ret = new int[size][size];
	Scanner console = new Scanner(System.in);
	for(int i = 0; i < size; i++){
	    for(int j = 0; j < size; j++){
	    System.out.print("Row (Integer)" + (i+1) + " Column (Integer)"+ (j+1) +": ");
	    while(!console.hasNextInt()){
		console.next();
		System.out.println("Not an integer!");
		System.out.print("Row (Integer)" + (i+1) + " Column (Integer)"+ (j+1) +": ");
	    }
	    ret[i][j] = console.nextInt();
	    }
	}
	return ret;
    }
    
    /**
     * print out the matrix
     *@param int[][] square: the matrix
     */
    public static void printMatrix(int[][] square) {
        for(int i = 0; i < 4; i++){
	    for(int j = 0; j < 4; j++){
	        System.out.printf("%2d",square[i][j]);
	        System.out.print(" ");
	    }
	    System.out.println();
	    }
    }
    
    /**
     *checking if 1-16 has occurred.
     *@param int[][] square: the matrix
     *@return boolean is every element from 1-16 exists in the matrix
     */
    public static boolean isExist(int[][] square) {
        //boolean isMagic = false;
        int[] count = new int[16];
        for (int k =1; k<=16; k++) {
           // System.out.println(count[k-1]);
            for(int i = 0; i < 4; i++){
                for(int j = 0; j < 4; j++){
                    if (square[i][j]==k) {
                        count[k-1] = count[k-1] + 1;
                    }
                }
            }
            //System.out.println(count[k-1]);
            if (count[k-1] ==0){
                System.out.println(k +" doesn't exist");
                //System.out.println("Not a MagicSquare!");
                return false;
            } else {
                System.out.println(k +" exists");
            }
        }
        return true;
    } 
    
    /**
     *create an int array to store row and column and diagonal sums
     *sum[0] to sum [3] are row sums, sum[4] to sum [7] are column sums, sum[8] to sum[9] are diagonal sums
     *@param int[][] square: the matrix
     *@return boolean
     */
    public static boolean isEqual(int[][] square) {
        int[] sum = new int[10];
        for(int i = 0; i < 4; i++){
            for(int j = 0; j < 4; j++){
                sum[i]+=square[i][j];
            }
        }
        
        if (sum[0]==sum[1] && sum[1]==sum[2] && sum [2]==sum[3]){
            System.out.println("Row sums are equal.");
            for(int j = 0; j < 4; j++){
            for(int i = 0; i < 4; i++){
                sum[4+j]+=square[i][j];
            }
            }            
            if (sum[4]==sum[5] && sum[5]==sum[6] && sum [6]==sum[7] && sum[7]==sum[3]){
                System.out.println("Column and row sums are equal.");
                sum[8]=square[0][0]+square[1][1]+square[2][2]+square[3][3];
                sum[9]=square[0][3]+square[1][2]+square[2][1]+square[3][0];
                if (sum[8]==sum[9] && sum[9]==sum[7]){
                    System.out.println("Row sum, Column sum and diagonal sum are equal!");
                    //System.out.println("This is a MagicSquare!");
                    return true;
                } else {
                    return false;
                    //System.out.println("Not a MagicSquare!");
                }         
            }  else {
                return false;
                //System.out.println("Not a MagicSquare!");
                //System.exit(1);
            }
        } else {
            return false;
            //System.out.println("Not a MagicSquare!");
            //System.exit(1);
        }
        //return true;
 	}           
}