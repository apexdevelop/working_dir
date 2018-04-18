import java.util.Scanner;
import java.io.*;

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
        //check commend-line arguments
        if(args.length != 1) {
            System.out.println("Usage: java MagicSquare filename");
            System.exit(0);
        } 
        
        File file0 = new File(args[0]);
        if(file0.exists()==false) {
            System.out.println("Unable to access input file: " + args[0]);
            System.exit(0);
        } 
        
        //get matrix size
        int size=0;
        try {
            File file1 = new File(args[0]);
            Scanner fileScanner = new Scanner(file1); 
            size = fileScanner.nextInt();
            fileScanner.close(); 
        } catch (FileNotFoundException e) {
                System.out.println("Error reading file: " + e);                
        } 
        int[][] square=new int[size][size];
        //get elements
        try {
            File file2 = new File(args[0]);
            Scanner fileScanner2 = new Scanner(file2); 
            String line0 = fileScanner2.nextLine();            
            for (int i =0; i<size; i++) {
                String line = fileScanner2.nextLine();
                Scanner lineScan = new Scanner(line);
                for (int j =0; j<size; j++) {
                square[i][j] = lineScan.nextInt();
                }
            }
            fileScanner2.close(); 
        } catch (FileNotFoundException e) {            
        } 
        
        boolean isMagic2=isMagicSquare(square);
        System.out.println("Magic Square: " + isMagic2);
        
    }
    
    /**
     * Return true if the square is a multiplicative magic square as defined above, false otherwise
     * Throw an IllegalArgumentException if the square does not have the same number of rows and columns
     *@return boolean
     */
    public static boolean isMagicSquare(int[][] square) {
        int size = square.length;
        int[] colArr=new int[size];
        for (int i =0; i<size; i++) {
            colArr[i]=square[i].length;
        }
        // Test if number of columns equals number of rows
        
        for (int p =0; p<size; p++) {          
            if (colArr[p]!=size) {
                throw new IllegalArgumentException("number of columns does not equal number of rows");
            } 
        }
        
        for (int p =0; p<size; p++) {
            for (int q=p+1;q<size;q++) {            
            if (colArr[p]!=colArr[q]) {
                throw new IllegalArgumentException("No equal number of columns");
            } 
            }  
        }
        
        //checking if every element is distinct.
        int[] singleArr = new int[size*size];
        for(int i = 0; i < size; i++){
            for(int j = 0; j < size; j++){
                singleArr[size*i+j]=square[i][j];
            }
        }
        
        for (int p =0; p<size*size; p++) {          
            for (int q=p+1;q<size*size;q++) {
            if (singleArr[p]==singleArr[q]) {
                //System.out.println("there are duplicate elements!");
                return false;
            }
            }
               
        }
        
        //Test equality of row products
        int[] rowProd = new int[size];
        for(int i = 0; i < size; i++){
            rowProd[i]=1;
            for(int j = 0; j < size; j++){
                rowProd[i]*=square[i][j];
            }
        } 
        for (int p =0; p<size; p++) {
            for (int q=p+1;q<size;q++) {            
            if (rowProd[p]!=rowProd[q]) {
                //System.out.println("row products are not equal!");
                return false;
            } 
            }  
        }
        
        //Test equality of column products
        int[] colProd = new int[size];
        for(int j = 0; j < size; j++){
            colProd[j]=1;
            for(int i = 0; i < size; i++){
                colProd[j]*=square[i][j];
            }
        }        
        for (int p =0; p<size; p++) {
            if (colProd[p]!=rowProd[0]) {
                //System.out.println("col products are not equal to row products!");
                return false;
            } 
        }        
        for (int p =0; p<size; p++) {
            for (int q=p+1;q<size;q++) {            
            if (colProd[p]!=colProd[q]) {
                //System.out.println("col products are not equal!");
                return false;
            } 
            }  
        }
        
         //Test equality of diagonal products
        int[] diagProd = {1,1};
        for(int i = 0; i < size; i++){   
            diagProd[0]*=square[i][i];
            diagProd[1]*=square[i][size-i-1];
        }
        for (int p =0; p<2; p++) {
            if (diagProd[p]!=rowProd[0]) {
                //System.out.println("diagonal products are not equal to row products!");
                return false;
            } 
        }   
        if (diagProd[0]!=diagProd[1]) {
            //System.out.println("diag products are not equal!");
            return false;
        } 
        return true;
 	}           
}