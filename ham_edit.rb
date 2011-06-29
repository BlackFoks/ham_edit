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
  
  def replace_styles!
    # get root nodes
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
  
  def process!(h=false, s=false)
    if !h && !s
      puts "Обрабатывать нечего..."
      return
    end
  
    folders = []
    
    if @is_batch
    end
    
    puts @folder
    
    Dir.chdir(@folder)
    Dir.chdir('Topics')
    
    xmls = Dir.glob('*.xml')
    
    @renames = []
    
    i = 1
    wputs "\nОбработка файлов...\n\n"
    xmls.each do |xml_filename|
      wputs "#{i}: #{xml_filename}"
      
      tf = TopicFile.new(xml_filename)
      
      if h
        tf.process_header!('Центр Начислений')
        wputs "    Заголовок перемещен"
      end
      
      if s
        tf.styles << { :old => 'Body Text Indent',  :new => 'Text_Style' }
        tf.styles << { :old => 'List Bullet',       :new => 'Style_Mark' }
        tf.styles << { :old => 'List Bullet+',      :new => 'Style_BOLD' }
        tf.styles << { :old => 'Hyperlink',         :new => 'Style_Link' }
        tf.styles << { :old => 'Примечание',        :new => 'Note_First' }
        tf.styles << { :old => 'annotation text',   :new => 'Style_Note' }
        tf.styles << { :old => 'Body Text Indent+', :new => 'Style_Image' }
        tf.styles << { :old => 'Код',               :new => 'Style_Example' }
        
        tf.replace_styles!
        wputs "    Стили заменены"
      end
      
      Dir.mkdir('_new') if !Dir.exists?('_new')
      
      File.open("_new/#{i}.xml", 'w') do |file|
        file.write(tf.doc.to_xml)
        wputs "    => #{i}.xml"
        
        @renames << { :old => xml_filename.split('.')[0], :new => i.to_s}
        
        #@renames[xml_filename.split('.')[0]] = i.to_s
      end     
      i += 1      
    end     
    
    Dir.chdir('..')
    # rename topic is in table of content
    toc = Nokogiri::XML(open('Maps/table_of_contents.xml'))
    
    # get root nodes
    base_nodes = [toc.root]
    
    # for every root node...
    base_nodes.each do |base_node|
      # for every style replacement...
      @renames.each do |rename|
        puts rename.inspect
        # replace style if exists
        process_toc(base_node, rename[:old], rename[:new])
      end
    end 
    
    # refs = toc.xpath('//topicref')
    # refs.each do |ref|
      # process_toc(ref)
    # end
    
    # puts toc.to_xml
    File.open('Maps/table_of_contents_11111.xml', 'w') do |toc_file|
      toc_file.write(toc.to_xml)
    end
    
  end

  def process_toc(node, old_href, new_href)
    if node
      # if style matches -> replace
      if node['href'] == old_href
        node['href'] = new_href
      end
      
      # if have children -> proceed they
      if node.children && !node.children.empty?
        node.children.each {|n| process_toc(n, old_href, new_href) }
      end
    end
  end
end

def wputs(str='')
  puts str.encode('cp866')
end

if ARGV.empty? || ARGV.count < 2
  wputs "Конвертер отчетов, заменяет стили и перемещает заголовки.\n\n"
  wputs "Способ использования: ruby ham_edit.rb [опции] [путь до распакованной папки]"
  wputs "  Примечание: распакованная папка должна содержать папку Topics."
  wputs ""
  wputs "Возможные опции:"
  wputs "    -s - замена стилей"
  wputs "    -h - перемещение заголовков"
  wputs "    -sh - замена стилей и перемещение заголовков\n"
  exit
end

fp = FileProcessor.new(ARGV[-1])

s, h = false, false

ARGV.each do |arg|
  puts arg
  if arg == '-h'
    h = true
  end
  
  if arg == '-s'
    s = true
  end
  
  if arg == '-sh' || arg == '-hs'
    s = true
    h = true
  end
end

fp.process!(h, s)