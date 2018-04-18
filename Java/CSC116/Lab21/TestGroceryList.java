/**
 * Starter code to test GroceryList and GroceryItemOrder
 * 
 * @author Yan Chen
 */
public class TestGroceryList {
    /** Constant for passing test output */
    public static final String PASS = "PASS";
    /** Constant for failing test output */
    public static final String FAIL = "FAIL";

    /** Counter for test cases */
    public static int testCounter = 0;
    /** Counter for passing test cases */
    public static int passingTestCounter = 0;

    /**
     * Starts program
     * 
     * @param args command line arguments
     */
    public static void main(String[] args) {
    GroceryList list = new GroceryList();  
    GroceryItemOrder carrots = new GroceryItemOrder("Carrots", 5, 0.40);  
    list.add(carrots); 
    GroceryItemOrder apples = new GroceryItemOrder("Apples",4, 0.15);  
    list.add(apples);
    
    GroceryList list2 = new GroceryList();   
    GroceryItemOrder carrots2 = new GroceryItemOrder("Carrots", 5, 0.40);  
    list2.add(carrots2); 
    GroceryItemOrder apples2 = new GroceryItemOrder("Apples",4, 0.15);  
    list2.add(apples2); 
    
    GroceryList list3 = new GroceryList();  
    GroceryItemOrder rice = new GroceryItemOrder("Rice", 1, 1.10);  
    list3.add(rice);  
    GroceryItemOrder tortillas = new GroceryItemOrder("Tortillas",10, .05);  
    list3.add(tortillas); 
    /** 
    GroceryItemOrder strawberries = new GroceryItemOrder("Strawberries", 1, 4.99);  
    list.add(strawberries);  
    GroceryItemOrder chicken = new GroceryItemOrder("Chicken",1, 5.99);  
    list.add(chicken);  
    GroceryItemOrder lettuce = new GroceryItemOrder("Lettuce",1, 0.99);  
    list.add(lettuce);  
    GroceryItemOrder milk = new GroceryItemOrder("Milk", 2,2.39);  
    list.add(milk);  
    */
 
    
    String id = "toString-carrots";
    String desc = "carrots.toString()";
    String exp = "5 Carrots at 0.4";
    String act = carrots.toString();
    testResult(id, desc, exp, act);
    
    id = "toString-list";
    desc = "list.toString()";
    exp = "5 Carrots at 0.4/4 Apples at 0.15/";
    act = list.toString();
    testResult(id, desc, exp, act);
    
    id = "carrots-equals-carrots2";
    desc = "carrots.equals(carrots2)";
    boolean expB = true;
    boolean actB = carrots.equals(carrots2);
    testResult(id, desc, expB, actB);
    
    id = "carrots-unequal-apples";
    desc = "carrots.equals(apples)";
    expB = false;
    actB = carrots.equals(apples);
    testResult(id, desc, expB, actB);
    
    id = "list-equals-list";
    desc = "list.equals(list)";
    expB = true;
    actB = list.equals(list);
    testResult(id, desc, expB, actB);
    
    id = "list-unequal-list3";
    desc = "list.equals(list3)";
    expB = false;
    actB = list.equals(list3);
    testResult(id, desc, expB, actB);
    
    id = "list-totalCost";
    desc = "list.totalCost()";
    double expi = 2.6;
    double acti = list.getTotalCost();
    testResult(id, desc, expi, acti);
    
    System.out.printf("\n%4d / %4d passing tests\n", passingTestCounter, testCounter);
    } 
    /**
     * Prints the test information.
     * 
     * @param id id of the test
     * @param desc description of the test (e.g., method call)
     * @param exp expected result of the test
     * @param act actual result of the test
     */
    private static void testResult(String id, String desc, String exp, String act) {
        testCounter++;
        String result = FAIL;
        if (exp.equals(act)) {
            result = PASS;
            passingTestCounter++;
        }
        System.out.printf("%-30s%-60s%-6s%-42s%-42s\n", id, desc, result, exp, act);
    }

    /**
     * Prints the test information.
     * 
     * @param id id of the test
     * @param desc description of the test (e.g., method call)
     * @param exp expected result of the test
     * @param act actual result of the test
     */
    private static void testResult(String id, String desc, boolean exp, boolean act) {
        testCounter++;
        String result = FAIL;
        if (exp == act) {
            result = PASS;
            passingTestCounter++;
        }
        System.out.printf("%-30s%-60s%-6s%-42s%-42s\n", id, desc, result, exp, act);
    }
    
     /**
     * Prints the test information.
     * 
     * @param id id of the test
     * @param desc description of the test (e.g., method call)
     * @param exp expected result of the test
     * @param act actual result of the test
     */
    private static void testResult(String id, String desc, double exp, double act) {
        testCounter++;
        String result = FAIL;
        if (exp == act) {
            result = PASS;
            passingTestCounter++;
        }
        System.out.printf("%-30s%-60s%-6s%-42s%-42s\n", id, desc, result, exp, act);
    }
}
