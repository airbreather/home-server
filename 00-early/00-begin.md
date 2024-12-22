# First thing to do

Directly on the server console:

- `passwd` to set the root password.
- `ip addr` to get the IP to SSH into.

Then SSH using that IP and proceed to the next step:

`ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@THE_IP`
