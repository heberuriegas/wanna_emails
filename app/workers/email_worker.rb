class EmailWorker
  include Sidekiq::Worker

  def perform(recollection_id)
    recollection = Recollection.find(recollection_id)

    begin
      recollection.get_emails
    rescue Exception => e
      recollection.failure
    end
  end
end
