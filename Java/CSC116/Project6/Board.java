public class Board {
  
  private int numberOfRows;
  private int numberOfColumns;
  private Square[][] squares;
  private int maximumNumberOfShips;
  private Ship[] ships;
  private int numberOfShips=0;
  
  /*This is the constructor of the Board class. 
  *The fields listed above should be initialized. 
  *Throw an IllegalArgumentException if numberOfRows < 1, 
  *numberOfColumns < 1, or maximumNumberOfShips < 0. 
  */
  public Board(int numberOfRows, int numberOfColumns, int maximumNumberOfShips) {
    this.numberOfRows = numberOfRows;
    this.numberOfColumns = numberOfColumns;
    this.maximumNumberOfShips = maximumNumberOfShips;
    if (this.numberOfRows<1 || this.numberOfColumns<0 || this.maximumNumberOfShips<0) {
                throw new IllegalArgumentException();
    } 
    squares = new Square[numberOfRows][numberOfColumns];
    for (int i = 0; i<numberOfRows; i++){
        for (int j = 0; j<numberOfColumns; j++) {
            squares[i][j] = new Square();
        }
    }
    ships = new Ship[maximumNumberOfShips];
  }
  
  /*adds a Ship to the board. This means that all Squares the length 
  *of the ship starting at the startRow and startCol must be updated 
  *appropriately. The isHorizontal determines which direction to fill 
  *Squares. The method returns true if the Ship is successfully added 
  *to the Board and false if the Ship could not be added due to another 
  *Ship in the way, reaching a Board boundary, or if the array of Ship's is full. 
  */
  public boolean addShip(int length, boolean isHorizontal, int startRow, int startCol) {
      Ship s = new Ship(length, isHorizontal, startRow, startCol);
      int y = s.getStartRow();
      int x = s.getStartCol();
      int size = s.getLength();
      int nAvailable = 0;
      if (numberOfShips<=maximumNumberOfShips) {
        if (!s.isHorizontal()) {          
         for (int i = 0; i<size;i++) {
             if (y + i < numberOfRows && !squares[y+i][x].hasShip()) {            
               nAvailable+=1; 
             }
         }
         if (nAvailable==size) { 
             for (int i = 0; i<size;i++) {
                 squares[y+i][x].addShip(s);
             }
             ships[this.numberOfShips] = s;
		     ++numberOfShips;
             return true;
         } else {
             return false;
         } 
        } else {
         for (int i = 0; i<size;i++) { 
             if (x + i < numberOfColumns && !squares[y][x+i].hasShip()) {            
               nAvailable+=1;  
             }
         }
         if (nAvailable == size) {
             for (int i = 0;i<size;i++) {
                 squares[y][x+i].addShip(s);
             }
             ships[this.numberOfShips] = s;
		     ++numberOfShips;
             return true;   
         } else {
             return false;
         }             
        }
      } else {
        return false;
      }
  }
  
  /*returns the number of Ships deployed on the Board */
  public int getNumberOfShips() {
      return this.numberOfShips;
  } 
  
  /*returns an array of the Ships deployed on the Board */
  public Ship[] getShips() {
      return ships;
  }
  
  /*If the Square located at the specified row and column has not been 
  *previously hit, the Square should be fired at and true should be returned. 
  *If the Square has already been hit, it should not be hit again and false 
  *should be returned. Throw an IllegalArgumentException if row < 0, col < 0, 
  *row >= number of rows, or col >= number of columns.
  */
  public boolean fireAtLocation(int row, int col) {
      if (row<0 || col<0 || row>numberOfRows || col>numberOfColumns) {
          throw new IllegalArgumentException();
      } 
      if (!squares[row][col].hasBeenHit()) {
          return true;
      } else {
          return false;
      }
  }
  
  /*returns true if the enemy has already fired on the Square located at 
  *the specified row and column. Throw an IllegalArgumentException 
  *if row < 0, col < 0, row >= number of rows, or col >= number of columns. 
  */
  public boolean hasBeenHit(int row, int col) {
      if (row<0 || col<0 || row>numberOfRows || col>numberOfColumns) {
          throw new IllegalArgumentException();
      } 
      if (squares[row][col].hasBeenHit()) {
          return true;
      } else {
          return false;
      }
  }
  
  /*returns true if all of the Ship's on the Board have been sunk by enemy fire.*/
  public boolean areAllShipsSunk() {
      for (int i = 0;i<numberOfShips;i++) {
          if (!ships[i].isSunk()) {
              return false;
          }
      }
      return true;
  }
  
  /*returns the number of rows in the Board*/
  public int getNumberOfRows() {
      return numberOfRows;
  }
  
  /*returns the number of columns in the Board*/
  public int getNumberOfColumns() {
      return numberOfColumns;
  }
  
  /*returns a String representation of a Board.*/
  public String toString() {
      String strBoard="";
      for (int i=0;i<numberOfRows;i++) {
          for (int j=0;j<numberOfColumns;j++) {
              strBoard= strBoard + squares[i][j].toString();
          }
          strBoard=strBoard+"\n";
       }
       return strBoard;
  }
}