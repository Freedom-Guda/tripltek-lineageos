"""Minimal flattened-device-tree dumper (dts-like text), no dtc needed."""
import string, struct, sys

data = open(sys.argv[1], "rb").read()
magic, total, off_struct, off_strings = struct.unpack_from(">4I", data, 0)
assert magic == 0xD00DFEED, "not a DTB"
PRINTABLE = set(string.printable.encode()) - set(b"\t\n\r\x0b\x0c")

def fmt(val: bytes) -> str:
    if not val:
        return ""
    parts = val.split(b"\0")
    if val.endswith(b"\0") and all(p and set(p) <= PRINTABLE for p in parts[:-1]):
        return " = " + ", ".join(f'"{p.decode()}"' for p in parts[:-1])
    if len(val) % 4 == 0:
        return " = <" + " ".join(f"0x{c:x}" for c in struct.unpack(f">{len(val)//4}I", val)) + ">"
    return " = [" + val.hex(" ") + "]"

pos, depth = off_struct, 0
while True:
    tok = struct.unpack_from(">I", data, pos)[0]; pos += 4
    if tok == 1:
        end = data.index(b"\0", pos); name = data[pos:end].decode() or "/"
        print("  " * depth + name + " {"); depth += 1
        pos = (end + 4) & ~3
    elif tok == 2:
        depth -= 1; print("  " * depth + "};")
    elif tok == 3:
        ln, nameoff = struct.unpack_from(">2I", data, pos); pos += 8
        pname = data[off_strings + nameoff:data.index(b"\0", off_strings + nameoff)].decode()
        print("  " * depth + pname + fmt(data[pos:pos + ln]) + ";")
        pos = (pos + ln + 3) & ~3
    elif tok == 4:
        continue
    elif tok == 9:
        break
    else:
        raise SystemExit(f"bad token {tok} at {pos}")
