# Conky Script

I use multiple computers with slightly different setups and CPU core counts
so it made sense to to generate the conkyrc on the fly and then pipe it in
to conky.  It only handles creating miltiple instances of conky (1 par
connected monitor and organising the multiple CPU counts.

# Requirements

The script requires that smartctl be installed (see my ubuntu setup script).
The user running conky be added to the disk group and the following line 
added to the end of the `/etc/sudoers` file:

```
%disk     ALL=(ALL:ALL) NOPASSWD: /usr/sbin/smartctl
```

# To Do

* Automate connected drives.
