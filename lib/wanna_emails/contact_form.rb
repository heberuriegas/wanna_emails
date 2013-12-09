require 'capybara'
require 'capybara/dsl'
require 'rubyfish'

Capybara.default_driver = :selenium

module WannaEmails
  module ContactForm

    SAMPLES ||= ['http://www.mananita.cl/','http://www.paramedicostens.cl/','http://www.coniana.cl/','http://www.novaelectric.cl/','http://www.comidasdelivery.cl','http://www.fasutosushi.cl/']
    DISTANCE ||= 3
    FIELDS_LIMIT ||= 2
    EXTENSIONS ||= ['','.html','.htm','.php','.jsp','.asp']

    include Capybara::DSL

    @@agent ||= Mechanize.new
=begin
    @@agent ||= TorPrivoxy::Agent.new(host: ENV['TOR_HOST'], password: ENV['TOR_PASSWORD'], privoxy_port: ENV['TOR_PRIVOXY_PORT'], control_port: ENV['TOR_CONTROL_PORT'], capybara: true) do |agent|
      #puts "New IP is: #{agent.ip}"
    end
=end

    @@dictionary = YAML::load_file 'config/locales/dictionary.yml'

    def current_page uri=nil
      @current_page = agent.get uri if uri.present?
      @current_page
    end

    def samples
      SAMPLES
    end

    def reload_sample
      current_page samples.sample
    end

    def agent
      @@agent
    end

    def contact_page options={}
      options.reverse_merge!(link: false)
      contact_page = contact_pages.sample
      if options[:link]
        contact_page
      else
        contact_page.present? ? contact_page.click : nil
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
                fields = form.fields_with(valid_attribute => item).select{|field| field.type != "hidden"}
                if fields.count >= FIELDS_LIMIT
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

    def fill_form form=contact_form, project=Project.all.sample, sender = Sender.new(generate: :ES)
      fill_hash = form_fields form

      visit form.page.uri.to_s
      
      name = fill_hash[:last_name].present? ? sender.name.split(' ') : [sender.name]

      # Fill name and lastname
      fill_field :name, name.first, fill_hash if fill_hash[:name].present?
      fill_field :last_name, name.last, fill_hash if fill_hash[:last_name].present?
      fill_field :email, sender.email, fill_hash if fill_hash[:email].present?
      fill_field :phone, Sender.mobile_number, fill_hash if fill_hash[:phone].present?
      fill_field :message, project.messages.sample.text, fill_hash if fill_hash[:message].present?
    end

    def form_fields form=contact_form
      form_fields = [:name, :last_name, :email, :phone, :message]

      result = {}
      dictionary_fields.each do |field,items|
        if form_fields.include? field.to_sym
          result[field.to_sym] = find_fields(items, form)
        end
      end
      result
    end

    private

    def fill_field name, value, fill_hash
      fill_hash[name].each do |name_field|
        if name_field.name[0..2] == 'FD:' || name_field.name == 'email_address_field'
          fill_dynamic_field name, value
        else
          fill_in name_field.name, with: value
        end
      end
    end

    def fill_dynamic_field name, value
      page.execute_script("$('div.label > span:contains(\"#{dictionary_items(name).first[1..-1]}\")').parent().next().children().attr('value','#{value}')")
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
              contact_uri = agent.get("http://#{tmep_page.uri.host}/#{item}.#{extension}")
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
            buttons.concat form.buttons_with(valid_attribute => /#{item}/i)
          end
        end
      end

      buttons.uniq
    end

    def find_submit forms=current_page.try(:forms)
      raise("ContactForm: Form not exists") unless forms.present?
      forms = forms.is_a?(Array) ? forms : [forms]
      find_buttons(dictionary_items(:submit), forms).sample
    end

    def find_fields items=[], form=contact_form
      raise("ContactForm: Form not exists") unless form.present?
      items = items.is_a?(Array) ? items : [items]
      valid_attributes = [:id, :name, :text]
      fields = []

      # Find with dictionary
      items.each do |item|
        valid_attributes.each do |valid_attribute|
          fields.concat form.fields_with(valid_attribute => /#{item}/i).select{|field| field.type != "hidden"}
        end
      end

      # Next of input to the element
      items.each do |item|
        temp_field = form.page.at("//*[contains(text(),'#{item[1..-1]}')]/following::input[@type!='hidden']")
        fields.concat form.fields_with(name: temp_field.attributes["name"].value) if temp_field.present?
      end if fields.empty?

      # Similarities with levensthein
      catch :done do
        items.each do |item|
          form.fields.select{|field| field.type != "hidden"}.each do |field|
            valid_attributes.each do |valid_attribute|
              temp_item = valid_attribute == :id ? field.node.attributes[valid_attribute.to_s] : field.send(valid_attribute)
              if levenstein(item, temp_item) <= DISTANCE
                if field.try(:name).present?
                  items << temp_item
                  dictionary_upgrade
                  links << link
                  throw :done
                end
              end
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
          links.concat temp_page.links_with(valid_attribute => /#{item}/i)
        end
      end

      # Similarities with levensthein
      catch :done do
        items.each do |item|
          temp_page.links.each do |link|
            valid_attributes.each do |valid_attribute|
              temp_item = valid_attribute == :text ? link.send(valid_attribute) : link.attributes[valid_attribute]
              if levenstein(item, temp_item) <= DISTANCE
                if link.attributes[:href].present?
                  items << link.attributes[:href].split('/').last.split('.').first
                  dictionary_upgrade
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
  end
end