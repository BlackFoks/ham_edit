# coding: utf-8
require 'nokogiri'

class TopicFile
  attr_reader :filename
  attr_accessor :styles
  
  def initialize(filename)
    @filename = filename
    @doc = nil
    @styles = []
  end
  
  def doc
    @doc || @doc = Nokogiri::XML(open(@filename))
  end
  
  # moves header and creates new header/para
  def process_header!(header_node_text='ueNTP HA4UC/|EHUU')    
    # getting header text
    header_text = self.doc.xpath('//body/header/para').first.text
    
    # create para header
    # if !self.para_header?
    if !self.doc.xpath('//body/para').first
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
    end    
  end
  
  def replace_styles!
    # get root nodes
    # base_nodes = self.doc.xpath('//')
    base_nodes = [self.doc.root]
    
    # for every root node...
    base_nodes.each do |base_node|
      # for every style replacement...
      @styles.each do |style|
        # replace style if exists
        process_node(base_node, style[:old], style[:new])
      end
    end
    
  end
  
  def process_node(node, old_style, new_style)
    if node
      # if style matches -> replace
      if node['styleclass'] == old_style
        node['styleclass'] = new_style
      end
      
      # if have children -> proceed they
      if node.children && !node.children.empty?
        node.children.each {|n| process_node(n, old_style, new_style) }
      end
    end
  end
  
end

def wputs(str='')
  puts str
end

# open topic file
tf = TopicFile.new('D:\projects\ham_edit\xml\test.xml')

# moving header
tf.process_header!('Центр Начислений')

# add style replacements
tf.styles << { :old => 'List Number', :new => 'STYLE_001' }
tf.styles << { :old => 'List Number 2', :new => 'STYLE_002' }
tf.styles << { :old => 'Normal', :new => 'BUGAGA' }

# replace!
tf.replace_styles!

# save file
File.open('D:\new_xml.xml', 'w') do |file|
  file.write(tf.doc.to_xml)
end