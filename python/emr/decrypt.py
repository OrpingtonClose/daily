import npre, base64, sys
pre = npre.bbs98.PRE()

private_key = base64.b64decode(sys.argv[1])
encrypted_message = base64.b64decode(sys.argv[2])

decrypted_message = pre.decrypt(private_key, encrypted_message)

print(decrypted_message)
