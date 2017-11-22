class Administrator::CertificateController < Administrator::BaseController
    
  def index   
  
  end
  
  def generate  
	@data = request.POST
	html = render_to_string(:action => :generate, :layout => "certificate.html") 
	pdf = WickedPdf.new.pdf_from_string(html) 
	send_data(pdf, :filename  => "certificate.pdf", :disposition => 'attachment') 
	
  end

  
  

end
