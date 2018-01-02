require 'nokogiri'
require 'open-uri'
require 'nokogiri-styles'
require "./CSSParser.rb"

def arr_to_str(_arr)
	str = ""
	_arr.each() do |el|
		str=str+el.to_s
	end
	str
end

#----------------------------------------------------------------
#*******************************************************************
def remove_blank_tags(_enter_point, _tag_name)
	#xpath_query  = ".//" + _tag_name+"[not(*)][not(normalize-space())]"
	xpath_query = ".//*[@class='blank']"
	node_set = _enter_point.xpath(xpath_query)
        node_set.each() do |node|
		node.remove
        end

end
#-------------------------------------------------------------------
def merge_paired_tags(_enter_point, _tag_name)
#usage version
        xpath_query  = ".//" + _tag_name
        node_set = _enter_point.xpath(xpath_query)
        node_set.each() do |node|
                if node.next_sibling!=nil and node.next_sibling.name==node.name
                        node<<node.next_sibling.inner_html
                        node.next_sibling.content = ""
                end
        end
	

end
#-------------------------------------------------------------------
def dbg_merge_paired_tags(_enter_point, _tag_name)
#debug version
	xpath_query  = ".//" + _tag_name
	node_set = _enter_point.xpath(xpath_query)
	counter =0
	node_set.each() do |node|
		if node.next_sibling!=nil and node['class']!="blank" and node.next_sibling.name==node.name
			puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!11"
			puts "Merge No:\t" + (counter+1).to_s
			puts "before merge:************************\n"
			puts "\tcurrent node\n\t\t name:\t" + node.name
			puts "\t\tcontent:\t"+node.content
			puts "\t\tmarkup:\t"+node.to_html
			puts "\tnext node\n"
			puts "\t\t name:\t" + node.next_sibling.name
			puts "\t\tcontent:\t"+node.next_sibling.content
			puts "\t\tmarkup:\t"+node.next_sibling.to_html
			node<<node.next_sibling.inner_html
			node.next_sibling.content = ""
			node.next_sibling['class'] = "blank"
			puts "\nafter merge**********************\n"
			puts "\tcurrent node\n"
			puts "\t\tcontent:\t"+node.content
			puts "\t\tmarkup:\t"+node.to_html
			counter=+1
		end
	end
	puts "Total mergings:\t" + counter.to_s
	#cleaning up blank nodes
	remove_blank_tags(_enter_point, _tag_name)	
end
#-------------------------------------------------------------------
def test_merge_paired_tags(_oDOM)
	node_set = _oDOM.xpath("/html/body/div[4]/p")

	node_set.each() do |node|
		puts "\n\n****************\n\n"
		puts "paragraph: " + node_set.index(node).to_s
		puts "The content before:\t"
	        puts node.content
#		dbg_merge_paired_tags(node, "b")
		#remove_blank_tags(node,"b")
		dbg_merge_paired_tags(node, "span")
		#remove_blank_tags(node,"b")
	        puts "The content after:\t"
        	puts node.content
	end

end
#**************************************************************************
def enable_style_tag(_oDOM)
	node = _oDOM.at_xpath("/html/head/style")
	s=node.inner_html.to_s
	s.delete("<![CDATA[")
	# needs a further look
	s.delete("\<\!--")
	s.delete("\/* Font Definitions *\/")
	s.delete("--\>")
	s.delete("--\>")
	s.delete("]]>")
	node.inner_html = s

end
def nested_spans_fix(_token)
	node_set = _token.xpath(".//span/child::span[1]")
	node_set.each() do |node|
		#passStyleToChildren(node)
		nested = node.parent.inner_html
		node.parent.after(nested)
		node.parent.content = ""
		node['note'] = "nested_span"
		puts "nested span fix performed:"
		puts _token.css_path.to_s + node.path.to_s
		#puts node.to_html
		
	end

end

def test_nested_spans_fix(_oDOM)
	node_set = _oDOM.xpath("/html/body/div[4]")
	nested_spans_fix(node_set[0])
	nested_spans_fix(node_set[0])
	enable_style_tag(_oDOM)
	_oDOM.write_xhtml_to(File.new('../output/write_html_to.html', 'w'), :encoding => 'UTF-8')
