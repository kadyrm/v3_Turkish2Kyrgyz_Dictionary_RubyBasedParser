require 'nokogiri'
require 'open-uri'
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
def put_html(_html_str)
# Status: Failure
	pattern = "span"
        _html_str.gsub!(/<[\w]+?>/,"\n"+pattern)

end
def insertLineBreaks(_token)
# Description: inserts line breaks and returns the number of inserted line breaks
# Assumption: at least one line exists in a token
# Algorithm:
#	1. checkout if there are not breaks already inserted
#	2. if so simply return lines count
#	3. else retrieve spans with css style = color:red
#	4. insert after eahc such an element breaking markup
#	5. return the number of inserted line breaks
	

	#1.
	breaks_s = _token.xpath(".//br")	
	if breaks_s.count != 0
	#2.
		breaks_s.count	
	#3.
	else
		eol_s = _token.xpath(".//span[@style=\"color:red\"]")
		puts "inside insertLineBreaks\n"
	#4.
		eol_s.each() do |eol|
			puts "next sibling before:\n" + eol.next_sibling.to_html
        	        eol.add_next_sibling "<br>"
			puts "next sibling after:\n" + eol.next_sibling.to_html
        	end
		puts "html code output:\n" + _token.to_html
		char = gets
		puts "eol elements refs after modification:\n"
		eol_s.each() do |eol|
			puts eol.to_html + "\n"
		end	
	#5.
		eol_s.count
	end
end
def getLine(_token, _index)
# Algorithm:
#	1. There must be <br> elements inserted in the token's html
#		otherwise do it
#	2. Get inner html of the token
#	3. Split the html code as a string delimited by <br>
#	4. Return a piece at the shown index

	#1
	breaks_s = _token.xpath(".//br")
	if breaks_s.count == 0
		insertLineBreaks(_token)
	end 
	#2.
	html_str = _token.inner_html
	#<debug>
	puts "\n***\nInside getLine\n"
	puts "\ntokens inner html:\n" + put_html(html_str)
	char = gets
	#</debug>
	#3.
	lines_arr = html_str.split("<br>")
	#<debug>
	puts "\n\t---\nLines retrieved:\n"
	counter=0
	lines_arr.each() do |el|
		puts "\nLine at " + counter.to_s + ":\n" + el + "\n"
		counter=counter+1
	end
	#</debug>
	char = gets
	#4.
	lines_arr[_index]
end
#-----------------------------------------------------------------++++
def test_getLine(_oDOM)
	entry_tokens = _oDOM.xpath("/html/body/div[4]/p[5]")
	node = entry_tokens[0]
	line=	getLine(node, 1)
	line_count = insertLineBreaks(node)
	puts "\ninside test_getLine\n"
	puts "Lines number:\t" + line_count.to_s
	puts "Line at index:" + line'
end
#***********************************************************************************
def DelimitLines(oDOM)
x_element = oDOM.xpath("/html/body/div/p/span[@style=\"color:red\"]")
	x_element.each() do |i|
		i.add_next_sibling "<br>"
	end
end

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
######################################################################
# MAIN FUNCTION
	# input	
	# creating input object
	html_data = File.read('../input/Cumakunova_tr_kg[901-1000].htm')
	# end
	# creating DOM object from input object
	oDOM = Nokogiri::HTML(html_data)
	# some testing

	test_getLine(oDOM)

	# end
	# output 
	# doesn't preserve turkish and kyrgyz specific letter
	#oDOM.write_xhtml_to(File.new('../output/write_html_to.html', 'w'), :encoding => 'UTF-8')

	# output below doesn't preserve content text at all
	#File.write('../output/write_html_to.html', oDOM.to_html(encoding: 'UTF-8'))
	# end


######################################################################
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
