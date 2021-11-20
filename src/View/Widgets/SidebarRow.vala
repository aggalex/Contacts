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
// ++++++++++++++++++ Based on Granite.SettingsSidebarRow: ++++++++++++++++++
/*
* Copyright (c) 2017 elementary LLC. (https://elementary.io)
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU Lesser General Public License as published by
* the Free Software Foundation, either version 2.1 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Library General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*/

using Granite;
using Granite.Widgets;
using Gtk;

using ViewModel;

namespace View.Widgets {
    private class SidebarRow : Gtk.ListBoxRow {

        public Gdk.Pixbuf? default_image;
        public Image icon_image { get; private set; default = new Image (); }

        public string? header { get; set; }

        public ContactHandler handler { get; construct; }

        public string status {
            set {
                status_label.set_markup ("<span font_size='small'>%s</span>".printf (value));
                status_label.no_show_all = false;
                status_label.show ();
            }
        }

        public string title {
            get {
                return _title;
            }
            set {
                _title = value;
                title_label.label = value;
            }
        }

        private Gtk.Label status_label;
        private Gtk.Label title_label;
        private string _title;

        public SidebarRow (ContactHandler handler) {
            Object (
                handler: handler
            );
        }

        construct {
            title_label = new Gtk.Label (handler.name);
            title_label.ellipsize = Pango.EllipsizeMode.END;
            title_label.xalign = 0;
            title_label.get_style_context ().add_class ("h3");

            status_label = new Gtk.Label (null);
            status_label.use_markup = true;
            status_label.ellipsize = Pango.EllipsizeMode.END;
            status_label.xalign = 0;

            var overlay = new Gtk.Overlay ();
            overlay.width_request = 38;
            overlay.add (icon_image);

            var icon_theme = IconTheme.get_default ();
            try {
                default_image = icon_theme.load_icon ("avatar-default", 32, 0);
            }
            catch (Error err) {
                error (err.message);
            }
            icon_image.pixbuf = default_image;

            var grid = new Gtk.Grid ();
            grid.margin = 6;
            grid.column_spacing = 6;
            grid.attach (overlay, 0, 0, 1, 2);
            grid.attach (title_label, 1, 0, 1, 1);
            grid.attach (status_label, 1, 1, 1, 1);

            add (grid);

            handler.changed.connect (on_info_changed);
            on_info_changed ();

            this.set_name (title.replace (" ", "_") + "_row");
        }

        public void on_info_changed () {
            this.title = handler.name;

            if (handler.icon != null) {
                this.icon_image.pixbuf = handler.icon.scale_simple (32, 32, Gdk.InterpType.HYPER);
            } else {
                this.icon_image.pixbuf = default_image;
            }

            if (handler.phones != null && handler.phones.length () != 0) {
                var phone = handler.phones.nth_data (0).data;
                this.status = phone.locale_to_utf8 (-1, null, null);
            } else {
                this.status = "";
            }
        }
    }
}
