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

    def call method, data = nil, additional_data = []
      xml = generate_request_xml(method, data, additional_data)

      api_response = request_from_api(xml)

      process_response(api_response)
    end

    def generate_request_xml method, data, additional_data
      other_namespaces = []
      namespace = method.split(':').first

      builder = Nokogiri::XML::Builder.new do |xml|
        xml.request("xmlns:#{namespace}" => "http://www.eurodns.com/#{namespace}") {
          xml.send(method) {
            unless data.nil?
              data.each do |variable, value|
                xml.send("#{namespace}:#{variable}", value)
              end
            end
          }

          unless additional_data.nil?
            additional_data.each do |value|
              method_with_namespace = value.first[0]
              data = value.first[1]

              (namespace, method) = method_with_namespace.split(':')
              
              other_namespaces.push(namespace).uniq!
              
              xml.send(method_with_namespace) {
                unless data.nil?
                  data.each do |variable, value|
                    xml.send("#{namespace}:#{variable}", value)
                  end
                end
              }            
            end
          end
        }
      end

      document = Nokogiri::XML(builder.to_xml)

      other_namespaces.each do |namespace|
        document.root.add_namespace(namespace, "http://www.eurodns.com/#{namespace}")
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
      xml.remove_namespaces!

      result = xml.root.xpath('//response/result').first
      result_code = result[:code].to_i

      if !result_code_means_success(result_code)
        raise InvalidApiResponse, "#{result_code} - #{result.xpath('//msg').first.text}"
      end

      xml.xpath('//resData')
    end

    protected
      def result_code_means_success result_code
        [1000, 1001].include?(result_code)
      end
  end
end