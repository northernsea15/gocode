import os
import time

while 1:
  try:
    f = open("/tmp/gm_set_date.txt")
    d = f.readline()
    cmd = "date -s '%s'" % d
    os.system(cmd) 
    f.close()
    os.remove("/tmp/gm_set_date.txt")
  except IOError:
    pass
    #print("File not accessible")
   
  time.sleep(1)
