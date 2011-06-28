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
  
  def move_header!
    # getting header text
    header_text = self.body_header.text
    
    # create para header
    if !self.para_header?
      # header and paras
      body_childs = self.doc.xpath('//body').first.children
      #puts body_childs.count
      
      # change header text
      h = body_childs.xpath('//header').first
      #h.unlink
      h_para = h.xpath('//para').first
      h_para_content = h_para.content
      h_para.content = "ueNTP HA4UC/|EHUU"
      
      para_header_node = Nokogiri::XML::Node.new('para', self.doc)
      para_header_node['styleclass'] = 'Style_Header2'

      para_header_text_node = Nokogiri::XML::Node.new('text', self.doc)
      para_header_text_node['styleclass'] = 'Style_Header2'
      para_header_text_node['translate'] = 'true'
      para_header_text_node.content = "BBEDITE HA3BAHIE CTPAHIu,bI"
      
      para_header_node.add_child(para_header_text_node)
      
      h.after(para_header_node)
      
      
      # puts h.inspect
      # puts h_para.to_xml
      puts doc.to_xml
      
      # get again
      body_childs = self.doc.xpath('//body').first.children
      # puts body_childs.count
      
      #puts h.to_s
      #puts body_childs.to_s

      #body_childs.each {|x| x.unlink }
      #puts body_childs.count
      
      # remove header node
      #header_node = body_childs.shift      
      #puts body_childs.count
      
      #body_childs.each {|x| self.doc.xpath('//body').first << x if x != header_node }
      
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

tf.move_header!

#puts tf.doc.to_xml
