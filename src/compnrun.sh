clear
if [ "$1" == "-r" ]; then
    GTK_DEBUG=interactive ./run
elif [ "$1" == "-rnd" ]; then
    ./run
else
    valac --pkg=json-glib-1.0 --pkg=gtk+-3.0 --pkg=granite Application.vala */*.vala */*/*.vala -o run && \
    GTK_DEBUG=interactive ./run
fi
