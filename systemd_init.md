# Init and systemd

## Init

System managing daemon `sysV` or `systemd` has always PID = 1.

sysV (init) - only one process at once while booting, obsolete, replaced by systemd.

Program: /sbin/init

Each service has a number and this number indicates order of starting services.In systemd order is written in
start-scripts (services can start simultaneously).

init is still used in distributions focused on small size.

`runlevel` - shows current runlevel (0-6)

N- runlevel was not changed since the system was booted

```sh
runlevel [0-6]  -changes the actual runlevel

0- halt
1- single user (text) mode (s or single) without network or other non-essential capabilities (maintenance mode)
2- not used (user definable)
3- full multi-user text mode, users can log in by network or console, all filesystems are mounted, alle services are started, no GUI
4- not used (user definable)
5- full multi-user graphical mode, like 3 but with GUI
6- reboot
```

```sh
Init supervise many startup porcesses:
-setting hostname
-setting locales
-fs check
-mounting filesystms
-deleting files from /tmp
-setting networking
-applying firewall rules
-starting daemons and other services.
```

`/etc/inittab` - stored definition of runlevels and default runlevel

id:runlevels:action:process

The action term defines how init will execute the process indicated by the term process.

The available actions are:

- `boot` - the process will be executed during system initialization. The field runlevelsis ignored.
- `bootwait`   -The process will be executed during system initialization and init will  wait  until  it  finishes  to continue. The field runlevels is ignored.
- `sysinit`    -The process will be executed after system initialization, regardless of runlevel. The field runlevels is ignored.
- wait       -The process will be executed for the given runlevels and init will wait until it finishes to continue.
- `respawn`    -The process will be restarted if it is terminated.
- `ctrlaltdel` -The process will be executed when the init process receives the SIGINT signal, triggered when the key sequence of Ctrl+Alt+Del is pressed.

telinit [runlevel number] -set the actual runlevel (telinit 0 makes poweroff)
telinit q   -reload init configuration (after any changes in /etc/inittab)

/etc/init.d -directory, stores scripts that init is using to setup each runlevel
Every runlevel has an associated directory in /etc/, named /etc/rc0.d/, /etc/rc1.d/, /etc/rc2.d/, etc., 
with the scripts that should be executed when the corresponding runlevel starts. 
As the same script can be used by different runlevels, the files in those directories are just symbolic links to the actual scripts in/etc/init.d/. 

## systemd

Init don`t have services dependencies management. All scripts that starts and stops services must run in order given by administrator.
New tasks must started when last task ends. They cant start simultaneously.

Systemd manages: processes, network connections (networkd), kernel journal entries (journald) and loggins (logind).
Systemd in not a single daemon, it is a set of programs, daemons, libraries, technologies and kernel components (modules).
Systemd can listen on service port or IPC connection points and sleep services when it is not used or awake them when client will try to connect. 

Systemd units -objects that systemd can manage, consists of a name, a type and a corresponding configuration file.

systemctl list-units            -list active units
--type=service                  -list only services
--type=target                   -list only targets
--state=running                 -only running services

systemctl list-unit-files       -list all units

Unit files in case of service includes: path to daemon binary, informs how to start and stop service, defines all other services dependencies.

Configuration files location depends of distro:
/etc/systemd/system     #your local unit files, the highest priority
/lib/systemd/system     #do not modify (spare files)
/usr/lib/systemd/system #do not modify (spare files)
/run/systemd/system     #tempolary unit files

systemd unit types:
-service    -system resources that can be initiated, interrupted and reloaded
-socket     -may be a filesystem socket or network socket, always have corresponding service unit, loaded whet the socked receives a request
-device     -is associated with hardware device (identified by the kernel), device will be an unit only when udev rule for this purpose exist
-mount      -mount point definition, similar to the /etc/fstab, have .mount extension
-automount  -mount point definition mounted automaticly, always have corresponding mount unit which is initiated when the automount mount point is accessed
-target     -grouping other units, managed as a single units
-snapshot   -saved state of systemd manager (not in every linux distribution)

SYSTEMCTL - managing units:

systemctl                                       -by default list units
systemctl start/stop/restart unit.service       -start/stop/restart
systemctl status unit.service                   -shows status of unit, without unit will list all servicess, -l -journal entries in full form
systemctl enable/disable unit.service           -run service after boot
systemctl is-enabled unit.service               -check status of enable/disable
systemctl kill unit.service                     -send signal to unit

Statuses:
bad         -error, usually problem in unit file
disabled    -present, but not configured to autostart, may works now (start command) 
enabled     -autostart on, Install directive works
indirect    -unactive, has Also entries
linked      -unit file available by symbolic link (file from another system)
static      -used by another unit, do not have Install directive, may be started manually or started as dependencies by another service
masked      -do not depends on systemd, disabled static unit (systemctl mask)

System TARGET files (replaces SysV Init Runlevels). 
They allow to start system with only needed services (units) depends of server purpose. 

Historical dependencies from init to systemd:
Runlevel:   Target:             Description:
0           poweroff.target     shutdown
emergency   emergency.target    basic shell for recovery
1           rescue.targed       single user mode
2           multi-user.target   commandline
3           multi-user.target   multi-user mode with networking 
4           multi-user.target   usually unused by init
5           graphical.target    multi-user mode with networking and GUI
6           reboot.target       reboot

systemctl get-default                           -returns default target filename
systemctl isolate [name.target]                 -change target (runlevel) immediately
systemctl set-default [target.name]             -change default target 
systemctl reboot                                -reboot
systemctl daemon-reloaded                       -reload unit files nad systemd configuration
systemctl add-wants multi-user.target my-local-service.service  #adding my-local-srvice to multi-user target

New service:

```sh
#/etc/systemd/system/newservice.service

