require 'nokogiri'
require 'httparty'

module EuroDNS
  class API
    include HTTParty

    def initialize username, password, environment = :production
      if environment.to_sym == :test
        @api_url = 'https://secure.tryout-eurodns.com:20015/v2/'
      elsif environment.to_sym == :production
        @api_url = 'https://secure.api-eurodns.com:20015/v2/'
      else
        raise Error, 'Invalid environment provided.'
      end

      @username = username
      @password = password
    end

    def call method, data = nil
      xml = generate_request_xml(method, data)

      api_response = request_from_api(xml)

      process_response(api_response)
    end

    def generate_request_xml method, data
      namespace = method.split(':').first

      document = Nokogiri::XML::Builder.new do |xml|
        xml.request("xmlns:#{namespace}" => "http://www.eurodns.com/#{namespace}") {
          xml.send(method) {
            unless data.nil?
              data.each do |variable, value|
                xml.send("#{namespace}:#{variable}", value)
              end
            end
          }
        }
      end

      document.to_xml
    end

    def request_from_api xml
      self.class.post(@api_url, {
        :body => {:xml => xml},
        :basic_auth => {
          :username => @username,
          :password => "MD5#{Digest::MD5.hexdigest(@password)}"  
        }
      })
    end

    def process_response response
      xml = Nokogiri::XML.parse(response)

      result = xml.root.xpath('//xmlns:response/xmlns:result', {'xmlns' => 'http://www.eurodns.com/'}).first
      result_code = result[:code].to_i

      if !result_code_means_success(result_code)
        raise InvalidApiResponse, "#{result_code} - #{result.xpath('//xmlns:msg', {'xmlns' => 'http://www.eurodns.com/'}).first.text}"
      end

      xml.xpath('//xmlns:resData', {'xmlns' => 'http://www.eurodns.com/'})
    end

    protected
      def result_code_means_success result_code
        [1000, 1001].include?(result_code)
      end
  end
end