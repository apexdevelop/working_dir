/**
 * Build a Window
 * @author Yan Chen
 */
 
public class Window {
    /** class constant: SPACE*/
    public static final int SPACE = 5;
    public static void main(String[] args) {               
        /**
         * start two loop of one "+===+===+" and three "|   |   |"
         */
        for (int m = 1; m <= 2; m++) {
            for (int i = 1; i <= 2; i++) {
                System.out.print("+");
                for (int j = 1; j <= SPACE; j++) {
                System.out.print("=");            
                }
            }
            System.out.println("+");
        
            for (int n = 1; n <= SPACE; n++) {
                for (int i = 1; i <= 2; i++) {
                    System.out.print("|");
                    for (int j = 1; j <=SPACE; j++) {
                    System.out.print(" ");            
                    }
                }
                System.out.println("|");
            }
        
        }       
        /**
         * finish the last "+===+===+"
         */
        for (int i = 1; i <= 2; i++) {
            System.out.print("+");
            for (int j = 1; j <= SPACE; j++) {
                System.out.print("=");            
            }
        }
        System.out.println("+");
  }
}