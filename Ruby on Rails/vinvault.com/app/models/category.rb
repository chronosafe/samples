class Category < ActiveRecord::Base
  has_many :items
  belongs_to :group

  attr_accessor :display_name

  @@cats = nil

  def self.cat(id)
    @@cats ||= Category.all.load.to_a
    @@cats.select {|s| s.id == id }.first
  end

  def self.named(name)
    @@cats ||= Category.all.load.to_a
    @@cats.select {|s| s.name == name }.first
  end

  def self.add_or_update(hash)
    cat = Category.where(name: hash[:name]).first_or_create
    cat.update_attributes(hash)
    DT.p "Creating/Updating category: #{cat.name}" if Settings.verbose
  end

  def display_name
    disp = self.label.nil? ? self.name : self.label
    disp.nil? ? '' : disp
  end
end


