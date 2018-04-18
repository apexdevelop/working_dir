/**
 * Automated white box test program for Board
 * @author Sarah Heckman
 */
public class BoardTest {
	public static final int ROWS = 8;
        public static final int COLS = 8;
        public static final int NUMBER_OF_SHIPS = 4;
	/** A private copy of the Board */
	private Board board;
	
	/**
	 * Initializes the field
	 */
	public BoardTest() {
		board = new Board(ROWS,COLS,NUMBER_OF_SHIPS);
	}
	
	/**
	 * Tests Board.addShip() method
	 */
	public void testAddShip() {
		board = new Board(ROWS,COLS,NUMBER_OF_SHIPS);
		System.out.println("testAddShip");
		
		//Test adding a Ship at a valid location
		boolean expectedOutput = true;
		boolean actualOutput = board.addShip(1, true, 3, 5);
		System.out.printf("Expected: %8s   Actual: %8s\n", expectedOutput, actualOutput);
	}
	
	/**
	 * Tests Board.addShip() method by Yan
	 */
	public void testAddShip2() {
		board = new Board(ROWS,COLS,NUMBER_OF_SHIPS);
		System.out.println("testAddShip2");
		
		//Test adding a Ship vertically
		boolean expectedOutput = true;
		boolean actualOutput = board.addShip(1, false, 5, 3);
		System.out.printf("Expected: %8s   Actual: %8s\n", expectedOutput, actualOutput);
	}
	
	/**
	 * Tests Board.getNumberOfShips() method
	 */
	public void testGetNumberOfShips() {
		board = new Board(ROWS,COLS,NUMBER_OF_SHIPS);
		System.out.println("testGetNumberOfShips");
		
		//Test that there are no Ships when a Board is initially created
		int expectedOutput = 0;
		int actualOutput = board.getNumberOfShips();
		System.out.printf("Expected: %8d   Actual: %8d\n", expectedOutput, actualOutput);
		
		//Test the number of Ships after adding a Ship
		board.addShip(3, true, 7, 1);
		expectedOutput = 1;
		actualOutput = board.getNumberOfShips();
		System.out.printf("Expected: %8d   Actual: %8d\n\n", expectedOutput, actualOutput);
		
		//Test the number of Ships after adding another Ship by Yan
		board.addShip(3, true, 6, 1);
		expectedOutput = 2;
		actualOutput = board.getNumberOfShips();
		System.out.printf("Expected: %8d   Actual: %8d\n\n", expectedOutput, actualOutput);
	}
	
	/**
	 * Tests Board.getShips() method
	 */
	public void testGetShips() {
		board = new Board(ROWS,COLS,NUMBER_OF_SHIPS);
		System.out.println("testGetShips");
		
		//Test that all Ships are null when a Board is first created
		Ship [] ships = board.getShips();
		for (int i = 0; i < ships.length; i++) {
			try {
				ships[i].toString();
				System.out.printf("Expected: NullPointerException   Actual: Ship at index %d is not null\n", i);
			} catch (NullPointerException e) {
				System.out.printf("Expected: NullPointerException   Actual: NullPointerException\n");
			}
		}
		
		//TestGetShips after adding another Ship by Yan
		board.addShip(3, true, 7, 1);
		for (int i = 0; i < ships.length; i++) {
			try {
				ships[i].toString();
				System.out.printf("Expected: Ship at index 0 is not null   Actual: Ship at index %d is not null\n", i);
			} catch (NullPointerException e) {
				System.out.printf("Expected: NullPointerException   Actual: NullPointerException\n");
			}
		}
	}
	
	/**
	 * Tests Board.fireAtLocation() method
	 */
	public void testFireAtLocation() {
		board = new Board(ROWS,COLS,NUMBER_OF_SHIPS);
		System.out.println("testFireAtLocation");
		
		//Test firing at a location that has never been fired at before
		boolean expectedOutput = true;
		boolean actualOutput = board.fireAtLocation(0, 0);
		System.out.printf("Expected: %8s   Actual: %8s\n", expectedOutput, actualOutput);
		
		//Test firing at a location that has never been fired at before
		expectedOutput = true;
		actualOutput = board.fireAtLocation(1, 1);
		System.out.printf("Expected: %8s   Actual: %8s\n", expectedOutput, actualOutput);
	}
	
	/**
	 * Tests Board.hasBeenHit() method
	 */
	public void testHasBeenHit() {
		board = new Board(ROWS,COLS,NUMBER_OF_SHIPS);
		System.out.println("TestHasBeenHit");
		
		//Test to ensure a location that has never been fired at really hasn't
		//been fired at
		boolean expectedOutput = false;
		boolean actualOutput = board.hasBeenHit(0, 0);
		System.out.printf("Expected: %8s   Actual: %8s\n", expectedOutput, actualOutput);
		
		//Test to ensure a location that has never been fired at really hasn't
		//been fired at
		expectedOutput = false;
		actualOutput = board.hasBeenHit(1, 1);
		System.out.printf("Expected: %8s   Actual: %8s\n", expectedOutput, actualOutput);
	}
	
	/**
	 * Tests Board.areAllShipsSunk() method
	 */
	public void testAreAllShipsSunk() {
		board = new Board(ROWS,COLS,NUMBER_OF_SHIPS);
		System.out.println("testAreAllShipsSunk");
		
		//Test that the provided ship isn't sunk after being hit once
		board.addShip(2, true, 0, 0);
		board.fireAtLocation(0, 0);
		boolean expectedOutput = false;
		boolean actualOutput = board.areAllShipsSunk();
		System.out.printf("Expected: %8s   Actual: %8s\n\n", expectedOutput, actualOutput);
		
		//Test that the provided ship is sunk after being hit twice
		board.fireAtLocation(0, 1);
		expectedOutput = true;
		actualOutput = board.areAllShipsSunk();
		System.out.printf("Expected: %8s   Actual: %8s\n\n", expectedOutput, actualOutput);
	}
	
	/**
	 * Starts the Board automated white box test cases.
	 * @param args command line arguments
	 */
	public static void main(String[] args) {
		BoardTest test = new BoardTest();
		test.testAddShip();
		test.testAddShip2();
		test.testGetNumberOfShips();
		test.testGetShips();
		test.testFireAtLocation();
		test.testHasBeenHit();
		test.testAreAllShipsSunk();
	}

}
