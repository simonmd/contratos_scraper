require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'unf'
require 'awesome_print'
require 'without_accents'
require 'multi_json'
url = ""
#url = "http://www.contratos.gov.co/consultas/detalleProceso.do?numConstancia=09-13-153418"
#url = "http://www.contratos.gov.co/consultas/detalleProceso.do?numConstancia=12-11-835441" # Multiples contratos
#doc = Nokogiri::HTML(open(url))
doc = Nokogiri::HTML(File.open("test_contratos_multiples.html"))

# XPath selectors para las diferentes secciones
@maintable = doc.search('//table[3]/tr')
@infogeneral = @maintable.at_xpath('//td[contains(text(), "General del Proceso")]')
@ubicacion = @maintable.at_xpath('//td[contains(text(), "Geogr")]')
@datoscontacto = @maintable.at_xpath('//td[contains(text(), "Datos de Contacto del Proceso")]')
@cronograma = @maintable.at_xpath('//td[contains(text(), "Cronograma del Proceso")]')
@infocontratos = @maintable.at_xpath('//td[contains(text(), "Contratos Asociados al Proceso")]')
@documentos = @maintable.at_xpath('//td[contains(text(), "Documentos del Proceso")]')
@hitos = @maintable.at_xpath('//td[contains(text(), "Hitos del Proceso")]')

def get_section(first)
  pn = first.parent
  section_attr = Hash.new
  until pn.next.matches?('tr.section-header')
    pn = pn.next
    key = pn.xpath('td[1]//text()').text.without_accents.strip.gsub(/[\n]+/, "").squeeze(" ")
    val = pn.xpath('td[2]//text()').text.without_accents.strip.gsub(/[\n]+/, "").squeeze(" ")
    unless key == '' || val == ''
      section_attr[key] = val
    end
  end
  section_attr
end

def get_contratos(first)
  section_attr = Array.new
  @maintable.css('tr.contrato-header').each do |c|
    ap c.next
    contrato_attr = Hash.new
    key = c.xpath('td[1]//text()').text.without_accents.strip.gsub(/[\n]+/, "").squeeze(" ")
    val = c.xpath('td[2]//text()').text.without_accents.strip.gsub(/[\n]+/, "").squeeze(" ")
    unless key == '' || val == ''
      contrato_attr[key] = val
    end
    section_attr.push(contrato_attr)
    ap section_attr
  end
  section_attr
end


# Cambiar los section rows a th para parsearlos mas facil
section_rows = @maintable.css('td.tttablas')
section_rows.each do |sec_td|
  sec_td.name = 'th'
  sec_td.parent['class'] = 'section-header'
end

# Cambiar el class de los rows de Numero de contrato para parsearlos mas facil
contrato_rows = @maintable.xpath('//td[contains(text(), "mero del Contrato")]')
contrato_rows.each do |cont_td|
  cont_td.parent['class'] = 'contrato-header'
end

contrato = Hash.new
contrato["infogeneral"] = get_section(@infogeneral) unless @infogeneral.nil?
contrato["ubicacion"] = get_section(@ubicacion) unless @ubicacion.nil?
contrato["infocontratos"] = get_section(@infocontratos) unless @infocontratos.nil?
contrato["cronograma"] = get_section(@cronograma) unless @cronograma.nil?
contrato["datoscontacto"] = get_section(@datoscontacto) unless @datoscontacto.nil?
#contrato["codigo"] = contrato["infocontratos"]["Numero del Contrato"] unless @infocontratos.nil?
#contrato["constancia"] = /(?<=\?numConstancia=)([a-zA-Z0-9_-])+/.match(url)[0]
ap contrato
#ap @maintable