end
#**********************************************************************
def fileIO_issue_fix(_oDOM)
	file_content=_oDOM.to_html
	if ! file_content.valid_encoding?
		s = file_content.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')
		puts "Encoding fix performed"
	end
	@doc = Nokogiri::HTML::DocumentFragment.parse s
	# output 
	# doesn't preserve turkish and kyrgyz specific letter
	_oDOM.write_xhtml_to(File.new('../output/write_html_to.html', 'w'), :encoding => 'UTF-8')

	# output below doesn't preserve content text at all
	#File.write('../output/write_html_to.html', oDOM.to_html(encoding: 'UTF-8'))
	# end

end

#**************************************************************************
def evalXPath(_current, _XPath)
	@doc = Nokogiri::HTML::DocumentFragment.parse _current.to_html
	output = @doc.xpath(_XPath)

end
#--------------------------------------------------------------------
def test_evalXPath(_oDOM)
	# some testing	
	curr_node = _oDOM.xpath("/html/body/div[4]/p[5]")
	nodes = evalXPath(curr_node, ".//node()[@style=\"color:red\"][1]/preceding::text()")
	puts nodes.to_s
	puts nodes.to_s.length

	# end			
end
#***********************************************************************************
def getLine(_entry_token, _line_num)

	line_markups = _entry_token.xpath(".//node()[@style=\"color:red\"]")
	if _line_num==1	
		nodes = evalXPath(_entry_token, ".//node()[@style=\"color:red\"][1]/preceding::text()")
		puts "line selected:\t" + nodes.to_s
		puts "line length:\t" + nodes.to_s.length.to_s
	else
		nodes = evalXPath(_entry_token, ".//node()[@style=\"color:red\"][1]/following::text()")
		puts "line selected:\t" + nodes.to_s
		puts "line length:\t" + nodes.to_s.length.to_s
	end					
end
#-----------------------------------------------------------------++++
def test_getLine(_oDOM)
	entry_tokens = _oDOM.xpath("/html/body/div[4]/p[5]")
	getLine(entry_tokens[0], 1)
end
#***********************************************************************************
def DelimitLines(oDOM)
x_element = oDOM.xpath("/html/body/div/p/span[@style=\"color:red\"]")
	x_element.each() do |i|
		i.add_next_sibling "<br>"
	end
end
#----------------------------------------------------------------
def MarkupDictData(oDOM)
	x_element = oDOM.xpath("/html/body/div")
	x_element.each() do |node|
		#i.add_next_sibling "<br>"
		i =  x_element.index(node)
		# i= n-1
		if (i+1)%4 == 0
			puts i+1
			node["class"]="DictData"
			puts node.attribute("class")
		end

end

end

###MAIN###########################################################
# creating io object
html_data = File.read('../input/Cumakunova_tr_kg[901-1000].htm')

# creating DOM object from io object
oDOM = Nokogiri::HTML(html_data)

tag_set = oDOM.xpath("/html/body/div[4]/p[5]")
node=tag_set[0]
MarkupDictData(oDOM)
parser = 	CSSParser.new(node, oDOM)
parser.get_rules()
# output below doesn't preserve turkish and kyrgyz specific letter
oDOM.write_xhtml_to(File.new('../output/write_html_to.html', 'w'), :encoding => 'UTF-8')

# output below doesn't preserve content text at all
#File.write('../output/write_html_to.html', oDOM.to_html(encoding: 'UTF-8'))
##################################################################


# CODE SNIPPETS
=begin
# code snippet from: https://stackoverflow.com/questions/24086304/nokogiri-write-html-to-oddness
# No1:
#File.write('write_html_to.html', doc.to_html(encoding: 'UTF-8'))
# No2:
#html_data.write_xhtml_to(File.new('write_xhtml_to.html', 'w'), :encoding => 'UTF-8')
# No3:
# modules.each do |url, klass|
=end
