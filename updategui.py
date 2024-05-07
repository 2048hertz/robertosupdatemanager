import gi
import subprocess

gi.require_version("Gtk", "3.0")
from gi.repository import Gtk

class UpdateManager(Gtk.Window):

    def __init__(self):
        Gtk.Window.__init__(self, title="Update Manager")
        self.set_border_width(10)

        # Create a label to display update status
        self.label = Gtk.Label(label="Click 'Check for Updates' to check for updates.")
        self.add(self.label)

        # Create a button to check for updates
        self.button = Gtk.Button(label="Check for Updates")
        self.button.connect("clicked", self.on_check_updates_clicked)
        self.add(self.button)

    def on_check_updates_clicked(self, button):
        # Call the Bash script to check for updates
        subprocess.run(["bash", "update_script.sh"])
        # Update the label to indicate that updates have been checked
        self.label.set_text("Updates checked. Please see terminal for details.")

win = UpdateManager()
win.connect("destroy", Gtk.main_quit)
win.show_all()
Gtk.main()
