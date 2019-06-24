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

namespace View.Widgets {

    public class InfoSectionSegmented : InfoSection{

        private string[] placeholders;

        public InfoSectionSegmented (string title, string[] placeholders) {
            base (title);
            this.placeholders = placeholders;
        }

        protected override void add_button_action () {
            new_entry (null, DataHelper.Type.DEFAULT.to_string ());
        }

        public new void new_entry (string[]? data, string type) {
            EditableLabelSegmented entry;
            if (data == null || data.length != placeholders.length)
                entry = new EditableLabelSegmented.empty (placeholders, type);
            else
                entry = new EditableLabelSegmented (data, placeholders, type);
            _new_entry (entry);
        }
    }
}
