# Contacts
An easy contact manager for elementary OS (RC State)

<p align="center">
    <img  src="https://github.com/aggalex/Contacts/blob/master/data/Images/Screenshot.png" alt="Screenshot"> <br>
</p>

### Building
Dependencies:
- `git`
- `elementary-sdk` 
- `libfolks-dev`

After installing all the required dependecies, you can build Contacts using:
```
git clone https://github.com/aggalex/Contacts.git com.github.aggalex.Contacts && cd com.github.aggalex.Contacts
meson build --prefix=/usr
cd build
ninja
sudo ninja install
```

### Release Date
> In the forthcoming future!
