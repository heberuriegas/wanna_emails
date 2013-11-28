class Message < ActiveRecord::Base
  belongs_to :project

  def sanitize(sender, recollection_page, options={})
    self.switch_text(':name', sender.name)

    if recollection_page.present?
      self.switch_text(':url', recollection_page.page.uri)

      if recollection_page.recollection.unique_pages == true
        self.switch_text ':recollection_name', recollection_page.recollection.name
      else
        self.switch_text ':recollection_name', recollection_page.page.host
      end
    end

    if options[:html] == true
      self.switch_text "\r\n",'<br />'
      self.switch_text "TradeGig.com",'www.TradeGig.com'
    end

    self
  end

  def switch_text old_text, new_text
    self.subject = self.subject.gsub old_text, new_text
    self.text = self.text.gsub old_text, new_text
    self
  end
end