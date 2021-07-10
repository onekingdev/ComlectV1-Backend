# frozen_string_literal: true

class PdfWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def env_path(in_path)
    Rails.env.production? || Rails.env.staging? ? in_path : "#{Rails.root}/public#{in_path}"
  end

  def perform(policy_doc_id)
    policy_doc = CompliancePolicyDoc.find(policy_doc_id)
    tmp_fd = Tempfile.new(['pdf-', '.pdf'])
    Libreconv.convert(env_path(policy_doc.doc_url.split('?')[0]), tmp_fd.path)
    uploader = PdfUploader.new(:store)
    file = File.new(tmp_fd)
    uploaded_file = uploader.upload(file)
    policy_doc.update(pdf_data: uploaded_file.to_json)
  end
end
