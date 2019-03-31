/*
* Copyright (c) {{yearrange}} Alex ()
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 2 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Alex Angelou <>
*/
using Granite;
using Granite.Widgets;
using Gtk;

namespace Contacts  {
    public class InfoSection  : Gtk.Box {

        public signal void changed (string text);
        public signal void info_changed ();

        private ListBox list_box = new Gtk.ListBox ();
        private int population = 0;
        private bool segmented = false;
        private bool misc = false;
        private string[] placeholders = null;

        public InfoSection (string title) {
            create (title);
        }

        public InfoSection.for_misc (string title) {
            misc = true;
            create (title);
        }

        public InfoSection.with_segmented_entries (string title, string[] placeholders) {
            this.placeholders = placeholders;
            segmented = true;
            create (title);
        }

        private void create (string title) {
            this.set_orientation (Gtk.Orientation.VERTICAL);
            this.set_spacing (0);

            var label = new Gtk.Label (null);
            label.set_markup (@"<b>$title</b>");
            label.xalign = 0;
            label.margin = 6;
            label.get_style_context ().add_class (Granite.STYLE_CLASS_H3_LABEL);

            var add_button = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.BUTTON);
            add_button.margin = 6;
            add_button.clicked.connect (() => {
                if (segmented) {
                    var data = new string[placeholders.length];
                    new_entry_segmented (data, DataTypes.DEFAULT);
                } else {
                    if (misc)
                        new_entry ("", DataTypes.MISC.DEFAULT);
                    else
                        new_entry ("", DataTypes.DEFAULT);
                }
            });

            var label_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
            label_box.pack_start (add_button, false, false, 0);
            label_box.pack_start (label, false, false, 0);

            this.pack_start (label_box, false, false, 0);
            this.pack_start (list_box, false, false, 0);
            this.get_style_context ().add_class ("transparent_background");
            this.margin = 12;
            this.get_style_context ().add_class (Granite.STYLE_CLASS_CARD);
        }

        public void new_entry (string data, string type) {
            if (!segmented) {
                var entry = new EditableLabel (data, type);
                _new_entry (entry);
            }
        }

        public void new_entry_segmented (string[] data, string type) {
            if (segmented) {
                var entry = new EditableLabelSegmented (data, placeholders, type);
                _new_entry (entry);
            }
        }

        private void _new_entry (EditableWidget entry) {
            string data;

            if (misc) {
                entry.get_menu ().clear ();
                foreach (var type in DataTypes.MISC.ALL) {
                    entry.get_menu ().append (type);
                }
            }

            data = entry.get_text ();

            population++;


            if (population == 1) {
                changed (entry.get_text ());
                entry.changed.connect (() => {
                    changed (entry.get_text ());
                    info_changed ();
                });
            } else {
                entry.changed.connect (() => {
                    info_changed ();
                });
            }

            var row = new Gtk.ListBoxRow ();
            row.set_selectable (false);
            row.get_style_context ().add_class ("transparent_background");
            row.set_name (data + "_row");
            entry.margin = 6;
            row.add (entry);

            entry.get_delete_button ().clicked.connect (() => {
                remove_entry ((ListBoxRow) entry.get_parent ());
            });

            var separator = new Gtk.Separator (Gtk.Orientation.HORIZONTAL);

            list_box.add (separator);
            list_box.add (row);
            list_box.show_all ();
        }

        public Gtk.ListBox get_list_box () {
            return list_box;
        }

        public void remove_entry (Gtk.ListBoxRow sender) {
            list_box.remove (list_box.get_row_at_index (sender.get_index () - 1));
            list_box.remove (sender);
            population--;
            if (population == 0) {
                changed ("");
            }
        }

        public string[] get_info () {
            var list = new List<string> ();
            var separator = true;
            foreach (Gtk.Widget? child in list_box.get_children ()) {
                if (!separator) {
                    string type_text, info_text;
                    type_text = ((EditableWidget) ((Gtk.Bin) child).get_child ()).get_type_text ();
                    info_text = ((EditableWidget) ((Gtk.Bin) child).get_child ()).get_text ();
                    if (!misc) {
                        list.append (type_text + " " + info_text);
                    } else {
                        switch (type_text) {
                            //case "Birthday":
                            //    list.append ("BDAY:" + info_text);
                            //    break;
                            case DataTypes.MISC.NICKNAME:
                                list.append ("NICKNAME;CHARSET=UTF-8:" + info_text);
                                break;
                            case DataTypes.MISC.WEBSITE:
                                list.append ("URL;CHARSET=UTF-8:" + info_text);
                                break;
                            default:
                                print (type_text + "++++++++++++++++++++++++++++++++++++\n");
                                list.append ("NOTE;CHARSET=UTF-8:" + info_text);
                                break;
                        }
                    }
                    separator = true;
                } else {
                    separator = false;
                }
            }
            var array = new string [list.length ()];
            for (int i=0; i<list.length (); i++) {
                array [i] = list.nth_data (i);
            }
            return array;
        }

        public string[] get_info_vcard () {
            string[] array;
            if (segmented) {
                var list = new List<string> ();
                var separator = true;
                foreach (Gtk.Widget? child in list_box.get_children ()) {
                    if (!separator) {
                        string type_text, info_text;
                            type_text = ((EditableLabelSegmented) ((Gtk.Bin) child).get_child ()).get_type_text ();
                            info_text = ((EditableLabelSegmented) ((Gtk.Bin) child).get_child ()).get_text ();
                        list.append (type_text + " " + info_text);
                        separator = true;
                    } else {
                        separator = false;
                    }
                }
                array = new string [list.length ()];
                for (int i=0; i<list.length (); i++) {
                    array [i] = list.nth_data (i);
                }
            } else {
                array = get_info ();
            }
            return array;
        }
    }
}
