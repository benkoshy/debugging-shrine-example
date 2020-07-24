class ConversationPdfWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5, queue: 'default'

  def perform(conversation_id)
    conversation = Conversation.find(conversation_id)
    title = "#{conversation.subject}"
    pdf_string = StringIO.new("test")

    conversation.pdf = pdf_string

    cached_pdf = conversation.pdf
    cached_pdf.metadata['filename'] = "#{title}.pdf"
    conversation.pdf_data = cached_pdf.to_json
    conversation.save
  end
end
