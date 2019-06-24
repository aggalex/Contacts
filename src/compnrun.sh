clear
if [ "$1" != "-r" ]; then
    valac --pkg=gtk+-3.0 --pkg=granite Application.vala */*.vala */*/*.vala -o run && \
    GTK_DEBUG=interactive ./run
else 
    GTK_DEBUG=interactive ./run
fi
