"""
Wolfram Cellular Automata by Daniel Shiffman.

Simple demonstration of a Wolfram 1-dimensional cellular automata
When the system reaches bottom of the window, it restarts with a new ruleset
Mouse click restarts as well. 
"""

class CA:
    
    def __init__(self, dead_rules, live_rules, bredth = 1):
        self.dead_rules = dead_rules
        self.live_rules = live_rules
        self.scl = 1    # How many pixels wide/high is each cell?
        self.cells = [0] * int(width / self.scl)
        self.bredth = bredth
        self.restart()  # Sets self.generation to 0, only middle cell to 1

     #Make a random ruleset
    def randomize(self):
        for i in range(8):
            self.cells[i] = [int(random(2)) for state in range(0, 1+int(width / self.scl))] 

    # Reset to generation 0
    def restart(self):
        for i in range(len(self.cells)):
            self.cells[i] = 0

        # We arbitrarily start with just the middle cell having a state of "1"
        self.cells[len(self.cells) / 2] = 1
        self.generation = 0

    # The process of creating the new generation
    def generate(self):
        nextgen = [0] * len(self.cells)
        #print(len(self.cells))
        
        for i in range(1, len(self.cells) - self.bredth):
            life_sum = 0
            me = self.cells[i]
            for neighbour in range(-self.bredth, self.bredth + 1):
                life_sum += self.cells[i + neighbour]
            life_sum -= me

            if me == 0:
                if  me == 0 and life_sum in self.live_rules():
                    nextgen[i] = 1
                else:
                    nextgen[i] = 0
            else:
                if me == 1 and life_sum in self.dead_rules():
                    nextgen[i] = 1
                else:
                    nextgen[i] = 0
                    
        # Copy the array into current value
        for i in range(1, len(self.cells) - 1):
            self.cells[i] = nextgen[i]

        self.generation += 1

    # This is the easy part, just draw the cells, 
    # fill 255 for '1', fill 0 for'0'
    def render(self):
        scl = self.scl
        for i in range(len(self.cells)):
            if (self.cells[i] == 1):
                fill(255)
            else:
                fill(0)

            noStroke()
            rect(i * scl, self.generation * scl, scl, scl)

    # The CA is done if it reaches the bottom of the screen
    def finished(self):
        if self.generation > height / self.scl:
            return True
        else:
            return False

def setup():
    global ca
    size(640, 360)
    #ca = CA(dead_rules = lambda: [0,2,5,6,7,8], live_rules = lambda: [1,4], bredth = 5)                    # Initialize CA
    # Cellular automata for rules?
    def dead_rule_fun():
        times = [0, 10]
        def exec_rule():
            times[0] += 1
            if times[0] >= 25:
                times[0] = 20
                
            if times[1] == 10:
                times[1] = 25
            else:
                times[1] = 10
            return [int(random(times[1])) for state in range(0, times[0])]
        return exec_rule
            

    ca = CA(dead_rules = dead_rule_fun(), 
            live_rules = lambda: range(0, 2), 
            bredth = 10)                    # Initialize CA
    #ca = CA(dead_rules = lambda: range(4, 20,2), live_rules = lambda: [0,1,2,3], bredth = 10)                    # Initialize CA
    background(0)


def draw():
    ca.render()      # Draw the CA
    ca.generate()    # Generate the next level

    # If we're done, clear the screen, pick a new ruleset and restart
    if ca.finished():
        background(0)
        ca.randomize()
        ca.restart()

def mousePressed():
    background(0)
    #ca.randomize()
    ca.restart()