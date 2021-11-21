# Contacts
An easy contact manager for elementary OS (RC State)

<p align="center">
    <img  src="https://github.com/aggalex/Contacts/blob/master/data/Images/Screenshot.png" alt="Screenshot"> <br>
</p>

### Dependencies:
- `git`
- `elementary-sdk`
- `libfolks-dev`

### Building
After installing all the required dependecies, you can build Contacts using:
```
git clone https://github.com/aggalex/Contacts.git com.github.aggalex.Contacts && cd com.github.aggalex.Contacts
meson build --prefix=/usr
cd build
ninja
sudo ninja install
```

### Debian Package Building
After installing all the required dependecies, you can build a deb package of contacts Contacts using:
```
mkdir Contacts && cd Contacts
git clone https://github.com/aggalex/Contacts.git com.github.aggalex.Contacts && cd com.github.aggalex.Contacts
dpkg-buildpackage -us -uc
```
After the last command, the debian package will exist into the "Contacts" folder that the first command created (the one containing the folder "com.github.aggalex.contacts" that contains the source code)

### Flatpak Building

To build a `flatpak` package you must be sure you can build the project and
have installed the SDK, e.g. by
```
flatpak install --user io.elementary.Sdk//6
```

Then you can generate the `flatpak` package in the `repo` directory by running

```
flatpak-builder --repo=repo --force-clean build-dir com.github.aggalex.contacts.yml
```

### Release Date
> In the forthcoming future!
