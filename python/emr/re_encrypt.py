import npre, base64, sys
pre = npre.bbs98.PRE()
re_encrypt_key = base64.b64decode(sys.argv[1])
encrypted_message = base64.b64decode(sys.argv[2])
re_encrypted_message = pre.reencrypt(re_encrypt_key, encrypted_message)
print(base64.b64encode(re_encrypted_message))