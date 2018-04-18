import java.util.*;
import java.io.*;

//when save from csv to txt, choose tab delimited format, if choose UTF16 Unicode, won't be able to read

public class calarr_multi_passarr
{
    public static final int INI_LEN=10000;
    
    public static void main(String[] args)
    {
        String[][] s = read_data();
    	calculate(s);
    }
    
    
    public static void calculate(String[][] s)
    {
        
        int nRow = s.length;
        int nCol = s[0].length;
    	
        double[][] numbers = new double[nRow][nCol];

        double[] sums = new double[nCol];
        double[] avgs = new double[nCol];
        
        for (int i=0;i<nRow;i++) {
        	for (int j = 0; j<nCol; j++) {
                	if (s[i][j].contentEquals("NaN")) {
                		numbers[i][j] =0.00;
                	} else {
                		numbers[i][j] = Double.parseDouble(s[i][j]);
                	}
                    sums[j]+=numbers[i][j];
        	}
        }                

        for (int i=0;i<nCol;i++) {
            avgs[i] = sums[i] /nRow;
            System.out.format("Col %d : %.2f%n",i,avgs[i]);
        }
    }
    
    public static String[][] read_data()
    { 
        Scanner console = new Scanner(System.in);
        int length=INI_LEN;
        String[][] entries = new String[length][length];

        int count = 0; //counting number of rows
        int size = 0; //number of columns
        //put in data
        Scanner fileScanner = getInputScanner(console);
        
        while (fileScanner.hasNextLine()) {
            String line = fileScanner.nextLine();
            Scanner lineScan = new Scanner(line);
            while (lineScan.hasNext()) {
                String newline = lineScan.next();
                String[] parts = newline.split(",");
                size = parts.length;
                for (int i=0;i<size;i++) {
                		entries[count][i] =parts[i];
                }                            
                count+=1;
            }
        }
        
        String[][] adj_entries = new String[count][size];
        for (int i = 0; i<count; i++) {
        	for (int j = 0; j<size; j++) {
        		adj_entries[i][j] = entries[i][j];
            }
        }
        
        return adj_entries;
    }
    
    /**
     * Reads filename from user until the file exists, then return a file
     * scanner
     * 
     * @param console Scanner that reads from the console
     * 
     * @return a scanner to read input from the file
     */
    public static Scanner getInputScanner(Scanner console) {
        System.out.print("Enter a file name to process: ");
        File file = new File(console.next());
        while (!file.exists()) {
            System.out.print("File doesn't exist. " + "Enter a file name to process: ");
            file = new File(console.next());
        }
        Scanner fileScanner = null;// null signifies NO object reference
                                   // while (result == null) {
        try {
            fileScanner = new Scanner(file);
        } catch (FileNotFoundException e) {
            System.out.println("Input file not found. ");
            System.out.println(e.getMessage());
            System.exit(1);
        }
        return fileScanner;
    }
}