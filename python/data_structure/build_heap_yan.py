# python3

class HeapBuilder:
  def __init__(self):
    self._swaps = []
    self._data = []

  def ReadData(self):
    n = int(input())
    self._data = [int(s) for s in input().split()]
    assert n == len(self._data)

  def WriteResponse(self):
    print(len(self._swaps))
    for swap in self._swaps:
      print(swap[0], swap[1])
  
  def GenerateSwaps(self):
    start = int(len(self._data)/2)
    i = start
    while i>=0:
      self.SiftDown(i)
      i = i - 1
  def SiftDown(self, i):
    minIndex = i
    l = 2*i + 1
    if(l < len(self._data) and self._data[l] < self._data[minIndex]):
      minIndex = l
    r = 2*i + 2
    if(r < len(self._data) and self._data[r] < self._data[minIndex]):
      minIndex = r
    if(i!=minIndex):
      self._swaps.append((i, minIndex))
      self._data[i], self._data[minIndex] = self._data[minIndex], self._data[i]
      self.SiftDown(minIndex)
      
  def Solve(self):
    self.ReadData()
    self.GenerateSwaps()
    self.WriteResponse()

if __name__ == '__main__':
    heap_builder = HeapBuilder()
    heap_builder.Solve()
