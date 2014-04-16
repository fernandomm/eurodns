require 'test_helper'

class TestApi < Test::Unit::TestCase
  def setup
    @eurodns = EuroDNS::API.new('username', 'password')
  end

  def test_xml_generation_without_paramaters
    request = @eurodns.generate_request_xml 'list:tdl', nil
    xml = Nokogiri::XML.parse(request)

    assert_equal xml.root.xpath('//list:tdl').length, 1
  end

  def test_xml_generation_with_parameters
    request = @eurodns.generate_request_xml 'ip:add', {:address => '192.168.0.1'}
    xml = Nokogiri::XML.parse(request)
    
    assert_equal xml.root.xpath('//ip:add/ip:address').length, 1
  end

  def test_xml_generation_with_additional_data
    request = @eurodns.generate_request_xml 'domain:create', {:name => 'example.org'}, [{
      'nameserver:create' => {
        fqdn: 'ns1.example.org',  
      }
    },{
      'nameserver:create' => {
        fqdn: 'ns2.example.org',  
      }
    }]

    xml = Nokogiri::XML.parse(request)
    
    assert_equal xml.xpath('//xmlns:fqdn', {'xmlns' => 'http://www.eurodns.com/nameserver'}).length, 2
  end

  def test_process_of_valid_response
    response = '<?xml version="1.0" encoding="UTF-8"?> 
<response xmlns:ip="http://www.eurodns.com/ip"> 
    <result code="1000"> 
        <msg>Command completed successfully</msg> 
    </result> 
    <resData> 
        <ip:list numElements="#LISTCOUNTER#"> 
            <ip:address>#IP ADDRESS#</ip:address> 
            <ip:address>#IP ADDRESS#</ip:address> 
            <ip:address>#IP ADDRESS#</ip:address> 
        </ip:list> 
    </resData> 
</response>'

    assert_nothing_raised do
      @eurodns.process_response response
    end
  end

  def test_process_of_invalid_response
    response = '<?xml version="1.0" encoding="UTF-8"?> 
<response xmlns:ip="http://www.eurodns.com/ip"> 
    <result code="2101"> 
        <msg>Internal SQL Error</msg> 
    </result> 
</response>'

    assert_raise EuroDNS::InvalidApiResponse do
      @eurodns.process_response response
    end
  end
end