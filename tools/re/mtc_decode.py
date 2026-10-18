"""Try decoding an MTK thermal policy file: char = plain + (index % 10), wrapping in 0x20..0x7a."""
import sys

LO, HI = 0x20, 0x7A

def decode_line(line: str) -> str:
    out = []
    for i, ch in enumerate(line):
        p = ord(ch) - (i % 10)
        if p < LO:
            p += HI - LO + 1
        out.append(chr(p))
    return "".join(out)

with open(sys.argv[1], "r", encoding="latin-1", newline="") as f:
    for raw in f.read().split("\r\n"):
        print(decode_line(raw))
