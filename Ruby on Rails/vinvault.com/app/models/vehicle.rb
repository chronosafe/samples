class Vehicle < ActiveRecord::Base
  belongs_to :pattern
  has_many :items, :dependent => :delete_all

  def to_xml(options={})
    xml = "<trim id='#{self.id}' name='#{self.trim}'>"
    if self.items.count > 0
      self.items.each do |i|
        xml += i.to_xml if i.category.enabled?
      end
    end
    xml += '</trim>'
    xml
  end

  def to_basic_xml
   body = ''
   engine = self.items.where(category: Category.named('Engine Type')).first
   trans = self.items.where(category: Category.named('Transmission-long')).first
   body += engine.to_xml if engine.present?
   body += trans.to_xml if trans.present?
   "<trim id='#{self.id}' name='#{self.trim}'>#{body}</trim>"
  end

  def item_list
    items.map { |i| {key: i.category.name, value: i.value, unit: i.category.unit} }
  end

  def needs_update?
    items.count < Settings.refresh_threshold
  end
end
