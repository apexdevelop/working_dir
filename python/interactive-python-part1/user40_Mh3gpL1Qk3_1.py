# template for "Stopwatch: The Game"
import simplegui
import math
# define global variables
interval = 100
count = 0
time="0:00.0"
x=0
y=0
is_running=False

# define helper function format that converts time
# in tenths of seconds into formatted string A:BC.D
def format(t):
    th_sec=int(t % 10)
    sec=int(math.floor(t/10))
    tsec=int(math.floor(t/100))
    min=int(math.floor(t/600))
    if t<600:
        min=0       
        if t<100:
            tsec=0
            if t<10:
                sec=0
        else:
            sec=int(math.floor((t-tsec*100)/10))
    else:
        tsec=int(math.floor((t-min*600)/100))
        sec=int(math.floor((t-min*600-tsec*100)/10))
    time=str(min) + ":" + str(tsec)+str(sec)+ "." + str(th_sec)
    return time 

# define event handlers for buttons; "Start", "Stop", "Reset"
def bstart():
    timer.start()
    global is_running
    is_running=True

def bstop():
    timer.stop()    
    global x,y
    global is_running
    if is_running==True:
        is_running=False
        y+=1
        if count % 10==0:
            x+=1    
    
def breset():
    timer.stop()
    global is_running
    is_running=False
    global count,x,y
    count=0
    x=0
    y=0

# define event handler for timer with 0.1 sec interval
def tick():
    global count
    count += 1
    
# define draw handler
def draw(canvas):
    global time
    time=format(count)
    canvas.draw_text(time, [200,150], 36, "White")
    canvas.draw_text(str(x)+"/"+str(y), [350,20], 24, "Blue")
# create frame
f = simplegui.create_frame("Stop Watch", 400, 300)

# register event handlers
f.add_button("Start", bstart, 100)
f.add_button("Stop", bstop, 100)
f.add_button("Reset", breset, 100)
f.set_draw_handler(draw)
timer = simplegui.create_timer(interval, tick)

# start frame
f.start()

# Please remember to review the grading rubric
