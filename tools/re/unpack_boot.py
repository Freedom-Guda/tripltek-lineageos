"""Split an Android v0/v1 boot image into kernel (decompressed if gzip), appended DTBs and ramdisk."""
import gzip, struct, sys, zlib
from pathlib import Path

img, out = Path(sys.argv[1]).read_bytes(), Path(sys.argv[2])
out.mkdir(parents=True, exist_ok=True)
assert img[:8] == b"ANDROID!", "not an Android boot image"
ksize, _, rsize, _, ssize, _, _, page, hver = struct.unpack_from("<9I", img, 8)
cmdline = img[64:576].split(b"\0")[0] + img[608:1632].split(b"\0")[0]
(out / "cmdline.txt").write_bytes(cmdline + b"\n")
koff = page
roff = koff + -(-ksize // page) * page
kernel, ramdisk = img[koff:koff + ksize], img[roff:roff + rsize]
(out / "ramdisk.bin").write_bytes(ramdisk)
print(f"header v{hver}, page {page}, kernel {ksize}, ramdisk {rsize}")
if kernel[:2] == b"\x1f\x8b":
    d = zlib.decompressobj(16 + zlib.MAX_WBITS)
    (out / "Image").write_bytes(d.decompress(kernel))
    tail = d.unused_data
    print(f"gzip kernel -> Image, {len(tail)} trailing bytes")
else:
    (out / "Image").write_bytes(kernel)
    tail = b""
for n, off in enumerate(i for i in range(len(tail)) if tail[i:i + 4] == b"\xd0\x0d\xfe\xed"):
    size = struct.unpack_from(">I", tail, off + 4)[0]
    (out / f"dtb{n}.dtb").write_bytes(tail[off:off + size])
    print(f"dtb{n}: {size} bytes")
