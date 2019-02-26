import npre, base64, sys
pre = npre.bbs98.PRE()

base64_private_key_a = base64.b64decode(sys.argv[1])
base64_private_key_b = base64.b64decode(sys.argv[2])

re_ab = pre.rekey(base64_private_key_a, base64_private_key_b)

print(base64.b64encode(re_ab))