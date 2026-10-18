"""Print array resources (default config) from a resources.arsc, with no dependencies."""
import re, struct, sys

data = open(sys.argv[1], "rb").read()
pattern = re.compile(sys.argv[2] if len(sys.argv) > 2 else ".", re.I)

def string_pool(off):
    _, hs, _ = struct.unpack_from("<HHI", data, off)
    count, _, flags, start, _ = struct.unpack_from("<5I", data, off + 8)
    out = []
    for o in struct.unpack_from(f"<{count}I", data, off + hs):
        p = off + start + o
        if flags & 0x100:  # UTF-8: utf16 length, then utf8 length (each 1-2 bytes)
            p += 2 if data[p] & 0x80 else 1
            n = data[p]; p += 1
            if n & 0x80:
                n = ((n & 0x7F) << 8) | data[p]; p += 1
            out.append(data[p:p + n].decode("utf-8", "replace"))
        else:
            n = struct.unpack_from("<H", data, p)[0]; p += 2
            out.append(data[p:p + 2 * n].decode("utf-16le", "replace"))
    return out

_, table_hs, _ = struct.unpack_from("<HHI", data, 0)
values = string_pool(table_hs)
pkg = table_hs + struct.unpack_from("<HHI", data, table_hs)[2]
_, pkg_hs, pkg_size = struct.unpack_from("<HHI", data, pkg)
type_off, _, key_off = struct.unpack_from("<3I", data, pkg + 268)
types, keys = string_pool(pkg + type_off), string_pool(pkg + key_off)

off = pkg + pkg_hs
while off < pkg + pkg_size:
    ctype, hs, size = struct.unpack_from("<HHI", data, off)
    if ctype == 0x0201:
        tid, _, _, count, entries = struct.unpack_from("<BBHII", data, off + 8)
        cfg_size = struct.unpack_from("<I", data, off + 20)[0]
        default = not any(data[off + 24:off + 20 + cfg_size])
        if types[tid - 1] == "array" and default:
            for o in struct.unpack_from(f"<{count}I", data, off + hs):
                if o == 0xFFFFFFFF:
                    continue
                e = off + entries + o
                esize, eflags, key = struct.unpack_from("<HHI", data, e)
                if not eflags & 1 or not pattern.search(keys[key]):
                    continue
                n = struct.unpack_from("<I", data, e + 12)[0]
                items = []
                for i in range(n):
                    _, _, _, dtype, val = struct.unpack_from("<IHBBI", data, e + esize + 12 * i)
                    items.append(values[val] if dtype == 0x03 else str(val))
                print(f"{keys[key]} ({n}): {', '.join(items)}")
    off += size
