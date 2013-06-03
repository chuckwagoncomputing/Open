#!/usr/local/bin/macruby
require 'rubygems'
require 'hotcocoa'
framework 'AppKit'
class Application
 include HotCocoa

 def start
  @plist = File.dirname(__FILE__) + "/items.plist"
  @icon = File.dirname(__FILE__) + "/logo.png"
  application(:name => "Open") do |app|
   app.delegate = self
   if File.file?(@plist)
    @items = load_plist File.read(@plist)
   else
    File.new(@plist, 'w')
   end
   @m = menu do |main|
    @items.each_key do |path|
     name = File.basename(path)
     main.item(:item, :title => name, :on_action => proc { `open #{path}` })
    end
    main.separator
    main.item(:settings)
    main.item(:quit)
   end
   @img = image(:file => @icon)
   @stat = status_item(:image => @img, :menu => @m, :length => 24, :highlight_mode => true)
  end
 end

 def on_settings(menu)
  window = window(:title => "Open Settings", :size => [500,500], :center => true)
  addButton = button(:title => "Add", :layout => {:align => :center, :expand => :width})
  addButton.on_action do
   dialog = NSOpenPanel.openPanel
   dialog.canChooseFiles = true
   dialog.canChooseDirectories = true
   dialog.allowsMultipleSelection = false
   if dialog.runModalForDirectory(nil, file:nil) == NSOKButton
    newitempath = dialog.filenames.first
    @items[newitempath] = true
    @items.writeToFile(@plist, :atomically => true)
    load_items
   end
  end
  rmButton = button(:title => "Remove", :layout => {:align => :center, :expand => :width})
  rmButton.on_action do
   rowtorm = @table.selectedRow
   @items.delete(@items.keys[rowtorm])
   @items.writeToFile(@plist, :atomically => true)
   load_items
  end
  itemsTable = scroll_view(:layout => {:expand => [:width, :height]}) do |scroll|
   scroll.setAutohidesScrollers(true)
   scroll << @table = table_view(:columns => [column(:id => :data, :title => 'Path')], :data => []) do |table|
    table.setUsesAlternatingRowBackgroundColors(true)
    table.setGridStyleMask(NSTableViewSolidHorizontalGridLineMask)                             
   end
  end
  window << rmButton
  window << addButton
  window << itemsTable
  load_items
  window.display
 end

 def load_items
  @table.dataSource.data.clear
  @items.each_key do |path|
   @table.dataSource.data << {:data => path}
  end
  @table.reloadData
  @m = menu do |main|
   @items.each_key do |path|
    name = File.basename(path)
    main.item(:item, :title => name, :on_action => proc { `open #{path}` })
   end
   main.separator
   main.item(:settings)
   main.item(:quit)
  end
  NSStatusBar.systemStatusBar.removeStatusItem(@stat)
  @stat = status_item(:image => @img, :menu => @m, :length => 24, :highlight_mode => true)
 end

end
Application.new.start
