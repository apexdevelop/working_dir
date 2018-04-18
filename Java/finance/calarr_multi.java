import java.util.*;
import java.io.*;

//when save from csv to txt, choose tab delimited format, if choose UTF16 Unicode, won't be able to read

public class calarr_multi
{
    public static final int INI_MIN=10000;
    public static final int INI_MAX=-10000;
    public static final int INI_LEN=10000;
    
    public static void main(String[] args)
    {
        calculate();
    }
    
    
    public static void calculate()
    {
        
        Scanner console = new Scanner(System.in);
        int length=INI_LEN;
        double[][] numbers = new double[length][length];

        double[] sums = new double[length];
        double[] avgs = new double[length];
        //double max = INI_MAX;
        //double min = INI_MIN;
        //double sumDev = 0;
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
                	if (parts[i].contentEquals("NaN")) {
                		numbers[count][i] =0.00;
                	} else {
                		numbers[count][i] = Double.parseDouble(parts[i]);
                	}
                    
                //System.out.println(numbers[count][i]);
                    sums[i]+=numbers[count][i];
                }                
                
//                if (numbers[count] > max) {
//                    max = numbers[count];
//                } 
//                if (numbers[count] < min) {
//                    min = numbers[count];
//                }
                            
                count+=1;
            }
        }
        //System.out.println(size);
        for (int i=0;i<size;i++) {
            //System.out.format("%.2f%n", sums[i]);
            avgs[i] = sums[i] /count;
            System.out.format("Col %d : %.2f%n",i,avgs[i]);
        }


//        System.out.println("max number is : " + max);
//        
//        System.out.println("min number is : " + min);
//        
//        for (int i=0; i<count;i++)
//        {
//           sumDev=sumDev+(numbers[i]-average)*(numbers[i]-average);
//        }
//        double standardDeviation = Math.sqrt(sumDev/(count-1));
//        System.out.format("The standard deviation is : %.2f%n",standardDeviation);
        
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