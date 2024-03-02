import threading
import sys
import time
def print_numbers():
    for i in range(1, 6):
        time.sleep(0.1)
        print('Number:', i)
        sys.stdout.flush()
def print_letters():
    for letter in 'abcde':
        time.sleep(0.1)
        print('Letter:', letter)
        sys.stdout.flush()
thread1 = threading.Thread(target=print_numbers)
thread2 = threading.Thread(target=print_letters)
thread1.start()
thread2.start()
thread1.join()
thread2.join()
print('Threads are done!')
sys.stdout.flush()
time.sleep(1)