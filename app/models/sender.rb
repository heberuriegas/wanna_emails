class Sender < ActiveRecord::Base
  belongs_to :sender_entity
  has_many :sent_emails

  LANGUAGES = [:ES,:EN]
  DOMAINS = ['@yahoo.com','@gmail.com','@hotmail.com','@outlook.com']
  LIMIT = 500

  def generate=(language)
    if LANGUAGES.include?(language)
      name = Sender.names(language).sample
      last_name = Sender.last_names(language).sample

      self.name = "#{name.capitalize} #{last_name.capitalize}"
      self.email = "#{name.underscore}#{last_name.underscore}#{rand(1000).to_s}#{DOMAINS.sample}".gsub('Ñ','n').gsub('ñ','n')
      self.password = ENV['ACCOUNTS_PASSWORD']
      self.language = language.to_s
    end
  end

  def self.languages
    LANGUAGES
  end

  def self.mobile_number(country = :CL)
    mobile_numbers = {
      CL: lambda { "95127#{rand(9)}#{rand(9)}#{rand(9)}#{rand(9)}" }
    }
    mobile_numbers[country].call
  end

  def user_name
    self.email.split('@').first
  end

  def sent?
    self.sent_emails.select('count(sent_at) as count').where(sent_emails: { sent_at: DateTime.now.strftime('%Y-%m-%d') }).group('sent_emails.sent_at').order(nil).try(:first).try(:count) || 0
  end

  def blocked?
    return self.sent? >= self.sender_entity.limit
  end

  def self.availables options = {}
    options.reverse_merge!(sent_at: DateTime.now.strftime('%Y-%m-%d'))
    filter_params = {}
    filter_params.merge! language: options[:language] if options[:language].present?

    sents = self.sents(options).to_sql

    self
      .joins("LEFT JOIN (#{sents}) as sents ON senders.id = sents.id", :sender_entity)
      .select('senders.*',"case when sents.count is NULL then sender_entities.limit else sender_entities.limit-sents.count end as count")
      .where(filter_params)
      .where('sents.count is NULL or sents.count < sender_entities.limit')
  end

  def self.availables_count options = {}
    sum = 0
    Sender.availables(options).each{|sender| sum+=sender.count}
    sum
  end

  def self.sents options={}
    options.reverse_merge!(sent_at: DateTime.now.strftime('%Y-%m-%d'))
    filter_params = { sent_emails: { sent_at:  options[:sent_at] } }
    filter_params.merge!(language: options[:language]) if options[:language].present?    
    self
      .joins(:sent_emails)
      .select('senders.*',"count(*) as count")
      .where(filter_params)
      .group('sent_emails.sender_id','senders.id')
  end

  def self.names(language = :ES)
    names = { ES: 
      ['MARTINA',
      'SOFIA',
      'FLORENCIA',
      'VALENTINA',
      'ISIDORA',
      'ANTONELLA',
      'ANTONIA',
      'EMILIA',
      'CATALINA',
      'FERNANDA',
      'CONSTANZA',
      'JAVIERA',
      'MAITE',
      'MARIA',
      'FRANCISCA',
      'AGUSTINA',
      'JOSEFA',
      'AMANDA',
      'CAMILA',
      'MONSERRAT',
      'TRINIDAD',
      'IGNACIA',
      'BELEN',
      'PAZ',
      'ANAIS',
      'VICTORIA',
      'LAURA',
      'PIA',
      'RENATA',
      'MAGDALENA',
      'ISABELLA',
      'MATILDA',
      'JULIETA',
      'ROCIO',
      'DANIELA',
      'EMILY',
      'MIA',
      'GABRIELA',
      'BARBARA',
      'JOSEFINA',
      'MATILDE',
      'ANAHIS',
      'PASCAL',
      'PAULA',
      'THIARE',
      'RAYEN',
      'GENESIS',
      'PALOMA',
      'CAROLINA',
      'MILLARAY',
      'BENJAMIN',
      'VICENTE',
      'MARTIN',
      'MATIAS',
      'JOAQUIN',
      'AGUSTIN',
      'CRISTOBAL',
      'MAXIMILIANO',
      'SEBASTIAN',
      'TOMAS',
      'DIEGO',
      'JOSE',
      'NICOLAS',
      'FELIPE',
      'LUCAS',
      'ALONSO',
      'BASTIAN',
      'JUAN',
      'GABRIEL',
      'IGNACIO',
      'FRANCISCO',
      'RENATO',
      'MAXIMO',
      'MATEO',
      'JAVIER',
      'DANIEL',
      'LUIS',
      'GASPAR',
      'ANGEL',
      'FERNANDO',
      'CARLOS',
      'EMILIO',
      'FRANCO',
      'CRISTIAN',
      'PABLO',
      'SANTIAGO',
      'ESTEBAN',
      'DAVID',
      'DAMIAN',
      'JORGE',
      'CAMILO',
      'ALEXANDER',
      'RODRIGO',
      'AMARO',
      'LUCIANO',
      'BRUNO',
      'ALEXIS',
      'VICTOR',
      'THOMAS',
      'JULIAN']
    }

    names[language]
  end

  def self.last_names language = :ES
    last_names = {
      ES:
        ['GONZALEZ',
        'MUÑOZ',
        'ROJAS',
        'DIAZ',
        'PEREZ',
        'SOTO',
        'CONTRERAS',
        'SILVA',
        'MARTINEZ',
        'SEPULVEDA',
        'MORALES',
        'RODRIGUEZ',
        'LOPEZ',
        'FUENTES',
        'HERNANDEZ',
        'TORRES',
        'ARAYA',
        'FLORES',
        'ESPINOZA',
        'VALENZUELA',
        'CASTILLO',
        'RAMIREZ',
        'REYES',
        'GUTIERREZ',
        'CASTRO',
        'VARGAS',
        'ALVAREZ',
        'VASQUEZ',
        'TAPIA',
        'FERNANDEZ',
        'SANCHEZ',
        'CARRASCO',
        'GOMEZ',
        'CORTES',
        'HERRERA',
        'NUÑEZ',
        'JARA',
        'VERGARA',
        'RIVERA',
        'FIGUEROA',
        'RIQUELME',
        'GARCIA',
        'MIRANDA',
        'BRAVO',
        'VERA',
        'MOLINA',
        'VEGA',
        'CAMPOS',
        'SANDOVAL',
        'ORELLANA',
        'ZUÑIGA',
        'OLIVARES',
        'ALARCON',
        'GALLARDO',
        'ORTIZ',
        'GARRIDO',
        'SALAZAR',
        'GUZMAN',
        'HENRIQUEZ',
        'SAAVEDRA',
        'NAVARRO',
        'AGUILERA',
        'PARRA',
        'ROMERO',
        'ARAVENA',
        'PIZARRO',
        'GODOY',
        'PEÑA',
        'CACERES',
        'LEIVA',
        'ESCOBAR',
        'YAÑEZ',
        'VALDES',
        'VIDAL',
        'SALINAS',
        'CARDENAS',
        'JIMENEZ',
        'RUIZ',
        'LAGOS',
        'MALDONADO',
        'BUSTOS',
        'MEDINA',
        'PINO',
        'PALMA',
        'MORENO',
        'SANHUEZA',
        'CARVAJAL',
        'NAVARRETE',
        'SAEZ',
        'ALVARADO',
        'DONOSO',
        'POBLETE',
        'BUSTAMANTE',
        'TORO',
        'ORTEGA',
        'VENEGAS',
        'GUERRERO',
        'PAREDES',
        'FARIAS',
        'SAN']
    }
    last_names[language]
  end
end
