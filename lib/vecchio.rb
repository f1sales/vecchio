require "vecchio/version"

require "f1sales_custom/parser"
require "f1sales_custom/source"
require "f1sales_helpers"

require "aws-sdk-s3"

module Vecchio
  class Error < StandardError; end

  class F1SalesCustom::Email::Source 
    def self.all
      [
        {
          email_id: 'websiteform',
          name: 'Website'
        }
      ]
    end
  end

  class F1SalesCustom::Email::Parser
    def parse
      parsed_email = @email.body.colons_to_hash
      attachments_links = upload_files(@email.attachments)

      {
        source: {
          name: F1SalesCustom::Email::Source.all.first[:name],
        },
        customer: {
          name: parsed_email['nome'],
          phone: parsed_email['telefone'].tr('^0-9', ''),
          email: parsed_email['email']
        },
        description: "Código de Availação: #{parsed_email['formulrio_de_avaliao_cdigo'].split("\n").first}",
        product: 'Avaliação',
        message: parsed_email['mensagem'],
        attachments: attachments_links
      }
    end

    private

    def upload_files(files)
      files.map do |file|
        s3 = Aws::S3::Resource.new(region:'sa-east-1')
        file_name = Time.now.to_i.to_s + '-' + File.basename(file.tempfile)
        obj = s3.bucket(ENV['BUCKET_NAME']).object(file_name)
        obj.upload_file(file.tempfile, { acl: 'public-read' })
        obj.public_url
      end
    end

  end
end
