/**
 * produce DrawRocket
 * @author Yan Chen
 */
 
 public class DrawRocket {
     public static void main(String[] args) {
        System.out.println("Rocket Height 3:");
        drawRocket(3);
        System.out.println("\n\nRocket Height 4:");
        drawRocket(4);
        System.out.println("\n\nRocket Height 5:");
        drawRocket(5);
    }
    
    public static void drawRocket (int height) {
        upper(height);
        strip(height);
        lower(height);
    }
        
    public static void upper (int height) {
            top(height);
            strip(height);
            middle1(height);
            middle2(height);
    }
    
    public static void lower (int height) {
            middle2(height);
            middle1(height);
            strip(height);
            top(height);
    }
        
    public static void top (int height){
        for (int i = 1; i <= 2 * height - 1; i++) {
            for (int j = 1; j < 2 * height - i + 1; j++) {
                System.out.print(" ");
            }
            for (int j = 2 * height - i + 1; j < 2 * height + 1; j++) {
                System.out.print("/");
            }
            for (int j = 2 * height + 1; j < 2 * height + 3; j++) {
                System.out.print("*");
            }
            for (int j = 2 * height + 3; j < 2 * height + 3 + i; j++) {
                System.out.print("\\");
            }
            System.out.println();
        }
    }
    
    public static void strip (int height){
        System.out.print("+");
        for (int j = 1; j <= 2 * height; j++) {
            System.out.print("=*");
        }
        System.out.print("+");
        System.out.println();
    }
    
    public static void middle1(int height){
        for (int i = 1; i <= height; i++) {
            System.out.print("|");
            for (int m = 1; m <= 2; m++) {
                for (int j = 1; j < height - i + 1; j++) {
                    System.out.print(".");
                }
                int count = 0;
                for (int j = height - i + 1; j < height + 1; j++) {
                    System.out.print("/\\");
                    count = count + 2;
                }
                for (int j = height - i + 1 + count; j < 2 * height + 1; j++) {
                    System.out.print(".");
                }
            }
            System.out.print("|");
            System.out.println();
        }
    }
    
    public static void middle2(int height){
        for (int i = 1; i <= height; i++) {
            System.out.print("|");
            for (int m = 1; m <= 2; m++) {
                for (int j = 1; j < i; j++) {
                    System.out.print(".");
                }
                int count = 0;
                for (int j = i; j < height + 1; j++) {
                    System.out.print("\\/");
                    count = count + 2;
                }
                for (int j = i + count; j < 2 * height + 1; j++) {
                    System.out.print(".");
                }
            }
            System.out.print("|");
            System.out.println();
        }
    }

 }