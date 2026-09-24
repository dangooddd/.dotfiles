import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
source = path.read_bytes()
converted = re.sub(rb"\\[\[\]]", b"$$", source)

if converted != source:
    path.write_bytes(converted)
