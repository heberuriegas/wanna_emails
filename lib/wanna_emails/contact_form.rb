require "capybara"
begin
  require 'capybara-webkit'
rescue LoadError => e
end

require 'rubyfish'

module WannaEmails
  module ContactForm

    SAMPLES ||= ['http://www.mananita.cl/','http://www.paramedicostens.cl/','http://www.coniana.cl/','http://www.novaelectric.cl/','http://www.comidasdelivery.cl','http://www.fasutosushi.cl/']
    DISTANCE ||= 2
    FIELDS_LIMIT ||= 2
    EXTENSIONS ||= ['','.html','.htm','.php','.jsp','.asp']
    INCREASE_DICTIONARY ||= true

    @@dictionary = YAML::load_file 'config/locales/dictionary.yml'

    def samples
      SAMPLES
    end

    def current_page uri=nil
      @current_page = agent.get uri if uri.present?
      @current_page
    end

    def reload_sample
      current_page samples.sample
    end

    def session
      @@session ||= Capybara::Session.new(:selenium)
    end

    def self.agent= agent
      @@agent = agent
    end

    def agent
      @@agent ||= Mechanize.new
    end

    def contact_page options={}
      options.reverse_merge!(link: false)
      contact_page = contact_pages.sample
      if options[:link]
        contact_page
      else
        if contact_page.present?
          contact_page.is_a?(String) ? agent.get(contact_page) : contact_page.click
        else
          nil
        end
      end
    end

    def contact_form temp_page = contact_page
      raise("ContactForm: Page not exists") unless temp_page.present?
      valid_attributes = [:id, :name, :text]
      search_terms = [:name, :email, :message]
      result_form = nil

      # Experiment, could be work.
      catch :done do
        temp_page.forms.each do |form|
          button = find_submit form
          if button.present?
            result_form = form
            throw :done
          end
        end
      end

      catch :done do
        temp_page.forms.each do |form|
          search_terms.each do |search_term|
            valid_attributes.each do |valid_attribute|
              dictionary_items(search_term).each do |item|
                begin
                  fields = form.fields_with(valid_attribute => item).select{|field| field.type != "hidden"}
                rescue StandardError => e
                end
                if fields.present? && fields.count >= FIELDS_LIMIT
                  result_form = form
                  throw :done
                end
              end
            end
          end
        end
      end unless result_form.present?

      result_form.present? ? result_form : temp_page.forms.try(:last)
    end

    def fill_form project=Project.all.sample, form=contact_form, page=current_page, sender=Sender.new(generate: :ES)
      fill_hash = form_fields form

      session.visit form.page.uri.to_s
      
      name = fill_hash[:last_name].present? ? sender.name.split(' ') : [sender.name]
      temp_page = page.is_a?(Page) ? page : Page.find_by(uri: page.uri.to_s)
      debugger
      message = project.messages.sample.sanitize(sender,temp_page.recollection_pages.sample, js: true)

      # Fill name and lastname
      fill_field :name, name.first, fill_hash if fill_hash[:name].present?
      fill_field :last_name, name.last, fill_hash if fill_hash[:last_name].present?
      fill_field :email, sender.email, fill_hash if fill_hash[:email].present?
      fill_field :phone, Sender.mobile_number, fill_hash if fill_hash[:phone].present?      
      begin
        fill_field :message, message.text, fill_hash if fill_hash[:message].present?
      rescue StandardError => e
        if e.message.include?('unterminated string literal')
          fill_field :message, message.text.gsub("\n", '\n'), fill_hash if fill_hash[:message].present?
        else
          raise 'Message can\'t fill'
        end
      end
      begin
        form.radiobuttons.group_by{|t| t['name']}.each {|key,value| session.choose value.first.text || value.first.name }
      rescue StandardError => e
        raise 'Radio buttons can\'t fill'
      end
      find_submit form
    end

    def form_fields form=contact_form
      form_fields = [:message, :email, :name, :last_name, :phone]

      result = {}
      form_fields.each do |field|
        items = dictionary_fields[field.to_s]
        temp_fields = find_fields(items, form)
        temp_fields.each do |temp_field|
          result.each do |key, values|
            values.each do |value|
              temp_fields.delete temp_field if value.name == temp_field.name && temp_field.name[0..2] != 'FD:'
            end
          end
        end 
        result[field.to_sym] = temp_fields
      end
      result
    end

    private

    def fill_field name, value, fill_hash
      fill_hash[name].each do |name_field|
        if (name_field.name[0..2] == 'FD:' && name_field.name.length > 15) || name_field.name == 'email_address_field'
          fill_dynamic_field name, value
        else
          session.fill_in name_field.name, with: value
        end
      end
    end

    def fill_dynamic_field name, value
      session.execute_script("message_temp = '#{value}'")
      session.execute_script("$('div.label > span:contains(\"#{dictionary_items(name).first[1..-1]}\")').parent().next().children().attr('value',message_temp)")
    end

    def contact_pages temp_page = current_page
      raise("ContactForm: Page not exists") unless temp_page.present?
      links = []
      items = dictionary_items(:contact)

      links.concat find_links(items)
      
      temp_page.frames.each do |frame|
        frame_page = agent.get(frame.src)
        links.concat find_links(items, frame_page)
      end if links.empty?

      catch :done do
        items.each do |item|
          EXTENSIONS.each do |extension|
            begin
              contact_uri = agent.get("http://#{temp_page.uri.host}/#{item}#{extension}")
              links << contact_uri.to_s
              throw :done
            rescue Mechanize::ResponseCodeError => e
            rescue SocketError
            end
          end
        end if links.empty?
      end

      links.uniq{ |link| link.href }
    end

    def dictionary
      @@dictionary = YAML::load_file 'config/locales/dictionary.yml'
    end

    def dictionary_fields language=:es
      @@dictionary[language.to_s.downcase]
    end

    def dictionary_items field, language=:es
      @@dictionary[language.to_s.downcase][field.to_s]
    end

    def dictionary_upgrade
      File.open('config/locales/dictionary.yml','w') do |file|
        file.write @@dictionary.to_yaml
      end
    end

    def levenstein word1,word2
      RubyFish::Levenshtein.distance word1, word2
    end

    def find_buttons items=[], forms=current_page.forms
      raise("ContactForm: Forms not exists") unless forms.present?
      forms = forms.is_a?(Array) ? forms : [forms]
      items = items.is_a?(Array) ? items : [items]
      valid_attributes=[:text, :id, :title, :value]
      buttons = []
      
      items.each do |item|
        valid_attributes.each do |valid_attribute|
          forms.each do |form|
            begin
              buttons.concat form.buttons_with(valid_attribute => /#{item}/i)
            rescue StandardError => e
            end
          end
        end
      end

      buttons.uniq
    end

    def find_submit forms=contact_page.try(:forms)
      raise("ContactForm: Form not exists") unless forms.present?
      forms = forms.is_a?(Array) ? forms : [forms]
      find_buttons(dictionary_items(:submit), forms).sample
    end

    def find_fields items=[], form=contact_form
      raise("ContactForm: Form not exists") unless form.present?
      items = items.is_a?(Array) ? items : [items]
      valid_attributes = [:id, :name]
      fields = []

      # Find with dictionary
      items.each do |item|
        valid_attributes.each do |valid_attribute|
          begin
            fields.concat form.fields_with(valid_attribute => /#{item}/i).select{|field| field.type != "hidden"}
          rescue StandardError => e
          end
        end
      end

      # Next of input to the element
      items.each do |item|
        temp_field = form.page.at("//*[contains(text(),'#{item[1..-1]}')]/following::input[@type!='hidden']")
        value = if temp_field.present? && temp_field.attributes["name"].present?
          temp_field.attributes["name"].value
        elsif temp_field.present? && temp_field.attributes["id"].present?
          temp_field.attributes["id"].value
        end
          
        fields.concat form.fields_with(name: value) if value.present?
      end if fields.empty?

      temp_fields = []
      temp_fields.concat form.page.search('input').map{ |node| Mechanize::Form::Field.new({'type' => node.attributes["type"].try(:value) || 'text', 'name' => node.attributes["name"].try(:value) || node.attributes["id"].try(:value) }) }
      temp_fields.concat form.page.search('textarea').map{ |node| Mechanize::Form::Field.new({ 'type' => node.attributes["type"].try(:value) || 'text', 'name' => node.attributes["name"].try(:value) || node.attributes["id"].try(:value) }) }

      # If mechanize dont recognize
      catch :done do
        items.each do |item|
          valid_attributes.each do |valid_attribute|
            temp_fields.select{|field| field.type != "hidden"}.each do |field|
              if field.try(:name).present? && field.name.match(/#{item}/i)
                fields << field
                throw :done
              end
            end
          end
        end
      end

      # Similarities with levensthein
      catch :done do
        items.each do |item|
          temp_fields.select{|field| field.type != "hidden"}.each do |field|
            if field.try(:name).present? && levenstein(item, field.name) <= DISTANCE
              items << field.name
              dictionary_upgrade
              fields << field
              throw :done
            end
          end
        end
      end if fields.empty?

      fields.uniq{ |field| field.name }
    end

    def find_links items=[], temp_page = current_page
      raise("ContactForm: Page not exists") unless temp_page.present?
      items = items.is_a?(Array) ? items : [items]
      valid_attributes = [:href, :text, :id, :title]
      links = []

      items.each do |item|
        valid_attributes.each do |valid_attribute|
          begin
            links.concat temp_page.links_with(valid_attribute => /#{item}/i)
          rescue StandardError => e
          end
        end
      end

      # Similarities with levensthein
      catch :done do
        items.each do |item|
          temp_page.links.each do |link|
            valid_attributes.each do |valid_attribute|
              temp_item = valid_attribute == :text ? link.send(valid_attribute) : link.attributes[valid_attribute]
              if levenstein(item, temp_item) <= DISTANCE && !dictionary_has?(temp_item)
                if link.attributes[:href].present?
                  if INCREASE_DICTIONARY
                    items << link.attributes[:href].split('/').last.split('.').first
                    dictionary_upgrade
                  end
                  links << link
                  throw :done
                end
              end
            end
          end
        end
      end if links.empty?

      links.uniq{ |link| link.href }
    end

    def dictionary_has? item
      dictionary_fields.each do |key,value|
        return true if key == item or value.include?(item)
      end
      false
    end
  end
end