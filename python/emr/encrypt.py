import base64, sys, npre

pre = npre.bbs98.PRE()

publicKey = base64.b64decode(sys.argv[1])
encrypted_message = pre.encrypt(publicKey, sys.argv[2])
print(base64.b64encode(encrypted_message))