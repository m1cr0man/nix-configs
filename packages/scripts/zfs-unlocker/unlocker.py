from subprocess import Popen, PIPE, TimeoutExpired
from getpass import getpass
from shlex import split
from time import sleep
from pathlib import Path
from sys import argv

def main():
  pwdfile = Path(argv[1])
  idfile = Path(argv[2])
  host = argv[3]
  port = argv[4] if len(argv) == 5 else 6416
  passwd = pwdfile.read_bytes().strip()
  while True:
    proc = Popen(split(
      f"ssh -o ConnectTimeout=10 -o ConnectionAttempts=1 -i {idfile}"
      f" -p {port} {host}"
    ), stdin=PIPE)
    try:
      proc.communicate(input=passwd, timeout=15)
      if proc.returncode is None:
        proc.kill()
      sleep(60)
    except TimeoutExpired:
      print("Timed out")

if __name__ == '__main__':
  main()
