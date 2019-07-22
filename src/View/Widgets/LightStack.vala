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

    /**
        This is a replacement for gtk stack that doesn't keep its members in memmory.
        It only takes a new widget, sets it as visible, plays a transition and destoys
        the old one asynchronously.
    */
    public class LightStack : Gtk.Bin {

        public signal void changed ();

        public delegate int CompareFunc (Widget a, Widget b);

        public CompareFunc compare_func = (a, b) => {
            return 0;
        };

        private Widget _default_widget = new Label ("Empty");
        private Gtk.Stack stack = new Gtk.Stack ();
        private Widget _child;

        public new Widget child {
            get {
                return _child;
            }
            set {
                set_visible_child (value);
            }
        }

        public Widget default_widget {
            get {
                return _default_widget;
            }
            set {
                if (_default_widget == _child) {
                    set_visible_child (value);
                }
                _default_widget = value;
            }
        }

        public StackTransitionType transition_type { 
            get {
                return stack.transition_type;
            }
            set {
                stack.transition_type = value;
            }
        }

        public uint transition_duration {
            get {
                return stack.transition_duration;
            }
            set {
                stack.transition_duration = value;
            }
        }

        construct {
            _child = _default_widget;
            stack.add (_child);
            stack.visible_child = _child;
            this.add (stack);
        }

        public void set_visible_child (owned Widget new_child) {
            var old_child = _child;
            _child = new_child;

            stack.add (new_child);

            if (old_child != null)
                stack.child_set_property (_child, "position", compare_func (old_child, new_child) < 0? 1: 0);

            stack.show_all ();

            var loop = new MainLoop ();
            stack.visible_child = _child;
            wait_for.begin ((int) stack.get_transition_duration (), (obj, res) => {
                loop.quit ();
            });
            loop.run ();

            changed ();

            wait_and_destroy.begin (old_child);

            return;
        }

        private async void wait_and_destroy (Widget old_child) {
            SourceFunc callback = wait_and_destroy.callback;

            ThreadFunc<bool> action = () => {
                wait_for.begin (1000, (obj, res) => {
                    wait_for.end (res);
                    stack.remove (old_child);
                });
                Idle.add((owned) callback);
                return true;
            };
            new Thread<bool> ("garbage-handling-thread", action);

            yield;
        }

        public void show_default_widget () {
            set_visible_child (_default_widget);
        }

        private async void nap (uint interval, int priority = GLib.Priority.DEFAULT) {
            GLib.Timeout.add (interval, () => {
                nap.callback ();
                return false;
            }, priority);
            yield;
        }

        private async void wait_for (int interval) {
            yield nap (interval);
        }

    }

}
