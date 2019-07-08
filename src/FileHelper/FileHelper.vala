/*
* Copyright (c) {{yearrange}} Alex Angelou ()
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNEs FOR A PARTICULAR PURPOsE.  see the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free software Foundation, Inc., 51 Franklin street, Fifth Floor,
* Boston, MA 02110-1301 UsA
*
* Authored by: Alex Angelou <>
*/

namespace FileHelper {

    private string get_data_folder () {
        var data_folder = Granite.Services.Paths.xdg_data_home_folder.get_path ();

        if (!(data_folder.has_suffix ("Contacts"))) {
            var home_path = Environment.get_home_dir ();
            Granite.Services.Paths.initialize ("Contacts", Granite.Services.Paths.xdg_data_home_folder.get_path () + "Contacts");
            data_folder = Granite.Services.Paths.xdg_data_home_folder.get_path ();
        }

        print (data_folder);

        return data_folder;
    }

    private string get_file_path (string filename, string path_suffix) {
        var data_folder = get_data_folder ();

        var path_builder = new StringBuilder (data_folder);
        path_builder.append (path_suffix);
        path_builder.append ("/");
        path_builder.append (filename);

        return path_builder.str;
    }

    public void rename (string old_name, string new_name, string path_suffix = "") {
        var old_path = get_file_path (old_name, path_suffix);
        var new_path = get_file_path (new_name, path_suffix);

        FileUtils.rename (old_path, new_path);
    }

    public void save (string filename, string data, string path_suffix = "") throws IOError {
        var path = get_file_path (filename, path_suffix);

        File file = File.new_for_path (path);

        print (@"INSIDE SAVE: $path\n");

        FileOutputStream ostream = file.replace (null, true, FileCreateFlags.PRIVATE);
        ostream.write (data.data);
    }

    public string read (string filename, string path_suffix = "") throws Error {
        var path = get_file_path (filename, path_suffix);

        File file = File.new_for_path (path);

        var istream = new DataInputStream (file.read ());
        var builder = new StringBuilder ();
        for (var line = istream.read_line_utf8 (null); line != null; line = istream.read_line_utf8 (null)) {
            builder.append (line);
            builder.append ("\n");
        }
        return builder.str;
    }

}
