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
    #if !self.doc.xpath('//body/para').first
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
    #end    
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

class FileProcessor
  def initialize(folder='.', is_batch=false)
    @folder = folder
    @is_batch = is_batch
  end
  
  def process!
    folders = []
    
    if @is_batch
    end
    
    puts @folder
    
    Dir.chdir(@folder)
    Dir.chdir('Topics')
    
    xmls = Dir.glob('*.xml')
    
    i = 1
    wputs "\nОбработка файлов...\n\n"
    xmls.each do |xml_filename|
      wputs "#{i}: #{xml_filename}"
      
      tf = TopicFile.new(xml_filename)
      tf.process_header!('Центр Начислений')
      
      tf.styles << { :old => 'Body Text Indent',  :new => 'Text_Style' }
      tf.styles << { :old => 'List Bullet',       :new => 'Style_Mark' }
      tf.styles << { :old => 'List Bullet+',      :new => 'Style_BOLD' }
      tf.styles << { :old => 'Hyperlink',         :new => 'Style_Link' }
      tf.styles << { :old => 'Примечание',        :new => 'Note_First' }
      tf.styles << { :old => 'annotation text',   :new => 'Style_Note' }
      tf.styles << { :old => 'Body Text Indent+', :new => 'Style_Image' }
      tf.styles << { :old => 'Код',               :new => 'Style_Example' }
      
      tf.replace_styles!
      
      Dir.mkdir('_new') if !Dir.exists?('_new')
      
      File.open("_new/#{i}.xml", 'w') do |file|
        file.write(tf.doc.to_xml)
        wputs "    => #{i}.xml"
      end     
      i += 1      
    end  

    # xmls.each do |xml_filename|
      # File.delete(xml_filename) 
    # end    
  end  
end

def wputs(str='')
  puts str.encode('cp866')
end

# open topic file
# tf = TopicFile.new('D:\projects\ham_edit\xml\test1.xml')

# moving header
# tf.process_header!('Центр Начислений')

# add style replacements
#tf.styles << { :old => 'List Number', :new => 'STYLE_001' }
#tf.styles << { :old => 'List Number 2', :new => 'STYLE_002' }
#tf.styles << { :old => 'Normal', :new => 'BUGAGA' }

# tf.styles << { :old => 'Body Text Indent',  :new => 'Text_Style' }
# tf.styles << { :old => 'List Bullet',       :new => 'Style_Mark' }
# tf.styles << { :old => 'List Bullet+',      :new => 'Style_BOLD' }
# tf.styles << { :old => 'Hyperlink',         :new => 'Style_Link' }
# tf.styles << { :old => 'Примечание',        :new => 'Note_First' }
# tf.styles << { :old => 'annotation text',   :new => 'Style_Note' }
# tf.styles << { :old => 'Body Text Indent+', :new => 'Style_Image' }
# tf.styles << { :old => 'Код',               :new => 'Style_Example' }

# replace!
# tf.replace_styles!

# save file
# File.open('D:\new_xml.xml', 'w') do |file|
  # file.write(tf.doc.to_xml)
# end

fp = FileProcessor.new('D:\projects\ham_edit\xml\CN')
fp.process!