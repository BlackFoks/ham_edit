# coding: utf-8
require 'nokogiri'

class TopicFile
  attr_reader = :filename
  
  def initialize(filename)
    @filename = filename
    @doc = nil
  end
  
  def doc
    @doc || @doc = Nokogiri::XML(open(@filename))
  end
  
  def body_header
    self.doc.xpath('//body/header/para').first
  end
  
  def para_header
    self.doc.xpath('//body/para').first
  end
  
  def para_header?
    if self.para_header
      true
    else
      false
    end
  end
  
  # def move_header!(header_node_text='ueNTP HA4UC/|EHUU')
  def process_header!(header_node_text='ueNTP HA4UC/|EHUU')
    # header_node_text='ueNTP HA4UC/|EHUU'
    
    # getting header text
    header_text = self.body_header.text
    
    # create para header
    if !self.para_header?
      # getting header and paras
      body_childs = self.doc.xpath('//body').first.children
      
      # getting header
      h = body_childs.xpath('//header').first
      
      # getting header's para
      h_para = h.xpath('//para').first
      
      # store page header text
      h_para_content = h_para.content
      
      # replace header's para text
      h_para.content = header_node_text
      
      # creating new para for header
      para_header_node = Nokogiri::XML::Node.new('para', self.doc)
      para_header_node['styleclass'] = 'Style_Header2'

      # creating para's text note with page header text 
      para_header_text_node = Nokogiri::XML::Node.new('text', self.doc)
      para_header_text_node['styleclass'] = 'Style_Header2'
      para_header_text_node['translate'] = 'true'
      para_header_text_node.content = h_para_content
      
      # add para's text into para node
      para_header_node.add_child(para_header_text_node)
      
      # insert para_header immedeatly after <header> node
      h.after(para_header_node)      
      
      puts doc.to_xml
      # body_childs = self.doc.xpath('//body').first.children      
    end    
  end
end

def wputs(str='')
  puts str
end

tf = TopicFile.new('D:\projects\ham_edit\xml\test.xml')
#wputs tf.body_header.text.encode('cp866')
#wputs tf.para_header.text.encode('cp866')
#wputs tf.para_header['styleclass'].encode('cp866')
#puts tf.para_header?

#wputs "aaaaaaa" if tf.para_header?

# tf.move_header!
tf.process_header!('Центр Начислений')

File.open('D:\new_xml.xml', 'w') do |file|
  file.write(tf.doc.to_xml)
end

#puts tf.doc.to_xml
