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

    public class ErrorBar : Revealer {

        private InfoBar bar = new Gtk.InfoBar ();
        private Label label = new Gtk.Label ("Empty");

        construct {
            bar.show_close_button = true;
            bar.message_type = MessageType.ERROR;
            // bar.no_show_all = true;
            // bar.hide ();
            var content_area = bar.get_content_area ();
            content_area.add (label);

            label.label = "Hello World!";

            this.add (bar);
            this.reveal_child = false;
            this.transition_type = RevealerTransitionType.SLIDE_DOWN;
        }

        public void show_message (string message) {
            label.label = message;

            this.reveal_child = true;

            var loop = new MainLoop ();
            show_pause.begin ((obj, res) => {
                loop.quit ();
            });
            loop.run ();

            this.reveal_child = false;
        }

        private async void nap (uint interval, int priority = GLib.Priority.DEFAULT) {
            GLib.Timeout.add (interval, () => {
                nap.callback ();
                return false;
            }, priority);
            yield;
        }

        private async void show_pause () {
            yield nap (6000);
        }

    }

}
