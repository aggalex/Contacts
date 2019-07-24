# Contacts
An easy contact manager for elementary OS (Beta State, fairly unstable)

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

### Beta state TODO:
- Translating
- Hardening stability
- proper error handling
- options menu
- tooltips
- autosaving
- defensive importing/exporting

List might grow according to the needs of the development. When the list is exhausted, the app will go in RC state, to smooth out any inconsistencies, and then the app will be released in appcenter.

### Release Date
> <i>When it's ready</i> ~~ <br><sup>- The elementary team
