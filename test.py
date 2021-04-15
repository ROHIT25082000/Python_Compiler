import subprocess as sp
import time
name = "input"
ext = ".txt"
for i in range(1,10):
    sp.run("clear -x",shell=True)
    sp.run("cat < "+name+str(i)+ext, shell=True)
    time.sleep(5)
    sp.run("./python.out <"+name+str(i)+ext, shell=True)
    time.sleep(10)
    sp.run("clear -x",shell=True)

sp.run("clear -x",shell=True)
print("All test case passed !!!!!")

