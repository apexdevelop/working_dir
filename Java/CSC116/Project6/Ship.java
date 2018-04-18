public class Ship{
    //instance fields
    private int length;
    private int nhit;
    private boolean isHorizontal;
    private int startRow;
    private int startCol;
    
    /*This constructor must initialize the class's instance variables using the parameter values. 
     *Throw an IllegalArgumentException if length < 1, startRow < 0, or startCol < 0
     */
    public Ship(int length, boolean isHorizontal, int startRow, int startCol){
        this.length = length;
        this.isHorizontal=isHorizontal;
        this.startRow=startRow;
        this.startCol=startCol;
        if (this.length<1 || this.startRow<0 || this.startCol<0) {
                throw new IllegalArgumentException();
        } 
    }
    
    /*returns the length of the ship
    */
    public int getLength(){
        return this.length;
    }
    
    /*returns true if the ship has horizontal orientation, false otherwise
    */
    public boolean isHorizontal(){
        return this.isHorizontal;
    }
    
    /*returns the row of the upper left corner of the Ship
    */
    public int getStartRow(){
        return this.startRow;
    }
    
    /*returns the column of the upper left corner of the Ship
    */
    public int getStartCol(){
        return this.startCol;
    }
    
    /*simulates hitting the ship (updates the appropriate instance variable)
    */
    public void hit(){
        nhit+=1;
    }
    
    /*returns true if the ship is sunk (has been hit as many times as its length).
    */
    public boolean isSunk(){
        if (this.nhit==this.length) {
            return true;
        } else {
            return false;
        }
    }
    
    public String toString(){
        return this.length + "," + this.startRow + ", " + this.startCol+ ", "+ this.isHorizontal + ", "+ this.nhit+ ", " + isSunk();
    }
}