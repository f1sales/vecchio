require 'ostruct'
require "f1sales_custom/parser"
require "f1sales_custom/source"
require 'rails'

RSpec.describe F1SalesCustom::Email::Parser do

  context 'when email is from website form' do
    let(:image_name){ 'img.jpg' }
    let(:email){ 
      email = OpenStruct.new
      email.to = [email: 'websiteform@lojateste.f1sales.org']
      email.subject = 'FormulÃ¡rio de avaliaÃ§Ã£o do site'
      email.body = "Formulário de avaliação código: *15072019153552*\n----------------------------------------------------------\n\n*Nome:* Marcio Teste\n*Email:* marcio@f1sales.com.br\n*Telefone:* 1232132323\n*Estado:* SP\n*Cidade:* Sao Paulo\n*Mensagem:* Teste Marcio."
      email.attachments = [
        ActionDispatch::Http::UploadedFile.new({
          filename: 'img.png',
          type: 'image/png',
          tempfile: File.new("#{File.expand_path(File.dirname(__FILE__))}/fixtures/#{image_name}")
        })
      ]

      email
    }

    let(:parsed_email) { described_class.new(email).parse }

    it 'contains website form as source name' do
      expect(parsed_email[:source][:name]).to eq(F1SalesCustom::Email::Source.all.first[:name])
    end

    it 'contains description' do
      expect(parsed_email[:description]).to eq('Código de Availação: 15072019153552')
    end

    it 'contains message' do
      expect(parsed_email[:message]).to eq('Teste Marcio.')
    end

    it 'contains name' do
      expect(parsed_email[:customer][:name]).to eq('Marcio Teste')
    end

    it 'contains email' do
      expect(parsed_email[:customer][:email]).to eq('marcio@f1sales.com.br')
    end

    it 'contains phone' do
      expect(parsed_email[:customer][:phone]).to eq('1232132323')
    end

    it 'contains product' do
      expect(parsed_email[:product]).to eq('Avaliação')
    end

    it 'contains an attachment' do
      expect(parsed_email[:attachments]).to eq(["https://f1sales-attachments-vecchio.s3.sa-east-1.amazonaws.com/#{Time.now.to_i}-img.jpg"])
    end
  end

end
