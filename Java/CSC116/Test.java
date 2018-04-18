
import java.io.*;
import java.util.*;

public class Test {
    public static void main(String[] args) {
        for (int i = 1;i<=6;i++) {
            if(i%3!=0) {
                System.out.print(i+" ");
                for (int j = 3; j>0;j--) {
                    if (j==i) {
                        System.out.print("!");                        
                    }
                    else {
                        System.out.print("$");
                    }
                }
                System.out.println();
            }
        }
    }

}