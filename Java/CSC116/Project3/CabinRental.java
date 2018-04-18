import java.io.*;
import java.util.*;

/**
 * print the rent of cabin on certain date
 * 
 * @author Yan Chen
 */
public class CabinRental {
    public static final int YEAR = 2016; //year;
     public static final int BEGIN_YEAR = 1753; //begin year;
    public static final int NOV_R = 500; //Red and White Rambler in Nov non holiday;
    public static final int NOV_W = 650; //Wolfpack Heaven in Nov non holiday;
    public static final int NOV_B = 700; //Belltower Bliss in Nov non holiday;
    
    public static final int H_NOV_R = 800; //Red and White Rambler in Nov holiday;
    public static final int H_NOV_W = 900; //Wolfpack Heaven in Nov holiday;
    public static final int H_NOV_B = 950; //Belltower Bliss in Nov holiday;
    
    public static final int DEC_R = 600; //Red and White Rambler in Dec non holiday;
    public static final int DEC_W = 850; //Wolfpack Heaven in Dec non holiday;
    public static final int DEC_B = 925; //Belltower Bliss in Dec non holiday;
    
    public static final int H_DEC_R = 1000; //Red and White Rambler in Dec holiday;
    public static final int H_DEC_W = 1200; //Wolfpack Heaven in Dec holiday;
    public static final int H_DEC_B = 1350; //Belltower Bliss in Dec holiday;
    /**
     * Starts the program
     * 
     * @param args array of command line arguments
     */
    public static void main(String[] args) {
        System.out.println("                     Welcome to Wolfpack Cabin Rental!");
        System.out.println("When prompted, please enter the cabin about which you would like to enquire");
        System.out.println("-- R (Red and White Rambler), W (Wolfpack Heaven), or B (Belltower Bliss) --");
        System.out.println("and the date in 2016 that you would like to begin your rental. Cabins rent");
        System.out.println("from Saturday to Saturday so this date must be a Saturday. The cost of renting");
        System.out.println("the cabin for that week will then be displayed.");
        userInterface();
    }

    /**
     * Interface with the user
     */
    public static void userInterface() {
        Scanner in = new Scanner(System.in);
        System.out.print("Enter cabin (R-ed and White Rambler, W-olfpack Heaven, B-elltower Bliss): ");
        String sCabin = in.next();
        sCabin = sCabin.toLowerCase();
        char cabin = sCabin.charAt(0);
        if (cabin!='r' && cabin!='w' && cabin !='b'){
            System.out.println("Invalid cabin");
            System.exit(1);
        }
        System.out.print("Enter month (11-12): ");
        int m = in.nextInt();
        if (m!=11 && m!=12){
            System.out.println("Invalid month");
            System.exit(1);
        }
        System.out.print("Enter day (must be a Saturday in month): ");
        int d = in.nextInt();
        if ((m==11 && d>30) ||(m==11 && d<5)|| (m==12 && d>31) || (d<1)){
            System.out.println("Invalid day");
            System.exit(1);
        }
        if (isSaturday(m,d,YEAR)){
            int cost = getCabinCost(cabin, m,d);
            System.out.println("Cost: $" + cost +".00");
        } else {
            System.out.println("Invalid day");
            System.exit(1);
        }
        
    }
    
    /**
     * Returns true if year >= 1753 and the date is a Saturday 
     * NOTE: 1753 is the first full year that the Gregorian calendar was used in the USA.
     * Returns false otherwise
     * @param month
     * @param day
     * @param year
     */
    public static boolean isSaturday(int month, int day, int year){
        if (year >=BEGIN_YEAR) {
            int w = year - (14 - month) / 12;
            int x = w + w / 4 - w / 100 + w / 400;
            int z = month +  12 * ((14 - month) / 12) - 2;
            int dayWeek = (day + x + (31 * z) / 12) % 7;
            if (dayWeek == 6) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }

    }
    
    /*
     * Returns the cost in whole dollars of renting the cabin for a week beginning 
     * on the given month and day in 2016.
     * Throws an IllegalArgumentException if the cabin is not 'r','R','w','W','b', or 'B' 
     * OR if the date is not a Saturday between Nov 5 and Dec 31, 2016 inclusive.
     * @param cabin
     * @param month
     * @param day
     */
    public static int getCabinCost(char cabin, int month, int day) {
        //throw exceptions
        if (cabin!='r' && cabin!='w' && cabin !='b'){
            throw new IllegalArgumentException("invalid cabin");
        }
        
        if (month!=11 && month!=12){
            throw new IllegalArgumentException("invalid month");
        }
        
        if ((month==11 && day>30) ||(month==11 && day<5)|| (month==12 && day>31) || (day<1)){
            throw new IllegalArgumentException("invalid day");
        }
        
        int w = YEAR - (14 - month) / 12;
        int x = w + w / 4 - w / 100 + w / 400;
        int z = month +  12 * ((14 - month) / 12) - 2;
        int dayWeek = (day + x + (31 * z) / 12) % 7;
        if (dayWeek != 6) {
            throw new IllegalArgumentException("not a Saturday");
        }
        
        int rent=0;
        if (cabin == 'r') {
        //Red and White Rambler
            if (month == 11){
                if (day == 19) {
                    rent = H_NOV_R;
                } else {
                    rent = NOV_R;
                }
            } else if (month == 12){
                if (day == 24 || day == 31) {
                    rent = H_DEC_R;
                } else {
                    rent = DEC_R;
                }
            }
        } else if (cabin == 'w') {
        //Wolfpack Heaven
          if (month == 11){
                if (day == 19) {
                    rent = H_NOV_W;
                } else {
                    rent = NOV_W;
                }
            } else if (month == 12){
                if (day == 24 || day == 31) {
                    rent = H_DEC_W;
                } else {
                    rent = DEC_W;
                }
            }
        } else { 
        // Belltower Bliss
          if (month == 11){
                if (day == 19) {
                    rent = H_NOV_B;
                } else {
                    rent = NOV_B;
                }
            } else if (month == 12){
                if (day == 24 || day == 31) {
                    rent = H_DEC_B;
                } else {
                    rent = DEC_B;
                }
            }
        }
        return rent;
    }
}