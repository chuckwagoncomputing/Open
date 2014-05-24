#!/usr/bin/env ruby
require 'gtk2'
require 'plist'

@plist = File.dirname(__FILE__) + "/items.plist" 
statusItem = Gtk::StatusIcon.new
statusItem.tooltip = 'Open'
statusItem.pixbuf = Gdk::Pixbuf.new('logo.png')
if File.file?(@plist)
 @items = Plist::parse_xml(@plist)
else
 File.new(@plist, 'w')
 File.open(@plist, 'w') do |plist|
  plist.write '<?xml version="1.0" encoding="UTF-8"?>'
  plist.write '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">'
  plist.write '<plist version="1.0">'
  plist.write '<dict>'
  plist.write '<key>/Placeholder</key>'
  plist.write '<true/>'
  plist.write '</dict>'
  plist.write '</plist>'
 end
end
@items = Plist::parse_xml(@plist)

def build_menu
 if @menu
  @menu = nil
  @quitItem = nil
  @settingsItem = nil
 end
 @menu = Gtk::Menu.new
 @items.each_key do |path|
  item = Gtk::MenuItem.new(File.basename(path))
  item.signal_connect('activate') do
   system('xdg-open "'+"#{path}"+'" 2> /dev/null >> /dev/null & return 0')
  end
  @menu.append(item)
 end
 @settingsItem = Gtk::ImageMenuItem.new(Gtk::Stock::PREFERENCES)
 @settingsItem.signal_connect('activate') do
  window = Gtk::Window.new('Open Settings')
  window.set_default_size(500, 500)
  window.set_window_position('center')
  addButton = Gtk::Button.new("Add")
  addButton.set_xalign(0.5)
  addButton.set_yalign(1.0)
  addButton.signal_connect('clicked') do
   newItemChooser = Gtk::FileChooserDialog.new("Select File",
                                               window, Gtk::FileChooser::ACTION_OPEN,
                                               nil,
                                               [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
                                               [Gtk::Stock::OPEN, Gtk::Dialog::RESPONSE_ACCEPT])
   if newItemChooser.run == Gtk::Dialog::RESPONSE_ACCEPT
    @items[newItemChooser.filename] = true
    File.open(@plist, 'w') do |file|
     file.puts @items.to_plist
    end
    load_items
   end
   newItemChooser.destroy
  end
  rmButton = Gtk::Button.new("Remove")
  rmButton.set_xalign(0.5)
  rmButton.set_yalign(1.0)
  rmButton.signal_connect('clicked') do
  if @itemsTable.selection.selected != nil
    @items.delete(@itemsTable.selection.selected.get_value(0))
    load_items
    File.open(@plist, 'w') do |file|
     file.puts @items.to_plist
    end
   end
  end
  @itemsList = Gtk::ListStore.new(String)
  load_items
  @itemsTable = Gtk::TreeView.new(@itemsList)
  column = Gtk::TreeViewColumn.new
  cell = Gtk::CellRendererText.new
  column.pack_start(cell, false)
  column.add_attribute(cell,'text',0)
  @itemsTable.append_column(column)
  contentBox = Gtk::VBox.new
  window.add(contentBox)
  contentBox.pack_start(@itemsTable)
  contentBox.pack_start(addButton, false)
  contentBox.pack_start(rmButton, false)
  window.show_all
 end
 def load_items
  @itemsList.clear
  @items.each_key do |path|
   @itemsList.append.set_value(0, path)
  end
  build_menu
 end
 @quitItem = Gtk::ImageMenuItem.new(Gtk::Stock::QUIT)
 @quitItem.signal_connect('activate'){Gtk.main_quit}
 @menu.append(Gtk::SeparatorMenuItem.new) 
 @menu.append(@settingsItem)
 @menu.append(@quitItem)
 @menu.show_all
end

build_menu
statusItem.signal_connect('activate') do |widget, event|
 @menu.popup(nil, nil, 1,  File.read('/proc/uptime').split(' ')[0].slice('.').to_i * 10) do |m, x, y|
  [x, y + 10]
 end
end

Gtk.main