[Unit]
Description=Service name

[Service]
ExecStart=/path/to/script/script.sh

[Install]
WantedBy=multi-user.target
```

Add execute privilages to script and change owner to root!

```sh
sudo systemctl start newservice
sudo systemctl enable newservice
```

[Unit] section in target files (dependencies):
Wants       -units, that should be started with our service (but not required to start)
Requires    -units, that must be actived with our service (and still running)
Requisite   -units , that must be active before our service
BindsTo     -like Requires, but more connected
PartOf      -like Requires but must be started or stopped (can be off while our service works)
Conflicts   -negative dependencies, services cannot works simultaneously

Order:
systemd starts services simultaneously, except service has Before or After entries. 
Systemd using this entries makes a list of start order. 


[Install] section in target files:
WantedBy        -option readed only when service is enable or disable, systemctl runs add-wants for WantedBy entry
RequiredBy      -option readed only when service is enable or disable, systemctl runs add-requires for RequiredBy entry

Editing unit file:
create direcotry and file:
/etc/systemd/system/unit-file.d/override.conf

This file wil lhave higher priority than old target files. 
If the same option is present in more files systemd will make a group of this option entry. 
To delete this option from older files make an empty value in override.conf:
ExecStart=          #delete old entry 
ExecStart=/usr/sbin/nginx -c /usr/local/www/nginx.conf      #creates new entry 
Next systemctl daemon-reload and restart service

______________________________________________________________________________________________________________
systemctl poweroff      -shutdown
systemctl reboot        -restart

In some distributions commands like poweroff can be linked to systemctl poweroff.
wall- used to send information to users (f.eg. about restart)

shutdown [OPTIONS] [TIME (required)] [MESSAGE]
-h  -power off
-r -reset
-c -cancell

TIME: default= +1, +5, now, hh:mm

systemctl suspend   -put system in low power mode, keeping current data in memory
systemctl hibernate -copy all memory data to disk, that current state of the system can be restored after boot up

acpi daemon -main power manager for linux, features as hibernating, suspending, actions with laptop lid, battery chaning, etc. 
______________________________________________________________________________________________________________

/etc/sysctl.conf -changes written here will be done while booting
sysctl -p -lists commands written in sysctl.conf

### systemd user mode

systemctl --user

Requirements:

- the user systemd daemon must be started
- systemctl must be able to find it

when you log in to a shell, both of these things happen. systemd hooks the log in process to start the user daemon and
the paths systemctl needs are set in shell variables. It's also possible to set a user to permit lingering and allow the
user's systemd daemon to keep running even when the user isn't logged in to the shell. `su`, even when you `su -` or
`su--login`, does not set the variables for systemctl to find the user daemon. They get unset when `su` is executed ,
and it will result in `systemctl --user` completely failing.

How to work around this? You need to log in to the user via a process that creates a clean login environment. Classic
way is to SSH as the user. However, there's a newer and more direct way to do it. If your system is sufficiently up to
date to support systemd's `machinectl` command, you can `machinectl shell [username]@host`. This is kind of the "new su"
that is systemd aware and takes care of the background things that just running su can miss.

<https://www.reddit.com/r/linuxadmin/comments/rxrczr/in_interesting_tidbit_i_just_learned_about_the/>