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

### Release Date
> In the forthcoming future!
