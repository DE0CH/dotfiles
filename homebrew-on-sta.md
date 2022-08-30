# Proposal to Installing Homebrew on the school's lab machines

## Introduction 
Usually, updating and installing new packages on a multi-user shared computer such as the ones in the lab require admin access and have a lot of security and stability concerns. But at the same time, software development often needs access to updated and new packages. Striving the balance is difficult because contacting the admin can take some time, downloading and building packages from source sometimes would just not work, and podman can add a lot of system overhead and requires extra configurations. Fortunately, we can use a rootless package manager, which achieves the perfect balance between user control and the security of the system. Therefore, I would like to propose that we install homebrew, a package manager, on the lab machines. 

Using homebrew does not require any privileged access to the host computer. It works by installing binaries in a custom location, or builds them from source, linking the package together and modifying the `PATH`. Another advantage of using homebrew is that it is completely optional, as the user can choose to opt in by adding a few lines of configuration (technical details will be explored later), otherwise there is no change to the behavior of the system. This means that homebrew would not replace or conflict with any other package manager -- nothing will break and the security and stability of the system will not be compromised at all. Homebrew is also extremely user friendly because if the user chooses to use homebrew, it works completely transparently to them: they can just, for example, run `brew install python3` to install a newer version of python and run it with `python3` with no extra steps. Provided that users play nicely with each other, we can let them share the same library of packages and manage the update and installation collectively.

## Technical Overview

By default, homebrew stores everything in `/home/linuxbrew/.linuxbrew` (called the homebrew prefix) and uses `/tmp` as a temporary build directory. Creating the `/home/linuxbrew` directory, and giving write permission to whoever is using homebrew is the only time when privileged access is required. Homebrew can also be installed in other directories as well (such as a user's home directory) but that is not recommended because packages would have to be built from source, and the packages are not rigorously tested to work in this configuration (though they should just work almost all the time). 

Although homebrew is not designed to be used by multiple users (most packages managers are not), it can be as long as the users using it have read and write access to the homebrew prefix. However, just giving everyone write permission is not ideal because among other things, whoever installs a package would own the files and directories of the newly installed package, making it hard for other people to use and update the package. A solution for this problem is to create a user, say `linuxbrew`, that everyone can login to and manage the homebrew packages. This can be achieved by giving authorized users and groups to switch to the user with sudo. 

After the installation is complete, users who want to use homebrew can modify their environment variable including path, and adding a alias to execute `brew` as `linuxbrew` when they type `brew` in the terminal. 

## Example Installation Procedure

The exact installation procedure obviously depends on the configuration of the system, so I aim to illustrate the steps to install homebrew and the caveats in a form that is easily adaptable to different situations. 

1. Create a new user named `linuxbrew`, making sure it uses `bash` (instead of `sh`) as the login shell. In my testing, `sh` would not work for some reason but I am not sure why. 

```bash
useradd -m linuxbrew -s /bin/bash
```

2. Run the installation script [https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh](https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh) as `linuxbrew` with the environmental variable `NONINTERACTIVE=1`. Sudoers and users except for root who have write access to `/home/linuxbrew` can also run it. 

```bash
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

3. Change the ownership of everything under (and including) `/home/linuxbrew` to `linuxbrew:linuxbrew` if not done so already. Also make sure `linuxbrew` has write permission, which should be should be the case if you have run the script.

```bash 
chown -R linuxbrew /home/linuxbrew
chgrp -R linuxbrew /home/linuxbrew
```

4. Allow authorized users to login to act as `linuxbrew` with sudo. n.b. it is not enough to simply allow the user to run the brew executable because sudo by default runs the command with `sh` but homebrew needs `bash` to work. This can be achieved by adding a line to `/etc/sudoers`.

```
%students ALL=(linuxbrew:linuxbrew) NOPASSWD:ALL
```

5. Give everyone read and execute permission to `/home/linuxbrew` and `/home/linuxbrew/.linuxbrew`, so they can use the install packages as their own user. It is not recommended to instead add everyone to the `linuxbrew` group because people can inadvertently write into the `.linuxbrew` directory with files owned by them, for example with `pip3 install`. 

```
chmod a+rx /home/linuxbrew /home/linuxbrew/.linuxbrew
```

Once homebrew is installed and configured, the user can opt into using homebrew by adding the following two lines to their `~/.profile`. The first line puts the exports brew's environment variable including a modified path that includes the homebrew bin. The second line makes it more transparent for users to use homebrew. 

```
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
alias brew='sudo -iu linuxbrew /home/linuxbrew/.linuxbrew/bin/brew'
```

The `-i` option in sudo (in combination with setting `bash` as `linuxbrew`'s login shell) is important because without it, the command uses `sh`, with which homebrew will not work properly.

It is also important to use the absolute path for homebrew in the command because the homebrew bin is not in the `PATH` of `linuxbrew`.

## Security Considerations

Installing homebrew does not change the system in any way and will not affect anything not using homebrew because everything is contained in the homebrew prefix and it will not be used by default. 

There are concerns with multiple user sharing the same installation of homebrew. The usability of homebrew depends on people respecting each other. If someone does not play nicely, at best people's code will break before someone manages to fix it and at worst some malicious actor can replace packages with malicious code to steal data. However, since everyone using the system is in the school and people are generally quite nice (we allow people to share cpu time without a quota system), I am confident that the installation of homebrew will be properly maintained by the community. 

## Personal Homebrew 

The one last concern it that homebrew packages can modified and updated by anyone. This usually doesn't cause a problem because most packages are fairly backward compatible. But for any snowflake or legacy application that breaks easily, there is always podman available. Alternatively, each user can choose to install their own copies of homebrew in their home folder, though they have to build packages from source or rely on an experimental feature by setting `HOMEBREW_RELOCATE_BUILD_PREFIX` to the installation path of homebrew. 

## Reference
1. [https://www.codejam.info/2021/11/homebrew-multi-user.html](https://www.codejam.info/2021/11/homebrew-multi-user.html)
2. [https://docs.brew.sh/Installation](https://docs.brew.sh/Installation)
3. [https://docs.brew.sh/Homebrew-on-Linux](https://docs.brew.sh/Homebrew-on-Linux)