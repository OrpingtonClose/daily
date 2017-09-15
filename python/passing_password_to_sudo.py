#https://docs.python.org/2/library/subprocess.html
#https://www.safaribooksonline.com/library/view/the-python-3/9780134291154/ch10.html
#https://www.sudo.ws/man/1.8.18/sudo.man.html

from subprocess import Popen, PIPE

#Use a custom password prompt with optional escape sequences. The following percent (‘%’) escape sequences are supported by the sudoers policy: 
sudo_prompt = "-p"

#When used without a command, invalidates the user's cached credentials. In other words, the next time sudo is run a password will be required. This option does not require a password and was added to allow a user to revoke sudo permissions from a .logout file.
#When used in conjunction with a command or an option that may require a password, this option will cause sudo to ignore the user's cached credentials. As a result, sudo will prompt for a password (if one is required by the security policy) and will not update the user's cached credentials.
#Not all security policies support credential caching.
sudo_reset_timestamp = "-k"

#Write the prompt to the standard error and read the password from the standard input instead of using the terminal device. The password must be followed by a newline character.
sudo_stdin = "-S"

bash_command_stub = ["sudo", sudo_prompt, sudo_reset_timestamp, sudo_stdin, "apt-get"]
bash_command_update = bash_command_stub + ["update"]
bash_command_upgrade = bash_command_stub + ["upgrade", "-y"]

password = b"<this password isn't real>"
password_passable = password + b"\n"

update = Popen(bash_command_update, stdout=PIPE, stdin=PIPE, stderr=PIPE)
update_stdout, update_stderr = update.communicate(password_passable) 
if update_stdout:
  print(update_stdout.decode("utf-8").replace("\n", "\nstdout> "))

if update_stderr:
  print(update_stderr.decode("utf-8").replace("\n", "\nstdout> "))


upgrade = Popen(bash_command_upgrade, stdout=PIPE, stdin=PIPE, stderr=PIPE)
upgrade_stdout, upgrade_stderr = upgrade.communicate(password) 

if upgrade_stdout:
  print(upgrade_stdout.decode("utf-8").replace("\n", "\nstdout> "))
if upgrade_stderr:
  print(upgrade_stderr.decode("utf-8").replace("\n", "\nstderr> "))

# print(upgrade_with_password.stdout.read())

