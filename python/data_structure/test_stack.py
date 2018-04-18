input="[]"
stack=[]
count=0
for i, char in enumerate(input):
    if char == "[" or char =="(" or char == "{":
       stack.append(char)
       count = count +1
print str(stack)